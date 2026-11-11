---
title: Definition of Ready and Done
description: Readiness, review, and completion gates for issues and pull requests.
---

# Definition of Ready and Done

Three shared gates govern issue readiness, pull request review readiness, and completion. Each gate applies at the issue's planning altitude.

## Definition of Ready

Readiness is type-specific. The canonical type pages own the detailed criteria; this gate determines what may move next.

### Aggregate readiness

An [Epic](Issues/Types/Epic.md#ready) or [PBI](Issues/Types/PBI.md#ready) is ready to decompose or coordinate when its [consumer expectations and scenarios](Issues/Process/Planning.md#consumer-expectations) are testable. Its native containment and dependency relationships are current. No open decision prevents the first required children from becoming ready. Aggregate readiness does not authorize Build or require a technical implementation plan in the aggregate body.

### Delivery-leaf readiness

A [Task](Issues/Types/Task.md#ready) or [Bug](Issues/Types/Bug.md#ready) is ready for Build when it owns one independently verifiable deliverable. Its local acceptance criteria and implementation plan are executable. Its native blockers are clear, and the change fits one reviewable pull request. An operational Task is ready only when the action, durable evidence, and independent verifier are identified before execution.

Readiness determines when work starts, not its scope. Keep an unready issue in refinement or planning; do not resolve missing planning during Build. See [Issue Hierarchy](Issues/Types/Hierarchy.md) for routing and [Issue Relationships](Issues/Process/Relationships.md) for authoritative blockers.

## Definition of Ready for Review

A pull request stays a **draft** until the author completes and self-reviews the change. Review readiness signals that the work is ready for an independent assessment before merge. The gate controls the handoff in the [Contribution Workflow](Contribution-Workflow.md).

A pull request is ready for review when:

- It closes one scoped Task or Bug delivery leaf. Every item in that leaf's implementation plan is complete or explicitly moved to a follow-up issue. Additional issues may be closed only when the [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) confirms the finished diff already delivers them.
- Native dependencies are current and every prerequisite the change relies on has landed; the pull request is not used to bypass a blocked-by edge.
- All required checks are green — not just tests that pass locally. CI is complete, not in progress, and a pull request that reports no checks has not met this item.
- The automated review loop has converged — a clean [Copilot round](Contribution-Workflow.md#the-copilot-review-loop) with no unresolved review threads.
- The [standards and framework alignment pass](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass) has run against the finished change, its result covers every changed surface in the pull request, and every exception links a follow-up issue.
- The [issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep) has run against scoped open issues, and every fully convergent issue is linked in the pull request with a closing keyword.
- The title and release-note-ready description are finalized per [PR Format](PR-Format.md). When the target route invokes Release Management, the `Release decisions` block, effective configuration, and applied `release:*` labels agree, and the [required decision check](../Capabilities/release-management/design.md#required-pre-merge-decision-check) passes; an explicit bump label is not mandatory when the valid effective default supplies the level, including supported caller overrides. When the route does not invoke Release Management, the block and labels are absent.
- Consumer release evidence is complete for the reviewed source under [PR Format](PR-Format.md#write-the-description), including explicit no-action outcomes and applicable immutable template compatibility. An upgrade PR also reconciles its complete baseline-to-target range through [Consumer Upgrades](Consumer-Upgrades.md); the newest release note alone is insufficient.
- Required post-merge publication, deployment, or template milestones name a [completion-owning issue](#post-merge-completion-ownership) and responsible owner before review; automatic PR closure cannot be their only completion signal.

Absent checks are not a pass. If a pull request reports no checks, inspect whether the workflow triggers cover its base branch. A base branch outside the `pull_request` trigger's `branches` filter is a common cause. Fix the trigger gap or file an issue; do not waive the gate.

A manual workflow dispatch does not substitute for the pull-request run. Event-gated jobs can be skipped, so a successful `workflow_dispatch` run can omit required verification. If checks cannot run before merge, state that in the pull request and link the issue that tracks the gap. This tells the reviewer that the gate is unmet.

Producer review before publication MAY use a verified immutable candidate or
prerelease source and an immutable template commit, as
[PR Format](PR-Format.md#complete-description-example) permits. If final template wiring
requires the released producer version, identify that work in a linked delivery
Task with its owner, sequencing, and completion evidence. Do not create a
circular pre-merge prerequisite, invent final release coordinates, or describe
pending template work as delivered. Candidate compatibility must be demonstrated,
not promised; this does not waive an existing native blocker.

If any item is open, keep the pull request in draft. Review readiness does not transfer unfinished author work to reviewers.

When a change affects community or contribution guidance, verify
[effective contribution guidance](Repository-Standard.md#contribution-guidance):
shared files remain in their organization `.github` source home, inherited
guidance resolves without repository-local copies, and needed local instructions
or documented exceptions are preserved. Already-correct guidance does not
require a file edit.

Once every item holds, hand the change off: mark it ready for review and enable auto-merge so it lands the moment review approves and the required checks stay green. See [Branching and Merging](Branching-and-Merging.md#required-checks-and-auto-merge).

Auto-merge waits only for requirements in the branch ruleset. These include required status checks and approvals. If the ruleset names no required status checks, approval alone can permit integration before CI completes. This violates [Required checks and auto-merge](Branching-and-Merging.md#required-checks-and-auto-merge), which requires the ruleset to enforce status checks. Add the missing status-check rule. Do not substitute manual build monitoring.

## Definition of Done

Completion follows the issue's delivery or aggregate path. Across all paths, the issue's acceptance criteria are verified, required documentation is current, and no known regression is left implicit.

### Documentation and design evidence

Relevant current specifications, designs, and documentation MUST match the delivered consumer expectations and behavior. Update the owning artifacts when the change affects their requirements, technical approach, supported usage, or instructions. Verify affected examples, links, and instruction routes together so a reader reaches consistent, working guidance.

Link the relevant document or anchor and record the verification in the delivery PR or operational audit evidence. If an existing design or document already describes the delivered result correctly, link it and explain why no update is needed; do not edit it solely to satisfy a checkbox. A missing artifact required by the change is work to complete, not evidence of an already-correct design.

Aggregate completion verifies this evidence against the combined consumer outcome, not only against each child's isolated result. The [Documentation Model](Documentation-Model.md#why-what-how-a-home-for-everything) owns where each artifact lives; issue bodies and PRs carry completion evidence rather than copies of those artifacts.

### Repository delivery leaf

A repository-delivery Task or Bug is done when its reviewed pull request is merged and closes that one leaf, required checks and tests pass, applicable coding standards hold, and the [documentation and design evidence](#documentation-and-design-evidence) is complete. Release or deploy it where that applies.

The overall producer outcome, where an integration template applies, requires
compatible **immutable template evidence for the actual published producer
identity**, and delivery of every necessary linked template change.
Reconcile candidate evidence with the published identity and rerun affected
validation when it differs. A verified existing template commit with a justified
no-change result satisfies the obligation; a promise to synchronize later does
not. Where no template applies, record why.

Keep the milestones distinct:

| Milestone | What its evidence establishes |
| --- | --- |
| Review readiness | The reviewed candidate has complete consumer evidence and verified applicable template compatibility. |
| Merge | The reviewed source change is integrated, not necessarily published. |
| Publication | The actual release/source identities and complete source-bound notes are available through the release process. |
| Template completion | Necessary linked template changes are delivered and immutable compatibility with the published producer identity is evidenced. |

#### Post-merge completion ownership

Name the issue that owns the **whole required outcome** before review, and keep
it open until that outcome is verified. Every repository PR still closes exactly
its one scoped Task or Bug; it must not close an aggregate.

When source integration and necessary template or other delivery work need
separate leaves, use a [PBI](Issues/Types/PBI.md) with those required native
children. The source leaf owns the independently verifiable integration
deliverable; the PBI owns the combined producer outcome, including publication
and template compatibility. The source PR references the PBI without a closing
keyword. The PBI remains open after the integration leaf closes, until its
required children and aggregate criteria are complete. A cross-link alone,
without an open completion owner, is insufficient.

For a single-leaf delivery whose own required publication or deployment follows
merge, with no aggregate owning that milestone, the named owner **reopens the
leaf immediately if the PR closes it before the required evidence exists**.
Keep it open while the milestone is pending or failed, and close it only after
recording the verified outcome. This preserves the ordinary PR closing link
without treating integration as proof of the later milestone.

### Operational Task

An operational Task is done without a pull request only after the action has durable audit evidence, an independent verifier confirms every acceptance criterion, and the Task is closed. The canonical [operational delivery path](Issues/Types/Task.md#operational-delivery) owns the required record.

### Aggregate issue

A PBI or Epic is done only when every required native child is complete and its own aggregate acceptance criteria, combined behavior, and [documentation and design evidence](#documentation-and-design-evidence) are verified. Close the aggregate directly after that verification; a delivery pull request must not close it.

Completion requires every applicable criterion. Skip a criterion only when it does not apply. If exceptions recur, correct the definition rather than weaken it.
