---
title: Capabilities
description: Each MSX capability has a spec for its requirements and a design for its implementation.
---

# Capabilities

Capabilities are the independently versioned systems and tools that the ecosystem builds and operates.
Each capability has a **spec** that states why it exists and what it must do.
Its **design** explains how the implementation meets the spec.
Both documents share the capability's folder. See the
[Documentation Model](../Ways-of-Working/Documentation-Model.md) for how spec
and design relate and evolve.

A *framework* is a capability whose design **composes other capabilities**.
The term does not define a different kind of document.
A framework uses the same spec-and-design structure and documentation location as other capabilities.

<!-- INDEX:START -->

| Section | Description |
| --- | --- |
| [Release Management](release-management/index.md) | Durable version resolution, publication, recovery, withdrawal, and consumer update policy for immutable releases. |
| [Repository Governance](repository-governance/index.md) | How every repository in an organization is classified, protected, and continuously reconciled against the controls its classification declares. |
| [Dependency Updates](dependency-updates/index.md) | How a repository's pinned dependencies are kept current and secure through automated update pull requests. |
| [Merge Automation](merge-automation/index.md) | How a pull request's required status checks become the machine-readable signal that drives automated approval and merge — green merges, red holds, nothing bypasses the gate. |
| [Downstream Release Propagation](downstream-release-propagation/index.md) | How producer releases reach dependents through verified upgrade pull requests or evidenced no-upgrade outcomes. |
| [Deployment](deployment/index.md) | How a change to managed resources is approved together with its effect and deployed exactly as approved — one spec, and one design for each combination of deploying a service provider from a CI/CD platform. |
| [VS Code Extension Framework](vscode-extension-framework/index.md) | How a VS Code extension is built, tested, versioned, packaged, and published — one GitHub-native pipeline, opt-in from a template and a single settings file. |
| [PowerShell on GitHub](powershell-on-github/index.md) | How we make GitHub a first-class platform for PowerShell through reusable modules, actions, and capability gaps we close over time. |
| [Agentic Development](agentic-development/index.md) | The framework for org-scoped documentation that gives agents project-specific standards and behavior. |

<!-- INDEX:END -->

## Where this connects

- [Documentation Model](../Ways-of-Working/Documentation-Model.md) — the spec-and-design model for each capability.
- [Ways of Working](../Ways-of-Working/index.md) — the processes for work on these capabilities.
