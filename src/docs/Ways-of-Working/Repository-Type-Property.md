---
title: Repository Type Property
description: How a single "Type" custom property classifies every repository in an initiative organization and drives which org-wide controls apply to it.
---

# Repository Type Property

[Organization Standard](Organization-Standard.md) requires every initiative to define
"repository types used by the initiative" and "required custom properties, labels, branch
protection, and review rules." This page is the concrete mechanism that satisfies both at
once: a single GitHub organization **custom property named `Type`**, whose value per
repository determines which org-wide rulesets and controls apply.

## The pattern

Each initiative organization defines:

1. One `single_select` custom property named `Type`, required on every repository, with a
   default value (typically `Other`).
2. An allowed-values list specific to that organization's actual repository shapes (a docs
   org and a module-publishing org will not need the same list).
3. Org-wide rulesets (branch protection, required reviews, and similar controls) that
   target repositories by their `Type` value instead of by repository name.

Setting a repository's `Type` is then the single action that determines every `Type`-scoped
control it inherits — no per-repository ruleset edits, no repository-name lists to keep in
sync by hand.

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

In both organizations, repositories with `Type: Memory` — the
[Memory Repository Template](../Capabilities/agentic-development/memory-template.md)'s
no-PR, direct-commit-to-`main` repositories — are excluded from the org-wide pull-request-
required ruleset. That template's workflow only works because the ruleset stops matching
`Memory`-typed repositories; without this, direct pushes to a memory repository's `main`
are rejected the same as on any other repository.

## Where this connects

- [Organization Standard](Organization-Standard.md) — the requirement this property
  implements: documented repository types and the custom properties, rulesets, and review
  rules attached to them.
- [Repository Standard](Repository-Standard.md) — the mandatory/type-specific/
  repository-specific file-set distinction that `Type` also drives over time.
- [Memory Repository Template](../Capabilities/agentic-development/memory-template.md) — the
  concrete repository type whose no-PR workflow motivated excluding `Type: Memory` from the
  pull-request-required ruleset in both current organizations.
