---
title: Define
description: Capture, refine, and plan a change into an actionable issue ready for implementation.
---

# Define

Take something someone wants — a feature, a bug, an improvement, external feedback, or a production signal — and turn it into a planned, actionable issue. The output is either a single Task with its three sections populated, or a decomposed initiative with structured sub-issues. Define plans work; it does not build it.

## When to use

Capture a desire for change, write an issue, plan work, decompose an epic, refine a bug report, create sub-issues, structure a feature request, or turn feedback into a task.

## Input

A description of a desired change, a feedback issue from a non-contributor (treated as input, never modified), a platform signal (error, failed run, alert), or an existing issue to refine.

## Flow

### 1. Capture

Turn the input into an issue with Section 1 (context and request).

1. Search for duplicates first — propose consolidation rather than creating a new issue.
2. Frame from the user's perspective per [Issue Format](../Ways-of-Working/Issue-Format.md).
3. Acceptance criteria must be user-observable and testable.

### 2. Refine

Ground the issue so anyone reading it agrees on what "done" means, up to the [Definition of Ready](../Ways-of-Working/Definition-of-Ready-and-Done.md).

1. Pain before solution — push back on implementation-framed requests.
2. Make assumptions explicit.
3. Acceptance criteria answerable yes or no by a non-author.
4. Ask one question at a time when interactive.

### 3. Plan

Decide how the work will happen and record the decisions.

1. **Task** — one deliverable, one pull request. Populate the technical decisions and the implementation plan per [Issue Format](../Ways-of-Working/Issue-Format.md).
2. **Larger work** — decompose into child issues per [Issue Hierarchy](../Ways-of-Working/Issue-Hierarchy.md).
3. Find the minimum viable path — spike, then proof of concept, then minimum viable product, then improve.
4. Record decisions with their rationale and the alternatives considered.
5. Resolve open questions before finishing; defer anything that does not block this slice to a follow-up issue.

## Operating rules

1. Tone is impersonal. The issue description is the source of truth; comments record what changed.
2. External references are hyperlinks.
3. Do not modify a feedback issue from a non-contributor — create an internal issue and cross-link.
4. Stop when the issue is plannable. Do not build, branch, or open pull requests — that is [Implement](implement.md).

## Where this connects

- [Workflow](../Ways-of-Working/Workflow.md) — the loop this opens.
- [Issue Format](../Ways-of-Working/Issue-Format.md) and [Issue Hierarchy](../Ways-of-Working/Issue-Hierarchy.md) — issue structure and levels.
- [Definition of Ready and Done](../Ways-of-Working/Definition-of-Ready-and-Done.md) — the readiness bar this aims for.
