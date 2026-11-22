---
title: Purpose and direction
description: The purpose behind the work, the audience it serves, and the least-privilege stance under every decision.
---

# Purpose and direction

## Start with Why — the Golden Circle

Each piece of work answers three questions:

- **Why** — what change in the world is this trying to make? Vision.
- **How** — what approach makes that change happen? Mission.
- **What** — what concrete thing is being delivered right now?

Strategy and planning apply Why, How, and What at each level, from long-lived aggregates to delivery leaves. This principle defines the questions. It does not assign them to issue sections or planning artifacts.

## Product / service mindset

Products serve people who **want** to use them. A product needs users to deliver value. Each decision considers whether it makes the product more useful and desirable to users.

## Build for all developers

Every platform and every shell is a target. Code, scripts, workflows, and documentation MUST work regardless of whether the developer is on Windows, macOS, or Linux. Line endings, path separators, shell assumptions — none of these may silently break someone's experience. Repository configuration such as `.gitattributes`, CI matrices, and test environments MUST reflect this.

## Build for the modern engineer

The audience is engineers who use current tools and platforms. Deprecated and end-of-life software is not supported. Target current, cross-platform, actively developed runtimes rather than legacy editions. This applies across the stack: latest stable releases, current LTS versions, and modern APIs. If a tool has a successor, the successor is the target.

## Dogfooding

Be the first customer of every service produced here. Avoid full self-dependency on a service before it is proven — use it in non-critical contexts first, then promote it as confidence grows.

## Least-privilege

Every identity — human, agent, or workflow — gets only the permissions it needs to complete its specific task, and nothing more. This applies to tokens, workflow permissions, API scopes, and agent capabilities.

Concretely:

- Workflow jobs declare `permissions` explicitly and as narrowly as possible. A job that only reads should never have write access.
- Agents are scoped to the actions they are authorized to take. An agent that reviews code should not be able to merge.
- Secrets and tokens are never passed wider than the step or job that needs them.
- When a required scope expands, that expansion is a deliberate, reviewed decision — not a default or a shortcut.

Least privilege limits the damage when an agent, token, or job is compromised or acts unexpectedly.
