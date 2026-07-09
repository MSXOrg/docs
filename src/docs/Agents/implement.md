---
title: Implement
description: Take a planned issue and deliver it as a review-ready pull request — branch, build, self-review, and finalize.
---

# Implement

Take a planned issue and deliver working software in a review-ready pull request. Owns the full delivery loop: branching, coding, committing, opening the pull request, tracking progress, running the automated review loop, responding to feedback, and finalizing the release note. Implement builds; it does not plan from scratch or review others' work.

## When to use

Implement an issue, build a feature, fix a bug, create a branch, open a pull request, respond to review feedback, or finalize a pull request. Given an initiative rather than a task, pick the next unfinished sub-issue.

## Input

A Task issue number or URL with its three sections populated.

## Flow

### 1. Orient

1. Read the issue fully — all three sections per [Issue Format](../Ways-of-Working/Issue-Format.md).
2. Read the repository README first per [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md).
3. Identify the stack and load the relevant [Coding Standards](../Coding-Standards/index.md). Repo-local linter config wins where it disagrees with a published standard.

### 2. Branch and draft pull request

Use [git worktrees](../Ways-of-Working/Git-Worktrees.md) for every issue.

1. Create a worktree from the default branch per [Branching and Merging](../Ways-of-Working/Branching-and-Merging.md).
2. Push an initial commit and immediately open a **draft** pull request so CI attaches from the first push.
3. Link the issue with a closing keyword, and assign the pull request.

### 3. Build

For each task in the plan:

1. Implement the change and self-review the staged diff.
2. Commit per [Commit Conventions](../Ways-of-Working/Commit-Conventions.md) — one logical change per commit.
3. Update the issue as each task completes — do not batch.
4. Push regularly so CI runs against current work.

When the plan is wrong, stop and document the conflict in a comment, then update the plan before resuming. Out-of-scope problems go to [Define](define.md).

### 4. Self-review and respond

1. Run the [Copilot review loop](../Ways-of-Working/Contribution-Workflow.md#the-copilot-review-loop) until it reports a clean round.
2. Triage each thread and CI failure per [Review Etiquette](../Ways-of-Working/Review-Etiquette.md): fix in scope and propagate the same fix elsewhere; file a follow-up for out-of-scope; reply, then resolve.

### 5. Finalize and hand off

When the change meets the [Definition of Ready for Review](../Ways-of-Working/Definition-of-Ready-and-Done.md):

1. Finalize the title, release-note description, and label per [PR Format](../Ways-of-Working/PR-Format.md).
2. Mark the pull request ready and enable auto-merge per [Branching and Merging](../Ways-of-Working/Branching-and-Merging.md).

## Operating rules

1. Micro-commits, one logical change each, with descriptive messages.
2. Progress is visible — issues updated as tasks complete, not in bulk.
3. Draft pull request from the start; stay in the issue's scope.
4. Mark ready only when the change meets the Definition of Ready for Review — never with open tasks.
5. No planning from scratch (that is [Define](define.md)); no reviewing others' pull requests (that is [Reviewer](reviewer.md)).

## Where this connects

- [Contribution Workflow](../Ways-of-Working/Contribution-Workflow.md) — the draft-first loop this runs.
- [Definition of Ready and Done](../Ways-of-Working/Definition-of-Ready-and-Done.md) — the gate this hands off at.
- [PR Format](../Ways-of-Working/PR-Format.md) and [Branching and Merging](../Ways-of-Working/Branching-and-Merging.md) — packaging and landing.
