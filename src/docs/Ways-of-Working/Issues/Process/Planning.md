---
title: Issue Planning
description: Consumer expectations for Epics and PBIs, with technical test-first plans in Task and Bug delivery leaves.
---

# Issue Planning

Issue planning separates consumer expectations from implementation. Epics and PBIs explain **Why** the work matters and **What** becomes observable for the consumer. Task and Bug delivery leaves add the technical **How** needed to deliver that result.

## Planning altitudes

| Native type | Consumer need and motivation | Observable result | Technical planning |
| --- | --- | --- | --- |
| [Epic](../Types/Epic.md) | The consumer problem and strategic outcome that advances an Initiative or objective. | Measurable aggregate expectations and scenarios at the repository's strategic scope. | Technical choices belong in the design and delivery leaves, not the Epic body. |
| [PBI](../Types/PBI.md) | The consumer's bounded need and why it contributes to the parent outcome. | Acceptance scenarios for the combined behavior of its children. | Coordinate native children by outcome; keep implementation choices in the design and delivery leaves. |
| [Task](../Types/Task.md) or [Bug](../Types/Bug.md) | Enough local consumer context to understand the delivery leaf independently. | One concrete, verifiable deliverable sized for one pull request or one audited operational completion. | Record implementation decisions, repository paths, interfaces, and the test-first execution plan. |

Every child retains enough local Why and acceptance criteria to be picked up independently. It references its parent's outcome instead of copying the parent's full body.

## Consumer expectations

Epics and PBIs MUST state the consumer's need, motivation, expectation, and observable behavior at their aggregate altitude. The consumer may be a user, integrator, operator, maintainer, or agent. Acceptance examples MUST describe a relevant context, an action or event, and a result the consumer or an independent verifier can observe. Use BDD-style Given / When / Then scenarios or an equally clear acceptance example; include failure or boundary cases where they distinguish the expected behavior.

Epics and PBIs MUST NOT require architecture choices, solution-component inventories, repository file or function lists, or technical implementation checklists in their bodies. Consumer-facing contracts and genuine constraints may be named with their rationale, but they do not prescribe the internal solution. Apply the [spec/design altitude test](../../Spec-Driven-Development.md#what-a-specification-is): changing the implementation without changing the consumer expectation does not change aggregate acceptance.

Scenarios clarify the need; they are not a second specification, a new test framework, or a separate BDD workflow. Link the relevant durable requirement and keep only the local context needed to understand this outcome. Task and Bug leaves retain technical decisions and translate the scenarios into the existing [test-first delivery plans](../../../Coding-Standards/Testing.md#test-first).

For example, a PBI can require a complete repository inventory with no silent omissions. A Task may name the pagination helper, repository paths, and tests needed to deliver that behavior. A Bug may identify an observed truncation, its verified root cause, and the failing regression test before the fix. Those leaf-local plans do not become requirements in the parent PBI.

## Ownership boundaries

Issue planning connects canonical artifacts; it does not replace them:

- [Goal Setting](../../Goal-Setting.md) owns Mission, OKR, and Initiative strategy. An Epic links delivery to that strategy.
- [Specifications](../../Spec-Driven-Development.md) own the durable Why and What of a capability.
- [Designs](../../Spec-Driven-Development.md#what-a-design-is) own the durable technical How.
- Epics and PBIs own consumer expectations, aggregate acceptance, readiness, and native outcome decomposition.
- Task and Bug leaves own per-change implementation decisions and executable plans.

Reference the owning artifact and capture only the local rationale required to understand the issue. When intent or design changes, update the canonical artifact first, then update affected issues and record the issue-body change in the audit trail.

Completion follows the shared [Definition of Done](../../Definition-of-Ready-and-Done.md#definition-of-done), including evidence that relevant design and documentation match the delivered expectations.

## Progressive decomposition

1. Start at the highest issue that can state the outcome honestly.
2. State the consumer's need and motivation, then use observable acceptance examples to establish scope.
3. Separate meaningful consumer outcomes with native sub-issues; link the current design rather than prescribing it in the aggregate.
4. Record technical choices and test-first execution steps in the Task or Bug that delivers each slice.
5. Continue until each leaf is ready with one concrete deliverable and its documentation verification in scope.

Decomposition does not create execution order by itself. Use [native dependency relationships](Relationships.md#execution-order) only where one item must finish before another can proceed; otherwise ready siblings remain eligible for parallel work.
