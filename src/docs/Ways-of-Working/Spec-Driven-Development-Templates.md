---
title: Spec-Driven Development Templates
description: A copyable skeleton for every spec-driven artifact — specification, feature addendum, design, implementation doc, guide, reference, research, decision record, standard, orchestration playbook, and decisions register.
---

# Spec-Driven Development Templates

Each artifact tier defined in [Spec-Driven Development](Spec-Driven-Development.md#the-artifact-tiers) has a template. Copy the template for the artifact. Each template contains all standard sections. **Delete a heading rather than marking it "N/A"** when it does not apply. Empty sections make relevant content harder to find.

Apply the [authoring conventions](Spec-Driven-Development.md#authoring-conventions) for the artifact being written. Specifications and designs use present-tense, impersonal, normative prose without document-maintenance dates or delivery status. Guides and playbooks use direct imperative steps. Research records past findings. Decision records preserve the rationale for the original choice.

Use the [subject-focused content rule](Documentation-Model.md#subject-focused-content) when you replace the placeholders.

These are durable artifact templates, not issue-body or implementation-plan templates. Issues follow their canonical [planning altitude](Issues/Process/Planning.md). Delivered work verifies the resulting artifacts through the shared [documentation and design evidence](Definition-of-Ready-and-Done.md#documentation-and-design-evidence) gate.

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

### FR1 — <what the capability does, behavioral, testable, no technology> {#fr1}

#### Behavioral scenarios

```gherkin
Scenario: <the case that makes FR1 concrete>
  Given <precondition>
  When <action>
  Then <observable result>
```

### FR2 — <...> {#fr2}

## Non-functional requirements

### NFR1 — <a quality attribute as a measurable condition: latency, availability, redaction, retention, cost> {#nfr1}

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
- <Any core requirement this feature specializes, linked by anchor into the core spec.>

## Scope

**In scope**

- <...>

**Out of scope**

- <...>

## Functional requirements

### FR1 — <feature-specific behavior> {#fr1}

#### Behavioral scenarios

```gherkin
Scenario: <...>
  Given <...>
  When <...>
  Then <...>
```

## Non-functional requirements

### NFR1 — <feature-specific quality attribute, measurable> {#nfr1}
````

## Design

````markdown
---
title: <Capability name> — Design
description: <One line: how the capability is built.>
---

# <Capability name> — Design

<The implementation approach, how it works, and why it satisfies the requirements.>

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

This artifact is optional. It holds concrete detail that needs a separate page under the [design/implementation altitude test](Spec-Driven-Development.md#what-a-design-is).

````markdown
---
title: <Capability name> — Implementation
description: <One line: the concrete values and names behind the design.>
---

# <Capability name> — Implementation

<The concrete settings, values, or identifiers and why the implementation uses them.>

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

<One line: the result of the procedure.>

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
description: <One line: the settings, interfaces, or values available for lookup.>
---

# <What is being looked up>

<The settings, interfaces, or values and the context needed to interpret them.>

| <Name> | <Type> | <Default> | <Meaning> |
|---|---|---|---|
| <...> | <...> | <...> | <...> |
````

## Research

Research is the one artifact written in the past tense. Git records its document dates.

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

<The context and constraint that made a choice necessary.>

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

## Standard

A standard states a rule, its rationale, and its enforcement method. The rationale appears beside the rule.

````markdown
---
title: <Subject the rule governs>
description: <One line: what this standard requires.>
---

# <Subject the rule governs>

<One paragraph: the rule in a sentence, and what goes wrong without it.>

## The source of truth

<Where the authoritative definition lives — a file, a config, a schema — and what
derives from it. Everything else references it rather than restating it.>

## Rules

| Rule | Requirement |
|---|---|
| <name> | <MUST / SHOULD / MAY statement> |

<Or a `###` subsection per rule where the rationale needs a separate explanation.>

## Enforcement

<What catches a violation, and where in the loop — editor, pre-commit, CI, review.>

## Exceptions

<The narrow cases the rule does not cover, how an exception is recorded, and who
may grant one. "None" is a valid answer and is better than silence.>
````

## Orchestration playbook

A playbook coordinates work in stages. Each stage finishes before the next starts. **Exit criteria** give observable completion evidence. The next stage cannot start until those criteria hold.

````markdown
---
title: <The orchestrated activity>
description: <One line: what this playbook produces.>
---

# <The orchestrated activity>

<The coordinated outcome and why the stages must run in order.>

## Purpose and scope

<The work and boundaries of the coordinated process.>

**Out of scope**

- <the adjacent thing this deliberately does not do, and where it belongs instead>

## Inputs and prerequisites

| Input | Required | Notes |
|---|---|---|
| <what must exist before starting> | Yes / No | <where it comes from> |

## Workflow stages

### Stage 1 — <name>

<What happens, and what it establishes.>

**Exit criteria.** <The observable condition that means this stage is done.>

### Stage 2 — <name>

<...>

**Exit criteria.** <...>

## Quality gates

<The conditions that hold across stages, not just at the end — what invalidates the
run and forces a return to an earlier stage.>

## Outputs and evidence

<What exists when the run completes, and where it lives. Evidence means artifacts a
reader can inspect, not an assertion that the work was done.>

## Canonical references

- [<Standard or capability this defers to>](<path>) — <what it carries>
````

## Decisions register

A register indexes settled decisions so each question is answered once. It does not replace a [decision record](#decision-record). A record explains one choice in detail, while the register links to choices that are no longer open.

````markdown
---
title: <Scope> — Decisions
description: <One line: the decisions this register holds.>
---

# <Scope> — Decisions

<The scope of the settled choices and their effect on the subject.>

## Recorded decisions

| Decision | Record |
|---|---|
| <the choice, stated as what is now true> | [<record>](<path>) |

## Standing choices

<Settled choices that are too small to need separate records. Each
links to the page that contains the detail.>

- **<Choice>** — <what was chosen and why>, per [<page>](<path>).
````

## Where this connects

- [Spec-Driven Development](Spec-Driven-Development.md) — the method these templates serve.
- [Documentation Model](Documentation-Model.md#capabilities-live-in-folders) — where each artifact file lives.
- [Markdown](../Coding-Standards/Markdown.md) — how the Markdown itself is written.
