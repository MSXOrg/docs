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
| [Spec](spec.md) | Requirements for release management — validated defaults, reviewed overrides, immutable artifacts, and complete consumer release records. |
| [Design](design.md) | How release management is built — effective defaults, owned overrides, keyed release types, source-bound notes, and build-once publication. |
| [Publishing Targets](design-publishing-targets.md) | The contract every publishing destination documents, with GitHub Releases as the reference target. |

<!-- INDEX:END -->
