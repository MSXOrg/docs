---
title: Session Interactions
description: Recognized phrases that run documented session procedures, independent of the runtime, without changing the operator's authority.
---

# Session Interactions

Session interactions provide repeatable procedures to record a tangent, prepare a handoff, or perform another session operation.
An **interaction** is a recognized phrase bound to one documented procedure.
That procedure defines the result for every runtime and operator, whether human or agent.

## An interaction is a phrase bound to a procedure

An interaction MUST be a short natural phrase, and it MUST resolve to a procedure defined in
documentation.

A short phrase lets a contributor request a session operation without a tool-specific command.
A defined procedure makes the expected result clear.
Without a defined procedure, runtimes can interpret the same phrase differently.

| Property | Requirement |
| --- | --- |
| Phrase | Short, natural, and unambiguous in the context of a working session |
| Procedure | Defined once in documentation, reachable from the index |
| Scope | Operates on the session or its artifacts, not on the domain of the work |
| Result | The same outcome regardless of runtime or operator |

## The standing vocabulary

These interactions are recognized.
Each phrase routes to a documented procedure rather than creating a second procedure definition.

| Phrase | What it means | What it does |
| --- | --- | --- |
| **Wrap up** | The session is ending, deliberately | Scan for untracked work: uncommitted changes, unpushed commits, undocumented decisions, and lessons worth retaining. Record each item in its owning artifact. |
| **Park** | This is real, but not now, and not here | Record the tangent in an issue in its owning repository. Include enough context for later action, then resume the original task. |
| **Triage** | Decide what this is before working it | Classify the item's type, owning repository, and whether it is already known. Route it without starting implementation. |
| **Handoff** | Someone or something else continues this | Prepare artifacts so another participant can resume the work. Record what remains as [state rather than as a message](../Capabilities/agentic-development/agent-interaction.md#handover-is-a-state-not-a-message). |
| **Status** | Tell me where this stands | Report completed, active, and remaining work, with blockers and open decisions. Reference the relevant issues and pull requests. Change nothing. |
| **Checkpoint** | Save a known-good point and keep going | Bring the tree to a coherent state. Record a work-in-progress commit and the task record. Note what the checkpoint covers, then continue working. |
| **Spin-off** | This is a separate concern | Record a tangent in its own issue, cross-linked to the current work, so the pull request retains one concern. |
| **Stop** | Abandon this | State what will be discarded. Confirm before changing anything. Record anything worth retaining as an issue, then discard the rest. |

Across the vocabulary, **no interaction decides anything about the work.**
Park records an item without judging it; triage classifies without implementing; status reports without changing the work.
An interaction routes or reports work and leaves the decision to its owner.

The effect on recorded state determines when it is safe to invoke each interaction:

| Effect | Interactions | Consequence |
| --- | --- | --- |
| Leave durable state | Wrap up, Park, Triage, Handoff, Checkpoint, Spin-off | Required context exists in durable artifacts; the session can be discarded without loss |
| Leave nothing | Status | Reports without changing state, including mid-task |
| Remove state | Stop | Destructive, and therefore the only interaction that MUST confirm first |

### Wrap up

Session work can remain outside durable artifacts: an unrecorded decision, a failed approach, or a problem without an issue.
Ending the session can lose that context.

Wrap-up is a **scan**, not a summary.
It records each untracked item in its owning artifact; a summary alone does not meet that requirement.
If a problem is too large to fix in scope, create an issue in its owning repository.
Do not retain it only in the session.

### Park

Park records a tangent without replacing the original task.
The tangent becomes an issue in its owning repository, with the context needed for later work.
The session then continues the original task.
A parked item MUST be understandable to a reader who was not in the session.

### Triage

Triage classifies an item before implementation.
It determines whether the item is well-formed, already known, and owned by the repository.
Triage resolves those questions, routes the classified item, and stops.
Starting implementation during triage MUST be treated as leaving the interaction.

### Handoff

Handoff prepares artifacts with enough context for another participant to resume the work.
It does not depend on private knowledge or session-only context.
A handoff message alone is insufficient; the artifacts need to be resumable before an announcement.

### Status

Status answers "where are we", also phrased as *recap* or *catch me up*, and has **no side effects**.
It reports completed work, active work, remaining work, blockers, and open decisions.
It references the relevant issues and pull requests so the reader can inspect them.

Status creates nothing, commits nothing, and changes nothing.
This makes it safe to request during a task.

Status MUST NOT fix anything it notices.
A problem found during reporting is a candidate for [park](#park) or [spin-off](#spin-off), not a fix made by Status.

### Checkpoint

A checkpoint marks a known-good point and then **continues work**.
Wrap-up ends the session; handoff prepares it for someone else.

Bring the tree to a coherent state.
Record a work-in-progress commit on the topic branch.
Update the task record with the checkpoint's scope and the next work.
Then keep working.

A checkpoint makes coherent work recoverable through a commit instead of leaving it only in uncommitted changes.
The commit records work in progress, not a claim that the work is finished or releasable.

### Spin-off

Spin-off and [park](#park) separate work for different reasons.
Park records a tangent for later work.
Spin-off separates a concern that does not belong in *this pull request*, even if it is the next work.

The test is scope, not timing: a pull request stays one concern, so a second concern gets its
own issue and its own pull request. Identify the tangent, say why it is separable, draft the
issue with a cross-reference to the current work, confirm, and return to the task.

A change that would make a reviewer ask "why is this here?" is a spin-off candidate.

### Stop

Stop is the only **destructive** interaction.

State plainly what will be discarded — which commits, which uncommitted changes, which
branches, which open pull requests — and get confirmation **before touching anything**. Only
then revert or discard.

The phrases "Stop", "abandon", and "drop it" can express frustration without authorizing the loss of work.
Confirmation establishes what the contributor intends to discard.

Then record why.
The reason can identify a failed approach, a discovered constraint, or a missing dependency.
Salvage anything worth keeping as an issue before the rest is discarded.

## Defined once, referenced everywhere

An interaction MUST be defined in exactly one place, and every runtime that recognizes it MUST
reference that definition rather than restate it.

This is the same rule the framework applies to
[client routes](../Capabilities/agentic-development/design.md#client-behavior) and to
[named intents](../Capabilities/agentic-development/plugin-distribution.md#an-intent-is-a-pointer),
for the same reason.
A procedure copied into a tool-specific instruction file can diverge from its source.
The same phrase can then produce different results across runtimes, despite appearing to follow the same standard.

A runtime may provide a shortcut, command, or packaged intent for an interaction.
It MUST NOT thereby define what the interaction does.

## What an interaction is not

The vocabulary remains small and separate from the workflow.

- An interaction MUST NOT define or replace a [workflow stage](Workflow.md#find-the-current-stage).
  Stages are how work progresses; interactions operate on the session. "Implement this issue"
  enters a stage and is not an interaction.
- An interaction MUST NOT be the only way to reach a procedure.
  A reader can reach the procedure through the index without knowledge of the phrase.
- An interaction MUST NOT carry authority the operator does not have. Parking an item creates
  an issue; it does not prioritize it. Wrap-up records a lesson; it does not change a standard.
- The vocabulary SHOULD stay small.
  A phrase set that needs its own reference becomes a command language that users must learn instead of recognize.
  Eight phrases is near the practical ceiling.
  Each phrase names a session operation that recurs in every project and otherwise lacks a consistent procedure.
  A ninth phrase needs to meet these conditions.
  If a phrase overlaps an existing one, extend the existing procedure instead.

Adding an interaction is a documentation change.
Define the procedure, bind a phrase to it here, and let each runtime reference it.
A phrase recognized by one runtime only is a local convenience and MUST NOT be relied on by documentation.

## Where this connects

- [Workflow](Workflow.md) — the stages interactions operate alongside, and the keyword shortcuts that enter them.
- [Agent Interaction](../Capabilities/agentic-development/agent-interaction.md#handover-is-a-state-not-a-message) — why handover is expressed as artifact state.
- [Plugin Distribution](../Capabilities/agentic-development/plugin-distribution.md) — how a runtime may package an interaction as an invocable intent without redefining it.
- [Runtime Integration](../Capabilities/agentic-development/runtime-integration.md) — what a runtime supplies, and why process is never part of it.
- [Spec-Driven Development](Spec-Driven-Development.md) — where a lesson found during wrap-up is written down.
