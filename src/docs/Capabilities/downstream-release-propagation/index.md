---
title: Downstream Release Propagation
description: How producer releases reach dependents through verified upgrade pull requests or evidenced no-upgrade outcomes.
---

# Downstream Release Propagation

When a producer cuts a release, every dependent is assessed against its actual
baseline. A needed upgrade produces a pull request with the reference change
and related actions, opened by a delegated cloud agent for human review. An
already-current or superseded target produces an evidenced no-upgrade outcome
instead. No dependent has to notice the release or track the bump by hand.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for downstream release propagation — each dependent receives an upgrade pull request or an evidenced no-upgrade outcome. |
| [Design](design.md) | How downstream release propagation is built — an inline notification coordinates qualification, conditional delegation, and upgrade pull requests. |

<!-- INDEX:END -->
