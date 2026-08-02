---
title: Agentic Development
description: The framework for org-scoped docs and memory repositories that give agents project-specific standards, working knowledge, and behavior.
---

# Agentic Development

The Agentic Development framework makes an organization the operating boundary for human and agent work. Each organization owns a `docs` repository for canonical knowledge and a `memory` repository for accumulated working context; every product repository carries a short router that points to those roots, and keeps its own nuance in the files a human already reads.

A repository adopts the framework by carrying thin agent pointer files and by letting agents resolve context through the organization first, then the repository, then the current task.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for refresh-first, index-first agentic development through canonical documentation, memory, and thin pointers. |
| [Design](design.md) | How the agentic development framework is built — OKF documentation, org memory, thin repo pointers, and deterministic context resolution. |
| [Memory Repository Template](memory-template.md) | The concrete, copy-pasteable scaffold every organization's memory repository instantiates, and why it deliberately breaks from the Repository Standard. |

<!-- INDEX:END -->
