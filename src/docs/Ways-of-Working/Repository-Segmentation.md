---
title: Repository Segmentation
description: What belongs in a repository, and when to split or combine.
---

# Repository Segmentation

What belongs in a repository, and when to split or combine. The boundary of a repository is the boundary of ownership, versioning, and deployment.

## One repository per independently-versioned thing

- A repository holds one thing that is owned, versioned, and released as a unit. If two parts ship on different schedules or to different places, they are two repositories.
- The test: can it be described in one sentence, owned by one team, and released on its own? If not, it is more than one repository.

## Segment by responsibility

- Single responsibility, at the repository level: one reason to change. A module, an action, a service, an infrastructure stack — each is its own repository.
- Resist both the monorepo of convenience and the micro-repo of habit. Split when responsibilities or lifecycles diverge; combine when parts are genuinely one thing.

## Segment by lifecycle and blast radius

- Things with different deployment models live apart. Application code that builds and ships an artifact has a different lifecycle from infrastructure that provisions environments.
- Keep blast radius small. A change in one repository should not require coordinated changes across many.

## The boundary drives the workflow

- A repository's deployment model determines its branching model and approval gates. See [Branching and Merging](Branching-and-Merging.md).
- Every repository is self-describing: a README at its root states what it is, what it owns, and how it ships. See [README-Driven Context](Readme-Driven-Context.md).
