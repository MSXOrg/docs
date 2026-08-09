---
title: Repository Segmentation
description: What belongs in a repository, and when to split or combine.
---

# Repository Segmentation

What belongs in a repository, and when to split or combine. The boundary of a repository is the boundary of ownership, versioning, and deployment — and therefore of a single responsibility, a single development lifecycle, and a single branch strategy. When those three align, the parts belong together; when any of them diverges, that divergence is the seam to split on.

## One repository per independently-versioned thing

- A repository holds one thing that is owned, versioned, and released as a unit. If two parts ship on different schedules or to different places, they are two repositories.
- The test: can it be described in one sentence, owned by one team, and released on its own? If not, it is more than one repository.

## Single responsibility — the S in SOLID, at repository scale

- The [Single Responsibility Principle](Principles/Software-Design.md#solid-in-plain-language) is not only for classes. A repository, like a class, should have **one reason to change**: one responsibility, one deployable, one audience.
- A module, an action, a service, an infrastructure stack — each is a single responsibility, so each is its own repository. When you cannot name a repository's responsibility in a sentence, it is holding more than one.
- Resist both extremes: the monorepo of convenience that fuses unrelated responsibilities, and the micro-repo of habit that scatters one responsibility across many. Segment at the boundary of a thing that is built, versioned, and deployed as a unit.

## Share a repository only when the development lifecycle is shared

- Things that are **built, tested, released, and versioned together** belong in one repository; things whose lifecycles differ belong apart, even when they serve the same product.
- The signal is the release: if changing one part forces the other to be re-released, they share a lifecycle; if it does not, they do not, and the boundary is real. Application code that compiles into an artifact has a different lifecycle from the infrastructure that provisions its environment, so they are separate repositories.
- A shared lifecycle keeps the blast radius small: a change lands, is validated, and ships as one unit, without lockstep coordination across repositories.

## Share a repository only when the branch strategy is shared

- A repository's deployment model dictates its **branch strategy** — how changes flow, which branches are protected, and what approvals gate a release. Parts that share a branch strategy can share a repository; parts that need different ones cannot.
- Code that promotes through environments needs a different flow from code that ships continuously from a single `main`. Forcing both models into one repository weakens both — one branch ends up over-gated, the other under-gated. See [Branching and Merging](Branching-and-Merging.md) for the models and how changes flow within a repository.

## The boundary is self-describing

- Every repository states, at its root, what it is, what it owns, and how it ships — in a README kept current with the code. See [README-Driven Context](Readme-Driven-Context.md).
- Documentation and decisions live with the code they describe, so the repository boundary also bounds its own context instead of scattering it into a central store.
- The boundary is also declared in machine-readable form, so automation can determine what a repository is without inferring it from file layout. See [Repository Type Property](Repository-Type-Property.md).

## The boundary determines the governance that applies

- Segmentation and governance are the same decision seen twice. The lifecycle and branch-strategy seams that decide where a repository ends are the seams that decide which branch model, which required files, and which protection rules it carries.
- A repository is therefore classified at creation, and its classification follows from the same questions used to draw its boundary: what it ships, how it is versioned, and how changes reach its default branch. See [Repository Governance](../Capabilities/repository-governance/spec.md).
- A repository that cannot be classified is usually mis-segmented. When one repository needs two branch models or two release cadences, the classification is not ambiguous — the boundary is wrong, and the resolution is to split rather than to hold both models in one place.

## Where this connects

- [Repository Standard](Repository-Standard.md) — the contract each segmented repository must satisfy.
- [Repository Governance](../Capabilities/repository-governance/index.md) — how a repository's classification drives its rules and required files.
- [Repository Type Property](Repository-Type-Property.md) — the declaration a repository carries so its boundary is machine-readable.
- [Branching and Merging](Branching-and-Merging.md) — the branch models a boundary must choose exactly one of.
