---
title: PowerShell Testing
description: Pester test naming and the Simple, Standard, and Advanced profiles for PowerShell modules.
---

# PowerShell Testing

PowerShell tests build on the [testing baseline](../Testing.md): they are test-first, locally runnable, deterministic, isolated, and automated in CI. Use [Pester](https://pester.dev/) and name ordinary test files `*.Tests.ps1`.

## Module test profiles

Simple, Standard, and Advanced are documentation profiles: conventions for arranging module-local tests, not selectable Process-PSModule modes. There is no layout setting in `.github/PSModule.yml`; Process-PSModule discovers the files present under `./tests/`.

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

Use subdirectories when parts of the suite need independent Pester configurations, containers, or ordinary test files:

```text
tests/
├── Unit/                                  # No configuration or containers: all test files
│   ├── GroupOne.Tests.ps1
│   └── GroupTwo.Tests.ps1
├── Integration/                           # The configuration takes precedence
│   ├── Integration.Configuration.ps1
│   ├── Read.Container.ps1
│   └── Write.Container.ps1
└── Compatibility/                         # No configuration: all containers
    ├── Linux.Container.ps1
    └── Windows.Container.ps1
```

Process-PSModule discovers tests recursively. Each directory independently uses the first matching form:

1. Exactly one `*.Configuration.ps1`. More than one configuration in the same directory is an error.
2. Otherwise, one or more `*.Container.ps1`.
3. Otherwise, all `*.Tests.ps1`.

The selected form takes precedence only within its directory; discovery continues into child directories.

## Unique test names

Process-PSModule derives `TestName` from the filename before the first dot. Give every discovered test artifact a unique first-dot prefix. For example, `Users.Unit.Tests.ps1` and `Users.Integration.Tests.ps1` both produce `Users` and collide; use distinct names such as `UsersUnit.Tests.ps1` and `UsersIntegration.Tests.ps1`.

## Root workflow phases

`tests/BeforeAll.ps1` and `tests/AfterAll.ps1` are optional Process-PSModule workflow phases that run before and after the module test matrix. Detection is not recursive: files with those names in nested directories are not workflow setup or teardown phases.
