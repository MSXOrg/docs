---
title: Purpose and direction
description: The purpose behind the work, the audience it serves, and the least-privilege stance under every decision.
---

# Purpose and direction

## Start with Why — the Golden Circle

Every piece of work — at every level — is groundable in three concentric questions:

- **Why** — what change in the world is this trying to make? Vision.
- **How** — what approach makes that change happen? Mission.
- **What** — what concrete thing is being delivered right now?

Strategy and planning apply Why, How, and What progressively, from long-lived aggregates down to delivery leaves. This principle fixes the questions; it does not assign them to particular body sections or planning artifacts.

## Product / service mindset

The thing being built is for people who should **want** to use it. Without users, it is nothing. Every decision is filtered through one question: does this make the product more wanted, or less?

## Build for all developers

Every platform and every shell is a target. Code, scripts, workflows, and documentation MUST work regardless of whether the developer is on Windows, macOS, or Linux. Line endings, path separators, shell assumptions — none of these may silently break someone's experience. Repository configuration such as `.gitattributes`, CI matrices, and test environments MUST reflect this.

## Build for the modern engineer

The audience is engineers using current tools and platforms. Deprecated and end-of-life software is not supported. Concretely: target current, cross-platform, actively-developed runtimes — not legacy editions frozen years ago. The same applies across the stack: latest stable releases, current LTS versions, modern APIs. If a tool has a successor, the successor is the target.

## Dogfooding

Be the first customer of every service produced here. Avoid full self-dependency on a service before it is proven — use it in non-critical contexts first, then promote it as confidence grows.

## Least-privilege

Every identity — human, agent, or workflow — gets only the permissions it needs to complete its specific task, and nothing more. This applies to tokens, workflow permissions, API scopes, and agent capabilities.

Concretely:

- Workflow jobs declare `permissions` explicitly and as narrowly as possible. A job that only reads should never have write access.
- Agents are scoped to the actions they are authorised to take. An agent that reviews code should not be able to merge.
- Secrets and tokens are never passed wider than the step or job that needs them.
- When a required scope expands, that expansion is a deliberate, reviewed decision — not a default or a shortcut.

The goal is to limit blast radius. If an agent, token, or job is compromised or behaves unexpectedly, least-privilege ensures the damage is contained.
