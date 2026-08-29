---
title: Release Management
description: How a source change becomes a versioned, immutable artifact, driven entirely on the GitHub platform.
---

# Release Management

Turning a merged change into a versioned, immutable artifact — a container
image, a GitHub Action or reusable workflow, a language package, a Terraform
module — paired with a GitHub Release and a git tag, driven by a configured
default and pull-request label overrides. An implementation may add a
GitHub-native ad hoc release path when its product needs one. No release CLI,
no hand-edited version file, no tagging ritual.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for release management — automatic, policy-driven, versioned releases driven entirely on the GitHub platform. |
| [Design](design.md) | How release management is built — a shared reusable workflow that resolves a configured or label-selected SemVer bump, builds once, and publishes. |
| [Publishing Targets](design-publishing-targets.md) | The contract every publishing destination documents, with GitHub Releases as the reference target. |

<!-- INDEX:END -->
