---
title: Task
description: One implementation-ready planned deliverable completed by one pull request or one audited operation.
---

# Task

A Task is the native issue type for one planned delivery leaf. It owns one independently verifiable deliverable and does not aggregate implementation sub-issues.

Repository work follows one Task, one branch, and one reviewable pull request. Work that has several independently deliverable pull requests is a [PBI](PBI.md).

## Issue body

Follow the universal [Issue Format](../Process/Format.md), with these Task-specific contents.

### Context and request

- State the single user, operator, or maintainer outcome.
- Write observable, testable acceptance criteria for that deliverable.
- Identify constraints, dependencies, and explicit non-goals.
- Link the parent PBI or Epic when the Task is part of an aggregate.

### Technical decisions

- Resolve the implementation choices needed to start without rediscovery.
- Name the repository paths, components, interfaces, and existing patterns involved.
- Record compatibility, failure-handling, migration, documentation, and test decisions when applicable.
- Leave no open decision that could materially change the implementation plan.

### Implementation plan

Write an actionable checkbox plan at repository-path and behavior level. For each behavior, put the test or verification step before its implementation step, following the [test-first standard](../../../Coding-Standards/Testing.md#test-first). Include documentation and final validation in the same plan.

The checklist describes one pull request. If it reveals independent deliverables, promote the issue to a PBI and create delivery children.

## Ready

A Task is implementation-ready when:

- it contains one deliverable with testable acceptance criteria;
- required technical decisions, paths, interfaces, dependencies, and blockers are resolved;
- the test-first implementation plan is specific enough to execute without replanning; and
- the expected output fits one reviewable pull request or the audited operational path below.

## Completion paths

### Repository delivery

Create one branch and draft pull request for the Task. The pull request implements the checklist, verifies the acceptance criteria, and closes only this Task after review and merge.

### Operational delivery

Use this path only when the deliverable creates no repository artifact to review. The issue must name the action, expected evidence, and verifier before work starts. Completion requires an audit comment that records:

- what was performed and by whom;
- when and where it was performed;
- links or captured output that provide durable evidence; and
- an independent verification result against every acceptance criterion.

Close the Task only after that verification succeeds. A verbal confirmation or an unaudited action is not completion.

See the [Contribution Workflow](../../Contribution-Workflow.md) for repository delivery and the [Issue Hierarchy](Hierarchy.md) for routing and promotion.
