---
title: Merge Automation
description: Required status checks control automated approval and merge without bypassing repository gates or review requirements.
---

# Merge Automation

Required status checks give automation a machine-readable merge signal.
Automation merges eligible pull requests when all required checks pass.
It holds a pull request when a required check fails, remains pending, or is
missing. Pipeline and ruleset gates remain binding.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for merge automation — required status checks as the signal, a ruleset that enforces them, and automation that merges on green and holds on red without bypassing the gate. |
| [Design](design.md) | How merge automation is built — named checks and commit statuses, a ruleset that requires them, and a GitHub App that approves and merges on green or holds on red. |

<!-- INDEX:END -->
