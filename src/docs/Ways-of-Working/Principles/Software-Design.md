---
title: Software design
description: SOLID, extensibility, smart defaults with local overrides, secure by default, DRY with judgment, and making change easy before making the change.
---

# Software design

## SOLID — in plain language

- **Single Responsibility.** One thing does one thing.
- **Open / Closed.** Extend by adding, not by modifying what already works.
- **Liskov Substitution.** If something derives from a base, it should be safely usable wherever the base is expected.
- **Interface Segregation.** Don't make consumers depend on things they don't use.
- **Dependency Inversion.** Depend on abstractions, not concretions.

## Extensible by default

The Open/Closed principle applies beyond code. Ways of working and standards form the **stable core**. Tools such as coding agents, runtimes, and integrations are **pluggable adapters**. Adding or replacing a tool requires pointers to the process documentation, not copies of process knowledge.

A new agent runtime adds an integration layer without changing shared process documentation.

## API-first

Expose a capability through a versioned API contract first. Every consumer is a client of that contract: a web UI, a CLI, a script, another service, or an agent. No client has a privileged path around it.

Design the API before the consumers. This gives clients one authoritative contract. Additional clients use that contract without coordinating through the first client. An interface hidden inside a UI forces later clients to reimplement it or automate the UI.

Describe and version the contract explicitly, using an OpenAPI document for an HTTP surface. A consumer pins a compatible major version and accepts additive changes without a coordinated release. A contract implied only by code does not provide an explicit versioned interface.

A feature available only through one client does not satisfy the shared API contract.

## Smart defaults, local overrides

The default is the smart, secure choice for normal use and when the user has no reason to override it. A system with no configuration is correct, safe, and useful. Configuration expresses a deliberate deviation from the default, not a prerequisite for basic use.

Set the default at the broadest scope, and let each narrower scope override it. The setting closest to the thing it controls wins:

```text
org / ecosystem     the widest default — set once, inherited everywhere
└── repository      may narrow the default for one codebase
    └── directory   may narrow it further for one area
        └── item    the last word — closest to what it configures
```

This hierarchy supports two properties:

- **Manageable across the wide.** Change the default once. Items without a local override inherit it. No duplicate configuration needs manual editing.
- **Flexible in the narrow.** A local edit defines the exception beside the item that needs it. It does not change the default for other items.

Make the shared default and local override easy to set. When they differ, the more specific setting wins by its position in the hierarchy. Do not add special cases to change that order.

The safe choice requires no extra setup because it is the default. A deliberate local override contains the exception. [Least-privilege](Purpose-and-Direction.md#least-privilege) and [secure by default](#secure-by-default) apply this principle to permissions and security. Documentation uses the same hierarchy to connect beliefs and practices.

## Secure by default

The safe configuration requires no decision. Security is a default property, not an optional step that depends on memory.

This applies smart defaults with local overrides to risk. When a convenient default and a safe default differ, the safe option MUST be the default. Relaxing it MUST be explicit, local, and visible in review. Opt-in safety does not make an unsafe default secure.

Concretely:

- New surfaces start closed. Grant access, exposure, and permission deliberately instead of removing them after the fact.
- Secrets are never a fallback value. Absent configuration fails the operation rather than silently continuing with something weaker.
- Scope a relaxation to the item that needs it. Record the reason beside it so reviewers can find and revisit it.
- Validation runs by default. Disabling a check requires justification.

The default makes the safe choice the easy choice. If a default leads to an incorrect action, correct the default rather than blaming the person who followed it.

## DRY — with judgment

Don't Repeat Yourself, but **do not extract too early**. Wait until the same non-trivial logic appears in three or more places, or until duplication creates a clear maintenance risk. Premature abstraction adds maintenance costs before its need is clear.

## Clean Code

Write code that is understandable. Code is read more often than it is written. Names, structure, and intent come before cleverness.

> Code should read like prose. It should tell a story that is easy to follow.

## Evolutionary design / architecture

Do not fix a design before its unknowns are understood. Experiment and iterate. Treat design as an evolving product rather than a fixed contract. Retain architecture that continues to meet requirements as conditions change.

## Make change easy, then make the easy change

When a change is difficult, first prepare the system in a separate, focused step. Then make the behavior change. Keep the two concerns separate:

- **Prepare** — refactor, rename, extract, reorganize. No behavior change.
- **Change** — add, remove, or alter behavior. No structural churn.

If preparation is difficult, prepare that step first. Each structural step makes the next change easier. Repeat until the behavior change is simple.

Separate steps allow different levels of care. Structural changes are reversible: an extracted helper can be inlined, and a rename can be undone. Behavior changes can have irreversible effects, such as output sent, a form filed, or a triggered side effect. Separating the steps gives irreversible decisions the additional care they need.
