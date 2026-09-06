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
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** Every update is a pull request; its review gate approves the bump, while its release impact is decided separately.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The updater and any auto-merge automation carry only the permissions they need.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** Adding a package ecosystem is a configuration entry, not new machinery.

## Scope

Any repository that pins external dependencies: Action and workflow SHAs,
container base images, language packages and lockfiles, and the manifests of any
other ecosystem the repository actually uses. Two questions are asked of every pin —
**currency** (is a newer version available?) and **security** (does the pinned
version carry a known advisory?).

Adopting the dependency includes the integration changes it requires, not just
changing its reference. Selecting and publishing the consumer repository's own
release remains out of scope and is governed by [Release
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
- **FR8 — Freshly published versions wait three days.** A version MUST NOT be proposed the moment it appears. The organization standard is a three-day cooldown, so a repository MUST omit an explicit `cooldown` mapping unless it deliberately adopts a non-default duration. The delay lets an upstream project withdraw or supersede a bad release before every consumer has a pull request open against it.
- **FR9 — Security advisories bypass the schedule.** An advisory affecting a pin raises an update on disclosure, out of band, and MUST be prioritised over scheduled currency updates.

### Review and release

- **FR10 — One reviewed pull request per update.** Each dependency update is a pull request that passes the full check suite before merge. Nothing is applied unreviewed, and no update takes a side channel around the gate.
- **FR11 — Release impact is decided separately.** The dependency updater MUST NOT choose the repository's release bump. After dependency changes are collected, the repository-wide effect is decided according to [Release Management](../release-management/spec.md).
- **FR12 — Review and merge follow the repository gate.** An update MUST pass the repository's normal review and required-check policy before merge.
- **FR13 — Automatic merge is never a bypass.** Where automatic merge is configured, it MUST preserve review requirements and required checks.
- **FR14 — Adoption covers the complete upgrade.** Each proposed upgrade MUST
  satisfy [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) from
  the consumer's actual immutable upstream baseline through its fixed target.
  Required integration actions, applicable template differences, and relevant
  consumer validation MUST be reconciled before review readiness. Missing
  evidence or a required action MUST block affected work, not become an
  optional follow-up. Before an update is eligible for automatic readiness,
  approval, or merge, verification of that evidence MUST be represented by a
  required PR check. A missing, stale, pending, or failed result MUST hold the
  update even when its other checks pass.

### Non-functional

- **NFR1 — SHA pins stay immutable.** An update to a SHA-pinned dependency rewrites the pin to the new commit SHA and records the human-readable version alongside it, so the pin stays exact and stays legible.
- **NFR2 — Update pull requests carry their evidence.** Each one includes the
  complete applicable upstream release evidence for the range it crosses,
  exact source identities, and the reconciled action/template and validation
  results required by [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md#outputs-and-evidence).
  The newest note or an updater's summary alone is insufficient; no-action
  releases remain accounted for. Equivalent authoritative external evidence
  does not need MSX formatting.
- **NFR3 — The mechanism is platform-native.** Checking, advisory correlation, and pull request creation are platform functions, not bespoke automation, so no repository maintains an updater of its own.

## Success criteria

- An outdated or vulnerable pin produces a pull request with no human trigger.
- An ecosystem added to a repository without a corresponding updater entry is a detectable finding, not a silent gap.
- The repository-wide release impact of dependency changes is decided separately under Release Management.
- No dependency pull request merges without passing the same checks as any other pull request.
- An update that skips releases still accounts for every applicable increment,
  and a no-action patch retains explicit evidence and relevant validation.
- Missing baseline, action, or applicable template evidence leaves the affected
  update blocked with a linked owning issue.
- An updater-created PR with green build checks but incomplete adoption
  evidence cannot be automatically marked ready, approved, or merged.

## Where this connects

- [Design](design.md) — the updater, review, and automatic-merge policy.
- [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) — the shared adoption procedure and complete-range evidence.
- [Release Management](../release-management/spec.md) — the separate repository-wide release decision for merged dependency changes.
- [Repository Governance](../repository-governance/spec.md) — the reconciliation that detects an uncovered ecosystem.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#keep-pinned-actions-current) — keeping pinned Actions current.
