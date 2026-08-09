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

Two properties are shared by all four, and they are what make the vocabulary worth having:

- **None of them decide anything about the work.** Parking an item does not judge it; triage
  classifies but does not implement. An interaction moves work into the right place and leaves
  the decision to whoever owns it.
- **All of them end with durable state.** The value of an interaction is that nothing is left
  in the session — after wrap-up or handoff, the session can be discarded without loss.

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
  the reason for using phrases at all.

Adding an interaction is therefore a documentation change: define the procedure, bind a phrase
to it here, and let each runtime reference it. A phrase recognised by one runtime only is a
local convenience and MUST NOT be relied on by documentation.

## Where this connects

- [Workflow](Workflow.md) — the stages interactions operate alongside, and the keyword shortcuts that enter them.
- [Agent Interaction](../Capabilities/agentic-development/agent-interaction.md#handover-is-a-state-not-a-message) — why handover is expressed as artifact state.
- [Plugin Distribution](../Capabilities/agentic-development/plugin-distribution.md) — how a runtime may package an interaction as an invocable intent without redefining it.
- [Runtime Integration](../Capabilities/agentic-development/runtime-integration.md) — what a runtime supplies, and why process is never part of it.
- [Spec-Driven Development](Spec-Driven-Development.md) — where a lesson found during wrap-up is written down.
