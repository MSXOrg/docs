---
title: Define Stage
description: The workflow stage that captures, routes, refines, and plans work at the correct issue altitude.
---

# Define Stage

Define is the first stage of the [Agent Workflow](index.md). It takes something someone wants — a feature, a bug, an improvement, external feedback, or a production signal — and routes it to the correct native issue type. The stage hands off an Epic or PBI ready to coordinate and decompose, or a Task or Bug ready for delivery. Define plans work; it does not build it.

## Enter this stage when

Capture a desire for change, write an issue, plan work, decompose an epic, refine a bug report, create sub-issues, structure a feature request, or turn feedback into a task.

## Input

A description of a desired change, a feedback issue from a non-contributor (treated as input, never modified), a platform signal (error, failed run, alert), or an existing issue to refine.

## Flow

### 1. Capture

Turn the input into an issue with a provisional native type and enough local context to refine it.

1. Search for duplicates first — propose consolidation rather than creating a new issue.
2. Follow the universal [Issue Format](../Ways-of-Working/Issues/Process/Format.md) and the selected type page for its body.
3. Acceptance criteria must be user-observable and testable.

### 2. Refine

Ground the issue so anyone reading it agrees on what "done" means, up to the [Definition of Ready](../Ways-of-Working/Definition-of-Ready-and-Done.md).

1. Pain before solution — push back on implementation-framed requests.
2. Make assumptions explicit.
3. Acceptance criteria answerable yes or no by a non-author.
4. Ask one question at a time when interactive.

### 3. Plan

Decide how the work will happen and record the decisions.

1. Route the work through the [Issue Hierarchy](../Ways-of-Working/Issues/Types/Hierarchy.md); do not infer altitude from effort, priority, or a legacy label.
2. For an Epic or PBI, establish native containment and dependency relationships and refine the first required children to their own readiness gates.
3. For a Task or Bug, produce one executable delivery plan sized for one pull request. Use the audited operational Task path only when no repository artifact exists.
4. Find the minimum viable path — spike, then proof of concept, then minimum viable product, then improve.
5. Record decisions at the issue's [planning altitude](../Ways-of-Working/Issues/Process/Planning.md), with rationale and alternatives where they matter.
6. Resolve open questions before finishing; defer anything that does not block this slice to a follow-up issue.

## Operating rules

1. Tone is impersonal. The issue description is the source of truth; comments record what changed.
2. External references are hyperlinks.
3. Do not modify a feedback issue from a non-contributor — create an internal issue and cross-link.
4. Stop when the issue meets the readiness gate for its altitude. Hand a ready delivery leaf to the [Implement stage](implement.md); do not build, branch, or open pull requests here.

## Where this connects

- [Workflow](../Ways-of-Working/Workflow.md) — the loop this opens.
- [Issue Format](../Ways-of-Working/Issues/Process/Format.md), [Issue Planning](../Ways-of-Working/Issues/Process/Planning.md), [Issue Relationships](../Ways-of-Working/Issues/Process/Relationships.md), and [Issue Hierarchy](../Ways-of-Working/Issues/Types/Hierarchy.md) — canonical issue ownership.
- [Definition of Ready and Done](../Ways-of-Working/Definition-of-Ready-and-Done.md) — the readiness bar this aims for.
