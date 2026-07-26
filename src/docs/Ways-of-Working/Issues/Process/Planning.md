---
title: Issue Planning
description: Progressive Why, How, and What decomposition across issue altitudes.
---

# Issue Planning

Issue planning adds detail progressively. Work starts with **Why**, gains an outcome-level **What**, and introduces only the **How** needed to decompose and deliver it. Detail increases toward ready delivery leaves; it is not copied upward before it is useful.

## Planning altitudes

| Native type | Why | How | What |
| --- | --- | --- | --- |
| [Epic](../Types/Epic.md) | States the strategic purpose and the outcome that advances an Initiative or objective. | Describes the outcome-level approach only far enough to identify coherent PBIs. | Defines the measurable aggregate result and its scope. |
| [PBI](../Types/PBI.md) | Explains why this bounded body of work contributes to its parent outcome. | Defines the delivery-level approach, interfaces, and decomposition into independently deliverable children. | Defines the bounded result and aggregate acceptance criteria. |
| [Task](../Types/Task.md) or [Bug](../Types/Bug.md) | Restates the local purpose so the delivery leaf is understandable on its own. | Records implementation decisions and the test-first execution plan. | Defines one concrete, verifiable deliverable sized for one pull request or one audited operational completion. |

Every child retains enough local Why and acceptance criteria to be picked up independently. It references its parent's outcome instead of copying the parent's full body.

## Ownership boundaries

Issue planning connects canonical artifacts; it does not replace them:

- [Goal Setting](../../Goal-Setting.md) owns Mission, OKR, and Initiative strategy. An Epic links delivery to that strategy.
- [Specifications](../../Spec-Driven-Development.md) own the durable Why and What of a capability.
- Designs own the durable technical How.
- Issues own the current decomposition, delivery decisions, readiness, and tracked work needed to close the gap between those artifacts and reality.

Reference the owning artifact and capture only the local rationale required to understand the issue. When intent or design changes, update the canonical artifact first, then update affected issues and record the issue-body change in the audit trail.

## Progressive decomposition

1. Start at the highest issue that can state the outcome honestly.
2. Add just enough Why and What to establish scope and acceptance.
3. Introduce How when it is needed to choose boundaries, interfaces, or delivery slices.
4. Create native sub-issues for work that has independent outcomes or completion.
5. Continue until each leaf is a ready Task or Bug with one concrete deliverable.

Decomposition does not create execution order by itself. Use [native dependency relationships](Relationships.md#execution-order) only where one item must finish before another can proceed; otherwise ready siblings remain eligible for parallel work.
