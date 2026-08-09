---
title: Repository Type Property
description: How a multi-select "Type" custom property classifies every repository in an initiative organization and drives which org-wide controls apply to it.
---

# Repository Type Property

[Organization Standard](Organization-Standard.md) requires every initiative to define
"repository types used by the initiative" and "required custom properties, labels, branch
protection, and review rules." This page is the concrete mechanism that satisfies both at
once: one GitHub organization **custom property named `Type`**, whose values per repository
determine which org-wide rulesets and controls apply.

This page owns the **mechanism** — how the property is declared, how ruleset conditions
target it, and how those conditions are changed safely. What the individual values *mean*
is owned by [Repository Types](../Capabilities/repository-governance/design-types.md), and
the governance they drive by [Repository
Governance](../Capabilities/repository-governance/spec.md).

## The pattern

Each initiative organization defines:

1. One `multi_select` custom property named `Type`, required on every repository, with a
   default value.
2. An allowed-values list specific to that organization's actual repository shapes (a docs
   org and a module-publishing org will not need the same list).
3. Org-wide rulesets (branch protection, required reviews, and similar controls) that
   target repositories by their `Type` values instead of by repository name.

Setting a repository's `Type` is then the single action that determines every `Type`-scoped
control it inherits — no per-repository ruleset edits, no repository-name lists to keep in
sync by hand.

## Why the property is multi-select

A repository's classification answers more than one question, and the answers are
independent. *How does a change reach the protected branch?* is a branch-model question.
*What else must be true before it does?* — the documentation builds, the artifact history
stays linear — is a layering question. A repository can be an infrastructure stack whose
documentation also publishes, and a single-select property cannot express that without
inventing a combined value for every pairing that occurs.

So `Type` is `multi_select`, and its values divide into branch-model types, layering types,
and the exemption type ([the catalogue](../Capabilities/repository-governance/design-types.md)).
A ruleset condition tests whether a repository's `Type` **includes** a value, so a layering
ruleset matches without knowing which branch model the repository also declares.

