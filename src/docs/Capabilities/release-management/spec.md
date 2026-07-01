---
title: Spec
description: Requirements for release management — automatic, label-driven, versioned releases driven entirely on the GitHub platform.
---

# Release Management — Spec

## Premise

A release turns a source change on a release branch into a **versioned,
immutable artifact** that other systems depend on. Merging a pull request *is*
releasing. Releasing MUST be automatic, predictable, and driven entirely on the
GitHub platform — a contributor focuses on the code they contribute, not a
release CLI, a hand-edited version file, or a tagging convention.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** The release process and version decision are version-controlled, never a GUI action or manual tag.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point; its review gate approves the code *and* the release, and the bump label records the versioning decision explicitly.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The rules are technology-agnostic at the core, with defined extension points per artifact type. A new artifact type supplies a convention and a publish step, not a new process.

## Scope

Applies to any repository that produces a versioned artifact on merge to a
release branch. One test decides applicability: **does merging produce a
versioned, immutable output that something else consumes by version?** If yes,
this capability governs the release. If no, there is nothing to release.

## Requirements

- **Semantic versioning.** Versions follow [SemVer 2.0.0](https://semver.org/) (`vMAJOR.MINOR.PATCH`), derived automatically — never written by hand.
- **Label-driven bump.** The bump level is a pull-request label — `Major` / `Minor` / `Patch` / `NoRelease` — defaulting to `Patch`. Conventional commit messages are **not** required.
- **A release per merge.** One merged PR to a release branch is one release, and the PR review gate is the release gate. Direct pushes and manual dispatch also release.
- **Stable and prerelease.** Every release is either **stable** (the latest version to adopt) or a **prerelease** (testable, not promoted to latest). A prerelease MUST be obtainable from an open pull request and/or from a prerelease branch.
- **Serialised releases.** Only one release process runs against a given version of the codebase (the same ref) at a time. A release mutates shared, version-anchored state — the tag, the version counter, the published artifact — so overlapping runs on the same ref MUST NOT race, and an in-flight release is never interrupted.
- **A single production authority.** Exactly one branch is in charge of the production (stable) version, so consumers get one unambiguous latest-stable and two branches can never publish competing production releases.
- **Notes from the contributor's own words.** The GitHub Release name is the version; its body is assembled from material the contributor already wrote (PR title + description, or commit message, or collected history). The PR description is therefore written for consumers.
- **Only artifact-affecting changes release.** A change that does not flow into the artifact (documentation, CI config) MUST NOT produce a release — though validation still runs on every merge.
- **Immutable references.** Consumers pin to the most immutable reference available — a container digest or a commit SHA — never a mutable tag.
- **Standard GitHub primitives only.** Pull requests, labels, comments, and workflow dispatch — no external tooling beyond `gh` and GitHub Actions.

## Success criteria

- Merging a labelled PR to a release branch produces a GitHub Release, a git tag, and (where one exists) a published artifact, with no manual step.
- The version bump matches the PR's label every time; a conflicting or ambiguous label set is **rejected**, never guessed.
- A documentation-only merge produces no new version but still runs its CI checks.
- Two release runs for the same ref never overlap; the second waits for the first to finish rather than racing it.
- Only the single production branch ever publishes a stable release.
- Every release is linkable and records its immutable artifact reference.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why this spec holds only the why and the what.
- [PR Format](../../Ways-of-Working/PR-Format.md) — the change-type labels that drive the bump.
- [Dependency Updates](../dependency-updates/spec.md) — update PRs are artifact-affecting and release through this capability.
