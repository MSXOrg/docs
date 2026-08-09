---
title: Issue Relationships
description: Native containment, progress, dependency order, and parallel execution rules.
---

# Issue Relationships

GitHub's native relationships are the authoritative issue graph. Prose may explain why a relationship exists, but it never recreates that graph.

## Containment and progress

Use native **sub-issues** to express that work is contained by an Epic, PBI, or nested PBI:

- The parent owns the aggregate outcome.
- Each child owns a distinct slice with local purpose and acceptance criteria.
- The parent's progress is derived from the completion state of its native sub-issues.
- Containment does not imply execution order.

Do not maintain a second child-link list in the parent body. The native sub-issue list is the current inventory and progress source.

## Execution order

Use native **blocked-by / blocking** relationships only when one issue must finish before another can proceed:

- The waiting issue is blocked by the prerequisite.
- The prerequisite is blocking the waiting issue.
- Removing or changing the dependency updates the native edge.
- List position, numbering, creation time, and sub-issue order do not create a dependency.

The native dependency graph is the source of truth for execution order. A checklist may describe work inside one delivery issue, but it does not order separate issues.

## Parallel execution

Ready siblings without dependency edges are eligible for parallel execution. Sharing a parent means they contribute to the same aggregate outcome; it does not make them sequential.

Add a dependency edge only for a real prerequisite. Coordination, shared context, or a preferred review order may be explained in prose, but those preferences do not block otherwise ready work.

## No duplicate relationship fields

Do not add any of the following as relationship sources of truth:

- Manual `Parent: #N` fields.
- Manual `Blocked by: #N` or `Blocking: #N` fields.
- Duplicated lists of child issue links.
- Statements that list position or numbering defines execution order.

When a relationship changes, update the native relationship first. Then add a brief audit comment when the reason is not self-evident. Links in prose are appropriate for rationale or supporting context, not for maintaining a parallel containment or dependency model.
