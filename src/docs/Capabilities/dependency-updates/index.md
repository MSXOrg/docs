---
title: Dependency Updates
description: How a repository's pinned dependencies are kept current and secure through automated, labelled update pull requests.
---

# Dependency Updates

Keeping the pinned dependencies a repository consumes — Action and workflow
SHAs, container base images, language packages, Terraform providers and
modules — current and free of known vulnerabilities, through automated update
pull requests that are reviewed and released like any other change.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for dependency updates — pinned dependencies kept current and secure through reviewed, released update pull requests. |
| [Design](design.md) | How dependency updates are built — Dependabot update PRs, a label scheme kept disjoint from release labels, and level-based auto-merge. |

<!-- INDEX:END -->
