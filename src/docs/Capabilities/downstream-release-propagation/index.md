---
title: Downstream Release Propagation
description: How a release in one repository propagates to the repositories that depend on it, via a delegated agent pull request.
---

# Downstream Release Propagation

When a producer cuts a release, every dependent automatically receives a pull
request that applies the update — the version bump and the related changes it
implies — opened by a delegated cloud agent, then reviewed and merged by a
human. No dependent has to notice the release or track the bump by hand.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for downstream release propagation — dependents automatically receive a reviewed pull request that applies each producer release. |
| [Design](design.md) | How downstream release propagation is built — an inline notification job that resolves the release and delegates a self-contained prompt to a cloud agent in each dependent. |

<!-- INDEX:END -->
