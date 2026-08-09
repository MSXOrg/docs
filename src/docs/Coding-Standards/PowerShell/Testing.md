---
title: PowerShell Testing
description: Pester test naming and the Simple, Standard, and Advanced profiles for PowerShell modules.
---

# PowerShell Testing

PowerShell tests build on the [testing baseline](../Testing.md): they are test-first, locally runnable, deterministic, isolated, and automated in CI. Use [Pester](https://pester.dev/) and name ordinary test files `*.Tests.ps1`.

## Module test profiles

Simple, Standard, and Advanced are documentation profiles: conventions for arranging module-local tests, not selectable Process-PSModule modes. All three feed the same filesystem discovery engine; there is no layout setting in `.github/PSModule.yml`.

Choose the smallest profile that keeps the suite easy to navigate.

### Simple

Use one root-level test file named after the module:

```text
tests/
└── <ModuleName>.Tests.ps1
```

The Simple layout fits a module whose tests remain readable as one suite.

### Standard

Use one root-level test file per public function group:

```text
tests/
├── <GroupOne>.Tests.ps1
├── <GroupTwo>.Tests.ps1
└── <Behavior>.Tests.ps1 (optional)
```

`<Group>` names the public function group the file covers. When public functions are organized under `src/functions/public/<Group>/`, use the same group name for the test file.

Ungrouped public functions and cross-cutting module behavior may use separate root-level `*.Tests.ps1` suites where appropriate. Name each suite after the functions or behavior it covers.

### Advanced

The Advanced profile is recommended when parts of the suite need independent Pester configurations, containers, or ordinary test files. Organize those parts in subdirectories:

```text
tests/
├── Unit/                                  # No configuration or containers: all test files
│   ├── GroupOne.Tests.ps1
│   └── GroupTwo.Tests.ps1
├── Integration/
│   └── Integration.Configuration.ps1
└── Compatibility/
    ├── Linux.Container.ps1
    └── Windows.Container.ps1
```

Different directories may use different forms. Process-PSModule recursively applies its [per-directory discovery precedence](https://psmodule.io/docs/Modules/Process-PSModule/), including sibling suppression, unique test-name requirements, and root-only workflow phases.
