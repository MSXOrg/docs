---
title: Vision
description: The mission and the philosophy of easy, fast, and safe.
---

# Vision

MSX exists to make great software delivery the **default** — easy, fast, and safe — for every developer and every agent.

This page states the **why** behind MSX. Products, languages, and tools change; the mission remains stable. The [Ways of Working](../Ways-of-Working/index.md), [Coding Standards](../Coding-Standards/index.md), and [Initiatives](../Initiatives/index.md) follow this mission.

## Start with Why

Work at every level is grounded in three concentric questions — the [Golden Circle](../Ways-of-Working/Principles/Purpose-and-Direction.md#start-with-why-the-golden-circle):

- **Why** — what change in the world is this trying to make? *Make the right thing the easy thing, so good software ships fast and safely.*
- **How** — what approach makes that change happen? *Everything as code, context before code, deterministic automation first, AI where judgment is needed, humans in the loop.*
- **What** — what concrete thing is being delivered right now? *The frameworks, actions, modules, and tools in the [Initiatives](../Initiatives/index.md).*

The Why is constant. The How is the way of working. The What is replaceable.

## The mission

> Make great software delivery the default — easy, fast, and safe — for every developer and every agent.

The mission gives contributors a shared direction for product decisions. It is not a roadmap or a product. The [Goal-Setting Framework](../Ways-of-Working/Goal-Setting.md) connects the mission to measurable objectives and concrete work.

## The three words

Every decision considers **easy**, **fast**, and **safe** together.

| Word     | What it asks of every decision                                                              |
| -------- | ------------------------------------------------------------------------------------------- |
| **Easy** | Is the right thing also the easy thing? Is the safe, smart choice the default choice?        |
| **Fast** | Does this shorten the loop between intention and feedback? Is there a thinner slice to ship now?  |
| **Safe** | Is this reversible? Is it observable? Will a failure teach something instead of causing harm?  |

Easy, fast, and safe are joint decision criteria. Ease without safety permits harmful choices. Safety without timely delivery prevents progress. Speed without ease increases workload. Each decision balances all three.

## AI-first, determinism-first

Two beliefs guide the work:

- **AI is a first-class participant.** Agents contribute to planning, implementation, and delivery. Workflows and documents support agent participation from the start.
- **Determinism comes first.** Deterministic tools handle work with a predictable, repeatable answer. AI *builds* those tools. It also handles ambiguity, judgment, natural language, and search spaces too large for handwritten rules.

Deterministic automation handles repeatable work. AI handles work that requires judgment or variable interpretation. Both remain available within the workflow, each for the work it handles best. [Principles → AI-first development](../Ways-of-Working/Principles/AI-First-Development.md) explains this division.

## How the vision cascades

The vision is defined once on this site and referenced by each layer:

```text
Vision (this site)              the why — stable, evergreen
└── Principles                  the beliefs every layer conforms to
    └── Ways of Working         the how — workflow, process, conventions
        ├── Coding Standards    the how, applied to code
        └── Capabilities        the how, applied to a named capability
            │                   each with its own spec (why/what) and design (how/what)
            └── Initiatives     the what — the products
                └── Repositories  each README is the local source of truth
                    └── Agents    read the same documentation as context before acting
```

Each layer references the one above instead of restating it. A repository's README links to the principles. An agent pointer leads to the documentation indexes instead of embedding a style guide or workflow stage. This preserves a single source of truth as the layers evolve.

References point in one direction only: upward. A layer names the layer it conforms to, and never enumerates the layers that conform to it. This direction keeps higher layers stable when a capability or repository changes.

## Where it comes to life

The [Initiatives](../Initiatives/index.md) apply the vision through products. Each one answers the same design question:

> What would this look like if it were easy, fast, and safe?

The [Initiatives](../Initiatives/index.md) describe how products apply these principles.
