---
title: Spec
description: Requirements for dependency updates — pinned dependencies kept current and secure through reviewed, released update pull requests.
---

# Dependency Updates — Spec

## Premise

Repositories pin dependencies with Action SHAs, image digests, package versions,
and provider constraints. A pinned version can contain a defect that a later
upstream version corrects. It can also contain a known vulnerability.

Dependency updates MUST run automatically on the GitHub platform. Each update
produces an ordinary pull request that follows the repository's review gate.
When the target route invokes Release Management, that capability resolves its
release decision and publication path separately from the updater. A route
without that invocation carries no `release:*` metadata.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Version-controlled configuration defines the dependency checks and their frequency.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** Every update is a pull request. Its review gate approves the dependency change separately from any applicable release decision.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The updater and any auto-merge automation have only the permissions they need.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** An additional package ecosystem uses a configuration entry, not a separate updater.

## Scope

This capability covers repositories that pin external dependencies. These include
Action and workflow SHAs, container base images, language packages and lockfiles,
and manifests for other ecosystems in use. Each pin has two checks:
**currency** (whether a newer version is available) and **security** (whether a
known advisory affects the pinned version).

Dependency adoption includes the required integration changes, not only the
reference change. Selecting and publishing the consumer repository's own
release remains out of scope. Where the target route invokes
[Release Management](../release-management/spec.md), that capability governs
the release decision and output.

## Requirements

### Coverage

- **FR1 — Every ecosystem present is classified.** Coverage MUST be derived from
  the manifests the repository actually contains. Each detected ecosystem MUST
  either be supported by the platform-native updater or have a centrally managed
  exception. An unclassified manifest indicates a coverage gap.
- **FR2 — Native support is configured.** Every detected ecosystem in the
  centrally maintained native-support catalog MUST have an updater entry for
  the directory its manifest governs.
- **FR3 — Unsupported ecosystems use a central exception.** The centrally managed
  exception register MUST record each unsupported ecosystem with its manifest,
  scope, reason, owner, and shared update mechanism.
  A repository MUST NOT create or maintain a repository-specific updater.
- **FR4 — Coverage is verifiable, not asserted.** The manifest inventory MUST
  support comparison with the configured native ecosystems and central exception
  register. This comparison makes coverage gaps detectable.
- **FR5 — Native configuration is generated, not hand-maintained.** Native
  updater configuration SHOULD be produced from supported manifests rather than
  written by hand. Generation uses the supported manifests as its source.
  A manually maintained configuration can omit an additional supported ecosystem.

### Cadence

- **FR6 — Currency is checked on a schedule.** Scheduled checks detect upstream versions without a human trigger.
- **FR7 — The schedule is configuration.** The schedule frequency and timezone MUST be configurable per organization. Each organization selects a cadence that matches consumer release needs. The timezone determines when update proposals arrive relative to working hours.
- **FR8 — Freshly published versions wait three days.** A version MUST NOT be proposed immediately after publication. The organization standard is a three-day cooldown. A repository MUST omit an explicit `cooldown` mapping unless it deliberately adopts a non-default duration. The delay gives the upstream project time to withdraw or replace a defective release before update proposals reach consumers.
- **FR9 — Security advisories bypass the schedule.** An advisory affecting a pin raises an update on disclosure, outside the schedule. The update MUST be prioritized over scheduled currency updates.

### Review and release

- **FR10 — One reviewed pull request per update.** Each dependency update has a pull request that stays draft until the normal review-readiness gate holds. It passes the full check suite before merge. No update bypasses review.
- **FR11 — Release decisions stay independent.** The dependency updater MUST NOT choose the repository's release bump or apply `release:*` labels. After dependency changes are collected, [Release Management](../release-management/spec.md) decides the repository-wide effect only when the target route invokes it.
- **FR12 — Review and merge follow the repository gate.** An update MUST pass the repository's normal review and required-check policy before merge.
- **FR13 — Automatic merge is never a bypass.** Where automatic merge is configured, it MUST preserve review requirements and required checks.
- **FR14 — Adoption covers the complete upgrade.** Each proposed upgrade MUST
  satisfy [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) from
  the consumer's actual immutable upstream baseline through its fixed target.
  The author or delegated agent MUST reconcile required integration actions,
  applicable template differences, and relevant consumer validation before review
  readiness. Missing evidence or a required action MUST block affected work, not
  become an optional follow-up. A required PR check MUST report the
  evidence-verification result before the update is eligible for automatic
  readiness, approval, or merge.
  A missing, stale, pending, or failed result MUST hold the
  update even when its other checks pass.

### Non-functional

- **NFR1 — SHA pins stay immutable.** A SHA-pinned update uses the target commit SHA and records its human-readable version alongside it. The SHA identifies the exact source. The version makes the pin readable.
- **NFR2 — Update pull requests carry their evidence.** Each one includes the
  complete applicable upstream release evidence for the range it crosses,
  exact source identities, and reconciled action/template and validation results.
  [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md#outputs-and-evidence)
  defines that evidence. The newest note or an updater's summary alone is
  insufficient. The evidence accounts for no-action releases too.
  Equivalent authoritative external evidence
  does not need MSX formatting.
- **NFR3 — The mechanism is platform-native.** The platform checks versions, correlates advisories, and creates pull requests. No repository maintains a separate updater.

## Success criteria

- An outdated or vulnerable pin produces a pull request with no human trigger.
- An ecosystem added to a repository without a corresponding updater entry is a detectable finding, not a silent gap.
- When the target route invokes Release Management, the repository-wide release decision for dependency changes is resolved separately under that capability.
- No dependency pull request merges without passing the same checks as any other pull request.
- An update that skips releases accounts for every applicable increment,
  and a no-action patch retains explicit evidence and relevant validation.
- Missing baseline, action, or applicable template evidence leaves the affected
  update blocked with a linked owning issue.
- An updater-created PR with passing build checks but incomplete adoption
  evidence cannot be automatically marked ready, approved, or merged.

## Where this connects

- [Design](design.md) — the updater, review, and automatic-merge policy.
- [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) — the shared adoption procedure and complete-range evidence.
- [Release Management](../release-management/spec.md) — the conditional, separate repository-wide release decision for merged dependency changes.
- [Repository Governance](../repository-governance/spec.md) — the reconciliation that detects an uncovered ecosystem.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#keep-pinned-actions-current) — keeping pinned Actions current.
