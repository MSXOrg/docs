---
title: Agentic Development
description: The framework for org-scoped documentation that gives agents project-specific standards and behavior.
---

# Agentic Development

The Agentic Development framework makes an organization the operating boundary for human and agent work. Each organization owns a `docs` repository for canonical knowledge; every product repository carries a short router that points to that root, and keeps its own nuance in the files a human already reads.

A repository adopts the framework by carrying a short router and the client routes that reach it, and by letting agents read outward — the repository's own files first, then the organization documentation, then the current task. The organization selects *which* context applies; the reading order decides what is read first.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for fresh, index-first agentic development through canonical documentation and thin pointers. |
| [Design](design.md) | How the agentic development framework is built — OKF documentation, thin repo pointers, and deterministic context resolution. |
| [AGENTS.md Template](AGENTS.template.md) | The repository-level agent router template and the guidance for applying it. |
| [MCP Servers](mcp-servers.md) | How one logical set of tool servers is defined once and declared by every runtime in its own format, so a documented procedure does not depend on which client runs it. |
| [Runtime Integration](runtime-integration.md) | How a runtime is wired into the framework — the entry file it reads, the lifecycle point where it verifies context freshness, the permissions it needs, and what a new runtime must supply to be supported. |
| [Plugin Distribution](plugin-distribution.md) | How recurring workflows are packaged as named intents that point to canonical documentation, and why a packaged shortcut never carries a copy of the procedure. |
| [Plugin Marketplaces](design-plugin-marketplaces.md) | How shared and initiative-owned Agent Plugin marketplaces are named, laid out, versioned, and updated. |
| [Agent Interaction](agent-interaction.md) | How humans and agents coordinate through issues, labels, and pull requests, and why intent and implementation are kept in separate artifacts. |
| [Advisory Agents](advisory-agents.md) | The pattern for automation that analyses work and publishes its conclusion as advice, without deciding, relabelling, or committing. |
| [Conformance](conformance.md) | What a repository must provide to be conformant with the agentic development framework, what it may add, and the duplication checks that keep the router thin. |
| [Agentic Development decisions](decisions/index.md) | Immutable records of one-way-door choices in the agentic development framework. |

<!-- INDEX:END -->
