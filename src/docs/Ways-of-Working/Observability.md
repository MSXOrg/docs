---
title: Observability
description: Why every failure must be registered somewhere queryable, retained long enough for trends to be visible, and written as data rather than prose so an agent can triage it.
---

# Observability

A failure that is not captured did not happen, as far as the system is concerned. Nobody
can fix a defect nobody knows about, and nothing accumulates as quietly as a class of
error that has been failing in the same way for months without ever being counted.

Observability is therefore treated as a property of the system, not a feature of an
operations dashboard bolted on afterwards. The requirement is small to state and
demanding to hold: **every failure MUST be registered somewhere it can be queried.**

## Surface every failure

Every failure, error, and exception MUST be registered somewhere queryable — not only
emitted into a log stream nobody watches.

A log line satisfies the letter of "we recorded it" and none of its purpose. The
question a maintainer actually asks is *how often, since when, and is it getting
worse*, and that question cannot be answered by a stream that is only ever read
backwards from an incident. The test of whether a failure is surfaced is whether
someone can ask a question of it without already knowing it exists.

This is the same argument as [shift left](Principles/Engineering-Practices.md#shift-left),
applied after release rather than before: the cost of a defect grows with how long it
stays invisible, and an unregistered failure is invisible indefinitely.

## Slowness is a failure

A slow response MUST be treated as a signal that the architecture or the implementation
is deficient, and registered with the same rigor as a hard failure.

Latency is usually filed under user experience, which quietly reclassifies it as taste
rather than defect. It is a defect. A response that takes ten seconds is telling you
something structural — a missing index, a serial call that should be parallel, an
abstraction doing far more work than its name suggests — and the information is lost
the moment it is dismissed as a nuisance.

Registering it means the same thing as registering an exception: a record that can be
counted, compared against yesterday, and attached to a change.

## Register once, retain over time

Registering a failure once is necessary and not sufficient. Failure data MUST be
retained long enough for trends to be visible.

A single record tells you a thing failed. A retained series tells you whether it is a
one-off or a worsening pattern, whether a component is drifting toward an outage, and
whether the fix that shipped last week actually worked. Those are the only questions
worth acting on, and none of them can be answered from one data point.

So the durable artifact is an aggregate view rather than an individual line: counts
over time, grouped by kind and by component. The individual record remains the
evidence; the series is what gets read.

## Failures are data, not prose

A registered failure MUST be structured data, not a human-readable sentence.

This is the point where observability meets
[AI-First Development](Principles/AI-First-Development.md). An agent can only work on a
defect it can find, and it finds defects by querying — filtering by kind, counting by
component, correlating against a deployment. Prose defeats every one of those
operations. A message assembled for a human to read at 3am is a string that has to be
parsed back into the fields it was built from, and parsing prose is guessing.

Concretely:

- The failure kind, the component, and the correlating identifier are **fields**, not
  words inside a sentence.
- Free text MAY accompany a record; it MUST NOT be the only place a fact lives.
- If answering "how many of these, in which component, since when" requires reading,
  the record is not yet data.

## Where this connects

- [AI-First Development](Principles/AI-First-Development.md) — why the machine-readable form is the primary form, not a convenience.
- [Engineering Practices](Principles/Engineering-Practices.md#shift-left) — the same cost curve, applied before a change ships.
- [Error Handling](../Coding-Standards/Error-Handling.md) — how an individual failure is raised and what a message must carry.
- [Continuous Practices](Continuous-Practices.md) — the always-on practices this feeds, and the feedback loop it closes.
