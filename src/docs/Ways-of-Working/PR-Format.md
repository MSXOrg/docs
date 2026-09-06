---
title: PR Format
description: Pull request title, description, change types, and labels.
---

# PR Format

Pull requests in the MSX ecosystem double as **release notes**. Write for end users, including downstream integrators: what changes, who is affected, and how to adopt it. Keep consumer instructions distinct from reviewer and maintainer evidence.

## The source of truth

The release-bound PR title and complete description are the authored release note. The contract lives in structured Markdown in that body, not a parallel JSON/YAML file or a version-specific migration guide. [Release Management](../Capabilities/release-management/design.md#release-notes) owns publication, resolved release coordinates, provenance, and traceable corrections.

Describe the **incremental change introduced by this release**, not a migration manual from every previous version. Consumers compose the applicable records across their upgrade range; a note for the newest release does not replace the intervening evidence.

## Title

```text
<Icon> [<Type>]: <User-facing outcome>
```

- The **Icon** matches the change type.
- The **Type** in brackets is one of: `Major`, `Feature` (Minor), `Patch`, `Fix`, `Docs`, `Maintenance`.
- The **outcome** describes what changed from the end user's perspective. Do not lead with private function or class names or refactoring verbs; public commands, inputs, APIs, paths, and settings are consumer-facing concepts.

### Good titles

- `🌟 [Major]: Legacy export command removed`
- `🚀 [Feature]: Custom templates now supported`
- `🩹 [Patch]: Default timeout value corrected`
- `🪲 [Fix]: Parameter validation no longer fails on null input`
- `📖 [Docs]: Installation guide updated with prerequisites`
- `⚙️ [Maintenance]: Internal build tooling stays current`

### Bad titles

- `Add support for custom templates` — describes the action, not the outcome.
- `Refactor parameter validation logic` — implementation language.
- `Update stuff` — meaningless.

## Change types

| Type        | Icon | Label            | Description                                           |
| ----------- | ---- | ---------------- | ----------------------------------------------------- |
| Major       | 🌟   | `release:major`  | Breaking changes that affect compatibility            |
| Feature     | 🚀   | `release:minor`  | New features or enhancements                          |
| Patch       | 🩹   | `release:patch`  | Small fixes or improvements                           |
| Fix         | 🪲   | `release:patch`  | Bugfixes (patch-level release impact)                 |
| Docs        | 📖   | `release:skip`   | Documentation changes only                            |
| Maintenance | ⚙️   | `release:skip`   | Internal upkeep without a shipped behavior or integration-contract change |

`release:pre-release` is a release mode, not a change type. Apply it alongside
exactly one of `release:patch`, `release:minor`, or `release:major` when an open
pull request must publish a prerelease. Never combine it with `release:skip`.

### Detecting the change type

Decide the type from the change **for the declared target audience**, including its integrators, not from the maintainer's implementation effort or the names of changed files. Read the [audience declaration in the README](Readme-Driven-Context.md#target-audience) and any explicitly adopted initiative definition first. Resolve and record missing or ambiguous audience context before finalizing the type; do not guess it from repository ownership.

Assess every affected supported use: commands, parameters, APIs, output shapes, configuration, permissions, installation, and runtime/tool requirements. User and integrator may be the same person, as the [PSModule audience](../Initiatives/PSModule.md#target-audience) illustrates. An interactive command still working does not make a change compatible if the same user's supported script integration breaks.

The change type is decided in this order:

1. **Explicit user input** — if the contributor / Shipper specified a type, verify it against the audience impact and applicable version policy. Resolve a conflict before finalizing the release decision; a label does not make a breaking change compatible.
2. **Pre-1.0.0 rule** — projects with no version tags or latest tag below `v1.0.0` follow [SemVer §4](https://semver.org/#spec-item-4). Major is **never** auto-detected for pre-1.0.0 projects. Breaking changes there are classified as Minor (`0.x.0`).
3. **Find the affected consumer contracts** in the branch diff. Paths help locate evidence; they do not determine impact:

    | Artifact type | Recognition hints | Consumer contract to inspect |
    | --- | --- | --- |
    | Library / Module | Source and package manifest | Public commands/APIs, parameters, output shapes, defaults, installation, and supported runtimes. |
    | GitHub Action | `action.yml` and its implementation | Inputs, outputs, permissions, execution environment, and behavior. |
    | Reusable Workflow | Callable workflows under `.github/workflows/` | Caller inputs, secrets, permissions, configuration, tool requirements, and behavior. |
    | Infrastructure module | Module source, variables, and outputs | Variable/output contracts, defaults, provider requirements, and managed-resource behavior. |

4. **Classification rules** (apply in order, against those contracts):
    1. **Docs** — documentation-only changes, not a functional change merely stored in a documentation file.
    2. **Maintenance** — internal-only changes with no effect on shipped behavior or supported integration contracts.
    3. **Major** — a supported user or integration contract breaks (pre-1.0.0 auto-detection maps this to Minor).
    4. **Feature (Minor)** — backward-compatible capabilities are added.
    5. **Patch or Fix** — backward-compatible fixes or small improvements.

Use the highest impact across the affected supported contracts, then apply the version policy. A small fix can be breaking; unrelated internal changes or documentation do not lower that impact.

Illustrative cases, not release history:

| Change | Audience-based classification |
| --- | --- |
| Remove a supported `Process-PSModule` caller input | Breaking for module maintainers integrating the workflow, not Maintenance because the edit is under `.github/`. |
| Change a module's supported output shape or raise its minimum PowerShell version | Breaking for PowerShell users and their integrations, even if only a manifest or one line changes. |
| Add an optional module parameter without changing existing calls | Feature (Minor): a compatible capability for the same PowerShell audience. |

## Description structure

Ordered, top to bottom.

### 1. Leading paragraph — Summary

A concise paragraph describing **what changes for the user**. Present tense, active voice. Never open with implementation language ("Refactored", "Updated class", "Added null checks").

### 2. User-facing changes — sections with headers

Organize by **what the user experiences**, not by what was changed internally.

- `## Breaking Changes` — what stopped working or changed incompatibly, regardless of the selected change type. Include pre-1.0 breaking behavior even when the version policy classifies it as Minor.
- `## New: <capability>` — new things the user can do.
- `## Changed: <behavior>` — existing behavior that now works differently.
- `## Fixed: <problem>` — problems now resolved.

Under each header:

- What the user can now do, or what changed for them.
- Who is affected, including changed public parameters and defaults.
- A link to the release-wide adoption path rather than a second sequence of instructions.
- Examples or code snippets showing new usage.

Do **not** include private implementation details or refactoring decisions here. Exact public interface names belong here when users need them to understand or adopt the change.

### 3. Adopting this release

Every PR includes `## Adopting this release` before the technical details. Give one ordered, release-wide path for the affected consumers, with applicability, prerequisites, and any required intermediate steps. Adapt the actions to the artifact: a library call, workflow input, service setting, or infrastructure module may need different consumer changes.

When updating the reference is sufficient, state: **No configuration, code, or invocation changes are required beyond selecting this release.** For a non-releasing change, state its adoption outcome explicitly too. An empty section or an absent migration paragraph is not evidence that no action is needed.

### 4. Release impact

Every PR includes `## Release impact`. Report the release resolver's decision; do not introduce a second version-selection policy.

| Field | Required content |
| --- | --- |
| Effective decision | The selected owned label and its semantic effect, or the configured policy that supplies the decision where supported. Identify the decision's source; do not assume a label name across producers. |
| Semantic effect | Major, minor, patch, or no release, plus stable/prerelease mode where applicable. Describe breaking behavior separately from its version classification. |
| Release/base coordinates | Before publication, state that final coordinates are resolved by the release process. The published record supplies the actual target version, tag, immutable source, version-computation base, and release/source baseline for the consumer delta, distinguishing the two bases when they differ. |

Before publication, name the intended semantic effect and state that final coordinates are **resolved by the release process**. Do not assign a final version in advance or retain a numeric prediction after the base changes. The publisher records the actual coordinates in a distinct publication envelope without rewriting the authored body. For a first release, identify the initial versioning baseline and state that there is no prior release; for `release:skip`, state that no version is produced.

### 5. Required ending blocks

At the very end of every PR description, use this exact structure:

```markdown
---
<details>
<summary>Technical details</summary>

### Consumer change record

<Incremental consumer evidence or an explicit no-action result.>

### Template baseline

<Verified compatible immutable template evidence, or why no template applies.>

### Maintainer evidence

<Implementation notes, plan progress, alignment, and issue-convergence evidence.>

</details>

<details>
<summary>Relevant issues (or links)</summary>

- Resolves Org/Repo#123
- Resolves Org/OtherRepo#124

### Related work

- Depends on Org/OtherRepo#124
- Followed by Org/OtherRepo#125
- References Org/OtherRepo#126

</details>
```

The **Technical details** block uses the three `###` headings shown above to separate consumer evidence from maintainer evidence. The deeper headings below organize this standard, not the PR body.

#### Consumer change record

Use one row per affected surface. A stable identifier within the record lets the adoption steps and later release records refer to the same change.

| Identifier / surface | Before | After | Applicability / prerequisites | Consumer action | Verification |
| --- | --- | --- | --- | --- | --- |
| `<change ID and public surface>` | `<previous behavior>` | `<released behavior>` | `<affected consumers and required starting state>` | `<exact edit or linked numbered detail>` | `<observable result or existing check>` |

Record exact changed configuration keys, workflow contracts, permissions, secret **names, never values**, public APIs, runtime/tool requirements, defaults, removals, and behavior. A list of changed filenames alone is insufficient. Link to numbered detail in the adoption path when commands or coordinated edits need more room; do not maintain competing instructions.

Record no-action outcomes explicitly, including changes that affect behavior but require no consumer edit. If no consumer-facing surface changes, say so instead of leaving an empty table. Applicability distinguishes consumers that need an action from those already using the released contract.

#### Template baseline

Where a framework or product has an applicable integration template, record:

| Field | Required content |
| --- | --- |
| Producer identity | Producer version and immutable source, or the immutable candidate source before publication. |
| Template identity | Template repository and full immutable commit SHA, not a branch, floating tag, or today's latest template. |
| Compatibility evidence | Evidence that this template commit works with the identified producer source, including required integration surfaces and the relevant validation result. |
| Template work | Linked template PRs and their delivery state, or a justified no-change result. An earlier compatible commit may be reused when the evidence supports it. |

Every applicable release identifies its verified compatible baseline; a claim of compatibility without evidence is insufficient. If no template applies, state that fact and why. Do not invent a template or describe pending template work as delivered.

#### Maintainer evidence

Keep internal implementation notes separate from the consumer record:

- Which internal functions, classes, or files were changed.
- Implementation approach and design decisions.
- Internal compatibility considerations not already owned by the consumer record.
- **Implementation plan progress** — cross-reference the closing Task or Bug's plan. Which plan steps does this PR complete? Which were moved to follow-up delivery issues?
- **Standards and framework alignment** — the result of the [alignment pass](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass), as one row per changed surface. The stage procedure owns when and how the pass is run; this block only carries its evidence.
- **Issue convergence sweep** — the scope used for the [session-end sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) and which additional open issues (if any) the finished diff fully satisfied.

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `src/**` (PowerShell) | Naming, Functions | Module source layout | Aligned |
| `.github/workflows/**` | GitHub Actions | Reusable workflow contract | Exception — Org/Repo#123 |

A result is `Aligned`, `Fixed in this PR`, or `Exception` with a link to the follow-up issue that carries it. A surface with no framework or domain documentation of its own is recorded as `None (no framework-specific docs)`.

The **Relevant issues (or links)** block is required and uses fully qualified references (`Org/Repo#N`) so links work across repositories.

Use one bullet per linked reference. Begin with the closing issues, each prefixed with `Resolves`; this applies to the scoped Task or Bug delivered by the pull request and to additional issues the [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) confirms are fully satisfied by the same finished diff. When the PR relates to other issues or pull requests, add a `### Related work` header below the `Resolves` list, then list each qualified reference with its relationship, such as `Depends on`, `Followed by`, or `References`. Closing keywords do not close pull requests. A parent PBI or Epic may appear as context without a closing keyword; never close an aggregate through a delivery pull request. Partially convergent or supporting issues are linked as non-closing context.

A PR that delivers a scoped Task or Bug must include at least one `Resolves` link. A PR that does not resolve an issue must include a `### Related work` header and an unordered list of qualified relationship references. If additional `Resolves` links are used, include sweep evidence in Technical details that shows those issues are fully satisfied. The [Issue Hierarchy](Issues/Types/Hierarchy.md) and [Issue Lifecycle](Issues/Process/Lifecycle.md) own type and closure semantics.

## Formatting

- Paragraphs are written as a **single unbroken line**. GitHub renders mid-paragraph newlines as spaces.
- The PR description is **the release note**. Write it for users, not reviewers.
- The PR title and description align with the closing Task or Bug's user-facing framing and recorded technical decisions.
- Refer to every issue or pull request as `Org/Repo#N`, including references in the current repository; do not use bare `#N` references.

## Example

This illustrative configuration change uses the same record shape for any artifact type; it does not depend on a particular package manager, language, or deployment mechanism.

````markdown
Job timeouts use the explicit `timeoutSeconds` setting. Existing timeout values and the 30-second default are unchanged.

## Breaking Changes

The `timeout` configuration key is removed. Configurations that still supply it are rejected. Rename it using the [adoption path](#adopting-this-release); configurations that omit the key need no configuration edit.

## Adopting this release

1. If the job configuration sets `timeout`, rename that key to `timeoutSeconds`, preserving its positive integer value in seconds. For example, `timeout: 20` becomes `timeoutSeconds: 20`. Do not supply both keys. If the key is absent, retain the 30-second default without adding a setting.
2. Select the published release through the integration's version reference or deployment mechanism. Apply the configuration edit with that version change, not to the previous version.
3. Run the existing configuration validation against the selected version: `timeoutSeconds: 20` is accepted and the removed `timeout: 20` is rejected. Run the existing timeout check to confirm cancellation at the configured limit, or 30 seconds when omitted.

## Release impact

| Field | Value |
| --- | --- |
| Effective decision | `release:major`, selected for removal of a supported configuration key. |
| Semantic effect | Major, stable; existing explicit configurations require the edit above. |
| Release/base coordinates | The release process resolves the actual version base, change baseline, target version, tag, and immutable source at publication. No final numeric version is assigned in this PR. |

---
<details>
<summary>Technical details</summary>

### Consumer change record

| Identifier / surface | Before | After | Applicability / prerequisites | Consumer action | Verification |
| --- | --- | --- | --- | --- | --- |
| TIMEOUT-KEY / job configuration | Optional `timeout`, a positive integer in seconds; default 30. | Optional `timeoutSeconds`, with the same units and default; `timeout` is rejected. | Every integration; only configurations using the removed key need an edit. | Rename the key without changing its value; see adoption steps 1-2. No configuration change when omitted. | Adoption step 3 accepts the new key, rejects the old key, and confirms the timeout behavior. |

### Template baseline

Not applicable: this product does not distribute an integration template.

### Maintainer evidence

- The configuration parser accepts `timeoutSeconds` and reports the removed key as invalid.
- Implementation plan progress: all steps in Org/Repo#218 are complete, including explicit-value and default-value coverage.
- Issue convergence sweep: configuration and timeout issues were inspected; no additional issue is fully satisfied.

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| Configuration parsing and timeout behavior | Naming, Error Handling, Testing | Product configuration contract | Aligned |

</details>

<details>
<summary>Relevant issues (or links)</summary>

- Resolves Org/Repo#218

### Related work

- References Org/Repo#220

</details>
````

For a no-action patch, keep both required user-facing blocks. State the no-action adoption outcome and record either the affected behavior with `No consumer edit required` or `No consumer-facing surface changes` under Consumer change record. Do not copy the breaking example's configuration actions into an unaffected release.

## Drafts and readiness

- The Shipper always creates the PR as **draft** so CI attaches immediately.
- A pull request is marked ready only when it meets every item in the [Definition of Ready for Review](Definition-of-Ready-and-Done.md#definition-of-ready-for-review) — nothing in that gate is left open. That page is the single checklist; this section does not restate it.
- Marking ready is a gate, not a person: anyone who can verify that gate — a contributor, or an agent acting on their behalf — may mark it ready. The gate, not the actor, is what makes it ready.
- Once ready, enable auto-merge (squash) so the change lands when review approves and the required checks stay green. See [Branching and Merging](Branching-and-Merging.md#required-checks-and-auto-merge).

## Branches and commits

- Branch naming: `<type>/<issue-number>-<short-slug>`, e.g. `fix/123-pagination-truncation`.
- Commit messages: plain, direct, descriptive. **No conventional-commit prefixes** (`fix:`, `feat:`, `docs:`). See [Commit Conventions](Commit-Conventions.md).
- Self-review the staged diff before each commit. Unintended files (debug output, editor temp, credentials) get caught before they reach the remote.

## Labels and assignment

- Apply the change-type label.
- Apply phase labels if the repo uses them (Planning, Implementation, etc.).
- Assign the current user.
- Request reviewers per `CODEOWNERS`; if none, fall back to repo defaults or skip.
