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
- **Set `$ErrorActionPreference = 'Stop'`** at the top of every script and module so errors are terminating, not silently swallowed.
- **Emit objects, not formatted text.** Return rich objects and let the caller format; reserve `Write-Host` for genuine console UX, and use `Write-Verbose` / `Write-Information` for progress narration.

## Formatting

These rules define the layout; [PSScriptAnalyzer](#toolchain) enforces them (its settings are derived from this standard, not the reverse), so author to them and let the formatter apply them:

- **One True Brace Style (OTBS).** Opening brace on the statement line, closing brace on its own line; always brace control blocks, even a single statement. No blank line straight after `{` or before `}`, and `else` / `elseif` / `catch` / `finally` sit on the line with the preceding closing brace.
- **Indent with four spaces, never tabs**, and indent comment-based help to align with the function it documents.
- **One space around operators and after commas** (`$a -eq $b`, `@(1, 2, 3)`), and **one space between a type and the name** — `[string] $Name`, not `[string]$Name`.
- **`elseif` is one word**, not `else if`.
- **Blank lines separate logical blocks.** No trailing whitespace, and end every file with a single newline.
- **Keep code lines readable — aim for roughly 120 columns.** When a call grows long, prefer [splatting](#idioms-and-pitfalls) over backtick line-continuations.

## Idioms and pitfalls

Beyond the basics, these language-specific habits keep PowerShell correct and fast:

- **Single-quote strings unless you need expansion.** Use `'literal'` by default; reserve `"...$var..."` for interpolation or escape sequences, and here-strings (`@'...'@`, `@"..."@`) for multi-line text — literal-versus-interpolated intent then stays obvious.
- **Splat calls that carry many parameters.** Build a `@{}` of parameters and splat it (`Get-Thing @params`) instead of a long line of `-Param value` pairs or backtick continuations; it reads better and diffs cleanly.
- **Put `$null` on the left of a comparison** — `$null -eq $x`, never `$x -eq $null`. Against a collection the right-hand form *filters* rather than tests. Use `-contains` / `-in` for membership, never `-eq`.
- **Suppress unwanted output with `$null = ...`** (or `[void]` for method calls), not `| Out-Null` — the pipeline form is markedly slower on hot paths.
- **Build collections with a typed list, not `+=` in a loop.** `$a += $x` reallocates the whole array every iteration; use `[System.Collections.Generic.List[T]]` with `.Add()`, and prefer a cmdlet's `-Filter` over piping to `Where-Object` on large sets.
- **Keep secrets out of source, and never `Invoke-Expression` untrusted input.** Take secrets as `[securestring]` or through `Get-Credential`, and guard state-changing commands with `ShouldProcess` (see [Functions](Functions.md)); the wider rules live in the [Security](../Security.md) baseline.

## Toolchain

The toolchain enforces this standard in CI — it does not define it. The rules above are the source of truth; each tool's configuration is derived from them:

- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** is the linter and formatter; its settings are derived from this standard, so passing it cleanly means matching the standard. Let it format — do not hand-format.
- **[Pester](https://pester.dev/)** is the test framework; test files are named `*.Tests.ps1`. See the [Testing baseline](../Testing.md).
