---
title: Session Interactions
description: Recognised phrases that steer a working session deterministically, why each is defined once as a standard rather than embedded in tool-specific files, and what an interaction may not do.
---

# Session Interactions

Most of a session is driven by the work itself: an issue is refined, a change is built, a
review is answered. But some things a contributor needs mid-session are not stages of the
work — they are operations *on* the session. Closing out cleanly. Setting a tangent aside
without losing it. Handing over.

These recur constantly and, left undefined, are performed differently every time. An
**interaction** is a recognised phrase bound to a defined procedure, so that asking for one of
these gets the same result on every occasion, in every runtime, from a human or an agent.

## An interaction is a phrase bound to a procedure

An interaction MUST be a short natural phrase, and it MUST resolve to a procedure defined in
documentation.

The phrase matters because the alternative is ceremony. A contributor mid-task will not invoke
a formal command to park a tangent; they will either describe the tangent in prose and hope it
is handled, or drop it. A recognised phrase costs nothing to use, which is the only reason it
gets used at the moment it is needed rather than retrospectively.

The binding to documentation matters because a phrase without a defined procedure is worse
than no phrase — it *looks* like a control while producing whatever the runtime improvises.

| Property | Requirement |
| --- | --- |
| Phrase | Short, natural, and unambiguous in the context of a working session |
| Procedure | Defined once in documentation, reachable from the index |
| Scope | Operates on the session or its artifacts, not on the domain of the work |
| Result | The same outcome regardless of runtime or operator |

## The standing vocabulary

These interactions are recognised. Each names a procedure that already exists elsewhere; the
phrase is the route to it, not a second definition of it.

