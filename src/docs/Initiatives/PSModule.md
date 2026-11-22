---
title: PSModule
description: The GitHub + PowerShell framework — reusable modules and the actions that ship them.
---

# PSModule

**[PSModule](https://github.com/PSModule)** is a framework for PowerShell development and delivery on GitHub. It applies the vision across the module delivery lifecycle.

It provides:

- **A module-building workflow** — GitHub Actions and reusable workflows that automate the complete PowerShell delivery lifecycle: build, test, version, and publish.
- **The modules themselves** — reusable PowerShell modules built with that workflow.

PSModule inherits the [Coding Standards](../Coding-Standards/index.md) and [Ways of Working](../Ways-of-Working/index.md) from this site and adds only framework-specific guidance. The canonical documentation for [Process-PSModule](https://psmodule.io/Process-PSModule/) describes the end-to-end module delivery workflow.

## Target audience

| Product | Audience and supported use |
| --- | --- |
| PowerShell modules | PowerShell users invoking commands interactively or integrating them into scripts, pipelines, and automation. Parameters, output shapes, defaults, and runtime requirements are user-facing contracts. |
| `PSModule/Process-PSModule` | Module maintainers using and integrating the delivery workflow into their module repositories. Caller inputs, permissions, configuration, and tool requirements are user-facing contracts. |

In both cases, users are also integrators: these are roles of the same audience, not separate classes of customer. Repository READMEs [declare their audience](../Ways-of-Working/Readme-Driven-Context.md#target-audience) by adopting this definition or stating their specialization.

## Module settings

The supported settings default is `.github/PSModule.yml`, through `SettingsPath`. It controls module-pipeline configuration, including module release settings. Module repositories do not need a separate `.github/release.settings.yml` file.

This is a supported naming exception under the [Naming standard](../Coding-Standards/Naming.md#solution-settings-files), not a requirement to migrate module settings. The [workflow input reference](https://psmodule.io/Process-PSModule/reference/workflow-inputs/) owns supported `SettingsPath` controls; the [settings reference](https://psmodule.io/Process-PSModule/reference/settings/) owns the module settings keys and defaults. Changing this supported interface requires a separate reader and migration change.

## Canonical boundary

Cross-org standards and reusable architecture are canonical in MSXOrg/docs, including:

- [Coding Standards](../Coding-Standards/index.md)
- [Capabilities](../Capabilities/index.md)
- [PowerShell on GitHub capability](../Capabilities/powershell-on-github/index.md)

`PSModule/Process-PSModule` is the canonical PSModule documentation source. It owns module-specific operational details, process and standards content, repository anatomy, and template onboarding.
