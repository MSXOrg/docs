---
title: Merge Automation
description: How a pull request's required status checks become the machine-readable signal that drives automated approval and merge — green merges, red holds, nothing bypasses the gate.
---

# Merge Automation

How the required status checks on a pull request become a single
machine-readable signal — so automation can merge a green pull request, hold a
red one, and never bypass the gate a pipeline or a ruleset sets.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for merge automation — required status checks as the signal, a ruleset that enforces them, and automation that merges on green and holds on red without bypassing the gate. |
| [Design](design.md) | How merge automation is built — named checks and commit statuses, a ruleset that requires them, and a GitHub App that approves and merges on green or holds on red. |

<!-- INDEX:END -->
