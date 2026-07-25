---
title: PBI
description: A bounded outcome delivered through multiple Task, Bug, or nested-PBI sub-issues.
---

# PBI

A Product Backlog Item (PBI) is the native issue type for one bounded outcome that needs multiple deliverables. It is an aggregate: child issues own implementation, while the PBI owns their combined result.

Use a PBI when the outcome needs more than one pull request or independently completable operational action. Use a [Task](Task.md) or [Bug](Bug.md) when one deliverable is enough.

## Issue body

Follow the universal [Issue Format](../Process/Format.md), with these PBI-specific contents.

### Context and request

- State one bounded user, operator, or maintainer outcome.
- Define in-scope and out-of-scope boundaries.
- Write aggregate acceptance criteria that verify the children work together, not criteria copied from each child.
- Identify constraints and dependencies that affect the whole body of work.

### Technical decisions

- Explain the decomposition into Task, Bug, or nested-PBI children.
- Define interfaces, contracts, ownership boundaries, and integration points between children.
- Record cross-child sequencing with native blocked-by relationships; containment alone does not imply order.
- Keep child-local implementation decisions in the child issue.

### Implementation plan

Use native sub-issues for every delivery child. The plan may summarize the linked children and their outcomes, but it does not replace them with an inline implementation checklist.

## Nested PBIs

Nest a PBI only when one child outcome is itself bounded but still needs multiple independent deliverables. Do not add nesting to mirror teams, components, phases, or reporting structure. If a nested PBI has only one real deliverable, demote it to a Task or Bug.

A defect that needs multiple pull requests is a PBI, not an oversized Bug. Decompose it into [Bug](Bug.md) children for independently correctable unexpected behavior and [Task](Task.md) children for planned enabling, migration, or follow-up work.

## Ready

A PBI is ready for delivery when:

- the bounded outcome, scope, and aggregate acceptance criteria are testable;
- interfaces, dependencies, and integration expectations are explicit;
- the work is decomposed far enough that the first delivery children meet their own readiness gates; and
- no unresolved decision would materially change the child boundaries.

## Aggregate closure

Close a PBI only when every required child is complete and the aggregate acceptance criteria have been verified across their combined output. Move deferred work to linked follow-ups and record integration or operational evidence in the PBI. A PBI does not own a direct implementation branch or closing pull request.

See the [Issue Hierarchy](Hierarchy.md) for containment, routing, and promotion or demotion.
