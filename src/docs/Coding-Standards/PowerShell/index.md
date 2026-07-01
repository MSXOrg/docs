---
title: PowerShell
description: Cross-platform PowerShell 7 — the conventions shared by every script, function, and class, with per-construct standards below.
---

# PowerShell

How PowerShell is written across the ecosystem. PowerShell is the tool for operational automation — talking to platform APIs, orchestrating cross-platform tasks, and gluing tools together. We target **PowerShell 7 LTS** (the cross-platform `pwsh`) and lean on PowerShell's advanced-function machinery rather than plain scripts.

This standard builds on the [language-agnostic baseline](../index.md); where the two overlap, the baseline rules apply and the conventions here add the PowerShell specifics. PowerShell is a heavily used language, so its standard **nests**: the shared conventions live on this page, and each construct — functions, classes, scripts — has its own page with the doc requirements, formatting, and section structure for that construct.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Functions](Functions.md) | Advanced functions — CmdletBinding, typed and validated parameters, pipeline blocks, ShouldProcess, and required comment-based help. |
| [Classes](Classes.md) | When to reach for a PowerShell class, and how to structure its members, constructors, and documentation. |
| [Scripts](Scripts.md) | Structure for standalone .ps1 scripts — requirements, parameters, help, and keeping the script thin. |

<!-- INDEX:END -->

## Shared conventions

These hold for all PowerShell, whatever the construct:

- **`Verb-Noun` naming** with an approved verb (`Get-Verb`) and a singular noun: `Get-RepositorySecret`, not `Fetch-Secrets`.
- **`PascalCase`** for functions, parameters, public variables, and class members; `camelCase` for local variables.
- **Full cmdlet names, never aliases** (`Where-Object`, not `?`; `ForEach-Object`, not `%`).
- **One True Brace Style (OTBS)** — opening brace on the statement line, closing brace on its own line; always brace control blocks, even single statements.
- **Set `$ErrorActionPreference = 'Stop'`** at the top of every script and module so errors are terminating, not silently swallowed.
- **Emit objects, not formatted text.** Return rich objects and let the caller format; reserve `Write-Host` for genuine console UX, and use `Write-Verbose` / `Write-Information` for progress narration.

## Toolchain

The toolchain is the enforcement mechanism, and it runs in CI:

- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** is the linter and formatter; code must pass it cleanly. The shared settings file is the source of truth for formatting — do not hand-format.
- **[Pester](https://pester.dev/)** is the test framework; test files are named `*.Tests.ps1`. See the [Testing baseline](../Testing.md).
