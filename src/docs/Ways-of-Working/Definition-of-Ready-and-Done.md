---
title: Definition of Ready and Done
description: The three gates that bracket every piece of work.
---

# Definition of Ready and Done

Three gates bracket work: one gates when an issue can move at its own altitude, one gates when a delivery pull request is ready for other people to review, and one gates when an issue can be called complete. All are shared contracts, not personal preferences.

## Definition of Ready

Readiness is type-specific. The canonical type pages own the detailed criteria; this gate determines what may move next.

### Aggregate readiness

An [Epic](Issues/Types/Epic.md#ready) or [PBI](Issues/Types/PBI.md#ready) is ready to decompose or coordinate when its aggregate outcome and acceptance criteria are testable, its native containment and dependency relationships are current, and no open decision prevents the first required children from becoming ready. Readiness does not send an aggregate into Build.

### Delivery-leaf readiness

A [Task](Issues/Types/Task.md#ready) or [Bug](Issues/Types/Bug.md#ready) is ready for Build when it owns one independently verifiable deliverable, its local acceptance criteria and implementation plan are executable, its native blockers are clear, and it fits one reviewable pull request. An operational Task is ready only when the action, durable evidence, and independent verifier are identified before execution.

Ready gates starting, not scope. An issue that is not ready stays in refinement or planning; it is not pulled into Build and figured out on the fly. See [Issue Hierarchy](Issues/Types/Hierarchy.md) for routing and [Issue Relationships](Issues/Process/Relationships.md) for authoritative blockers.

## Definition of Ready for Review

A pull request stays a **draft** until it is genuinely ready for other people to spend attention on it. "Ready for review" is not "work has started" or "please take a look" — it is a deliberate signal that the change is complete and self-reviewed, and that the only thing left is another perspective before merge. It gates the hand-off in the [Contribution Workflow](Contribution-Workflow.md).

A pull request is ready for review when:

- It closes one scoped Task or Bug delivery leaf, and every item in that leaf's implementation plan is complete or explicitly moved to a follow-up issue. Additional issues may be closed only when the [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) confirms the finished diff already delivers them.
- Native dependencies are current and every prerequisite the change relies on has landed; the pull request is not used to bypass a blocked-by edge.
- All required checks are green — not just tests that pass locally. CI is complete, not in progress.
- The automated review loop has converged — a clean [Copilot round](Contribution-Workflow.md#the-copilot-review-loop) with no unresolved review threads.
- The [standards and framework alignment pass](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass) has run against the finished change, its result covers every changed surface in the pull request, and every exception links a follow-up issue.
- The [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) has run against scoped open issues, and every fully convergent issue is linked in the pull request with a closing keyword.
- The title, release-note description, and exactly one change-type label are finalized. See [PR Format](PR-Format.md).

If any item is open, the pull request stays a draft. Marking it ready with known-open work shifts the author's unfinished job onto reviewers — the opposite of what the signal means.

Once every item holds, hand the change off: mark it ready for review and enable auto-merge so it lands the moment review approves and the required checks stay green. See [Branching and Merging](Branching-and-Merging.md#required-checks-and-auto-merge).

## Definition of Done

Completion follows the issue's delivery or aggregate path. Across all paths, the issue's acceptance criteria are verified, required documentation is current, and no known regression is left implicit.

### Repository delivery leaf

A repository-delivery Task or Bug is done when its reviewed pull request is merged and closes that one leaf, required checks and tests pass, applicable coding standards hold, and the affected evergreen specification and documentation describe the delivered behavior. Release or deploy it where that applies.

### Operational Task

An operational Task is done without a pull request only after the action has durable audit evidence, an independent verifier confirms every acceptance criterion, and the Task is closed. The canonical [operational delivery path](Issues/Types/Task.md#operational-delivery) owns the required record.

### Aggregate issue

A PBI or Epic is done only when every required native child is complete and its own aggregate acceptance criteria and evidence are verified. Close the aggregate directly after that verification; a delivery pull request must not close it.

Done is binary. Skip a criterion only when it genuinely does not apply. If "done" repeatedly needs exceptions, fix the definition rather than quietly lowering the bar.
