---
title: Principles
description: The foundational beliefs and product mindset behind every decision.
---

# Principles

The ideas underneath how work happens — between people, and between people and their agents. These are evergreen; every other layer refers back to them.

Principles are grouped by theme; each theme is its own page so an agent can load only the one it needs. Start here, then follow the theme that fits the task.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Purpose and direction](Purpose-and-Direction.md) | The purpose behind the work, the audience it serves, and the least-privilege stance under every decision. |
| [AI-first development](AI-First-Development.md) | Agents as first-class participants, determinism before intelligence, and how humans and agents share the work. |
| [Software design](Software-Design.md) | SOLID, extensibility, smart defaults with local overrides, secure by default, DRY with judgment, and making change easy before making the change. |
| [Engineering practices](Engineering-Practices.md) | Write it down, everything as code, evergreen documentation, test-driven development, fleet-wide change, and shift-left quality. |
| [Planning and delivery](Planning-and-Delivery.md) | Roadmapping, lean delivery, and the loops that keep iteration fast. |
| [References](References.md) | The literature behind these principles. |

<!-- INDEX:END -->

## Why these principles matter

These are the assumptions every other decision rests on. When behaviour is unclear or contested, the answer comes from here. When something here turns out to be wrong, this page changes — not one agent, one repository, or one review.

## What a principle is

A principle is a belief that holds across every capability, repository, and runtime. It states a position, not a procedure: it says what is always true, and leaves to a standard or a specification the question of how that is achieved in one place.

A principle MUST be true of work that has not been imagined yet. A rule that only makes sense for one capability, one language, or one tool is not a principle — it belongs in the standard or specification that owns that ground. This is the test that keeps this layer small: if a statement would need editing when a new product is added, it was never a principle.

## Principles do not link down

Every layer below this one conforms to these principles and MUST NOT restate them. The direction of reference is fixed:

- A standard, specification, or design **links up** to the principle it obeys, and never copies its wording.
- A principle **does not link down** to the standard, capability, or product that applies it.

The asymmetry is deliberate. A principle that names the things that currently implement it acquires a maintenance burden it cannot carry: every new capability becomes an edit here, and every retired one leaves a dangling claim. Keeping references one-directional means this layer stays stable while everything beneath it moves.

The consequence for a reader is that this layer answers *why*, and never enumerates *where*. To find what applies a principle, read the layer that claims it — the standard or specification says which principle it conforms to, so the relationship is discoverable from below without being duplicated above.

A principle MAY name another principle. Cross-references inside this layer are horizontal, not downward, and do not create the coupling this rule exists to prevent.
