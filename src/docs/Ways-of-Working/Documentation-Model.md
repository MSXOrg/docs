---
title: Documentation Model
description: How every capability is documented — a spec for the why and a design for the how, colocated, concise, and kept evergreen for humans and agents alike.
---

# Documentation Model

Documentation is a product, not a byproduct — and it is written once for two
audiences, **humans and agents**. This page describes how the documentation on
this site is organised so both find what they need fast: every capability is
described by a **spec** and a **design**, kept side by side, kept short, and
kept current as the system evolves.

## A spec and a design for every capability

Each capability the ecosystem builds is documented by two evergreen documents:

| Document | Owns | Answers | Written for |
| --- | --- | --- | --- |
| **Spec** | Requirements, expectations, needs | **Why** it exists and **what** it must do | Whoever decides *whether* and *what* to build |
| **Design** | Implementation approach | **How** and **what** we build to deliver the spec | Whoever *builds* and maintains it |

The **spec** is the contract — the behaviour, guarantees, and success criteria a
user (human or agent) can rely on. It never prescribes implementation. The
**design** is the current answer to *how we deliver that contract*: the
mechanism, the moving parts, the configuration. Both are durable, and both
evolve — neither is a one-time plan.

Only the detail of a *single change* — the paths touched, the trade-off taken
this once — stays out of both, living in the [issue](Issue-Format.md) and the
pull request where it belongs.

## Capabilities live in folders

Related docs sit together, and close to the thing they describe. Each capability
is a folder holding its spec and design side by side:

```text
Capabilities/
  release-management/
    index.md      # what this capability is
    spec.md       # the why + what
    design.md     # the how + what we build
```

A reader opens one folder and has the whole picture — the requirement and the
implementation, one click apart. This is [Documentation lives close to the thing
it documents](Principles/Engineering-Practices.md#documentation-lives-close-to-the-thing-it-documents)
applied to the spec–design pair; where a design maps to a repository, the same
two documents live with the code.

## Why, what, how — a home for everything

| Concern | Owned by |
| --- | --- |
| **Why / what** a capability must do | the capability's **spec** |
| **How / what** we build to deliver it | the capability's **design** |
| **How we work** — process, principles, conventions | [Ways of Working](index.md) |
| **How code looks** — style applied to code | [Coding Standards](../Coding-Standards/index.md) |
| **How this one change is implemented** — paths, trade-offs | the [issue](Issue-Format.md) and the PR |

Keeping implementation out of the spec is what makes the spec durable:
implementation detail rots fastest, so the spec leaves it to the design, and the
design leaves per-change detail to the issue and the PR.

## It starts with a need

Every capability begins with a need and moves through a spec, then a design,
then code — and loops:

1. **Need** — a request, a bug, a review observation, a platform change.
2. **Spec** — agree the next version's requirements: why it matters and what it
   must do. Nothing is committed to building yet.
3. **Design** — once committed to deliver, describe how and what we will build.
4. **Build** — implement, evolving the design *and* the spec as development
   teaches you things.
5. **Operate** — running the system surfaces new needs, and the loop returns.

```mermaid
flowchart LR
    Need(["Need<br/>(request, bug, signal)"]) --> Spec["Spec<br/>(why + what)"]
    Spec --> Design["Design<br/>(how + what)"]
    Design --> Build["Build<br/>(spec + design evolve)"]
    Build --> Ops["Operate"]
    Ops -->|new needs| Need
```

Both the spec and the design are **evolutionary**: development almost always
changes your understanding, so you amend them in place rather than treating the
first draft as fixed. The gap between the spec and what the system actually does
is the work.

## Evergreen and evolutionary

Specs and designs are **evergreen**: written in the present tense as if the
system already behaves as described, and amended in place as intent changes. Git
history records what changed; the document records only what is true now.

- **Declarative and present-tense.** It reads like a good README — a reader
  trusts any line as the current contract.
- **Normative.** Requirements use MUST / SHOULD / MAY so obligations are
  unambiguous.
- **No status, deltas, phasing, or open questions.** Those rot the moment they
  are written; they belong in issues, PRs, and git history.
- **Measurable success criteria.** A spec states outcomes a reader can verify —
  *"a repository list returns every repository by default, with no silent
  truncation"* — never *"the sync is fast."*

Before a spec or design change is accepted it passes a quick rubric — is every
requirement testable, are criteria measurable and implementation-free, is it
present-tense and free of status? — applied in the reviewer's head and the PR
([4-eyes](Principles/AI-First-Development.md#4-eyes-or-n-eyes-principle)), leaving no artifact behind.

## Concise by default

Respect the reader's attention — human or agent. A document earns nothing by
being long.

- **Short and scannable.** Lead with the point. Prefer a table or a list to a
  paragraph. If a reader must scroll to find the rule, it is too long.
- **One fact, one place.** State a thing once and link to it; never duplicate
  ([DRY](Principles/Software-Design.md#dry-with-judgment)). Duplication is how docs begin to
  disagree with themselves.
- **Delete, don't stub.** A section that does not apply is removed, not marked
  "N/A". Empty scaffolding hides the real content.
- **Close together.** Related docs share a folder; docs sit near the code they
  describe. Laziness is a design constraint — the less a reader must travel, the
  more they actually read.

## For humans and agents

The same pages serve both. A contributor reads the index, follows the
description inward, and drills from section to page until they reach the answer;
an agent does exactly the same before it acts. Because the docs are the single
source, there is no separate "agent manual" to drift —
[Agentic Development](Agentic-Development.md) explains how agent configuration
points at these pages rather than copying them.

## Where this connects

- [Workflow](Workflow.md) — the loop specs and designs revolve around.
- [Agentic Development](Agentic-Development.md) — how humans and agents consume these docs.
- [README-Driven Context](Readme-Driven-Context.md) — why the README is the front door and the spec goes ahead of the code.
- [Coding Standards](../Coding-Standards/index.md) — how the code a design describes is written.
