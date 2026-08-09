---
title: Issue Hierarchy
description: Shared taxonomy, routing, containment, and promotion rules for native issue types.
---

# Issue Hierarchy

The MSX issue hierarchy separates strategic aggregation from delivery. Altitude reflects outcome scope and containment, not priority, effort, uncertainty, or organizational structure.

## Taxonomy

| Altitude | Native issue type | Owns | Delivery |
| --- | --- | --- | --- |
| Strategic aggregate | [Epic](Epic.md) | One repository outcome tied to an Initiative and delivered by multiple PBIs. | Progress and closure aggregate from child PBIs. |
| Bounded aggregate | [PBI](PBI.md) | One bounded outcome delivered by multiple child issues. | Progress and closure aggregate from Tasks, Bugs, or nested PBI children. |
| Delivery leaf | [Task](Task.md) | One planned deliverable. | One pull request, or one audited and independently verified operational action. |
| Delivery leaf | [Bug](Bug.md) | One correction for unexpected behavior. | One pull request with regression-first verification. |

Bug is a native delivery type at Task altitude, not a label or an additional hierarchy level.

Feature remains temporary live metadata while [migration task #90](https://github.com/MSXOrg/docs/issues/90) retires existing usage. It describes a kind of work, not planning altitude, and must not be used as a hierarchy node.

## Routing

Start at a delivery leaf and promote only when the work proves larger:

- Use **Task** for one planned repository deliverable or one audited operational action.
- Use **Bug** for one independently correctable instance of unexpected behavior.
- Use **PBI** when one bounded outcome needs multiple pull requests or independently completable actions.
- Use **Epic** when one repository's strategic outcome implements an Initiative through multiple PBIs.

A defect that requires multiple pull requests is a PBI with Bug children for independently correctable behavior and Task children for planned enabling, migration, or follow-up work. Do not stretch one Bug across several pull requests.

## How to express the hierarchy

Use GitHub's native sub-issue relationship for containment:

```text
Epic
└── PBI
    ├── Task
    ├── Bug
    └── PBI
        └── Task or Bug
```

- Epic and PBI are aggregates. Their children own delivery branches, pull requests, or operational evidence.
- Task and Bug are leaves and do not aggregate implementation work through sub-issues.
- A nested PBI is valid only when its bounded child outcome still needs multiple delivery issues.
- Each child's acceptance criteria cover only its slice; the parent owns criteria for the combined outcome.
- Containment does not imply sequence. Use native blocked-by and blocking relationships when execution order matters.

GitHub's native relationships are the source of truth. Text links may aid readers, but they do not replace the platform relationship.

## Promotion and demotion

Change type when decomposition reveals the issue is at the wrong altitude:

- Promote a Task or Bug to PBI when it needs multiple delivery children.
- Promote a PBI to Epic only when it represents a strategic repository outcome tied to an Initiative and needs multiple PBIs.
- Demote a PBI to Task or Bug when only one delivery leaf remains.
- Demote an Epic to PBI when it represents one bounded outcome rather than a strategic aggregate.

Update the issue body for its new type, rebuild native containment, and add an audit comment explaining what changed and why. Promotion or demotion preserves the original issue whenever practical so its discussion and decisions remain traceable.

See the [Goal-Setting Framework](../../Goal-Setting.md) for the Initiative boundary and the [Issue Format](../Process/Format.md) for the universal body structure.

For pull requests, this hierarchy also guides where to look first during the session-end [issue convergence sweep](../../Workflow-Stages/Implement.md#6-issue-convergence-sweep) (parent and sibling delivery leaves before wider searches).
