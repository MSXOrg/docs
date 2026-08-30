---
title: Release Management
description: How a source change becomes a versioned, immutable artifact, driven entirely on the GitHub platform.
---

# Release Management

Turning a merged change into a versioned, immutable artifact — a container
image, a GitHub Action or reusable workflow, a language package, a Terraform
module — paired with a GitHub Release and a git tag, normally driven by
pull-request labels. An implementation may add a GitHub-native ad hoc release
path when its product needs one. No release CLI, no hand-edited version file,
no tagging ritual.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for release management — automatic, label-driven, versioned releases driven entirely on the GitHub platform. |
| [Design](design.md) | How release management is built — a shared reusable workflow that reads pull-request labels, computes the SemVer bump, and cuts the release. |
| [Publishing Targets](design-publishing-targets.md) | The contract every publishing destination documents, with GitHub Releases as the reference target. |

<!-- INDEX:END -->
