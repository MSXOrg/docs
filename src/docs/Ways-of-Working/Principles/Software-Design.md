---
title: Software design
description: SOLID, extensibility, smart defaults with local overrides, DRY with judgment, and making change easy before making the change.
---

# Software design

## SOLID — in plain language

- **Single Responsibility.** One thing does one thing.
- **Open / Closed.** Extend by adding, not by modifying what already works.
- **Liskov Substitution.** If something derives from a base, it should be safely usable wherever the base is expected.
- **Interface Segregation.** Don't make consumers depend on things they don't use.
- **Dependency Inversion.** Depend on abstractions, not concretions.

## Extensible by default

Extend by adding, not by modifying what already works — the Open/Closed principle, applied beyond code to how the whole system grows. Ways of working and standards are the **stable core**; the tools that act on them — coding agents, runtimes, integrations — are **pluggable adapters** that slot in. Adding or swapping a tool means writing new pointers, not rewriting process knowledge.

The system stays pluggable: the docs do not change when a new agent runtime is added — only a new integration layer is written. See the [Agentic Development](../Agentic-Development.md) specification for how this plays out in practice.

## Smart defaults, local overrides

The default is the smart, secure choice — what you would pick most of the time, and the safe option when unsure. A system with no configuration is already correct, safe, and useful out of the box. Configuration exists to *deviate* from a good default, never to reach a usable one.

Set the default at the broadest scope, and let each narrower scope override it. The setting closest to the thing it controls wins:

```text
org / ecosystem     the widest default — set once, inherited everywhere
└── repository      may narrow the default for one codebase
    └── directory   may narrow it further for one area
        └── item    the last word — closest to what it configures
```

This shape is chosen for manageability over the life of a system, and it earns two properties at once:

- **Manageable across the wide.** Change the default in one place and everything that has not opted out follows. You set the norm once instead of finding and editing many copies of it.
- **Flexible in the narrow.** Deviating is a small, local edit beside the item that needs it — not a fight with the system, and not a change that ripples outward. The exception lives with the thing it applies to.

Make the wide default easy to set and the local override easy to make. When the two disagree, the more specific one wins — predictably, by its position in the hierarchy, never by special-casing.

This is [Easy and Safe](../../index.md) expressed as design: doing the right thing takes no effort because it is the default, and deviating is deliberate and contained because it is a local override. [Least-privilege](Purpose-and-Direction.md) and [secure by default](../../Coding-Standards/Security.md) are this principle applied to permissions and security; the way [the vision cascades](../../Vision/index.md) is its shape applied to knowledge.

## DRY — with judgment

Don't Repeat Yourself, but **don't extract too early**. Wait until the same non-trivial logic appears in three or more places, or until the duplication is clearly load-bearing. Premature abstraction is more expensive than duplication.

## Clean Code

Write code that is understandable. Code is read more often than it is written. Names, structure, and intent come before cleverness.

> Code should read like prose. It should tell a story that is easy to follow.

## Evolutionary design / architecture

Don't decide what you don't yet know. Experiment, iterate, treat design as a product — not a fixed contract. Architecture earns its right to be permanent by surviving change.

## Make change easy, then make the easy change

When a change is hard, resist the temptation to force it. First, restructure the system so the change becomes easy — as a separate, focused step. Then make the change itself. This separates two concerns:

- **Prepare** — refactor, rename, extract, reorganise. No behaviour change.
- **Change** — add, remove, or alter behaviour. No structural churn.

Applied recursively: if the preparation step is also hard, first make that easy. Work like a zipper — each structural step unlocks the next, until the actual behaviour change is trivial.

Keeping the two steps separate also lets you apply different levels of rigour. Structural changes are reversible — an extracted helper can be inlined again, a rename can be undone. Behaviour changes are often not — output sent, a form filed, a side effect triggered cannot be recalled. Irreversible decisions deserve more care. Separating the two gives you room to apply that care where it actually matters.
