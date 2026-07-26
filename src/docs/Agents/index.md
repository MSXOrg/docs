---
title: Agents
description: The roles agents play across the ecosystem — authored once as documentation and pointed to from each repository.
---

# Agents

The roles agents play across the MSX ecosystem, authored once as documentation. Each page describes one role — its job, when to use it, and the steps it follows — grounded in the [Ways of Working](../Ways-of-Working/index.md) rather than restating them.

These descriptions are the **single source for agent behaviour**. A repository does not carry its own copy; its `AGENTS.md` and `CLAUDE.md` are thin pointers to these pages ([Agentic Development](../Ways-of-Working/Agentic-Development.md)). Humans read the same pages a new teammate would.

The lifecycle runs **Define → Implement → Review**: capture and plan the work, build it in a pull request, then review it. Two supporting roles — Security Reviewer and Agent Author — run alongside.

## Contents

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Define](define.md) | Capture, route, refine, and plan work at the correct native issue altitude. |
| [Implement](implement.md) | Take one ready Task or Bug and deliver it as a review-ready pull request. |
| [Reviewer](reviewer.md) | Review someone else's pull request for delivery, taste, security, and undiscussed decisions. |
| [Security Reviewer](security-reviewer.md) | A structured, defensive security review that reports vulnerabilities as an actionable responsible-disclosure issue. |
| [Agent Author](agent-author.md) | Create and maintain the agent role descriptions and the per-repository pointer files that reference them. |

<!-- INDEX:END -->
