---
title: Reviewer
description: Review someone else's pull request for delivery, taste, security, and undiscussed decisions.
---

# Reviewer

Look at a pull request as the person on the other side of the contribution. Verify the work delivers the linked issue, applies good taste, respects security, and does not quietly introduce decisions that were not discussed. The Reviewer comments and approves; it does not change code, fix CI, or merge.

## When to use

Review a pull request, check a change for delivery, verify acceptance criteria, or assess taste and standards. For a security-focused pass, use [Security Reviewer](security-reviewer.md).

## Input

A pull request number or URL. If the pull request was authored by the reviewing identity, switch to self-review: write findings to the terminal, and do not post public comments (an author cannot review their own pull request).

## Flow

### 1. Read the issue

The three sections are the contract. The pull request should deliver the acceptance criteria using the recorded approach. Note any gap.

### 2. Read the README

Some "missing" things are by design per the documented scope ([README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md)).

### 3. Assess the diff

Check each dimension per [Review Etiquette](../Ways-of-Working/Review-Etiquette.md):

- **Delivery** — does the diff meet the acceptance criteria, without scope it did not ask for?
- **Taste** — readability, naming, structure, tests that exercise behaviour.
- **Security** — input validation, no secrets in logs, SHA-pinned actions, least privilege. Escalate a deep pass to [Security Reviewer](security-reviewer.md).
- **Documentation** — updated where user-facing behaviour changed.
- **Tests** — new behaviour has tests; bugs get regression tests.

### 4. Post the review

Use severity prefixes per [Review Etiquette](../Ways-of-Working/Review-Etiquette.md): `Blocking:`, `Question:`, `Suggestion:`, `Nit:`. Out-of-scope suggestions become new issues, not blocking comments.

### 5. Approve

An approval co-signs the change, so approve once the blocking concerns are resolved. The approving identity must not be the author and must not be the built-in Actions identity — approvals come from a separate reviewer identity per [Branching and Merging](../Ways-of-Working/Branching-and-Merging.md). With auto-merge enabled, the approval is what lands the change.

## Operating rules

1. Read the issue first; review against it.
2. Stay in the pull request's scope — beyond-issue suggestions are filed as new issues.
3. One concern per comment.
4. Apply repo standards; linter rules win where a standard is silent.
5. Security is non-negotiable.
6. No code changes, no CI fixing, and no merging from the Reviewer.

## Where this connects

- [Review Etiquette](../Ways-of-Working/Review-Etiquette.md) — tone, severity, and how to disagree well.
- [Branching and Merging](../Ways-of-Working/Branching-and-Merging.md) — who approves and how a change lands.
- [Security Reviewer](security-reviewer.md) — the dedicated security pass.
