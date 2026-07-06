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

## Tools and controllers

PowerShell falls into two kinds, and the difference decides how a command shapes its output:

- A **tool** is a reusable unit — an advanced function, usually exported from a module. It takes input only through parameters and emits **raw, least-manipulated objects**, so it stays usable in situations its author never imagined; a tool that measures a size returns bytes, not a rounded string.
- A **controller** is a script that automates one process by calling tools. It may reshape, round, or format data for how it will be read, and it is not meant to be reused.

Keep the shaping at the edge: tools stay general and emit raw objects, and a controller — or a format view (`.format.ps1xml`) — turns those into presentation. This is the [thin script](Scripts.md) rule seen from the other side, and it is why tools [emit objects, not text](#shared-conventions).

## Shared conventions

These hold for all PowerShell, whatever the construct:

- **`Verb-Noun` naming** with an approved verb (`Get-Verb`) and a singular noun: `Get-RepositorySecret`, not `Fetch-Secrets`.
- **`PascalCase`** for functions, parameters, public variables, and class members; `camelCase` for local variables.
- **Full cmdlet names, never aliases** (`Where-Object`, not `?`; `ForEach-Object`, not `%`).
- **Full parameter names, and standard ones.** Pass parameters by name and avoid positional arguments in shared code — `Get-Process -Name pwsh`, not `Get-Process pwsh` — so a call survives parameter-set changes and reads clearly. Name your own parameters after PowerShell's built-ins (`Path`, `Name`, `ComputerName`), not `$Param_Computer`.
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
- **Match text with the operator built for it.** Use `-like` for wildcard patterns and `-match` for regular expressions instead of hand-rolled string surgery; both default to case-insensitive, so add the `-c` prefix (`-clike`, `-cmatch`, `-ceq`) when a comparison must be case-sensitive.
- **Reuse before you build.** Work down the [reuse order](../Functions.md#reuse-before-you-build) — a built-in cmdlet or operator, then an existing function (public or private), then a trusted module (`#Requires -Modules` / `RequiredModules`), then your own code (small logic inline, a larger capability as its own module).
- **PowerShell already *is* .NET; work at that level rather than wrapping it.** Casts, type accelerators (`[datetime]`, `[int]`), the `-split` / `-replace` / `-match` operators, and member methods (`.Trim()`, `.Where()`) all resolve to the base class library — using .NET means reaching for BCL types and methods for the computation, not restating everything as `[Namespace.Type]::Method(...)`. Where idiomatic PowerShell already resolves to the same .NET call, leave it; reach for explicit .NET only where it is measurably faster or more precise, and keep cmdlets and the pipeline where you need them for glue or readability.
- **Do the work in .NET when you implement it.** When you write the logic yourself — or fix an internal function that is too slow or imprecise on a hot path — call the .NET base class library directly instead of a cmdlet pipeline: `[System.IO.File]::ReadAllText($path)` over `Get-Content -Raw`, `[System.IO.Path]::Combine(...)` for paths, `[System.Text.StringBuilder]` for repeated concatenation, `[int]::TryParse(...)` for parsing. .NET methods are faster and their contracts are precise; keep cmdlets where their clarity is worth more than the speed. The next two rules are specific cases.
- **Suppress unwanted output with `$null = ...`** (or `[void]` for method calls), not `| Out-Null` — the pipeline form is markedly slower on hot paths.
- **Build collections with a typed list, not `+=` in a loop.** `$a += $x` reallocates the whole array every iteration; use `[System.Collections.Generic.List[T]]` with `.Add()`, and prefer a cmdlet's `-Filter` over piping to `Where-Object` on large sets.
- **Guard a value that must not change.** Declare it with `Set-Variable -Name Pi -Value 3.14159 -Option ReadOnly` — or `-Option Constant` for one that can never be reassigned or removed — so an accidental write fails loudly instead of quietly winning.
- **Keep secrets out of source, and never `Invoke-Expression` untrusted input.** Accept credentials as a `[PSCredential]` parameter with the `[Credential()]` attribute rather than calling `Get-Credential` inside a reusable function, so a caller can pass one they already hold, and take other sensitive values as `[securestring]`. Guard state-changing commands with `ShouldProcess` (see [Functions](Functions.md)); the wider rules live in the [Security](../Security.md) baseline.

## Toolchain

The toolchain enforces this standard in CI — it does not define it. The rules above are the source of truth; each tool's configuration is derived from them:

- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** is the linter and formatter; its settings are derived from this standard, so passing it cleanly means matching the standard. Let it format — do not hand-format.
- **[Pester](https://pester.dev/)** is the test framework; test files are named `*.Tests.ps1`. See the [Testing baseline](../Testing.md).
