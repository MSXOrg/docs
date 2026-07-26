---
title: Frameworks
description: Frameworks are capabilities whose design composes other capabilities — being absorbed into Capabilities, documented with the same spec and design.
---

# Frameworks

A *framework* is a [capability](../Capabilities/index.md) whose design **composes
other capabilities** into one opinionated pipeline that takes a repository from
source to shipped with a single configuration file. "Framework" is an adjective
for that kind of capability, not a separate documentation model: each framework
carries the same **spec** and **design** as any other capability.

This standalone section is being **absorbed into
[Capabilities](../Capabilities/index.md)** and will be **removed** once empty —
the consolidation runs one direction, because `capability` is the noun and
`framework` is only an adjective. The evidence it should move is already here:
`vscode-extension-framework` lives under Capabilities with a spec and a design.
As each framework below gains its spec and design it moves under Capabilities;
when both have moved, this section and its navigation entry are deleted.

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
