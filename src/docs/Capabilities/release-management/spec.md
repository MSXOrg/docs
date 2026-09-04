---
title: Spec
description: Requirements for release management — automatic, policy-driven, versioned releases driven entirely on the GitHub platform.
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
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point; its review gate approves the code *and* the release. The version-controlled `DefaultBump` records the repository's normal versioning policy, and an owned bump label records a reviewed override.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The rules are technology-agnostic at the core, with defined extension points per artifact type. A new artifact type supplies a convention and a publish step, not a new process.

## Scope

Applies to any repository that produces a versioned artifact on merge to a
release branch. One test decides applicability: **does merging produce a
versioned, immutable output that something else consumes by version?** If yes,
this capability governs the release. If no, there is nothing to release.

## Requirements

- **Semantic versioning.** Versions follow [SemVer 2.0.0](https://semver.org/) (`vMAJOR.MINOR.PATCH`), derived automatically — never written by hand.
- **Namespaced release decision with a configurable default.** Release automation reads only the `release:` namespace. `DefaultBump` MUST accept exactly `patch`, `minor`, or `major` and MUST resolve to `patch` when omitted. With no owned bump label, automation MUST use the resolved `DefaultBump`; when present, exactly one of `release:patch`, `release:minor`, or `release:major` MUST override it. `release:prerelease` MAY be used alone or with exactly one owned bump label on an open pull request and MUST use that owned bump when present, otherwise the resolved `DefaultBump`. `release:skip` MUST prevent publication and MUST NOT be combined with another owned release label. Multiple owned bump labels MUST fail. Bare `patch`, `minor`, and `major` labels and all unrelated labels MUST be ignored. Conventional commit messages are **not** required.
- **A release per merge.** One merged PR to a release branch is one release unless it carries `release:skip`, and the PR review gate is the release gate. The bump comes from one explicit owned bump label or the resolved `DefaultBump`. `release:skip` validates without publishing. This pull-request path is the required release interface.
- **Ad hoc release is optional.** An implementation MAY expose `workflow_dispatch` when its product needs an ad hoc release outside the merge flow; implementations are not required to support it. A dispatch MUST require an explicit release decision and release-note context, and MUST use the same version, build, validation, immutability, and publication controls as a merged pull request. A direct push MUST NOT be an ad hoc release interface, and an empty pull request MUST NOT be created solely to trigger a release.
- **Version before build.** The version MUST be resolved before the artifact is built, so the version is part of the artifact's identity rather than a label attached afterwards.
- **Build once.** The artifact MUST be built exactly once and MUST NOT be altered after it is built. The same bytes flow through validation and publishing. Rebuilding to publish means the tested artifact and the published artifact are different artifacts.
- **Release types.** Every release branch MUST produce exactly one type: **stable** (the latest version to adopt), **prerelease** (early testable output), or **release candidate** (promotable output that is not latest). A branch MUST NOT produce more than one type. A prerelease MUST also be obtainable from an open pull request carrying `release:prerelease`, using its explicit owned bump label or the resolved `DefaultBump`.
- **Serialised releases.** Only one release process runs against a given version of the codebase (the same ref) at a time. A release mutates shared, version-anchored state — the tag, the version counter, the published artifact — so overlapping runs on the same ref MUST NOT race, and an in-flight release is never interrupted.
- **A single production authority.** Exactly one branch is in charge of the production (stable) version, so consumers get one unambiguous latest stable release and two branches can never publish competing production releases.
- **Notes from the contributor's own words.** The GitHub Release name is the version; its body comes from the pull request title and description, or from the required release-note context of an optional ad hoc dispatch. The PR description is therefore written for consumers.
- **Only artifact-affecting changes release.** A change that does not flow into the artifact (documentation, CI config) MUST carry `release:skip` and MUST NOT produce a release — though validation still runs on every merge.
- **Immutable references.** Consumers pin to the most immutable reference available — a container digest or a commit SHA — never a mutable tag.
- **Publish through a target contract.** Every publishing destination is reached through the same [publishing-target contract](design-publishing-targets.md), so the release process stays one process regardless of how many destinations a repository has. Adding a destination supplies a contract and a publish step; it MUST NOT change the release process.
- **All-or-nothing across targets.** Where a repository publishes one artifact to more than one destination, a version MUST NOT end up present on some destinations and absent from others. Partial publication is a failure, reported as one, and resumed by completing the remaining destinations with the same immutable artifact and version.
- **Recovery distinguishes retries from changed output.** Retrying validation or publication of unchanged bytes MUST reuse their artifact and version. A correction that changes the bytes MUST create a new versioned artifact; an existing version is never overwritten or reused.
- **Standard GitHub primitives only.** Pull requests, labels, comments, and, where implemented, workflow dispatch — no external tooling beyond `gh` and GitHub Actions.

### Consumer update policies

A consumer chooses how much version movement it accepts. Selecting a policy is a **consumer-side** concern — the release capability's obligation is to publish versions that make every policy expressible:

| Policy | Accepts | Suits |
| --- | --- | --- |
| **Latest** | any newer version, including major | consumers that track the current release and have tests to catch breakage |
| **Lock major boundary** | newer minor and patch within one major | the default for a library dependency under SemVer |
| **Lock minor boundary** | newer patch only | consumers that accept fixes but no new surface |
| **Lock specific version** | nothing; movement is an explicit change | consumers under change control |
| **Lock immutable fingerprint** | nothing; the reference is a digest or SHA | consumers that require the exact bytes to be provable |

Because versions are semantic, immutable, and published once, a consumer can adopt any of these without the producer knowing which one it chose.

## Success criteria

- Merging a PR without `release:skip` to a release branch produces a GitHub Release, a git tag, and (where one exists) a published artifact, using one explicit owned bump label or the resolved `DefaultBump` with no manual step.
- An explicit namespaced bump label overrides `DefaultBump` every time; without one, the validated `DefaultBump` is used. An invalid default or conflicting owned label set is rejected, while bare and unrelated labels are ignored.
- An open pull request carrying `release:prerelease` publishes a prerelease without promoting it to latest, using one explicit owned bump label when present and the resolved `DefaultBump` otherwise.
- A configured prerelease branch publishes prerelease versions, and a configured release-candidate branch publishes `-rc.N` versions; neither promotes an artifact to latest.
- The artifact that consumers download is byte-identical to the artifact that passed validation.
- A documentation-only merge carrying `release:skip` produces no new version but still runs its CI checks.
- Two release runs for the same ref never overlap; the second waits for the first to finish rather than racing it.
- Only the single production branch ever publishes a stable release.
- A version that reaches one publishing target reaches all of them, or the release is reported as failed.
- Every release is linkable and records its immutable artifact reference.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Publishing Targets](design-publishing-targets.md) — the contract each destination documents.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why this spec holds only the why and the what.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — why release labels are owned by the `release:` namespace.
- [PR Format](../../Ways-of-Working/PR-Format.md) — the change-type labels that drive the bump.
- [Dependency Updates](../dependency-updates/spec.md) — update PRs are artifact-affecting and release through this capability.
