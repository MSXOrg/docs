---
title: Downstream Release Propagation
description: How producer releases reach dependents through verified upgrade pull requests or evidenced no-upgrade outcomes.
---

# Downstream Release Propagation

When a producer publishes a release, propagation assesses every dependent
against its actual baseline. For a needed upgrade, a delegated cloud agent
opens a pull request for human review. The pull request contains the reference
change and related actions. An already-current or superseded target produces
an evidenced no-upgrade outcome instead.
Dependents do not need to discover the release or track reference updates manually.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for downstream release propagation — each dependent receives an upgrade pull request or an evidenced no-upgrade outcome. |
| [Design](design.md) | How downstream release propagation is built — an inline notification coordinates qualification, conditional delegation, and upgrade pull requests. |

<!-- INDEX:END -->
