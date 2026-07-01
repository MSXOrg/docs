---
title: PowerShell
description: Advanced functions, comment-based help, and error handling for cross-platform PowerShell.
---

# PowerShell

How PowerShell is written across the ecosystem. PowerShell is the tool for operational automation — talking to platform APIs, orchestrating cross-platform tasks, and gluing tools together. We target **PowerShell 7 LTS** (the cross-platform `pwsh`), and lean on PowerShell's advanced-function machinery rather than writing plain scripts.

This standard builds on the [language-agnostic baseline](index.md); where the two overlap, the baseline rules apply and the conventions below add the PowerShell specifics.

## Naming and structure

- **`Verb-Noun` for every function**, using an approved verb (`Get-Verb`) and a singular noun: `Get-AutomationSecret`, `Set-RepositorySecret`.
- **`PascalCase`** for function names, parameters, and public variables.
- **One public function per file** in a module; group related functions into a `.psm1` module with an explicit export list.
- Use **full cmdlet names, never aliases**, in scripts and modules (`Where-Object`, not `?`; `ForEach-Object`, not `%`).

## Write advanced functions

- **Start every function with `[CmdletBinding()]`** so it gets common parameters, `-Verbose`, and `-ErrorAction`.
- **Type every parameter** and declare a `param()` block with validation attributes (`[Parameter(Mandatory)]`, `[ValidateSet(...)]`, `[ValidateNotNullOrEmpty()]`).
- **Declare dependencies with `#Requires`** — module names and minimum versions — at the top of the file.

```powershell
#Requires -Modules Pester

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$AppDisplayName,

    [int]$SecretValidityDays = 180
)

$ErrorActionPreference = 'Stop'
```

## Support `-WhatIf` for state-changing code

- Any function that **creates, changes, or deletes** state declares `[CmdletBinding(SupportsShouldProcess)]` and guards the mutation with `if ($PSCmdlet.ShouldProcess(...))`, so `-WhatIf` and `-Confirm` work.

## Errors and output

- **Set `$ErrorActionPreference = 'Stop'`** at the top of scripts so errors are terminating and do not silently continue.
- **`throw` for terminating errors**; `Write-Error` only where the caller is expected to handle a non-terminating one.
- **Emit objects, not formatted text.** Return rich objects and let the caller format; never `Write-Host` data that another command might consume. Use `Write-Verbose` / `Write-Information` for progress narration.

## Comment-based help

Every public function and script carries comment-based help — at minimum `.SYNOPSIS`, `.DESCRIPTION`, a `.PARAMETER` entry per parameter, and at least one `.EXAMPLE`.

```powershell
<#
.SYNOPSIS
    Rotates the automation secret and syncs it to the target secret store.
.DESCRIPTION
    Idempotent: removes the existing secret, creates a replacement, and
    updates the secret it feeds.
.PARAMETER AppDisplayName
    Display name of the application whose secret is rotated.
.EXAMPLE
    ./rotate-secret.ps1 -SecretValidityDays 365
#>
```

## Tooling

- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** is the linter and formatter; code must pass it cleanly.
- **[Pester](https://pester.dev/)** is the test framework, with test files named `*.Tests.ps1`.
