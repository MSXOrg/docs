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
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point; its review gate approves the code *and* the release. An owned bump label records a per-change decision; a version-controlled repository default records the policy used when no level is supplied.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The rules are technology-agnostic at the core, with defined extension points per artifact type. A new artifact type supplies a convention and a publish step, not a new process.

## Scope

Applies to any repository that produces a versioned artifact on merge to a
release branch. One test decides applicability: **does merging produce a
versioned, immutable output that something else consumes by version?** If yes,
this capability governs the release. If no, there is nothing to release.

## Requirements

- **Semantic versioning.** Versions follow [SemVer 2.0.0](https://semver.org/) (`vMAJOR.MINOR.PATCH`), derived automatically — never written by hand.
- **A resolved PR release decision.** The repository MAY configure `DefaultBump` as `patch`, `minor`, or `major`; invalid values MUST fail. Multiple owned bump labels, or `release:skip` combined with another owned release label, MUST fail. A valid `release:skip` MUST select no release without resolving a bump. For publishing decisions, one owned `release:patch`, `release:minor`, or `release:major` label MUST take precedence over the configured default; without a bump label, a valid `DefaultBump` MUST supply the level; without either source, automation MUST fail with a missing-decision error, never assume `patch`. `release:pre-release` MAY use either the explicit or configured bump; the mode alone does not supply a level. Bare or unrelated labels MUST be ignored. Conventional commit messages are **not** required.
- **A release per merge.** One eligible merged PR with a resolved bump to a release branch is one release, and the PR review gate is the release gate. `release:skip` validates without publishing. This pull-request path is the required release interface.
- **Decision validation blocks merge.** Every PR targeting a release branch MUST receive a named release-decision CI check required by the branch ruleset or protection. Missing decisions, invalid defaults, and conflicting owned labels MUST fail that check before merge, not only during publication. Source, release-label, and release-settings changes MUST re-evaluate the decision. A failing, pending, or absent required result MUST block both manual and automated merge; a log message, warning, or skipped validator is not enforcement. A valid `release:skip` MUST report a successful no-release decision, not skip the check.
- **Ad hoc release is optional.** An implementation MAY expose `workflow_dispatch` when its product needs an ad hoc release outside the merge flow; implementations are not required to support it. A dispatch MUST require an explicit release decision and release-note context, and MUST use the same version, build, validation, immutability, and publication controls as a merged pull request. A direct push MUST NOT be an ad hoc release interface, and an empty pull request MUST NOT be created solely to trigger a release.
- **Version before build.** The version MUST be resolved before the artifact is built, so the version is part of the artifact's identity rather than a label attached afterwards.
- **Build once.** The artifact MUST be built exactly once and MUST NOT be altered after it is built. The same bytes flow through validation and publishing. Rebuilding to publish means the tested artifact and the published artifact are different artifacts.
- **Stable and prerelease.** Every release is either **stable** (the latest version to adopt) or a **prerelease** (testable, not promoted to latest). A prerelease MUST be obtainable from an open pull request carrying `release:pre-release`, using its explicit or configured bump, and/or from a prerelease branch.
- **Serialised releases.** Only one release process runs against a given version of the codebase (the same ref) at a time. A release mutates shared, version-anchored state — the tag, the version counter, the published artifact — so overlapping runs on the same ref MUST NOT race, and an in-flight release is never interrupted.
- **A single production authority.** Exactly one branch is in charge of the production (stable) version, so consumers get one unambiguous latest stable release and two branches can never publish competing production releases.
- **Notes from the contributor's own words.** The GitHub Release name is the version; its body MUST preserve the release-bound pull request title and complete description, or equivalent complete release-note context for an optional ad hoc dispatch. The authored record follows [PR Format](../../Ways-of-Working/PR-Format.md#description-structure); adoption and technical details MUST NOT be omitted or summarized away.
- **Only artifact-affecting changes release.** A change that does not affect the delivered artifact or its supported consumer contracts MUST carry `release:skip` and MUST NOT produce a release — though validation still runs on every merge. Documentation and internal CI configuration qualify only when they meet that condition. An Action or reusable workflow is itself a product for its callers; its interface and behavior MUST NOT be dismissed as internal tooling because of the file path.
- **Immutable references.** Consumers pin to the most immutable reference available — a container digest or a commit SHA — never a mutable tag.
- **Publish through a target contract.** Every publishing destination is reached through the same [publishing-target contract](design-publishing-targets.md), so the release process stays one process regardless of how many destinations a repository has. Adding a destination supplies a contract and a publish step; it MUST NOT change the release process.
- **All-or-nothing across targets.** Where a repository publishes one artifact to more than one destination, a version MUST NOT end up present on some destinations and absent from others. Partial publication is a failure, reported as one, and resumed by completing the remaining destinations with the same immutable artifact and version.
- **Recovery distinguishes retries from changed output.** Retrying validation or publication of unchanged bytes MUST reuse their artifact and version. A correction that changes the bytes MUST create a new versioned artifact; an existing version is never overwritten or reused.
- **Standard GitHub primitives only.** Pull requests, labels, comments, and, where implemented, workflow dispatch — no external tooling beyond `gh` and GitHub Actions.

### Release evidence

- **Incremental consumer contract.** Every release MUST describe its consumer-facing delta against an identified release/source baseline, including applicability, exact actions, and verification, or explicit no-action evidence. Breaking behavior MUST be documented independently of its semantic-version classification. An applicable integration template MUST be identified by repository and verified compatible immutable commit, with producer-source compatibility evidence and linked template work or a justified no-change result.
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

- Merging an eligible PR with an explicit or configured bump produces a GitHub Release, a git tag, and (where one exists) a published artifact, with no manual step.
- For a publishing PR, an explicit owned bump label overrides the configured default; without that label, a valid `DefaultBump` supplies the level and is recorded as its source.
- A PR with no explicit level, configured default, or valid no-release decision fails the required decision check and cannot merge. Invalid defaults and conflicting owned labels also block merge rather than selecting a fallback.
- Removing the only decision source or changing its inputs re-evaluates the PR check; a prior result does not validate different inputs.
- An open pull request carrying `release:pre-release` and an explicit or configured bump publishes a prerelease without promoting it to latest.
- The artifact that consumers download is byte-identical to the artifact that passed validation.
- A documentation-only merge carrying `release:skip` produces no new version but still runs its CI checks.
- Two release runs for the same ref never overlap; the second waits for the first to finish rather than racing it.
- Only the single production branch ever publishes a stable release.
- A version that reaches one publishing target reaches all of them, or the release is reported as failed.
- Every release is linkable and records its immutable artifact reference.
- The published authored title and body match the release-bound snapshot in full, including adoption, consumer/template evidence, and maintainer details.
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
