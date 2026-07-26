---
title: PowerShell Testing
description: Pester test naming and the Simple and Standard layouts for PowerShell modules.
---

# PowerShell Testing

PowerShell tests build on the [testing baseline](../Testing.md): they are test-first, locally runnable, deterministic, isolated, and automated in CI. Use [Pester](https://pester.dev/) and name test files `*.Tests.ps1`.

## Module test layouts

Keep module test files directly under `./tests/` and choose the smallest layout that keeps the suite easy to navigate.

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

## Framework-specific layouts

Nested test directories, multiple test configurations, and the mapping from suites to jobs are framework behavior, not part of this standard. Follow the framework documentation when a repository needs those capabilities.
