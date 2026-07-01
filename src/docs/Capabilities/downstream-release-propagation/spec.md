---
title: Spec
description: Requirements for downstream release propagation — dependents automatically receive a reviewed pull request that applies each producer release.
---

# Downstream Release Propagation — Spec

## Premise

The ecosystem is many small repositories that depend on each other by **version
reference** — a pinned `uses:` SHA, an image digest, a deployed tag. A reference
drifts the moment the producer cuts a release. Maintaining them by hand does not
scale: missed bumps keep security fixes out of the workflows that run them, and
missed *related* changes merge a bump that then breaks at runtime. When a
producer releases, every dependent MUST automatically receive a pull request
that applies the update — and the changes it implies — for a human to review.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles.md):

- **[Everything as Code](../../Ways-of-Working/Principles.md#everything-as-code).** Propagation is a workflow in the producer, not a checklist or a calendar reminder.
- **[AI-first development](../../Ways-of-Working/Principles.md#ai-first-development).** The automation creates context and delegates the change to an agent, which opens the PR; a human reviews and merges.
- **[Least-privilege](../../Ways-of-Working/Principles.md#least-privilege).** The notification uses a narrowly scoped cross-repo token, never a broad standing credential.
- **[Written once, referenced everywhere](../../Ways-of-Working/Principles.md#dry-with-judgment).** Dependents are declared in one place in the producer; adding one is a one-line change.

## Applicability

Two shapes occur; both are the same mechanism with a different artifact:

| Shape | Producer | Dependent | What the PR changes |
| --- | --- | --- | --- |
| **Pinned reference** | A reusable workflow or action | Repos that pin it with `uses:` | The pinned SHA, with the version as a trailing comment |
| **Published artifact** | An app repo that builds a container image | The deploy repo that runs it | The deployed image tag / digest |

## Requirements

- **Automatic on stable release.** A stable producer release MUST trigger propagation to every declared dependent. Prereleases MUST NOT propagate.
- **Full context, not just a number.** Each dependent receives the new version, the immutable reference (commit SHA or image digest), the release notes, and any related-change context the update implies.
- **A PR per dependent, opened by an agent.** The mechanical work — the bump plus the fixes that make it work — is delegated to a cloud agent *in the dependent*, which opens the pull request directly. No tracking issue is created.
- **Humans decide.** A human reviews and merges each PR; the agent applies what it can safely do now and calls out larger or riskier work as follow-up.
- **Backfill on demand.** Propagation MUST be re-runnable for a specific release — for a missed event, or a dependent added after the release.

## Success criteria

- A stable release yields one PR in each declared dependent, carrying the immutable reference and an impact summary, with no manual tracking.
- A prerelease yields none.
- A dependent added after a release can be back-filled without cutting a new release.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Release Management](../release-management/spec.md) — the release this propagates.
- [Dependency Updates](../dependency-updates/spec.md) — the inbound counterpart, for external dependencies.
