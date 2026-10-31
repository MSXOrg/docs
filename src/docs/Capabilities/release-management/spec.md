---
title: Spec
description: Requirements for release management — validated defaults, reviewed overrides, immutable artifacts, and complete consumer release records.
---

# Release Management — Spec

## Premise

A release turns a source change on a release branch into a **versioned,
immutable artifact** that other systems depend on. Merging a pull request *is*
releasing. Releasing MUST be automatic, predictable, and driven entirely on the
GitHub platform — a contributor focuses on the code they contribute, not a
release CLI, a hand-edited version file, or a tagging convention.

A target route participates when its effective pipeline produces a versioned,
immutable output consumed by version. This includes shared workflows and native
producer pipelines. The optional `.github/release.config.yml` refines the route's
settings; its absence does not opt a managed route out.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** The release process and version decision are version-controlled, never a GUI action or manual tag.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point; its review gate approves the code *and* the release. An owned bump label records a per-change override; a documented effective default records the policy used when no level is supplied.
- **[Smart defaults, local overrides](../../Ways-of-Working/Principles/Software-Design.md#smart-defaults-local-overrides).** Shared defaults make an unconfigured managed route useful; repository settings and supported caller inputs provide deliberate narrower overrides.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The rules are technology-agnostic at the core, with defined extension points per artifact type. A new artifact type supplies a convention and a publish step, not a new process.

## Scope

Applies to any repository that produces a versioned artifact on merge to a
release branch. One test decides applicability: **does merging produce a
versioned, immutable output that something else consumes by version?** If yes,
this capability governs the release, including native producer routes. If no,
there is nothing to release and the PR carries no release metadata or
`release:*` labels.

## Requirements

- **Semantic versioning.** Versions follow [SemVer 2.0.0](https://semver.org/) (`vMAJOR.MINOR.PATCH`), derived automatically — never written by hand.
- **Release behavior determines applicability.** Every PR targeting a managed release route MUST be evaluated, including native producer routes and routes without `.github/release.config.yml`. An unmanaged route MUST NOT require, apply, or report release metadata or any `release:*` label.
- **Producer compatibility is verified, not inferred.** The effective producer revision's settings and owned-label mapping MUST be verified. A differing released interface MUST have a verified adapter or producer/configuration migration before canonical signals are used. Unsupported signals MUST block finalization and required decision validation, not become an ignored skip request or an excuse to classify a managed route as unmanaged. Exact adoption actions belong in the producer's PR/release record.
- **Settings have documented defaults and supported overrides.** Release automation MUST document setting names, accepted values, shared defaults, and supported caller overrides. Repository settings MUST override shared defaults; explicitly supplied supported caller inputs MUST override repository settings for that invocation. Unknown settings and invalid supplied values MUST fail even when a narrower override or explicit bump label exists. Omission MUST inherit a documented default rather than require configuration to become usable.
- **A resolved PR release decision.** `DefaultBump` accepts exactly `patch`, `minor`, or `major` and has the shared default `patch`. With no owned bump label, automation MUST use the valid effective default without requiring a per-PR bump label. Exactly one of `release:patch`, `release:minor`, or `release:major` MUST override that default. `release:prerelease` uses the resolved bump; mode alone supplies no level. Multiple owned bump labels, or `release:skip` with another owned release label, MUST fail. A valid skip MUST suppress publication without resolving a bump. If no valid level resolves, automation MUST fail rather than select a fallback. Bare and unrelated labels MUST be ignored. Conventional commit messages are **not** required.
- **A release per eligible merge.** One artifact-affecting merged PR with a resolved bump to a managed release route is one release, and the PR review gate is the release gate. The bump comes from one explicit owned bump label or the valid effective `DefaultBump`. `release:skip` and out-of-scope changes validate without publishing. This pull-request path is the required release interface.
- **Ad hoc release is optional.** An implementation MAY expose `workflow_dispatch` when its product needs an ad hoc release outside the merge flow; implementations are not required to support it. A dispatch MUST require an explicit release decision and release-note context, and MUST use the same version, build, validation, immutability, and publication controls as a merged pull request. A direct push MUST NOT be an ad hoc release interface, and an empty pull request MUST NOT be created solely to trigger a release.
- **Version before build.** The version MUST be resolved before the artifact is built, so the version is part of the artifact's identity rather than a label attached afterwards.
- **Build once.** The artifact MUST be built exactly once and MUST NOT be altered after it is built. The same bytes flow through validation and publishing. Rebuilding to publish means the tested artifact and the published artifact are different artifacts.
- **Release types.** Every release branch MUST produce exactly one type: **stable** (the latest version to adopt), **prerelease** (early testable output), or **release candidate** (promotable output that is not latest). A branch MUST NOT produce more than one type. A prerelease MUST also be obtainable from an open pull request carrying `release:prerelease`, using its explicit owned bump label or the resolved `DefaultBump`.
- **Decision validation blocks merge.** Every PR targeting a managed release route MUST receive a named release-decision CI check required by the branch ruleset or protection. Missing decisions, invalid defaults, and conflicting owned labels MUST fail that check before merge, not only during publication. Source, release labels, release settings, supported caller inputs, and effective-pipeline changes MUST re-evaluate the decision. A failing, pending, or absent required result MUST block both manual and automated merge; a log message, warning, or skipped validator is not enforcement. A valid `release:skip` MUST report a successful no-release decision, not skip the check.
- **Serialised releases.** Only one release process runs against a given version of the codebase (the same ref) at a time. A release mutates shared, version-anchored state — the tag, the version counter, the published artifact — so overlapping runs on the same ref MUST NOT race, and an in-flight release is never interrupted.
- **A single production authority.** Exactly one branch is in charge of the production (stable) version, so consumers get one unambiguous latest stable release and two branches can never publish competing production releases.
- **Notes from the contributor's own words.** The GitHub Release name is the version; its body MUST preserve the release-bound pull request title and complete description, or equivalent complete release-note context for an optional ad hoc dispatch. The authored record follows [PR Format](../../Ways-of-Working/PR-Format.md#write-the-description); classified results and their scoped supporting evidence MUST NOT be omitted or summarized away.
- **Only artifact-affecting changes release.** On a managed release route, a change that does not affect the delivered artifact or its supported consumer contracts MUST carry `release:skip` and MUST NOT produce a release — though validation still runs on every merge. Unmanaged routes omit that label and all release metadata. Documentation and internal CI configuration qualify only when they meet the artifact-impact condition. An Action or reusable workflow is itself a product for its callers; its interface and behavior MUST NOT be dismissed as internal tooling because of the file path.
- **Immutable references.** Consumers pin to the most immutable reference available — a container digest or a commit SHA — never a mutable tag.
- **Publish through a target contract.** Every publishing destination is reached through the same [publishing-target contract](design-publishing-targets.md), so the release process stays one process regardless of how many destinations a repository has. Adding a destination supplies a contract and a publish step; it MUST NOT change the release process.
- **All-or-nothing across targets.** Where a repository publishes one artifact to more than one destination, a version MUST NOT end up present on some destinations and absent from others. Partial publication is a failure, reported as one, and resumed by completing the remaining destinations with the same immutable artifact and version.
- **Recovery distinguishes retries from changed output.** Retrying validation or publication of unchanged bytes MUST reuse their artifact and version. A correction that changes the bytes MUST create a new versioned artifact; an existing version is never overwritten or reused.
- **Standard GitHub primitives only.** Pull requests, labels, comments, and, where implemented, workflow dispatch — no external tooling beyond `gh` and GitHub Actions.

### Release evidence

- **Evidence stays with the result it supports.** Consumer instructions appear in each result's prose and examples, with supporting validation, source, and template evidence in that result's `Technical details` block. Internal-only work without classified sections carries the action or no-action result in its summary and applicable evidence in the supporting block after the boundary. A global evidence block does not replace result-scoped evidence.
- **Incremental consumer contract.** Every release MUST describe its complete consumer-facing delta against an identified release/source baseline: what changed, why, affected supported uses, compatibility, and exact actions with prerequisites, ordering, and verification, or an explicit no-action result with its compatibility basis. Breaking behavior MUST be documented independently of its semantic-version classification. An applicable integration template MUST be identified by repository and verified compatible immutable commit, with producer-source compatibility evidence and linked template work or a justified no-change result.
- **Sufficient upgrade history.** Reading every applicable record after the actual consumed baseline through the target in release order MUST be sufficient to compose the required actions. Notes MUST explain superseded actions and retain required intermediate installations or runs; reading a record MUST NOT itself require installing its version. Required migration instructions MUST remain in PR/release records, not repository migration guides or a parallel changelog. PRs and diffs MAY provide optional depth but MUST NOT substitute for missing instructions. Resource docs describe supported target-state behavior and usage.
- **Resolved coordinates.** The release process MUST record the actual target version, tag, immutable source and artifact identity, effective release decision and its source, version-computation base, and consumer-change baseline. The version base and change baseline MUST be distinguished when they differ. A first release MUST identify its initial versioning baseline and lack of a prior release. Authors MUST NOT assign a final version before resolution.
- **Traceable publication.** Generated identity and provenance MAY surround the authored note as a distinct envelope; they MUST NOT replace or rewrite it. The release MUST retain the note's source identity and snapshot provenance so its relationship to the published code is inspectable. Every destination carrying release notes, including downstream propagation, MUST receive the complete record.
- **Correct release scope.** A bundled release's integration PR MUST cover every bundled consumer delta. An optional ad hoc release MUST provide equivalent evidence without implying a nonexistent PR. A prerelease MUST preserve the note appropriate to its immutable published source, not a later final-PR description that describes different code.
- **Metadata-only correction.** A correction to published notes MUST retain an audit of the original and corrected content, reason, supporting source evidence, actor, and time. It MUST NOT alter release artifacts, tags, source identities, or the behavior attributed to a version. Unverifiable historical facts MUST be registered as gaps, not guessed.

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

- Merging an eligible artifact-affecting PR with a resolved bump to a managed release route produces a GitHub Release, a git tag, and (where one exists) a published artifact with no manual step. Skip and out-of-scope changes validate without publishing.
- A publishing PR inherits the documented patch default when no repository setting, supported caller override, or owned bump label is supplied. Repository settings, supported caller inputs, and an explicit owned bump label override it in that order, with the chosen source recorded.
- Invalid supplied settings and conflicting owned labels fail even when another input supplies a valid level. Removing a bump override re-evaluates the required check against the effective default; source, settings, and caller changes invalidate prior evidence.
- A managed native producer route and a route without `.github/release.config.yml` still receive release-decision validation; an unmanaged route carries no release metadata or labels.
- An open pull request carrying `release:prerelease` publishes a prerelease without promoting it to latest, using one explicit owned bump label when present and the resolved `DefaultBump` otherwise.
- A configured prerelease branch publishes prerelease versions, and a configured release-candidate branch publishes `-rc.N` versions; neither promotes an artifact to latest.
- The artifact that consumers download is byte-identical to the artifact that passed validation.
- On a managed route, a merge outside the artifact/consumer scope carrying `release:skip` produces no version but still runs its checks; an unmanaged route omits release labels and metadata entirely.
- Two release runs for the same ref never overlap; the second waits for the first to finish rather than racing it.
- Only the single production branch ever publishes a stable release.
- A version that reaches one publishing target reaches all of them, or the release is reported as failed.
- Every release is linkable and records its immutable artifact reference.
- The published authored title and body match the release-bound snapshot in full, including adoption, consumer/template evidence, and maintainer details.
- Consumers compose their alignment actions from complete ordered release notes, including explicit no-action releases, without mining PRs, diffs, or repository migration history.
- A consumer can identify the actual target, version base, change baseline, and any applicable compatible template without relying on a moving branch, alias, or today's documentation.
- A bundled or ad hoc note covers its complete change range, and a prerelease note never gains instructions for code absent from that prerelease.
- A published-note correction is traceable to released-source evidence while all artifact and source identities remain unchanged.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Publishing Targets](design-publishing-targets.md) — the contract each destination documents.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why this spec holds only the why and the what.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — why release labels are owned by the `release:` namespace.
- [PR Format](../../Ways-of-Working/PR-Format.md) — the change-type labels that drive the bump.
- [Dependency Updates](../dependency-updates/spec.md) — update PRs are artifact-affecting and release through this capability.
