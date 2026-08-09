---
title: Agentic Development
description: The framework for org-scoped docs and memory repositories that give agents project-specific standards, working knowledge, and behavior.
---

# Agentic Development

The Agentic Development framework makes an organization the operating boundary for human and agent work. Each organization owns a `docs` repository for canonical knowledge and a `memory` repository for accumulated working context; every product repository carries a short router that points to those roots, and keeps its own nuance in the files a human already reads.

A repository adopts the framework by carrying a short router and the client routes that reach it, and by letting agents read outward — the repository's own files first, then the organization documentation and memory, then the current task. The organization selects *which* context applies; the reading order decides what is read first.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for refresh-first, index-first agentic development through canonical documentation, memory, and thin pointers. |
| [Design](design.md) | How the agentic development framework is built — OKF documentation, org memory, thin repo pointers, and deterministic context resolution. |
| [Memory Repository Template](memory-template.md) | The concrete, copy-pasteable scaffold every organization's memory repository instantiates, and why it deliberately breaks from the Repository Standard. |
| [MCP Servers](mcp-servers.md) | How one logical set of tool servers is defined once and declared by every runtime in its own format, so a documented procedure does not depend on which client runs it. |
| [Runtime Integration](runtime-integration.md) | How a runtime is wired into the framework — the entry file it reads, the lifecycle point its refresh attaches to, the permissions it needs, and what a new runtime must supply to be supported. |
| [Plugin Distribution](plugin-distribution.md) | How recurring workflows are packaged as named intents that point to canonical documentation, and why a packaged shortcut never carries a copy of the procedure. |
| [Agent Interaction](agent-interaction.md) | How humans and agents coordinate through issues, labels, and pull requests, and why intent and implementation are kept in separate artifacts. |
| [Advisory Agents](advisory-agents.md) | The pattern for automation that analyses work and publishes its conclusion as advice, without deciding, relabelling, or committing. |
| [Conformance](conformance.md) | What a repository must provide to be conformant with the agentic development framework, what it may add, and the duplication checks that keep the router thin. |
| [Agentic Development decisions](decisions/index.md) | Immutable records of one-way-door choices in the agentic development framework. |

<!-- INDEX:END -->
