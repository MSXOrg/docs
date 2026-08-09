---
title: Spec-Driven Development Templates
description: A copyable skeleton for every spec-driven artifact — specification, feature addendum, design, implementation doc, guide, reference, research, and decision record.
---

# Spec-Driven Development Templates

One skeleton per artifact tier defined in [Spec-Driven Development](Spec-Driven-Development.md#the-artifact-tiers). Copy the one that matches the tier being written. Every section is present so nothing is forgotten; **delete a heading rather than marking it "N/A"** — empty scaffolding hides the real content.

Each template assumes the [authoring conventions](Spec-Driven-Development.md#authoring-conventions): present tense, impersonal, normative, and free of dates and status.

## Specification

````markdown
---
title: <Capability name> — Spec
description: <One line: what this capability guarantees.>
---

# <Capability name> — Spec

<One paragraph of intended state — present tense, as if it already exists.>

## Problem

<The enduring condition this capability addresses, and who it affects.>

## Outcomes and impact

- **Outcome:** <what becomes true for users or operators>
- **DORA:** <expected direction — lead time · deploy frequency · change-failure rate · time to restore>
- **Domain signal:** <one measurable metric this moves>

## Users and jobs

<Who uses this, and the job it gets done.>

## Scope

**In scope**

- <...>

**Out of scope**

- <...>

## Non-goals

- <an outcome someone might expect this to pursue that it deliberately does not — and why>

## Functional requirements

### FR1 — <what the capability does, behavioral, testable, no technology> { #fr1 }

#### Behavioral scenarios

```gherkin
Scenario: <the case that makes FR1 concrete>
  Given <precondition>
  When <action>
  Then <observable result>
```

### FR2 — <...> { #fr2 }

## Non-functional requirements

### NFR1 — <a quality attribute as a measurable condition: latency, availability, redaction, retention, cost> { #nfr1 }

#### Behavioral scenarios

```gherkin
Scenario: <the case that makes NFR1 measurable>
  Given <precondition>
  When <action>
  Then <observable result within the stated threshold>
```

## Acceptance criteria

<Cross-cutting scenarios only — behavior spanning more than one requirement. Requirement-local scenarios stay under their requirement.>

```gherkin
# AC1 — Verifies: FR1, NFR1
Scenario: <the flow that spans both>
  Given <precondition>
  When <action>
  Then <observable result>
```

## Constraints and assumptions

- **Constraint:** <a boundary the solution respects>
- **Assumption:** <taken as true; flag if unverified>

## Dependencies

- <work, access, or decision this waits on — linked>

## Open questions

- [NEEDS CLARIFICATION: <specific question>]   <!-- resolved and removed before acceptance -->

## Where this connects

- `design.md` — how these requirements are delivered.
````

## Feature addendum

A [feature addendum](Spec-Driven-Development.md#core-and-feature-addenda) extends the core spec. It restates nothing and starts its own numbering at `FR1`.

````markdown
---
title: <Feature name>
description: <One line: what this feature adds to the capability.>
---

# <Feature name>

<One paragraph: what this feature makes true, and how it relates to the core.>

## Extends

- `../spec.md` — the core requirements this feature inherits.
- <Any core requirement this feature specialises, linked by anchor into the core spec.>

## Scope

**In scope**

- <...>

**Out of scope**

- <...>

## Functional requirements

### FR1 — <feature-specific behavior> { #fr1 }

#### Behavioral scenarios

```gherkin
Scenario: <...>
  Given <...>
  When <...>
  Then <...>
```

## Non-functional requirements

### NFR1 — <feature-specific quality attribute, measurable> { #nfr1 }
````

## Design

````markdown
---
title: <Capability name> — Design
description: <One line: how the capability is built.>
---

# <Capability name> — Design

<One paragraph on how the spec is realised.>

## Specification

<Link to the specification this design serves.>

## Approach

<The chosen approach, and why it satisfies the requirements.>

## Alternatives considered

| Option | Trade-offs | Verdict |
|---|---|---|
| <option> | <trade-offs> | Chosen / Rejected — <reason> |

## Architecture

<Components and how they fit together. A diagram where it helps.>

## Data and contracts

<Schemas, interfaces, APIs, and events other things depend on.>

## Security

<Trust boundaries, authentication and authorization, secrets, and threats for new surfaces.>

## Testing strategy

<How the requirement scenarios and acceptance criteria are verified — contract, integration, end-to-end, unit — and what runs in CI.>

## Rollout and operability

<Sequencing, feature flags, migration, observability, and the runbooks for the top alerts.>

## Decisions

<Decision-record links for the one-way-door choices made here.>
````

## Implementation doc

Optional. Added only once the design has accumulated concrete detail — see the [design/implementation altitude test](Spec-Driven-Development.md#what-a-design-is).

````markdown
---
title: <Capability name> — Implementation
description: <One line: the concrete values and names behind the design.>
---

# <Capability name> — Implementation

<One line: what concrete detail this page pins, and which design it serves.>

## Design

<Link to the design this implements.>

## Settings

| Setting | Value | Applies to | Rationale |
|---|---|---|---|
| <name> | <exact value> | <scope> | <why this value> |

## Names and identifiers

| Element | Name | Owner |
|---|---|---|
| <element> | <exact name> | <owning component> |

## Requirement crosswalk

| Requirement | Satisfied by |
|---|---|
| FR1 | <the concrete element that satisfies it> |
````

## Guide

````markdown
---
title: <Task the reader wants to accomplish>
description: <One line: the outcome of following these steps.>
---

# <Task the reader wants to accomplish>

<One line: what the reader ends up with.>

## Before starting

- <access, tool, or state required>

## Steps

1. <one action, imperative, verifiable>
2. <...>

## Verify

<How the reader confirms it worked.>

## If it fails

| Symptom | Cause | Resolution |
|---|---|---|
| <symptom> | <cause> | <resolution> |
````

## Reference

````markdown
---
title: <What is being looked up>
description: <One line: the facts this page holds.>
---

# <What is being looked up>

<One line: what this page is the single source for.>

| <Name> | <Type> | <Default> | <Meaning> |
|---|---|---|---|
| <...> | <...> | <...> | <...> |
````

## Research

Research is the one artifact written in the past tense. Git carries its dates.

````markdown
---
title: <Question that was investigated>
description: <One line: what was explored and what it concluded.>
---

# <Question that was investigated>

## Question

<What was being decided, and why the answer mattered.>

## What was examined

- <option, source, or experiment>

## Findings

| Finding | Evidence |
|---|---|
| <what was found> | <link or measurement> |

## Conclusion

<What the exploration concluded, and the spec, design, or decision record that now carries it.>
````

## Decision record

````markdown
---
title: <Decision, stated as the choice made>
description: <One line: the decision and its scope.>
---

# <Decision, stated as the choice made>

## Context

<The forces in play and the constraint that made a choice necessary.>

## Decision

<The choice, stated in the present tense as the thing that is now true.>

## Options considered

| Option | Trade-offs | Verdict |
|---|---|---|
| <option> | <trade-offs> | Chosen / Rejected — <reason> |

## Consequences

- <what this makes easy>
- <what this makes hard, and what would have to change to revisit it>

## Supersession

<Nothing, or: superseded by <link>, which now carries this choice.>
````

## Where this connects

- [Spec-Driven Development](Spec-Driven-Development.md) — the method these templates serve.
- [Documentation Model](Documentation-Model.md#capabilities-live-in-folders) — where each artifact file lives.
- [Markdown](../Coding-Standards/Markdown.md) — how the Markdown itself is written.
