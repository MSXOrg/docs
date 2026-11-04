---
title: Repository Segmentation
description: What belongs in a repository, and when to split or combine.
---

# Repository Segmentation

A repository's boundary follows its ownership, versioning, and deployment. These boundaries define one responsibility, one development lifecycle, and one branch strategy. Parts belong together when they share that responsibility, lifecycle, and branch strategy. When any of them differ, the parts belong in separate repositories.

## One repository per independently-versioned thing

- A repository contains one unit of ownership, versioning, and release. If two parts have different release schedules or destinations, they belong in separate repositories.
- The test: can it be described in one sentence, owned by one team, and released on its own? If not, it is more than one repository.

## Single responsibility — the S in SOLID, at repository scale

- The [Single Responsibility Principle](Principles/Software-Design.md#solid-in-plain-language) is not only for classes. A repository, like a class, should have **one reason to change**: one responsibility, one deployable, one audience.
- A module, an action, a service, and an infrastructure stack each have one responsibility and belong in separate repositories. A repository whose responsibility cannot be stated in one sentence contains more than one responsibility.
- Avoid a monorepo that combines unrelated responsibilities. Do not divide one responsibility across multiple repositories. Use the boundary of the unit built, versioned, and deployed together.

## Share a repository only when the development lifecycle is shared

- Parts that are **built, tested, released, and versioned together** belong in one repository. Different lifecycles require separate repositories, even when the parts serve the same product.
- If a change to one part requires the other to be released again, the parts share a lifecycle. Otherwise, they have separate lifecycles. Compiled application code and the infrastructure that provisions its environment have different lifecycles, so they belong in separate repositories.
- A shared lifecycle limits the scope of each change. The unit is validated and released together, without coordinated releases across repositories.

## Share a repository only when the branch strategy is shared

- A repository's deployment model determines its **branch strategy**: change flow, protected branches, and required release approvals. Parts can share a repository only when they share a branch strategy.
- Code promoted through environments needs a different flow from code released continuously from a single `main`. Combining both models can require unnecessary approvals for one part and insufficient approvals for the other. See [Branching and Merging](Branching-and-Merging.md) for the models and change flow.

## The boundary is self-describing

- Every repository has a root README that states its purpose, ownership, and release process. The README stays current with the code. See [README-Driven Context](Readme-Driven-Context.md).
- Documentation and decisions stay with the code they describe. The repository boundary includes that context instead of separating it into a central store.
- The boundary is also declared in machine-readable form, so automation can determine what a repository is without inferring it from file layout. See [Repository Type Property](Repository-Type-Property.md).

## The boundary determines the governance that applies

- Segmentation determines which branch model, required files, and protection rules apply. The selected lifecycle and branch strategy define both the repository boundary and its governance.
- A repository is classified at creation. Its classification follows from its release unit, versioning, and change flow to the default branch. See [Repository Governance](../Capabilities/repository-governance/spec.md).
- A repository that cannot be classified usually has the wrong boundary. If it needs two branch models or release schedules, split it rather than combine both models in one repository.

## Where this connects

- [Repository Standard](Repository-Standard.md) — the contract each segmented repository must satisfy.
- [Repository Governance](../Capabilities/repository-governance/index.md) — how a repository's classification drives its rules and required files.
- [Repository Type Property](Repository-Type-Property.md) — the declaration a repository carries so its boundary is machine-readable.
- [Branching and Merging](Branching-and-Merging.md) — the branch models a boundary must choose exactly one of.
