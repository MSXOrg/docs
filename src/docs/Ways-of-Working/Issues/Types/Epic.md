---
title: Epic
description: A strategic repository aggregate that turns one Initiative into measurable outcomes and PBIs.
---

# Epic

An Epic is the native issue type for a strategic outcome that needs multiple PBIs in one repository. It is an aggregate: progress comes from its native sub-issues, not from an implementation branch or closing pull request.

Use an Epic when the work connects strategy to several bounded bodies of work. Use a [PBI](PBI.md) when one bounded outcome is enough.

## Strategy boundary

An Initiative is an organization-level bet under an OKR; an Epic is that Initiative's repository-level delivery aggregate. Link the Initiative and relevant OKR rather than copying their full bodies. When an Initiative spans repositories, each repository owns the Epic for its part of the outcome.

The Epic states the repository contribution through the Golden Circle:

- **Why:** the problem, strategic objective, and Key Result this work is expected to move.
- **How:** the capability-level approach and boundaries, without implementation detail.
- **What:** the observable repository outcomes the child PBIs collectively deliver.

## Issue body

Follow the universal [Issue Format](../Process/Format.md), with these Epic-specific contents.

### Context and request

- Link the parent Initiative and relevant OKR.
- State the strategic outcome through Why, How, and What.
- Define success measures with a baseline or current state, a target, and how the result will be observed.
- Bound the in-scope and out-of-scope outcomes.
- Write aggregate acceptance criteria that prove the PBIs combine into the intended outcome.

### Technical decisions

- Record the chosen scope boundaries and significant trade-offs.
- Explain the decomposition into PBIs and why each boundary is independently meaningful.
- Identify interfaces, ownership boundaries, dependencies, and sequencing between PBIs.
- Keep implementation decisions in the child PBI, Task, or Bug where they can be made at the right altitude.

### Implementation plan

Use native sub-issues for the child PBIs. The plan may summarize those links and their intended outcomes, but it does not contain an inline implementation checklist.

## Ready

An Epic is ready for decomposition when:

- the Initiative and OKR relationship is linked and the repository boundary is clear;
- Why, How, What, success measures, scope, and aggregate acceptance criteria are explicit;
- the initial PBI boundaries, interfaces, dependencies, and ownership are understood; and
- no open decision prevents the first PBIs from becoming ready.

## Aggregate closure

Close an Epic only when every required child PBI is complete, the aggregate acceptance criteria are verified, and the success measures have current evidence. Move any intentionally deferred outcome to a linked follow-up before closure. Record the final evidence in the Epic; do not close it through a direct implementation pull request.

See the [Goal-Setting Framework](../../Goal-Setting.md) for the Mission-to-Initiative model and the [Issue Hierarchy](Hierarchy.md) for containment and routing.
