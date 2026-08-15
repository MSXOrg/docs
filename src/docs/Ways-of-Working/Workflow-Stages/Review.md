---
title: Review
description: Procedure for the Workflow stage that independently reviews a pull request for delivery, taste, security, and decisions.
---

# Review

Review is the independent-assessment stage of the canonical [Workflow](../Workflow.md). It verifies that a pull request delivers its closing Task or Bug, applies good taste, respects security, and does not quietly introduce decisions that were not discussed. This stage comments and approves; it does not change code, fix CI, or merge.

## Enter this stage when

Review a pull request, check a change for delivery, verify acceptance criteria, or assess taste and standards. For a security-focused pass, enter [Security Review](Security-Review.md).

## Input

A pull request number or URL. If the pull request was authored by the reviewing identity, switch to self-review: write findings to the terminal, and do not post public comments (an author cannot review their own pull request).

## Flow

### 1. Read the delivery issue

Confirm the pull request closes one scoped Task or Bug delivery leaf, then review against that leaf's acceptance criteria, decisions, and plan. Parent PBI or Epic links provide context but do not expand the pull request's scope or close the aggregate. Additional closing links are valid only when the [issue convergence sweep](Implement.md#6-issue-convergence-sweep) shows the diff fully satisfies those issues.

### 2. Read the README

Some "missing" things are by design per the documented scope ([README-Driven Context](../Readme-Driven-Context.md)).

### 3. Assess the diff

Check each dimension per [Review Etiquette](../Review-Etiquette.md):

- **Delivery** — does the diff meet the acceptance criteria, without scope it did not ask for?
- **Taste** — readability, naming, structure, tests that exercise behaviour.
- **Security** — input validation, no secrets in logs, external action and reusable-workflow references pinned to full commit SHAs, owned major-tag references meeting the controlled-release exception, and least privilege. Escalate a deep pass to [Security Review](Security-Review.md).
- **Documentation** — updated where user-facing behaviour changed.
- **Standards and framework alignment** — the pull request records the author's [alignment pass](Implement.md#5-standards-and-framework-alignment-pass), the result covers every changed surface, and each exception links a real follow-up issue. Spot-check at least one row against the canonical standard or framework page rather than trusting the summary; a missing or hollow pass is a blocking finding.
- **Issue convergence sweep** — the pull request records the author's [sweep](Implement.md#6-issue-convergence-sweep), including scoped search coverage and any convergent issues linked with closing keywords. Spot-check at least one linked closing issue against the delivered diff; a claimed convergence with no visible delivery evidence is a blocking finding.
- **Tests** — new behaviour has tests; bugs get regression tests.

### 4. Post the review

Use severity prefixes per [Review Etiquette](../Review-Etiquette.md): `Blocking:`, `Question:`, `Suggestion:`, `Nit:`. Out-of-scope suggestions become new issues, not blocking comments.

### 5. Approve

An approval co-signs the change, so approve once the blocking concerns are resolved. The approving identity must not be the author and must not be the built-in Actions identity — approvals come from a separate reviewer identity per [Branching and Merging](../Branching-and-Merging.md). With auto-merge enabled, the approval is what lands the change.

## Operating rules

1. Read the issue first; review against it.
2. Stay in the pull request's scope — beyond-issue suggestions are filed as new issues.
3. One concern per comment.
4. Apply repo standards; linter rules win where a standard is silent.
5. Security is non-negotiable.
6. No code changes, CI fixes, or merging in the Review stage; required changes return to [Implement](Implement.md).

## Where this connects

- [Review Etiquette](../Review-Etiquette.md) — tone, severity, and how to disagree well.
- [Implement](Implement.md#5-standards-and-framework-alignment-pass) and [Implement](Implement.md#6-issue-convergence-sweep) — the author-side session-end passes this stage verifies.
- [PR Format](../PR-Format.md) — delivery-leaf closure and contextual aggregate links.
- [Branching and Merging](../Branching-and-Merging.md) — who approves and how a change lands.
- [Security Review](Security-Review.md) — the specialized security path.
