---
title: Epic
description: A strategic repository aggregate that turns one Initiative into measurable outcomes and PBIs.
---

# Epic

An Epic is the native issue type for a strategic outcome that needs multiple PBIs in one repository. It is an aggregate: progress comes from its native sub-issues, not from an implementation branch or closing pull request.

Use an Epic when the work connects strategy to several bounded bodies of work. Use a [PBI](PBI.md) when one bounded outcome is enough.

## Strategy boundary

An Initiative is an organization-level bet under an OKR; an Epic is that Initiative's repository-level delivery aggregate. Link the Initiative and relevant OKR rather than copying their full bodies. When an Initiative spans repositories, each repository owns the Epic for its part of the outcome.

The Epic states the repository contribution at the [consumer-expectation altitude](../Process/Planning.md#consumer-expectations):

- **Consumer and need:** who is affected and what they need to achieve.
- **Motivation:** the problem, strategic objective, and Key Result this work is expected to move.
- **Expectation:** the observable repository outcomes the child PBIs collectively deliver, not the components used to deliver them.

## Issue body

Follow the universal [Issue Format](../Process/Format.md), with these Epic-specific contents.

### Context and request

- Link the parent Initiative and relevant OKR.
- Identify the consumer, their need, and why the strategic outcome matters to them.
- Define success measures with a baseline or current state, a target, and how the result will be observed.
- Bound the in-scope and out-of-scope outcomes.
- Link relevant current specifications and designs rather than restating them.

### Consumer scenarios

Write aggregate acceptance examples that prove the PBIs combine into the intended consumer outcome. Keep them at strategic scope, with success measures that an independent verifier can observe.

For example, maintainers need to trust repository coverage before deciding where to improve fleet health:

```gherkin
Scenario: Maintainers can trust fleet coverage
  Given maintainers manage repositories across several organizations
  When they assess fleet health
  Then every repository in the agreed scope is accounted for
  And any gap in coverage is explicit before they act on the result
```

The Epic names the coverage baseline, target, and observation method; it does not require a service, dashboard, library, or file layout.

### Scope and coordination

Explain meaningful outcome boundaries and constraints only where they help coordinate the work. Use native sub-issues for child PBIs and native dependencies for genuine prerequisites. The native graph owns inventory and progress; do not copy a child-link list into the body. Technical choices stay in the linked design and Task or Bug leaves.

## Ready

An Epic is ready for decomposition when:

- the Initiative and OKR relationship is linked and the repository boundary is clear;
- the consumer need, motivation, success measures, scope, and aggregate scenarios are explicit;
- the initial PBI outcome boundaries and native relationships are understood; and
- no open decision prevents the first PBIs from becoming ready.

## Aggregate closure

Close an Epic only when every required child PBI is complete, the aggregate acceptance criteria are verified, and the success measures have current evidence. Move any intentionally deferred outcome to a linked follow-up before closure. Record the final evidence in the Epic; do not close it through a direct implementation pull request.

Verify the relevant design, documentation, and their links through the shared [Definition of Done](../../Definition-of-Ready-and-Done.md#definition-of-done), including the combined consumer outcome rather than only each child's evidence.

See the [Goal-Setting Framework](../../Goal-Setting.md) for the Mission, OKR, and Initiative model and the [Issue Hierarchy](Hierarchy.md) for containment and routing.