| Phrase | What it means | What it does |
| --- | --- | --- |
| **Wrap up** | The session is ending, deliberately | Scan for work that exists but is not tracked — uncommitted changes, unpushed commits, undocumented decisions, lessons worth keeping — and land each one in its proper artifact |
| **Park** | This is real, but not now, and not here | Move a tangent out of the session into an issue in the repository that owns it, with enough context to be actionable later, and return to the original task |
| **Triage** | Decide what this is before working it | Classify the item — its type, the repository that owns it, whether it is already known — and route it, without beginning implementation |
| **Handoff** | Someone or something else continues this | Bring the artifacts to a state another participant can resume from, and record what remains as [state rather than as a message](../Capabilities/agentic-development/agent-interaction.md#handover-is-a-state-not-a-message) |
| **Status** | Tell me where this stands | Report what is done, in progress, and outstanding, with blockers and open decisions, referencing the issues and pull requests involved — and change nothing |
| **Checkpoint** | Save a known-good point and keep going | Bring the tree to a coherent state, record a work-in-progress commit and the task record, note what the checkpoint covers, and continue working |
| **Spin-off** | This is a separate concern | Move a tangent discovered mid-task into its own issue, cross-linked to the current work, so the pull request stays one concern |
| **Stop** | Abandon this | State plainly what will be discarded, confirm before touching anything, then discard it — salvaging anything worth keeping as an issue |

One property holds across the whole vocabulary, and it is what makes it worth having:
**no interaction decides anything about the work.** Parking an item does not judge it; triage
classifies but does not implement; status reports without steering. An interaction moves work
into the right place, or reports on it, and leaves the decision to whoever owns it.

Beyond that, they divide by what they leave behind, and the difference is worth being explicit
about because it determines how safe each one is to invoke:

| Effect | Interactions | Consequence |
| --- | --- | --- |
| Leave durable state | Wrap up, Park, Triage, Handoff, Checkpoint, Spin-off | Nothing is left in the session; it can be discarded without loss |
| Leave nothing | Status | Free to invoke at any time, including mid-task |
| Remove state | Stop | Destructive, and therefore the only interaction that MUST confirm first |

### Wrap up

Wrap-up exists because the end of a session is where work leaks. A contributor who has been
deep in a task holds a great deal that is not written down: a decision and its reason, a dead
end worth not repeating, a small problem noticed and not registered. Ending the session
discards all of it silently.

So wrap-up is a **scan**, not a summary. Producing a description of what happened is not
wrap-up; landing each untracked thing in the artifact that should hold it is. Where the scan
finds a problem too large to fix in scope, it becomes an issue in the owning repository —
never a note that survives only in the session.

### Park

Parking is the counterpart, applied mid-session. Real work is discovered while doing other
work, and the two bad options are to follow the tangent (losing the original task) or to drop
it (losing the tangent).

Park takes the third: the tangent becomes an issue in the repository that owns it, with the
context that makes it actionable, and the session returns to what it was doing. A parked item
MUST be legible to someone who was not in the session, because the session is exactly what
will not be available when the item is picked up.

### Triage

Triage separates *classifying* an item from *working* it. Something arrives — a report, a
request, an observation — and the reflex is to start on it, which commits effort before
establishing whether the item is well-formed, already known, or even owned here.

So triage resolves those questions and stops. Its output is a routed, classified item, and
beginning implementation during triage MUST be treated as leaving the interaction.

### Handoff

Handoff makes continuation possible without transferring context that only exists in one
head or one session. It is defined by its result: the artifacts alone are sufficient to
resume from.

That is why handoff is a state and not a message. A message announcing a handover leaves the
work in whatever state it happened to be in; a handoff brings the artifacts to a resumable
state first, and the announcement becomes redundant.

### Status

Status answers "where are we" — also phrased as *recap*, or *catch me up* — and its defining
property is that it has **no side effects**. It reports: what is done, what is in progress,
what remains, and which blockers or undecided questions stand in the way, referencing the
issues and pull requests concerned so the reader can go and look.

It creates nothing, commits nothing, and changes nothing. That constraint is the whole value.
An operation that might quietly commit, file, or reorganise something is one a contributor
hesitates to invoke mid-task; one that provably does not is free, and gets used at the moment
the question actually arises rather than at the end.

Status MUST NOT fix anything it notices. A problem found while reporting is a candidate for
[park](#park) or [spin-off](#spin-off), not something to slip in.

### Checkpoint

A checkpoint marks a known-good point and then **carries on**. That distinguishes it from
wrap-up, which ends the session, and from a handoff, which prepares it for someone else.

Bring the tree to a coherent state, record a work-in-progress commit on the topic branch,
update the task record, and note what the checkpoint covers and what comes next. Then keep
working.

The reason to have a phrase for it is that long tasks otherwise accumulate hours of
uncommitted work whose only backup is the session. A checkpoint costs a commit and converts an
unrecoverable position into a recoverable one. The commit is explicitly work in progress and
carries no claim to be complete or releasable.

### Spin-off

Spin-off and [park](#park) look similar and are aimed at different problems. Park sets a
tangent aside because it is *not now*. Spin-off separates a concern because it does not belong
in *this pull request*, even though it may well be worked next.

The test is scope, not timing: a pull request stays one concern, so a second concern gets its
own issue and its own pull request. Identify the tangent, say why it is separable, draft the
issue with a cross-reference to the current work, confirm, and return to the task.

A change that would make a reviewer ask "why is this here?" is a spin-off candidate.

### Stop

Stop is the only **destructive** interaction, and its procedure is shaped by that entirely.

State plainly what will be discarded — which commits, which uncommitted changes, which
branches, which open pull requests — and get confirmation **before touching anything**. Only
then revert or discard.

The confirmation is not politeness. "Stop", "abandon", and "drop it" are said in frustration
more often than in judgement, and a session that acts on the first reading of any of them will
eventually destroy something the contributor meant to keep.

Then record why. Work is abandoned for a reason, and that reason is usually the most valuable
thing the session produced: an approach that does not work, a constraint discovered late, a
dependency that turned out to be missing. Salvage anything worth keeping as an issue before
the rest is discarded.

## Defined once, referenced everywhere

An interaction MUST be defined in exactly one place, and every runtime that recognises it MUST
reference that definition rather than restate it.

This is the same rule the framework applies to
[client routes](../Capabilities/agentic-development/design.md#client-behavior) and to
[named intents](../Capabilities/agentic-development/plugin-distribution.md#an-intent-is-a-pointer),
for the same reason. An interaction embedded in a tool-specific instruction file is a copy,
and copies drift: the phrase then means one thing in one runtime and something subtly
different in another, while both appear to honour the same standard. A contributor who learns
the behaviour in one place is then wrong somewhere else, which is worse than not knowing it.

A runtime may make an interaction *easier to invoke* — a shortcut, a command, a packaged
intent. It MUST NOT thereby define what the interaction does.

## What an interaction is not

The vocabulary stays useful only by staying small and staying out of the way of the process.

- An interaction MUST NOT define or replace a [workflow stage](Workflow.md#find-the-current-stage).
  Stages are how work progresses; interactions operate on the session. "Implement this issue"
  enters a stage and is not an interaction.
- An interaction MUST NOT be the only way to reach a procedure. The phrase is a convenience
  over documentation that stands on its own, so the procedure remains reachable through the
  index by someone who has never heard the phrase.
- An interaction MUST NOT carry authority the operator does not have. Parking an item creates
  an issue; it does not prioritise it. Wrap-up records a lesson; it does not change a standard.
- The vocabulary SHOULD stay small. A phrase set large enough to need its own reference is a
  command language, and a command language is learned rather than recognised — which forfeits
  the reason for using phrases at all. Eight phrases is near the practical ceiling: each one
  earns its place by naming an operation on the session that recurs in every project and that
  is otherwise performed differently every time. A ninth needs to clear that bar, and a phrase
  that overlaps an existing one belongs in that one's procedure instead.

Adding an interaction is therefore a documentation change: define the procedure, bind a phrase
to it here, and let each runtime reference it. A phrase recognised by one runtime only is a
local convenience and MUST NOT be relied on by documentation.

## Where this connects

- [Workflow](Workflow.md) — the stages interactions operate alongside, and the keyword shortcuts that enter them.
- [Agent Interaction](../Capabilities/agentic-development/agent-interaction.md#handover-is-a-state-not-a-message) — why handover is expressed as artifact state.
- [Plugin Distribution](../Capabilities/agentic-development/plugin-distribution.md) — how a runtime may package an interaction as an invocable intent without redefining it.
- [Runtime Integration](../Capabilities/agentic-development/runtime-integration.md) — what a runtime supplies, and why process is never part of it.
- [Spec-Driven Development](Spec-Driven-Development.md) — where a lesson found during wrap-up is written down.
