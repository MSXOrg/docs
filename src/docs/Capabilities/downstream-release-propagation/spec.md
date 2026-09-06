---
title: Spec
description: Requirements for downstream release propagation — each dependent receives an upgrade pull request or an evidenced no-upgrade outcome.
---

# Downstream Release Propagation — Spec

## Premise

The ecosystem is many small repositories that depend on each other by **version
reference** — a pinned `uses:` SHA, an image digest, a deployed tag. A reference
drifts the moment the producer cuts a release. Maintaining them by hand does not
scale: missed bumps keep security fixes out of the workflows that run them, and
missed *related* changes merge a bump that then breaks at runtime. When a
producer releases, every dependent MUST be assessed for an upgrade. A needed
upgrade produces a pull request applying the update and its related changes
for human review; an already-current or superseded target produces an evidenced
no-upgrade outcome instead.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Propagation is a workflow in the producer, not a checklist or a calendar reminder.
- **[AI-first development](../../Ways-of-Working/Principles/AI-First-Development.md).** The automation creates context and delegates the change to an agent, which opens the PR; a human reviews and merges.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The notification uses a narrowly scoped cross-repo token, never a broad standing credential.
- **[Written once, referenced everywhere](../../Ways-of-Working/Principles/Software-Design.md#dry-with-judgment).** Dependents are declared in one place in the producer; adding one is a one-line change.

## Applicability

Two shapes occur; both are the same mechanism with a different artifact:

| Shape | Producer | Dependent | What the PR changes |
| --- | --- | --- | --- |
| **Pinned reference** | A reusable workflow or action | Repos that pin it with `uses:` | The pinned SHA, with the version as a trailing comment |
| **Published artifact** | An app repo that builds a container image | The deploy repo that runs it | The deployed image tag / digest |

## Requirements

- **Automatic on stable release.** A stable producer release MUST trigger propagation to every declared dependent. Prereleases MUST NOT propagate.
- **Full context, not just a number.** Each dependent receives the new version, the immutable reference (commit SHA or image digest), the release notes, and any related-change context the update implies.
- **Complete consumer-range adoption.** Each dependent MUST follow
  [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) from its actual
  consumed upstream baseline to the propagated target. The received note MUST
  retain the complete source-bound release record, but it is only one input:
  it MUST NOT replace inspection of every applicable release the consumer
  crosses, its composed actions, or its target-template comparison.
- **A pull request per needed upgrade, opened by an agent.** The mechanical work — the bump plus the fixes that make it work — is delegated to a cloud agent *in the dependent*, which opens the pull request when qualification establishes an actual upgrade. **How** the agent is engaged is a design choice, not a requirement: the spec requires delegation and a pull request for the repository change, not a particular delegation mechanism.
- **A delivery leaf before the pull request.** The dependent MUST create or reuse
  a Task or Bug for the producer version before the agent opens its pull request.
  The leaf carries the executable local plan and acceptance criteria required by
  the [Definition of Ready](../../Ways-of-Working/Definition-of-Ready-and-Done.md#delivery-leaf-readiness),
  and the pull request closes exactly that leaf.
- **Idempotent by identity.** Propagation MUST be safe to run more than once for
  the same producer version. A repeated run reuses the existing delivery Task or
  Bug and MUST NOT open a second pull request for it.
- **Humans decide.** A human reviews and merges each PR. Missing provenance,
  release/action evidence, applicable template compatibility, or required
  validation MUST leave affected work blocked with an owning issue. Larger
  or riskier required work MUST NOT be treated as an optional follow-up to an
  otherwise ready reference bump.
- **Backfill on demand.** Propagation MUST be re-runnable for a specific release — for a missed event, or a dependent added after the release. Backfill uses the same idempotency, so re-running for an already-propagated dependent is a no-op rather than a duplicate.
- **A fixed target, not an implicit downgrade.** A delayed notification or
  backfill MUST retain its selected target rather than substitute the newest
  release. If it is no longer an upgrade from the consumer's actual baseline,
  record that outcome; propagation MUST NOT downgrade the consumer.
- **No-upgrade is a terminal outcome, not an empty PR.** Qualification MUST
  record the proven baseline, target, and comparison evidence in the delivery
  issue before repository changes begin. When no upgrade or other local
  acceptance work remains, close an unneeded open leaf as **not planned** with
  that reason; do not claim a shipped implementation or create an empty PR.
  Preserve existing closed records on repeat notifications. An existing PR or
  unmet local criterion requires scope reconciliation, not automatic
  cancellation from a version comparison alone.

## Success criteria

- A stable release yields one pull request in each dependent needing an upgrade,
  carrying the immutable reference and an impact summary without manual
  coordination; other dependents retain an evidenced no-upgrade outcome.
- A prerelease yields none.
- Running propagation twice for the same version reuses the same delivery
  record and, when an upgrade is needed, the same pull request rather than a duplicate.
- A dependent added after a release can be back-filled without cutting a new release.
- A dependent that skipped releases carries complete applicable range evidence,
  reconciled actions, and immutable target-template evidence or a justified
  no-template result; a missing required fact blocks readiness.
- Successful notification or reuse of an issue does not claim consumer
  completion; review, merge, and applicable publication/template obligations
  remain distinct.
- An equal or lower target creates no empty PR, and any unneeded open delivery
  issue has an explicit no-upgrade disposition rather than remaining in progress.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md) — the per-dependent adoption procedure, including historical targets and stop conditions.
- [Release Management](../release-management/spec.md) — the release this propagates.
- [Dependency Updates](../dependency-updates/spec.md) — the inbound counterpart, for external dependencies.
- [Issue Hierarchy](../../Ways-of-Working/Issues/Types/Hierarchy.md) and [PR Format](../../Ways-of-Working/PR-Format.md) — the delivery leaf and closure rules this automation follows.
