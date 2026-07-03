---
title: Purpose and direction
description: Why we build, who we build for, and the least-privilege stance under every decision.
---

# Purpose and direction

## Start with Why — the Golden Circle

Every piece of work — at every level — should be groundable in three concentric questions:

- **Why** — what change in the world are we trying to make? Vision.
- **How** — what approach do we take to make that change happen? Mission.
- **What** — what concrete thing are we delivering right now? OKRs → initiatives → tasks.

When an issue is being written, the **Why** belongs in the Context part of Section 1. The **How** belongs in Section 2 (Technical Decisions). The **What** belongs in Section 3 (Implementation Plan).

## Product / service mindset

We are building something for people who should **want** to use it. Without users, we are nothing. Every decision is filtered through: does this make the product more wanted, or less?

## Build for all developers

We target all platforms and all shells. Our code, scripts, workflows, and documentation must work regardless of whether the developer is on Windows, macOS, or Linux. Line endings, path separators, shell assumptions — none of these should silently break someone's experience. Repository configuration (`.gitattributes`, CI matrices, test environments) must reflect this.

## Build for the modern engineer

We build for engineers using the latest tools and platforms. We do not support deprecated or end-of-life software. Concretely: we target current, cross-platform, actively-developed runtimes — not legacy editions frozen years ago. The same applies across the stack: latest stable releases, current LTS versions, modern APIs. If a tool has a successor, use the successor.

## Dogfooding

Be the first customer of every service we build. But avoid full self-dependency on a service before it is proven — explore and use it in non-critical contexts first, then promote it as confidence grows.

## Least-privilege

Every identity — human, agent, or workflow — gets only the permissions it needs to complete its specific task, and nothing more. This applies to GitHub tokens, workflow permissions, API scopes, and agent capabilities.

Concretely:

- Workflow jobs declare `permissions` explicitly and as narrowly as possible. A job that only reads should never have write access.
- Agents are scoped to the actions they are authorised to take. An agent that reviews code should not be able to merge.
- Secrets and tokens are never passed wider than the step or job that needs them.
- When a required scope expands, that expansion is a deliberate, reviewed decision — not a default or a shortcut.

The goal is to limit blast radius. If an agent, token, or job is compromised or behaves unexpectedly, least-privilege ensures the damage is contained.
