---
title: Repository Type Property
description: The multi-select Type property that selects organization-wide repository controls.
---

# Repository Type Property

[Organization Standard](Organization-Standard.md) requires every initiative to define
repository types, required custom properties, labels, branch protection, and review
rules. One GitHub organization **custom property named `Type`** provides the
classification mechanism. Its repository values determine which organization-wide
rulesets and controls apply.

This page defines the **mechanism**: property declaration, ruleset conditions,
and safe condition changes. [Repository Types](../Capabilities/repository-governance/design-types.md)
defines the individual values. [Repository Governance](../Capabilities/repository-governance/spec.md)
defines the controls they select.

## The pattern

Each initiative organization defines:

1. One `multi_select` custom property named `Type`, required on every repository, with a
   default value.
2. An allowed-values list specific to that organization's repository types. A documentation
   organization and a module-publishing organization need different lists.
3. Organization-wide rulesets (branch protection, required reviews, and similar controls) that
   target repositories by their `Type` values instead of by repository name.

Each repository's `Type` selects every `Type`-scoped control it inherits.
Administrators do not need per-repository ruleset edits or manually maintained
lists of repository names.

## Why the property is multi-select

A repository's branch model and additional obligations are independent.
The branch model answers *how does a change reach the protected branch?*
Layering answers *what else must be true before it does?* Examples include a
documentation-build check and linear artifact history. A repository can contain
an infrastructure stack and publish documentation. A single-select property needs
a distinct value for each combination.

So `Type` is `multi_select`, and its values divide into branch-model types, layering types,
and the exemption type ([the catalog](../Capabilities/repository-governance/design-types.md)).
A ruleset condition tests whether a repository's `Type` **includes** a value, so a layering
ruleset matches without knowing which branch model the repository also declares.

Combinations must be validated: a multi-select property accepts any subset,
including contradictory values. The [validation
rules](../Capabilities/repository-governance/design-types.md#validation-rules) define valid
sets. [Reconciliation](../Capabilities/repository-governance/design.md#drift-detection-and-reconciliation)
enforces these rules because the property schema cannot express them.

## Migrating from a single-select property

The platform does not convert a property between selection modes in place, so the migration
uses a temporary, uniquely named property and recreates the canonical name:

1. Choose a unique name, such as `Type_Migration`.
   After you verify that no organization property uses the name, create it as `multi_select`.
2. Populate it for every repository from the current single-select `Type`.
   Each value set has one element with the same meaning.
3. Create or update every replacement ruleset to read `Type_Migration`.
   Verify its computed coverage against the existing ruleset as described below.
   Both controls remain active until the coverage sets match.
4. When no rule reads the old single-select `Type`, delete that schema.
   Create the canonical `Type` schema as `multi_select`. Copy each temporary
   value set into it.
5. Update every ruleset from `Type_Migration` to the new canonical `Type`.
   Verify the coverage diff again. Delete `Type_Migration` only when nothing reads it.

Do not add a second value until you verify the second coverage comparison.
Keep value additions separate from mode changes so the cause of each coverage
difference remains clear.

## Filter by exclusion, not by inclusion

When a ruleset condition targets `Type`, use an **exclude** list of exempt `Type`
values. Keep the `include` list empty. Do not use an include allow-list of covered
values.

```json
"repository_property": {
  "include": [],
  "exclude": [{ "name": "Type", "source": "custom", "property_values": ["Unmanaged"] }]
}
```

An empty `include` array matches every repository; the `exclude` array then subtracts
specific `Type` values. This means:

- A ruleset automatically covers an added `Type` value. No ruleset edit is required.
- Only `Type` values an administrator explicitly names in `exclude` lose coverage.
  No repository loses coverage without an explicit exclusion.

An include allow-list leaves any unlisted `Type` value without coverage. This
includes values added later. Exclusion-based conditions are the only form of
this pattern that preserves coverage as types are added.

## Verifying a migration before cutting over

A change from name-based or single-purpose-property conditions to `Type` changes
live branch protection. Verify coverage before replacing the condition:

1. Use `GET /orgs/{org}/properties/values` to list every organization repository and its `Type` or prior property value.
2. Compute, for the **current** ruleset condition, which repositories are covered.
3. Create the replacement ruleset under a temporary name so both rulesets can remain active.
   For each repository, use `GET /repos/{owner}/{repo}/rules/branches/{branch}` to
   determine the **new** condition's actual coverage. This uses GitHub's evaluation
   rather than a manual interpretation of condition JSON.
4. Diff the two coverage sets. The only differences should be the `Type` values the
   migration intentionally excludes. Any other difference means the new condition is wrong.
5. After the diff matches expectations, update the real ruleset with its complete replacement representation.
   Repeat the coverage check. Delete the temporary replacement only after you confirm that the real ruleset is active.

## Ruleset updates use `PUT`, not `PATCH`

Update an organization ruleset with `PUT /orgs/{org}/rulesets/{ruleset_id}` and
the complete desired ruleset representation. Do not use `PATCH`: the documented
update operation is `PUT`. `PUT` preserves the ruleset identity. The temporary
replacement and coverage comparison verify the change before the real ruleset
is updated.

## Deprecating single-purpose properties

An initiative can have a narrow, single-purpose property, such as a `BranchStrategy`
property with values `None` / `GitHub Flow` that selects one ruleset.
After a ruleset condition migrates to `Type` and coverage is verified, retire the
narrow property (`DELETE /orgs/{org}/properties/schema/{name}`). Do not keep
overlapping classification properties. `Type` should answer "what kind of
repository is this," and every `Type`-scoped control should read from it.

## Historical organization inventories

The values below are historical inventories, recorded before the branch-model,
layering, and exemption taxonomy existed. They are **not** canonical type
examples and must not be copied into a new organization without migration:

| Organization | `Type` allowed values | Notes |
| --- | --- | --- |
| `MSXOrg` | `Docs`, `VSCodeExtension`, `Other` | Legacy values that predate the canonical taxonomy. |
| `PSModule` | `Action`, `Archive`, `Docs`, `Framework`, `FunctionApp`, `Module`, `Other`, `Template`, `Workflow` | Legacy values that predate the canonical taxonomy. |

An organization's canonical list is shaped by what it builds, but it has the
taxonomy defined by [Repository Types](../Capabilities/repository-governance/design-types.md):
one branch model (explicit or defaulted), any layering values, and `Unmanaged` as
the sole exemption. A migration maps historical values into that taxonomy before
the canonical `Type` property becomes authoritative.

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
