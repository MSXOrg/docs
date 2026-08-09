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

A capability whose design **composes other capabilities** is called a
*framework* — an adjective, not a different kind of document. It lives here with
the same spec-and-design shape as any other capability.

<!-- INDEX:START -->

| Section | Description |
| --- | --- |
| [Release Management](release-management/index.md) | How a source change becomes a versioned, immutable artifact, driven entirely on the GitHub platform. |
| [Repository Governance](repository-governance/index.md) | How every repository in an organization is classified, protected, and continuously reconciled against the controls its classification declares. |
| [Dependency Updates](dependency-updates/index.md) | How a repository's pinned dependencies are kept current and secure through automated, labelled update pull requests. |
| [Merge Automation](merge-automation/index.md) | How a pull request's required status checks become the machine-readable signal that drives automated approval and merge — green merges, red holds, nothing bypasses the gate. |
| [Downstream Release Propagation](downstream-release-propagation/index.md) | How a release in one repository propagates to the repositories that depend on it, via a delegated agent pull request. |
| [Deployment](deployment/index.md) | How a change to managed resources is approved together with its effect and deployed exactly as approved — one spec, and one design for each combination of deploying a service provider from a CI/CD platform. |
| [VS Code Extension Framework](vscode-extension-framework/index.md) | How a VS Code extension is built, tested, versioned, packaged, and published — one GitHub-native pipeline, opt-in from a template and a single settings file. |
| [PowerShell on GitHub](powershell-on-github/index.md) | How we make GitHub a first-class platform for PowerShell through reusable modules, actions, and capability gaps we close over time. |
| [Agentic Development](agentic-development/index.md) | The framework for org-scoped docs and memory repositories that give agents project-specific standards, working knowledge, and behavior. |

<!-- INDEX:END -->

## Where this connects

- [Documentation Model](../Ways-of-Working/Documentation-Model.md) — the spec-and-design model every capability here follows.
- [Ways of Working](../Ways-of-Working/index.md) — how the work that builds these capabilities happens.
