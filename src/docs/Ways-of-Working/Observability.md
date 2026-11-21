---
title: Observability
description: Why every failure must be registered somewhere queryable, retained long enough for trends to be visible, and written as data rather than prose so an agent can triage it.
---

# Observability

An unregistered failure supplies no queryable evidence for investigation or trend
analysis. Maintainers need records to identify defects and count repeated errors.

Observability is a system property, not only a dashboard feature.
**Every failure MUST be registered somewhere it can be queried.**

## Surface every failure

Every failure, error, and exception MUST be registered somewhere queryable.
A log stream alone does not satisfy this requirement unless its failure records
can be queried.

Maintainers need to query failure frequency, first occurrence, and changes over
time. A failure is surfaced when a maintainer can find it through a query without
first knowing it exists.

This applies the [shift left](Principles/Engineering-Practices.md#shift-left)
principle after release. Early detection limits the time that a defect remains
unobserved. Queryable records make that detection possible.

## Slowness is a failure

The system MUST treat a slow response as a defect signal and register it with the
same rigor as a hard failure.

A slow response can indicate a defect in the architecture or implementation.
It is not only a user-experience concern. For example, a response that takes ten
seconds can indicate a structural defect. Possible causes include a missing
index, sequential calls that can run in parallel, or an abstraction that does
unnecessary work.

The slow-response record supports counts, comparisons across days, and
correlation with a change, as an exception record does.

## Register once, retain over time

One failure record is not sufficient. Failure data MUST be retained long enough
for trends to be visible.

A retained series shows whether a failure is isolated or becomes more frequent.
It can show whether a component approaches an outage and whether a released fix
corrects the defect.

An aggregate view shows counts over time, grouped by kind and component.
The individual records remain the evidence for that view.

## Failures are data, not prose

A registered failure MUST be structured data, not a human-readable sentence.

Structured fields let an agent query failure facts directly. The agent can filter
by kind, count by component, and correlate records with a deployment. This
supports [AI-First Development](Principles/AI-First-Development.md).

A prose message requires the reader or agent to extract those facts from text.
Structured records keep the facts explicit and consistently queryable.

Concretely:

- The failure kind, the component, and the correlating identifier are **fields**, not
  words inside a sentence.
- Free text MAY accompany a record; it MUST NOT be the only place a fact lives.
- If answering "how many of these, in which component, since when" requires reading
  free text, the record is not structured data.

## Where this connects

- [AI-First Development](Principles/AI-First-Development.md) — why the machine-readable form is the primary form, not a convenience.
- [Engineering Practices](Principles/Engineering-Practices.md#shift-left) — the same cost curve, applied before a change ships.
- [Error Handling](../Coding-Standards/Error-Handling.md) — how an individual failure is raised and what a message must carry.
- [Continuous Practices](Continuous-Practices.md) — the always-on practices this feeds, and the feedback loop it closes.
