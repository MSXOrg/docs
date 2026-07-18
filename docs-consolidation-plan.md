# Docs Consolidation Plan

Date: 2026-07-18
Branch: `plan/docs-consolidation-msxorg-2026-07-18`
Worktree: `/Users/AD08640/Repos/github.com/MSXOrg/docs/plan-consolidation-2026-07-18`

## Decision

`MSXOrg/docs` is the canonical home for cross-org documentation

`PSModule/docs` is reduced to PSModule-org specific documentation only:

- module catalog and module specs (what each module is and does)
- Process-PSModule framework details (how modules are structured and built)
- How to build using the framework.
- module repository anatomy (what goes where)
- onboarding path from PSModule template
- optional module dashboard extension spec (version, stars, health metadata)

## Intake mapping from PSModule/docs

### Move to MSXOrg/docs (or merge into existing pages)

- `src/docs/Style-Guides/*`
- `src/docs/GitHub-Actions/*`
- `src/docs/PowerShell/Standard/*`
- `src/docs/PowerShell/Scripts/*`
- `src/docs/PowerShell/DSC/*`
- `src/docs/PowerShell/FunctionApps/*`
- `src/docs/Solutions/*`

These are ecosystem standards and reusable practices, not PSModule-org-only references.

### Canonical destinations in MSXOrg/docs

- `src/docs/Coding-Standards/*`
- `src/docs/Coding-Standards/PowerShell/*`
- `src/docs/Capabilities/*`
- `src/docs/Initiatives/PSModule.md`

Rules:

- merge by topic, do not blind copy
- de-duplicate where MSX already has equivalent guidance
- preserve examples and intent that add concrete value

## Scope that remains in PSModule/docs

Keep module-by-module operational specifics and framework implementation details in PSModule docs:

- module catalog and module-level docs
- Process-PSModule internals and folder contracts
- template onboarding for new modules
- optional dashboard extension spec

## Target IA for PSModule/docs (post-consolidation)

- `src/docs/index.md`
- `src/docs/Modules/index.md`
- `src/docs/Modules/Catalog/index.md`
- `src/docs/Modules/Catalog/<module>.md`
- `src/docs/Modules/Process-PSModule/index.md`
- `src/docs/Modules/Process-PSModule/repository-structure.md`
- `src/docs/Modules/Process-PSModule/module-anatomy.md`
- `src/docs/Modules/Process-PSModule/build-test-pack-publish.md`
- `src/docs/Modules/Process-PSModule/template-quickstart.md`
- `src/docs/Modules/Dashboard-Extension/index.md` (optional)
- `src/docs/Modules/Dashboard-Extension/spec.md` (optional)

## Execution waves

### Wave 1: Baseline crosswalk and landing pages

- add consolidation note and links in `Initiatives/PSModule.md`
- prepare missing target pages in Coding Standards and Capabilities

### Wave 2: Standards merge

- migrate standards/style guidance into canonical MSX pages
- reconcile conflicts in favor of current MSX standards model

### Wave 3: Solutions and capabilities merge

- migrate reusable solution docs into capability structure
- keep PSModule-only runbooks out of MSX canonical scope

### Wave 4: PSModule scope reduction

- replace moved PSModule sections with concise pointers to MSX canonical docs
- build the module-centric IA and Process-PSModule deep-dive pages

### Wave 5: Quality gates and release

- run index generation and link validation in both repos
- verify one canonical location per moved topic
- publish coordinated PRs per wave

## PR slicing

- PR 1 (MSX): intake skeleton and first migrated section
- PR 2 (MSX): remaining standards and solution/capability migrations
- PR 3 (PSModule): module-centric IA and pointer pages
- PR 4 (PSModule): module catalog population and Process-PSModule deep dive

## Success criteria

- readers find standards and reusable practices only in `MSXOrg/docs`
- readers find module inventory/process specifics only in `PSModule/docs`
- no duplicated canonical guidance across repos
- both docs sites build and pass link/index validation

## Open decisions

- should Process-PSModule implementation details be canonical in PSModule docs with a summary in MSX, or canonical in MSX with a mirror in PSModule?
- should module dashboard data be generated in CI and published as docs pages, or surfaced via a separate extension service?
- which PSModule repositories are in scope for initial catalog coverage (all modules vs prioritized set)?