The consequence is that combinations must be validated rather than assumed: a multi-select
property accepts any subset, including contradictory ones. The [validation
rules](../Capabilities/repository-governance/design-types.md#validation-rules) state which
subsets are meaningful, and validation is enforced by
[reconciliation](../Capabilities/repository-governance/design.md#drift-detection-and-reconciliation)
rather than by the property schema, which cannot express them.

## Migrating from a single-select property

The platform does not convert a property between selection modes in place, so the migration
creates a second property and retires the first — the same shape as the condition migration
below, and subject to the same verification:

1. Create the `multi_select` property alongside the existing `single_select` one.
2. Populate it for every repository from the current single value, so each repository's new
   value set is a one-element set carrying the same meaning.
3. Verify computed coverage is unchanged before repointing anything, using the coverage diff
   described below.
4. Repoint every ruleset condition onto the new property.
5. Retire the old property once no condition reads it, per [deprecating single-purpose
   properties](#deprecating-single-purpose-properties).

Only after step 4 is verified does a repository gain a second value. Adding values and
changing the property's mode at the same time makes a coverage diff impossible to attribute.

## Filter by exclusion, not by inclusion

When a ruleset condition targets `Type`, write it as an **exclude** list of the `Type`
values that should be exempt, with an empty `include` list — not an include allow-list of
the values that should be covered.

```json
"repository_property": {
  "include": [],
  "exclude": [{ "name": "Type", "source": "custom", "property_values": ["Memory"] }]
}
```

An empty `include` array matches every repository; the `exclude` array then subtracts
specific `Type` values. This means:

- Adding a brand-new `Type` value in the future (a new repository shape nobody has
  invented yet) is covered by the ruleset automatically, with no ruleset edit required.
- Only `Type` values an administrator has explicitly named in `exclude` ever lose
  coverage. Nothing falls out silently.

An include allow-list inverts this safety property: any repository whose `Type` is not on
the list silently loses coverage, including every future `Type` value nobody remembered to
add. Exclude-based conditions are the only version of this pattern that is safe to extend
over time.

## Verifying a migration before cutting over

Moving a ruleset from a name-based or single-purpose-property condition onto `Type` is a
live change to branch protection. Verify it does not silently drop coverage for any
repository before making it live:

1. Enumerate every repository in the organization and the `Type` (or prior property) value
   it currently has, via `GET /orgs/{org}/properties/values`.
2. Compute, for the **current** ruleset condition, which repositories are covered.
3. Create the replacement ruleset under a temporary name so both rulesets can exist side by
   side, then use `GET /repos/{owner}/{repo}/rules/branches/{branch}` per repository to
   compute which repositories the **new** condition actually covers (this is more reliable
   than reasoning about condition JSON by hand, since it reflects GitHub's own evaluation).
4. Diff the two coverage sets. The only differences should be the `Type` values the
   migration intentionally excludes. Any other difference means the new condition is wrong.
5. Only after the diff matches expectations: delete the old ruleset, then create the final
   ruleset under its real name, then delete the temporary one. This ordering means both
   rulesets are briefly active together rather than there being a gap with neither active.

## A known API quirk: ruleset `PATCH` may not work

`PATCH` on `/orgs/{org}/rulesets/{id}` has been observed to fail (`404`) for tokens that
otherwise have full `GET`/`POST`/`DELETE` access to the same endpoint, including on a
disposable test ruleset created solely to isolate the failure. Treat in-place ruleset edits
as unreliable and use the delete-old / create-new sequence above instead, even for small
condition changes.

## Deprecating single-purpose properties

An initiative may have started with a narrow, single-purpose property (for example, a
`BranchStrategy` property with values like `None` / `GitHub Flow`, used only to gate one
ruleset). Once a `Type` property exists and a ruleset condition has been migrated onto it
and verified, retire the narrow property (`DELETE /orgs/{org}/properties/schema/{name}`)
rather than keeping two overlapping classification properties. `Type` is the one property
that should answer "what kind of repository is this," and every `Type`-scoped control
should read from it.

## Worked examples

Both current MSX initiative organizations use this pattern:

| Organization | `Type` allowed values | Notes |
| --- | --- | --- |
| `MSXOrg` | `Docs`, `Memory`, `VSCodeExtension`, `Other` | Introduced from scratch, replacing a prior single-purpose `BranchStrategy` property. |
| `PSModule` | `Action`, `Archive`, `Docs`, `Framework`, `FunctionApp`, `Memory`, `Module`, `Other`, `Template`, `Workflow` | `Memory` added to an existing, already-populated `Type` property; the ruleset condition changed from a repository-name allow-list (`~ALL`) to a `Type`-based exclude. |

An organization's list is its own. The values above are shaped by what those two
organizations actually build; another organization adopting the pattern names the shapes it
has. What every list has in common is the structure — one default branch-model value, any
layering values the organization needs, and one exemption value — not the vocabulary.

In both organizations, repositories with `Type: Memory` — the
[Memory Repository Template](../Capabilities/agentic-development/memory-template.md)'s
no-PR, direct-commit-to-`main` repositories — are excluded from the org-wide pull-request-
required ruleset. That template's workflow only works because the ruleset stops matching
`Memory`-typed repositories; without this, direct pushes to a memory repository's `main`
are rejected the same as on any other repository.

## Where this connects

- [Repository Governance](../Capabilities/repository-governance/spec.md) — the framework this
  property is the input to.
- [Repository Types](../Capabilities/repository-governance/design-types.md) — what each value
  means, how values compose, and which combinations are invalid.
- [Organization Standard](Organization-Standard.md) — the requirement this property
  implements: documented repository types and the custom properties, rulesets, and review
  rules attached to them.
- [Repository Standard](Repository-Standard.md) — the mandatory/type-specific/
  repository-specific file-set distinction that `Type` also drives over time.
- [Memory Repository Template](../Capabilities/agentic-development/memory-template.md) — the
  concrete repository type whose no-PR workflow motivated excluding `Type: Memory` from the
  pull-request-required ruleset in both current organizations.
