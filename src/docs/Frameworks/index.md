---
title: Frameworks
description: The complete, end-to-end frameworks the ecosystem ships — opinionated automation a project adopts wholesale to go from source to shipped.
---

# Frameworks

The complete, end-to-end frameworks a project adopts wholesale. Where a
[capability](../Capabilities/index.md) is a single independently versioned thing
the ecosystem builds, a framework composes many of them into one opinionated
pipeline that takes a repository from source to shipped with a single
configuration file.

Each framework is documented as its own section — an overview plus the pages that
cover how it works, how to use it, and how to configure it.

<!-- INDEX:START -->

| Section | Description |
| --- | --- |
| [Agentic Development](Agentic-Development/index.md) | The framework for org-scoped docs and memory repositories that give agents project-specific standards, working knowledge, and behavior. |
| [Process-PSModule](Process-PSModule/index.md) | The end-to-end GitHub Actions workflow that builds, tests, versions, and publishes every PSModule PowerShell module and documentation site — configured through a single settings file and zensical.toml for site generation. |

<!-- INDEX:END -->

## Where this connects

- [Initiatives](../Initiatives/index.md) — the programs these frameworks grow out of, including [PSModule](../Initiatives/PSModule.md).
- [Capabilities](../Capabilities/index.md) — the independently versioned building blocks a framework composes.
- [Coding Standards](../Coding-Standards/index.md) — the standards a framework's pipeline enforces.
- [Ways of Working](../Ways-of-Working/index.md) — how the work that builds and uses these frameworks happens.
