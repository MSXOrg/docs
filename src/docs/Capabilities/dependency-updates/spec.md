---
title: Spec
description: Requirements for dependency updates — pinned dependencies kept current and secure through reviewed, released update pull requests.
---

# Dependency Updates — Spec

## Premise

Every repository pins dependencies by version — Action SHAs, image digests,
package versions, provider constraints. Those pins age: a newer version fixes a
bug the repository still carries, and a disclosed advisory turns a safe pin into
a vulnerability. Keeping them current MUST be automatic and driven on the GitHub
platform, producing ordinary pull requests that are reviewed and released
through the same gate as any change — never a side channel that bypasses review.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** What is checked and how often is version-controlled configuration, not a manual audit.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** Every update is a pull request; its review gate approves the bump and the release it produces.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The updater and any auto-merge automation carry only the permissions they need.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** Adding a package ecosystem is a configuration entry, not new machinery.

## Scope

Any repository that pins external dependencies: Action and workflow SHAs,
container base images, language packages and lockfiles, and the manifests of any
other ecosystem the repository actually uses. Two questions are asked of every pin —
**currency** (is a newer version available?) and **security** (does the pinned
version carry a known advisory?).

Out of scope: what an update *does* to the artifact. That is the release the update
produces, and it is governed by [Release
Management](../release-management/spec.md).

## Requirements

### Coverage

- **FR1 — Every ecosystem present is classified.** Coverage MUST be derived from
  the manifests the repository actually contains. Each detected ecosystem MUST
  either be supported by the platform-native updater or have a centrally managed
  exception; an unclassified manifest is an uncovered pin that ages silently.
- **FR2 — Native support is configured.** Every detected ecosystem in the
  centrally maintained native-support catalogue MUST have an updater entry for
  the directory its manifest governs.
- **FR3 — Unsupported ecosystems use a central exception.** An ecosystem the
  native updater does not support MUST be recorded in the centrally managed
  exception register with its manifest, scope, reason, owner, and shared update
  mechanism. A repository MUST NOT create or maintain a bespoke updater.
- **FR4 — Coverage is verifiable, not asserted.** The manifest inventory MUST be
  comparable against the configured native ecosystems and the central exception
  register, so a gap is a detectable finding rather than something noticed when a
  pin is years stale.
- **FR5 — Native configuration is generated, not hand-maintained.** Native
  updater configuration SHOULD be produced from supported manifests rather than
  written by hand. A generated configuration cannot drift from the repository; a
  hand-written one drifts when a supported ecosystem is added.

### Cadence

- **FR6 — Currency is checked on a schedule.** No human watches upstream releases.
- **FR7 — The schedule is configuration.** Frequency and the timezone it is expressed in MUST be configurable per organization. There is no correct global cadence: a repository whose consumers deploy continuously wants updates sooner than one that ships quarterly, and a schedule expressed in a timezone nobody works in produces pull requests nobody triages.
- **FR8 — Freshly published versions wait.** A version MUST NOT be proposed the moment it appears. A cooldown between publication and proposal lets an upstream project withdraw or supersede a bad release before every consumer has a pull request open against it.
- **FR9 — Security advisories bypass the schedule.** An advisory affecting a pin raises an update on disclosure, out of band, and MUST be prioritised over scheduled currency updates.

### Batching

- **FR10 — Low-risk updates MAY be grouped; breaking ones MUST NOT be.** Minor and patch updates within one ecosystem MAY share a pull request, because reviewing twelve patch bumps separately costs twelve reviews and yields no more information than one. A major update MUST be isolated, because it is the update whose diff has to be read.
- **FR11 — Grouping never crosses ecosystems.** A group's review requires knowing one ecosystem's conventions; mixing ecosystems in one pull request means no single reviewer is qualified for the whole diff.

### Review and labelling

- **FR12 — One reviewed pull request per update or group.** Each update is a pull request that passes the full check suite before merge. Nothing is applied unreviewed, and no update takes a side channel around the gate.
- **FR13 — Update level is labelled.** Every update pull request MUST carry the category, the ecosystem, and the dependency's own version-change level, so review routing and triage do not require opening the diff.
- **FR14 — Update labels MUST NOT reuse the release bump vocabulary.** The label that signals the *dependency's* version level MUST be namespaced away from the release-bump labels ([automation labels](../../Ways-of-Working/Automation-Labels.md#every-set-is-namespaced)). A dependency update is artifact-affecting and therefore produces a release; one shared vocabulary across the two dimensions would set this repository's version from the upstream project's decision.
- **FR15 — Review posture follows update level.** Patch and minor updates MAY merge automatically once every required check passes. A major update MUST require human review and MUST NOT merge automatically. A repository MAY tighten this and MUST NOT loosen it.
- **FR16 — Automatic merge is never a bypass.** Where an update merges without review, it does so because the checks passed, not because the checks were skipped.

### Non-functional

- **NFR1 — SHA pins stay immutable.** An update to a SHA-pinned dependency rewrites the pin to the new commit SHA and records the human-readable version alongside it, so the pin stays exact and stays legible.
- **NFR2 — Update pull requests carry their evidence.** Each one includes the upstream release notes or changelog for the range it crosses. A reviewer deciding on a bump should not have to leave the pull request to find out what changed.
- **NFR3 — The mechanism is platform-native.** Checking, advisory correlation, and pull request creation are platform functions, not bespoke automation, so no repository maintains an updater of its own.

## Success criteria

- An outdated or vulnerable pin produces a labelled pull request with no human trigger.
- An ecosystem added to a repository without a corresponding updater entry is a detectable finding, not a silent gap.
- The dependency's version level is legible from labels without opening the diff, and never changes this repository's release bump by itself.
- No dependency pull request merges without passing the same checks as any other pull request.

## Where this connects

- [Design](design.md) — the label scheme, the updater, and the automatic-merge policy.
- [Release Management](../release-management/spec.md) — the versioning update pull requests feed into, and the bump vocabulary these must not reuse.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — the namespacing rule that keeps the two version dimensions disjoint.
- [Repository Governance](../repository-governance/spec.md) — the reconciliation that detects an uncovered ecosystem.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#keep-pinned-actions-current) — keeping pinned Actions current.
