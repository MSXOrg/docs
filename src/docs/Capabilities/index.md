---
title: Capabilities
description: The capabilities the ecosystem builds, each documented by a spec (why and what) and a design (how and what).
---

# Capabilities

The independently versioned things the ecosystem builds and runs. Each
capability is documented by a **spec** — the why and the what — and a
**design** — the how and the what we build — kept side by side in the
capability's folder. See the
[Documentation Model](../Ways-of-Working/Documentation-Model.md) for how spec
and design relate and evolve.

<!-- INDEX:START -->

| Section | Description |
| --- | --- |
| [Release Management](release-management/index.md) | How a source change becomes a versioned, immutable artifact, driven entirely on the GitHub platform. |
| [Dependency Updates](dependency-updates/index.md) | How a repository's pinned dependencies are kept current and secure through automated, labelled update pull requests. |
| [Downstream Release Propagation](downstream-release-propagation/index.md) | How a release in one repository propagates to the repositories that depend on it, via a delegated agent pull request. |

<!-- INDEX:END -->

## Where this connects

- [Documentation Model](../Ways-of-Working/Documentation-Model.md) — the spec-and-design model every capability here follows.
- [Ways of Working](../Ways-of-Working/index.md) — how the work that builds these capabilities happens.
