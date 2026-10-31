---
title: PBI
description: A bounded outcome delivered through multiple Tasks, Bugs, or nested PBI sub-issues.
---

# PBI

A Product Backlog Item (PBI) is the native issue type for one bounded outcome that needs multiple deliverables. It is an aggregate: child issues own implementation, while the PBI owns their combined result.

Use a PBI when the outcome needs more than one pull request or independently completable operational action. Use a [Task](Task.md) or [Bug](Bug.md) when one deliverable is enough.

## Issue body

Follow the universal [Issue Format](../Process/Format.md) and canonical [consumer-expectation altitude](../Process/Planning.md#consumer-expectations), with these PBI-specific contents.

### Context and request

- Identify the consumer, their bounded need, and why meeting it matters.
- State the expected observable behavior and its contribution to the parent outcome.
- Define in-scope and out-of-scope boundaries.
- Identify constraints and dependencies that affect the whole body of work.
- Link relevant current specifications and designs rather than restating them.

### Consumer scenarios

Write aggregate acceptance examples that verify the children work together for the consumer, not implementation criteria copied from each child.

For example, a maintainer needs a complete repository inventory so their checks do not silently miss work:

```gherkin
Scenario: The default inventory is complete
  Given a caller can access 137 repositories
  When they request an inventory without an explicit limit
  Then all 137 repositories appear exactly once

Scenario: Incomplete coverage is not presented as success
  Given one repository in the requested scope cannot be read
  When a caller requests the inventory
  Then the failure is explicit
  And a partial inventory is not presented as complete
```

Pagination helpers, internal interfaces, file paths, and implementation steps belong in the design and delivery leaves, not these acceptance examples.

### Scope and coordination

Explain the consumer outcome boundaries that justify Tasks, Bugs, or nested PBIs. Use native sub-issues for every delivery child and native blocked-by relationships for genuine prerequisites; containment alone does not imply order. Do not duplicate the native child inventory in the body or turn coordination into an implementation checklist.

## Nested PBIs

Nest a PBI only when one child outcome is itself bounded but still needs multiple independent deliverables. Do not add nesting to mirror teams, components, phases, or reporting structure. If a nested PBI has only one real deliverable, demote it to a Task or Bug.

A defect that needs multiple pull requests is a PBI, not an oversized Bug. Decompose it into [Bug](Bug.md) children for independently correctable unexpected behavior and [Task](Task.md) children for planned enabling, migration, or follow-up work.

## Ready

A PBI is ready for delivery when:

- the consumer need, motivation, bounded outcome, scope, and aggregate scenarios are testable;
- consumer-facing constraints, native dependencies, and combined behavior expectations are explicit;
- the work is decomposed far enough that the first delivery children meet their own readiness gates; and
- no unresolved decision would materially change the child boundaries.

## Aggregate closure

Close a PBI only when every required child is complete and the aggregate acceptance criteria have been verified across their combined output. Move deferred work to linked follow-ups and record integration or operational evidence in the PBI. A PBI does not own a direct implementation branch or closing pull request.

Verify the relevant design, documentation, and their links against that combined output through the shared [Definition of Done](../../Definition-of-Ready-and-Done.md#definition-of-done).

See the [Issue Hierarchy](Hierarchy.md) for containment, routing, and promotion or demotion.
