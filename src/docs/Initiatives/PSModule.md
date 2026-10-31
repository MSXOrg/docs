---
title: PSModule
description: The GitHub + PowerShell framework — reusable modules and the actions that ship them.
---

# PSModule

**[PSModule](https://github.com/PSModule)** makes it *easy* to build, test, and ship PowerShell on GitHub — the fullest expression of the vision, end-to-end.

It is two things at once:

- **A module-building workflow** — GitHub Actions and reusable workflows that automate the whole PowerShell delivery lifecycle: build, test, version, and publish.
- **The modules themselves** — a growing collection of reusable PowerShell modules built with that workflow.

PSModule inherits the [Coding Standards](../Coding-Standards/index.md) and [Ways of Working](../Ways-of-Working/index.md) from this site and adds only what is specific to the framework. The end-to-end workflow that ships every module — [Process-PSModule](https://psmodule.io/docs/Modules/Process-PSModule/) — is documented at its canonical site.

## Target audience

| Product | Audience and supported use |
| --- | --- |
| PowerShell modules | PowerShell users invoking commands interactively or integrating them into scripts, pipelines, and automation. Parameters, output shapes, defaults, and runtime requirements are user-facing contracts. |
| `PSModule/Process-PSModule` | Module maintainers using and integrating the delivery workflow into their module repositories. Caller inputs, permissions, configuration, and tool requirements are user-facing contracts. |

In both cases, users are also integrators: these are roles of the same audience, not separate classes of customer. Repository READMEs [declare their audience](../Ways-of-Working/Readme-Driven-Context.md#target-audience) by adopting this definition or stating their specialization.

## Canonical boundary

Cross-org standards and reusable architecture are canonical in MSXOrg/docs, including:

- [Coding Standards](../Coding-Standards/index.md)
- [Capabilities](../Capabilities/index.md)
- [PowerShell on GitHub capability](../Capabilities/powershell-on-github/index.md)

`PSModule/Process-PSModule` is the canonical PSModule documentation source. It owns module-specific operational details, process and standards content, repository anatomy, and template onboarding.
