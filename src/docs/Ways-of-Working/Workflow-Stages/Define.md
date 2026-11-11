---
title: Define
description: Procedure for the Workflow stage that captures, routes, refines, and plans work at the correct issue altitude.
---

# Define

Define is the first stage of the canonical [Workflow](../Workflow.md). It records a requested change and assigns the correct native issue type. Inputs include feature requests, bugs, improvements, external feedback, and production signals. The output is an Epic or PBI ready for coordination and decomposition, or a Task or Bug ready for delivery. Define plans work; it does not build it.

## Enter this stage when

Capture a desire for change, write an issue, plan work, decompose an epic, refine a bug report, create sub-issues, structure a feature request, or turn feedback into a task.

## Input

Input is a desired change, a feedback issue from a non-contributor, a platform signal, or an existing issue to refine. Platform signals include errors, failed runs, and alerts. Treat non-contributor feedback issues as input; never modify them.

## Flow

### 1. Capture

Turn the input into an issue with a provisional native type and enough local context to refine it.

1. Search for duplicates first. If a duplicate exists, propose consolidation instead of another issue.
2. Follow the universal [Issue Format](../Issues/Process/Format.md) and the selected type page for its body.
3. Acceptance criteria must be user-observable and testable.

### 2. Refine

Refine the problem and expected result until the issue meets the [Definition of Ready](../Definition-of-Ready-and-Done.md).

1. Identify the problem before you select a solution. Challenge requests that prescribe implementation without a stated problem.
2. Make assumptions explicit.
3. Make each acceptance criterion answerable yes or no by a non-author.
4. Ask one question at a time when interactive.

### 3. Plan

Separate consumer expectations from delivery planning at the canonical [issue planning altitude](../Issues/Process/Planning.md).

1. Route the work through the [Issue Hierarchy](../Issues/Types/Hierarchy.md); do not infer altitude from effort, priority, or a legacy label.
2. For an Epic or PBI, apply the [consumer-expectation rule](../Issues/Process/Planning.md#consumer-expectations), establish native containment and dependency relationships, and refine the first required children to their own readiness gates.
3. For a Task or Bug, retain technical decisions and produce one test-first executable delivery plan sized for one pull request, including relevant design and documentation verification. Use the audited operational Task path only when no repository artifact exists.
4. Select the minimum viable path: spike, proof of concept, minimum viable product, then improvements.
5. Keep durable technical choices in the design and per-change decisions in delivery leaves; link those artifacts from aggregates rather than prescribing their implementation.
6. Resolve open questions before finishing; defer anything that does not block this slice to a follow-up issue.

## Operating rules

1. Tone is impersonal. The issue description is the source of truth; comments record what changed.
2. External references are hyperlinks.
3. Do not modify a feedback issue from a non-contributor — create an internal issue and cross-link.
4. Stop when the issue meets the readiness gate for its altitude. Hand a ready delivery leaf to the [Implement stage](Implement.md); do not build, branch, or open pull requests here.

## Where this connects

- [Workflow](../Workflow.md) — the process whose first stage this procedure defines.
- [Issue Format](../Issues/Process/Format.md), [Issue Planning](../Issues/Process/Planning.md), [Issue Relationships](../Issues/Process/Relationships.md), and [Issue Hierarchy](../Issues/Types/Hierarchy.md) — canonical issue ownership.
- [Definition of Ready and Done](../Definition-of-Ready-and-Done.md) — the readiness gate for the resulting issue.
