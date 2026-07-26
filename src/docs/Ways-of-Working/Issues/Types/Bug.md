---
title: Bug
description: One implementation-ready correction for unexpected behavior, delivered at Task level.
---

# Bug

A Bug is a native delivery type at the same altitude as a [Task](Task.md). It owns one independently correctable instance of unexpected behavior and one reviewable pull request.

Use Bug for a correction, not as a label or hierarchy level. A defect that needs multiple pull requests becomes a [PBI](PBI.md) with Bug and Task children.

## Issue body

Follow the universal [Issue Format](../Process/Format.md), with these Bug-specific contents.

### Context and request

- **Observed behavior:** what happens, including exact errors, outputs, or impact.
- **Expected behavior:** the observable result that should occur instead.
- **Reproduction:** the smallest repeatable steps, inputs, and commands.
- **Environment:** relevant versions, runtime, operating system, host, and configuration.
- **Regression:** whether this worked before and the last known working version, or an explicit unknown.
- **Workaround:** the current mitigation, or an explicit statement that none is known.
- **Acceptance criteria:** the corrected behavior and the regressions that must remain prevented.

### Technical decisions

- Bound the root cause to the affected behavior, component, contract, or change based on available evidence.
- Distinguish verified cause from hypotheses; do not use the correction to absorb unrelated refactoring.
- Record compatibility, failure-handling, and rollout decisions needed for the fix.
- Define the failing regression test that will demonstrate the problem before implementation.

### Implementation plan

Start by reproducing the failure in an automated regression test. Then implement the smallest root-cause correction, run the affected and broader test surfaces, and update relevant documentation. If automation is genuinely impossible, record the reason and an equivalent repeatable verification before implementation.

## Ready

A Bug is implementation-ready when:

- observed and expected behavior, reproduction, environment, regression status, workaround, and acceptance criteria are explicit;
- the correction is bounded to one pull request;
- the root-cause boundary and unresolved hypotheses are clear enough to prevent scope drift;
- dependencies and blockers are known; and
- the regression-test-first plan can be executed.

## Closure

Close a Bug only after its pull request is reviewed and merged, the regression test or recorded equivalent fails before the correction and passes after it, and the acceptance criteria are verified. Record any intentionally deferred cleanup as linked Task children of the relevant PBI or as separate follow-up Tasks.

See the [Issue Hierarchy](Hierarchy.md) for routing and promotion when investigation reveals more than one deliverable.
