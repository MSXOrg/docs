---
title: Scripts
description: Structure for standalone .ps1 scripts — requirements, parameters, help, and keeping the script thin.
---

# Scripts

A script (`.ps1`) is an entry point, not a home for logic. Keep scripts **thin**: parse input, call functions, report results. Anything reusable belongs in a function in a module.

## Section structure

A script file is laid out top to bottom in this order:

1. **`#Requires`** statements — PowerShell version and module dependencies. Prefer a **minimum** version (`ModuleVersion`) so security patches and fixes flow in. When a new *major* of a dependency would break you — a test framework such as Pester is the typical case — bound it to that major by adding `MaximumVersion` (e.g. `ModuleVersion = '6.0.0'; MaximumVersion = '6.999.999'`), and add the `GUID` to pin module identity. Avoid exact `RequiredVersion` pins, which freeze out patches and go stale.
2. **Comment-based help** — the same sections and order as a [function's](Functions.md#comment-based-help-required), only without the enclosing `function` block: `.SYNOPSIS`, `.DESCRIPTION`, at least one `.EXAMPLE`, then `.INPUTS`, `.OUTPUTS`, `.NOTES`, and `.LINK` as they apply. Document each parameter with an inline comment above it, just as a function does.
3. **`[CmdletBinding()]` + `param()`** — typed and validated, mandatory first; add `SupportsShouldProcess` when the script changes state.
4. **`$ErrorActionPreference = 'Stop'`**.
5. **Body** — the thin orchestration.

```powershell
#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.999.999' }

<#
    .SYNOPSIS
    Rotate the automation secret and sync it to the target store.

    .DESCRIPTION
    Remove the current secret, create a replacement, and update the store that consumes it.

    .EXAMPLE
    ./Rotate-Secret.ps1 -ValidityDays 365
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # How long the new secret stays valid, in days.
    [Parameter()]
    [int] $ValidityDays = 180
)

$ErrorActionPreference = 'Stop'

# thin orchestration: call the functions that do the real work
```

## Rules

- **Name scripts `Verb-Noun.ps1`** to match the function convention.
- **No side effects on load.** A script runs top to bottom when invoked; it should not do work merely by being dot-sourced.
- **Return objects**, so the script composes in a pipeline like any other command.

## Paths

- **Do not depend on the current directory.** Avoid relative paths and `~` — the meaning of `~` depends on the current PowerShell provider — and build paths from `$PSScriptRoot` with `Join-Path`.
- **Pass full paths to .NET and native calls.** .NET methods and external executables resolve relative paths against `[System.Environment]::CurrentDirectory`, which PowerShell does not keep reliably in step with `$PWD` — it can lag `Set-Location`, and diverges in non-FileSystem providers (`Registry`, `Cert:`). Resolve to a full path first.
