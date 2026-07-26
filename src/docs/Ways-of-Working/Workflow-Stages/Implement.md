---
title: Implement
description: Procedure for the Workflow stage that delivers one ready Task or Bug as a review-ready pull request.
---

# Implement

Implement is the delivery stage of the canonical [Workflow](../Workflow.md). It takes one ready, unblocked Task or Bug and produces working software in a review-ready pull request. The stage owns branching, coding, committing, opening the pull request, tracking progress, running the automated review loop, responding to feedback, and finalizing the release note. Implement builds delivery leaves; it does not implement an Epic or PBI aggregate, plan from scratch, or supply the independent review.

## Enter this stage when

Implement a Task, fix a Bug, create a branch, open a pull request, respond to review feedback, or finalize a pull request. Given an Initiative, Epic, or PBI, follow native containment and blocked-by relationships to a ready delivery leaf; do not treat list order as execution order.

## Input

A ready repository-delivery Task or Bug number or URL. An operational Task follows its canonical [operational delivery path](../Issues/Types/Task.md#operational-delivery) instead of this pull-request flow.

## Flow

### 1. Orient

1. Read the delivery issue fully, including its type-specific body, native parent, and dependency edges.
2. Read the repository README first per [README-Driven Context](../Readme-Driven-Context.md).
3. Identify the stack and load the relevant [Coding Standards](../../Coding-Standards/index.md). Repo-local linter config wins where it disagrees with a published standard.

### 2. Branch and draft pull request

Use [git worktrees](../Git-Worktrees.md) for every repository-delivery Task or Bug.

1. Create a worktree from the default branch per [Branching and Merging](../Branching-and-Merging.md).
2. Push an initial commit and immediately open a **draft** pull request so CI attaches from the first push.
3. Close exactly that Task or Bug in the pull request. Reference a parent PBI or Epic only as non-closing context, then assign the pull request.

### 3. Build

For each step in the delivery plan:

1. Implement the change and self-review the staged diff.
2. Commit per [Commit Conventions](../Commit-Conventions.md) — one logical change per commit.
3. Update the issue as each plan step completes — do not batch.
4. Push regularly so CI runs against current work.

When the plan is wrong, stop and document the conflict in a comment, then update the plan before resuming. Out-of-scope problems go to [Define](Define.md).

### 4. Self-review and respond

1. Run the [Copilot review loop](../Contribution-Workflow.md#the-copilot-review-loop) until it reports a clean round.
2. Triage each thread and CI failure per [Review Etiquette](../Review-Etiquette.md): fix in scope and propagate the same fix elsewhere; file a follow-up for out-of-scope; reply, then resolve.

### 5. Finalize and hand off

When the change meets the [Definition of Ready for Review](../Definition-of-Ready-and-Done.md):

1. Finalize the title, release-note description, and label per [PR Format](../PR-Format.md).
2. Mark the pull request ready and enable auto-merge per [Branching and Merging](../Branching-and-Merging.md).

## Operating rules

1. Micro-commits, one logical change each, with descriptive messages.
2. Progress is visible — the delivery issue is updated as plan steps complete, not in bulk.
3. Draft pull request from the start; stay in the issue's scope.
4. Mark ready only when the change meets the Definition of Ready for Review — never with open plan steps.
5. Return unplanned work to [Define](Define.md) and hand review-ready work to [Review](Review.md).

## Where this connects

- [Contribution Workflow](../Contribution-Workflow.md) — the draft-first loop this runs.
- [Issue Lifecycle](../Issues/Process/Lifecycle.md) and [Issue Relationships](../Issues/Process/Relationships.md) — delivery-leaf eligibility and blockers.
- [Definition of Ready and Done](../Definition-of-Ready-and-Done.md) — the gate this hands off at.
- [PR Format](../PR-Format.md) and [Branching and Merging](../Branching-and-Merging.md) — packaging and landing.
