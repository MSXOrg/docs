---
title: Spec
description: Required status checks and repository rulesets govern automated approval and merge without bypasses.
---

# Merge Automation — Spec

## Premise

Required status checks determine whether a pull request can merge.
For an eligible, routine change, a passing result SHOULD trigger automated merge
without manual status inspection.
Every merge-blocking pipeline publishes a **named status check**.
A repository **ruleset** requires it.

Automation reads the combined required-check result. It merges eligible pull
requests when all required checks pass. Otherwise, it holds the pull request and
signals that more work is needed. The checks are the contract.
Automation reads this contract and MUST NOT bypass a failing, pending, or missing
required check.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Version-controlled ruleset configuration defines which checks gate merge. The gate does not depend on reviewer memory.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The required checks record the decision. A passing result permits merge for an eligible change. A failing result withholds it.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The automation has only the scopes it needs to read status and record its decision. It has no unused repository-write scope.

## Scope

This capability covers repositories whose merge readiness can be determined by
checks, including applications, libraries, Actions, and infrastructure modules.
The **signal** is the set of required status checks on the pull request.
The **actor** is the automation (a GitHub App or equivalent) that reads them.
Ruleset configuration defines *which* checks gate merge. This capability turns
that configured decision into action.

## Requirements

- **Every merge-blocking pipeline surfaces a named status check.** A pipeline that reports only in logs or comments cannot block a pull request. See [Gate merges with a named status check](../../Coding-Standards/GitHub-Actions.md#gate-merges-with-a-named-status-check) for authoring them.
- **The gate is enforced by a ruleset.** A ruleset (or branch protection) lists the required checks by their exact name or context. An unlisted check is advisory and cannot block a pull request. The ruleset enforces the gate.
- **Automation acts only on the signal.** For a pull request in the eligible set, all required checks passing MUST permit automated approval and merge. Any failed or pending result MUST hold it. The automation reads status, not the diff.
- **No bypass.** Automation MUST NOT merge a pull request whose required checks are failing, pending, or absent. Its holds are stricter than a human reviewer's, never weaker.
- **Human-required changes are never auto-merged.** Breaking changes and changes that policy marks for review require human approval even when all required checks pass. This matches the dependency-update policy for major bumps.
- **Least-privilege.** The automation has only status/checks **read** plus the minimum write scope to record its decision (approve, or enable native auto-merge). It uses the platform's own auto-merge instead of performing the merge itself when that suffices.

## Success criteria

- A pull request whose required checks all pass, and that is in the eligible set, is approved and merged with no human action.
- A pull request with a failing, pending, or missing required check is held, and the reason is visible on the pull request.
- No pull request ever merges with a required check failing, pending, or absent.

## Where this connects

- [Design](design.md) — the mechanisms, the ruleset, and the automation that deliver this.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#gate-merges-with-a-named-status-check) — authoring the named checks this consumes.
- [Dependency Updates](../dependency-updates/spec.md) — the auto-merge policy this generalizes. Dependency update PRs are the canonical eligible set.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — pull-request-only integration and the green-before-review rule.
- [Review Etiquette](../../Ways-of-Working/Review-Etiquette.md) — where human judgment still applies.
