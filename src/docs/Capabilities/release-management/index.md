---
title: Release Management
description: Durable version resolution, publication, recovery, withdrawal, and consumer update policy for immutable releases.
---

# Release Management

Turning approved source into a versioned, immutable artifact — a container
image, GitHub Action or reusable workflow, language package, Terraform module,
or documentation site — with durable release state and evidence. The ordinary
path starts from a reviewed merge; an approved manual request can release an
accumulated range. Both paths resolve once, build once, resume by recorded
phase, and advertise only completed eligible releases.

Contributors express release intent through GitHub. Maintainers can recover,
retire, or withdraw releases without reusing versions or rewriting history, and
consumers select an update policy that matches their trust boundary.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for durable, recoverable, policy-driven releases and trustworthy consumer updates. |
| [Design](design.md) | Durable release intents, lifecycle transitions, recovery, withdrawal, aliases, announcements, and implementation coverage. |
| [Publishing Targets](design-publishing-targets.md) | Destination contracts for version mapping, prereleases, immutability, withdrawal, aliases, constraints, and release records. |
| [Accept Moved Release Tags](accept-moved-release-tags.md) | Refresh an owned moving release alias locally and configure Git to keep it current. |

<!-- INDEX:END -->
