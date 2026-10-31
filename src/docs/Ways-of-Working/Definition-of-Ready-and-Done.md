---
title: Definition of Ready and Done
description: The three gates that bracket every piece of work.
---

# Definition of Ready and Done

Three gates bracket work: one gates when an issue can move at its own altitude, one gates when a delivery pull request is ready for other people to review, and one gates when an issue can be called complete. All are shared contracts, not personal preferences.

## Definition of Ready

Readiness is type-specific. The canonical type pages own the detailed criteria; this gate determines what may move next.

### Aggregate readiness

An [Epic](Issues/Types/Epic.md#ready) or [PBI](Issues/Types/PBI.md#ready) is ready to decompose or coordinate when its [consumer expectations and scenarios](Issues/Process/Planning.md#consumer-expectations) are testable, its native containment and dependency relationships are current, and no open decision prevents the first required children from becoming ready. Readiness does not send an aggregate into Build or require a technical implementation plan in its body.

### Delivery-leaf readiness

A [Task](Issues/Types/Task.md#ready) or [Bug](Issues/Types/Bug.md#ready) is ready for Build when it owns one independently verifiable deliverable, its local acceptance criteria and implementation plan are executable, its native blockers are clear, and it fits one reviewable pull request. An operational Task is ready only when the action, durable evidence, and independent verifier are identified before execution.

Ready gates starting, not scope. An issue that is not ready stays in refinement or planning; it is not pulled into Build and figured out on the fly. See [Issue Hierarchy](Issues/Types/Hierarchy.md) for routing and [Issue Relationships](Issues/Process/Relationships.md) for authoritative blockers.

## Definition of Ready for Review

A pull request stays a **draft** until it is genuinely ready for other people to spend attention on it. "Ready for review" is not "work has started" or "please take a look" — it is a deliberate signal that the change is complete and self-reviewed, and that the only thing left is another perspective before merge. It gates the hand-off in the [Contribution Workflow](Contribution-Workflow.md).

A pull request is ready for review when:

- It closes one scoped Task or Bug delivery leaf, and every item in that leaf's implementation plan is complete or explicitly moved to a follow-up issue. Additional issues may be closed only when the [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) confirms the finished diff already delivers them.
- Native dependencies are current and every prerequisite the change relies on has landed; the pull request is not used to bypass a blocked-by edge.
- All required checks are green — not just tests that pass locally. CI is complete, not in progress, and a pull request that reports no checks has not met this item.
- The automated review loop has converged — a clean [Copilot round](Contribution-Workflow.md#the-copilot-review-loop) with no unresolved review threads.
- The [standards and framework alignment pass](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass) has run against the finished change, its result covers every changed surface in the pull request, and every exception links a follow-up issue.
- The [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) has run against scoped open issues, and every fully convergent issue is linked in the pull request with a closing keyword.
- The title, release-note description, and effective release decision and its source are finalized per [PR Format](PR-Format.md). Where Release Management applies, its [required decision check](../Capabilities/release-management/design.md#required-pre-merge-decision-check) passes; an explicit label is not mandatory when a valid configured default supplies the level.

Absent checks are not a pass. When a pull request reports no checks at all, the usual cause is that the workflow's triggers do not cover it — a base branch outside the `pull_request` trigger's `branches` filter is the common one — and that is a gap to fix or file, not a gate to wave through. Manually dispatching the workflow against the branch does not substitute for it either: jobs gated on the event type are skipped silently, so a green `workflow_dispatch` run can hide verification that never ran. If the checks genuinely cannot be made to run before merge, say so in the pull request and link the issue tracking it, so the reviewer knows the gate was not met instead of assuming it was.

If any item is open, the pull request stays a draft. Marking it ready with known-open work shifts the author's unfinished job onto reviewers — the opposite of what the signal means.

Once every item holds, hand the change off: mark it ready for review and enable auto-merge so it lands the moment review approves and the required checks stay green. See [Branching and Merging](Branching-and-Merging.md#required-checks-and-auto-merge).

Auto-merge gates only on what the ruleset declares. It waits for the required status checks and required approvals the branch ruleset names, and for nothing else — so where a ruleset declares no required status checks, an armed auto-merge lands on approval alone and never waits for CI, and "auto-merge is enabled" means considerably less than it appears to. That is a misconfiguration, not a local variation to work around: [Required checks and auto-merge](Branching-and-Merging.md#required-checks-and-auto-merge) already requires the ruleset to enforce required status checks, so a repository without them is in breach of it. The fix is to add the rule, not to compensate by watching the build by hand.

## Definition of Done

Completion follows the issue's delivery or aggregate path. Across all paths, the issue's acceptance criteria are verified, required documentation is current, and no known regression is left implicit.

### Documentation and design evidence

Relevant current specifications, designs, and documentation MUST match the delivered consumer expectations and behavior. Update the owning artifacts when the change affects their requirements, technical approach, supported usage, or instructions. Verify affected examples, links, and instruction routes together so a reader reaches consistent, working guidance.

Link the relevant document or anchor and record the verification in the delivery PR or operational audit evidence. If an existing design or document already describes the delivered result correctly, link it and explain why no update is needed; do not edit it solely to satisfy a checkbox. A missing artifact required by the change is work to complete, not evidence of an already-correct design.

Aggregate completion verifies this evidence against the combined consumer outcome, not only against each child's isolated result. The [Documentation Model](Documentation-Model.md#why-what-how-a-home-for-everything) owns where each artifact lives; issue bodies and PRs carry completion evidence rather than copies of those artifacts.

### Repository delivery leaf

A repository-delivery Task or Bug is done when its reviewed pull request is merged and closes that one leaf, required checks and tests pass, applicable coding standards hold, and the [documentation and design evidence](#documentation-and-design-evidence) is complete. Release or deploy it where that applies.

### Operational Task

An operational Task is done without a pull request only after the action has durable audit evidence, an independent verifier confirms every acceptance criterion, and the Task is closed. The canonical [operational delivery path](Issues/Types/Task.md#operational-delivery) owns the required record.

### Aggregate issue

A PBI or Epic is done only when every required native child is complete and its own aggregate acceptance criteria, combined behavior, and [documentation and design evidence](#documentation-and-design-evidence) are verified. Close the aggregate directly after that verification; a delivery pull request must not close it.

Done is binary. Skip a criterion only when it genuinely does not apply. If "done" repeatedly needs exceptions, fix the definition rather than quietly lowering the bar.
