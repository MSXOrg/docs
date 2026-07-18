---
title: Agentic Development
description: The framework for org-scoped docs and memory repositories that give agents project-specific standards, working knowledge, and behavior.
---

# Agentic Development

The Agentic Development framework makes an organization the operating boundary for human and agent work. Each organization owns a `docs` repository for canonical knowledge and a `memory` repository for accumulated working context; every product repository points to those two roots and adds only local nuance.

A repository adopts the framework by carrying thin agent pointer files and by letting agents resolve context through the organization first, then the repository, then the current task.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for the agentic development framework — org-scoped documentation, memory, and pointer files that make agents behave correctly per project. |
| [Design](design.md) | How the agentic development framework is built — OKF documentation, org memory, thin repo pointers, and deterministic context resolution. |

<!-- INDEX:END -->
