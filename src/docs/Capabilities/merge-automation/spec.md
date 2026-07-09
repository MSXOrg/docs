---
title: Spec
description: Requirements for merge automation — required status checks as the signal, a ruleset that enforces them, and automation that merges on green and holds on red without bypassing the gate.
---

# Merge Automation — Spec

## Premise

Whether a pull request is ready to merge is a question with a definite answer:
do all the checks that must pass, pass? For an eligible, routine change that
answer SHOULD drive the merge, not wait on a person to notice a green tick. Every
pipeline that must hold a pull request publishes a **named status check**; a
repository **ruleset** requires it; automation reads the combined result and
acts — merging when the required checks are green, holding and signalling that
more work is needed when they are not. The checks are the contract. Automation
only reads them and MUST NOT merge around a failing, pending, or missing required
check.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Which checks gate merge is version-controlled ruleset configuration, not reviewer memory or tribal knowledge.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The required checks encode the decision: a green result is the approval to merge, a red one withholds it.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The automation carries only the scopes it needs to read status and record its decision — never broad repository write it does not use.

## Scope

Any repository where merge readiness can be decided by checks — an application, a
library, an Action, an infrastructure module. The **signal** is the set of
required status checks on the pull request; the **actor** is the automation (a
GitHub App or equivalent) that reads them. Deciding *which* checks gate merge is
ruleset configuration; this capability is about turning that decision into
action.

## Requirements

- **Every merge-blocking pipeline surfaces a named status check.** A run that only writes to the log or a comment cannot hold a pull request. See [Gate merges with a named status check](../../Coding-Standards/GitHub-Actions.md#gate-merges-with-a-named-status-check) for authoring them.
- **The gate is enforced by a ruleset.** A ruleset (or branch protection) lists the required checks by their exact name or context. Enforcement is configuration, never convention — an unlisted check is advisory and cannot hold a pull request.
- **Automation acts only on the signal.** All required checks green MUST make the pull request eligible for automated approval and merge; any red or pending result MUST hold it. The automation reads status; it does not judge the diff.
- **No bypass.** Automation MUST NOT merge a pull request whose required checks are failing, pending, or absent. It holds strictly more than a human would, never less.
- **Human-required changes are never auto-merged.** Changes outside the eligible set — breaking changes, or those a policy marks for review — require a human approval regardless of a green result, mirroring the dependency-update policy for major bumps.
- **Least-privilege.** The automation carries only status/checks **read** plus the minimum write scope to record its decision (approve, or enable native auto-merge). It does not perform the merge itself where the platform's own auto-merge suffices.

## Success criteria

- A pull request whose required checks all pass, and that is in the eligible set, is approved and merged with no human action.
- A pull request with a failing or missing required check is held, and the reason is visible on the pull request.
- No pull request ever merges with a required check failing, pending, or absent.

## Where this connects

- [Design](design.md) — the mechanisms, the ruleset, and the automation that deliver this.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#gate-merges-with-a-named-status-check) — authoring the named checks this consumes.
- [Dependency Updates](../dependency-updates/spec.md) — the auto-merge policy this generalises; dependency update PRs are the canonical eligible set.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — pull-request-only integration and the green-before-review rule.
- [Review Etiquette](../../Ways-of-Working/Review-Etiquette.md) — where human judgment still applies.
