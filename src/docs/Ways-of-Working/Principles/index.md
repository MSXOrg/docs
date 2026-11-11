---
title: Principles
description: The foundational beliefs and product mindset behind every decision.
---

# Principles

These principles guide work between people and agents. They remain stable as products and practices change.

Each theme has a separate page so a reader or agent can load only the relevant principles. Use the index to select a theme for the task.

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

These principles supply shared assumptions when behavior is unclear or contested. A correction belongs in the owning principle, not in an isolated agent, repository, or review.

## What a principle is

A principle states a belief that applies across every capability, repository, and runtime. It states a position rather than a procedure. Standards and specifications describe how to apply that position in a specific context.

A principle MUST be true of work that has not been imagined yet. A rule for one capability, language, or tool belongs in its standard or specification. Adding a product does not require a principle to change.

## Principles do not link down

Every layer below this one conforms to these principles and MUST NOT restate them. The direction of reference is fixed:

- A standard, specification, or design **links up** to the principle it obeys, and never copies its wording.
- A principle **does not link down** in normative prose to the standard,
  capability, or product that applies it.

A principle that lists its implementations requires an edit whenever a capability is added or retired. One-directional references let implementations change without changing the principle.

The generated index and other navigation links are allowed to list their direct
children: they help a reader find a page and do not claim that a child implements
or governs its parent. The prohibition applies to normative dependency links,
which would couple a stable principle to the changing things that apply it.

This layer explains *why* a principle applies. Standards and specifications identify the principles they follow. Readers discover those relationships from the applying layer instead of a duplicate list here.

A principle MAY name another principle. References between principles are horizontal and do not create a dependency on an implementation.
