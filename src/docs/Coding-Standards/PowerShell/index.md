---
title: PowerShell
description: Cross-platform PowerShell 7 — the conventions shared by every script, function, and class, with per-construct standards below.
---

# PowerShell

PowerShell is the tool for operational automation: platform API calls, cross-platform task orchestration, and tool integration. The target is **PowerShell 7 LTS**, the cross-platform `pwsh`. Use PowerShell's advanced-function features rather than plain scripts.

PowerShell-specific conventions extend the [language-agnostic baseline](../index.md). Where the rules overlap, the baseline rules apply. Functions, classes, and scripts have additional documentation, formatting, and section-structure requirements.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Functions](Functions.md) | Advanced functions — CmdletBinding, typed and validated parameters, pipeline blocks, ShouldProcess, and required comment-based help. |
| [Classes](Classes.md) | When to reach for a PowerShell class, and how to structure its members, constructors, and documentation. |
| [Scripts](Scripts.md) | Structure for standalone .ps1 scripts — requirements, parameters, help, and keeping the script thin. |
| [PowerShell Testing](Testing.md) | Pester test naming and the Simple, Standard, and Advanced profiles for PowerShell modules. |
| [Messaging](Messaging.md) | Write-Verbose for user-facing operational progress and normal troubleshooting; Write-Debug for developer-focused internals and deep diagnostics. |
| [Version Constraints](Version-Constraints.md) | Express module and package version constraints as NuGet version ranges — the canonical notation across PSResourceGet, .NET package references, and (mapped) #Requires and module manifests. |
| [Module Requirements](Requires-Modules.md) | Valid `#Requires -Modules` version specifications — minimum, major-lock (with the `N.*` wildcard), exact, and GUID identity pinning — with an executable proof. |

<!-- INDEX:END -->

## Tools and controllers

PowerShell code uses two roles. The role determines the form of a command's output:

- A **tool** is a reusable unit, usually an advanced function exported from a module. It accepts input only through parameters. It emits **raw, least-manipulated objects** so other callers can reuse the data. A tool that measures size returns bytes, not a rounded string.
- A **controller** is a script that automates one process by calling tools. It may reshape, round, or format data for its readers. It is not intended for reuse.

Keep presentation formatting in controllers. Tools emit raw objects; a controller or a format view (`.format.ps1xml`) converts them for display. This follows the [thin script](Scripts.md) rule and explains why tools [emit objects, not text](#shared-conventions).

## Shared conventions

These hold for all PowerShell, whatever the construct:

- **`Verb-Noun` naming** with an approved verb (`Get-Verb`) and a singular noun: `Get-RepositorySecret`, not `Fetch-Secrets`.
- **`PascalCase`** for functions, parameters, public variables, and class members; `camelCase` for local variables.
- **Full cmdlet names, never aliases** (`Where-Object`, not `?`; `ForEach-Object`, not `%`).
- **Full parameter names, and standard ones.** Pass parameters by name and avoid positional arguments in shared code: `Get-Process -Name pwsh`, not `Get-Process pwsh`. Named arguments keep the call clear and preserve its meaning across parameter-set changes. Name your own parameters after PowerShell's built-ins (`Path`, `Name`, `ComputerName`), not `$Param_Computer`.
- **Map data and integration verbs predictably.** Data modules use `ConvertFrom-` / `ConvertTo-` with a neutral PowerShell object structure. Use `Import-` / `Export-` for file or store round trips. Use `Format-`, `Merge-`, `Compare-`, `Test-`, or `Remove-<Noun>Entry` for structure operations.

  API and integration modules name commands after the resource and intent, not the transport. Map `GET` to `Get-`, create-style `POST` to `New-` / `Add-`, `PUT` / `PATCH` to `Set-` / `Update-`, and `DELETE` to `Remove-`. For non-CRUD operations, use the approved verb that matches the user intent.
- **Set `$ErrorActionPreference = 'Stop'`** at the top of every script and module so errors are terminating, not silently swallowed.
- **Emit objects, not formatted text.** Return rich objects and let the caller format them. Reserve `Write-Host` for console user interfaces. Use `Write-Verbose` / `Write-Information` for progress messages.

## Formatting

These rules define the layout. [PSScriptAnalyzer](#toolchain) checks the configured rules; its settings derive from these rules, not the reverse. Write code to the rules and let the formatter apply them:

- **One True Brace Style (OTBS).** Put the opening brace on the statement line and the closing brace on its own line. Always brace control blocks, even a single statement. Do not put a blank line directly after `{` or before `}`. Put `else` / `elseif` / `catch` / `finally` on the line with the preceding closing brace.
- **Indent with four spaces, never tabs**, and indent comment-based help to align with the function it documents.
- **One space around operators and after commas** (`$a -eq $b`, `@(1, 2, 3)`), and **one space between a type and the name** — `[string] $Name`, not `[string]$Name`.
- **`elseif` is one word**, not `else if`.
- **Use lowercase language keywords** (`if`, `else`, `foreach`, `class`, `enum`, `return`) and reserve PascalCase for commands and named symbols.
- **Blank lines separate logical blocks.** No trailing whitespace, and end every file with a single newline.
- **Keep code lines readable — aim for approximately 120 columns.** When a call grows long, prefer [splatting](#idioms-and-pitfalls) over backtick line-continuations.
- **Avoid semicolons, ternary expressions, and regions in shared code.** Put one statement on each line, use ordinary `if` / `else` when a conditional value matters, and structure code with functions, modules, and headings rather than `#region` blocks.

## Idioms and pitfalls

Beyond the basics, these language-specific habits keep PowerShell correct and fast:

- **Single-quote strings unless you need expansion.** Use `'literal'` by default; reserve `"...$var..."` for interpolation or escape sequences, and here-strings (`@'...'@`, `@"..."@`) for multi-line text — literal-versus-interpolated intent then stays obvious.
- **Splat calls that carry many parameters.** Build a `@{}` of parameters and splat it (`Get-Thing @params`) instead of a long line of `-Param value` pairs or backtick continuations. This makes parameters easier to read and compare in diffs.
- **Put `$null` on the left of a comparison** — `$null -eq $x`, never `$x -eq $null`. Against a collection the right-hand form *filters* rather than tests. Use `-contains` / `-in` for membership, never `-eq`.
- **Match text with the operator for the pattern.** Use `-like` for wildcard patterns and `-match` for regular expressions instead of custom string manipulation. Both default to case-insensitive comparisons. Add the `-c` prefix (`-clike`, `-cmatch`, `-ceq`) when a comparison must be case-sensitive.
- **Use the built-in intent checks for strings and wildcards.** Use `[string]::IsNullOrWhiteSpace($value)` for blank input and `[System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($pattern)` when deciding whether a value contains wildcard syntax.
- **Prefer owned code over third-party dependencies in modules.** For a shipped module, exhaust PowerShell itself, the .NET base class library, and already-owned code before adding an external module, DLL, or package. A third-party dependency requires long-term trust and maintenance. Add it only when the capability's size or specialization makes an owned implementation less appropriate.
- **Reuse before you build.** Follow the [reuse order](../Functions.md#reuse-before-you-build) within controlled code: a built-in cmdlet or operator, an existing function (public or private), shared owned code, then new code. Use a trusted external module (`#Requires -Modules` / `RequiredModules`) only after evaluating those options and the ownership trade-off above. State its acceptable versions as a [version range](Version-Constraints.md).
- **Use PowerShell's .NET integration directly.** Casts, type accelerators (`[datetime]`, `[int]`), the `-split` / `-replace` / `-match` operators, and member methods (`.Trim()`, `.Where()`) all resolve to the base class library. Use BCL types and methods for computation rather than rewriting every operation as `[Namespace.Type]::Method(...)`. Keep idiomatic PowerShell when it resolves to the same .NET call. Use explicit .NET only when it is measurably faster or more precise. Keep cmdlets and the pipeline for integration or readability.
- **Do the work in .NET when you implement it.** When you write the logic yourself — or fix an internal function that is too slow or imprecise on a hot path — call the .NET base class library directly instead of a cmdlet pipeline: `[System.IO.File]::ReadAllText($path)` over `Get-Content -Raw`, `[System.IO.Path]::Combine(...)` for paths, `[System.Text.StringBuilder]` for repeated concatenation, `[int]::TryParse(...)` for parsing. .NET methods are faster and their contracts are precise; keep cmdlets where their clarity is worth more than the speed. The next two rules are specific cases.
- **Suppress unwanted output with `$null = ...`** (or `[void]` for method calls), not `| Out-Null` — the pipeline form is markedly slower on hot paths.
- **Build collections with a typed list, not `+=` in a loop.** `$a += $x` reallocates the whole array every iteration; use `[System.Collections.Generic.List[T]]` with `.Add()`, and prefer a cmdlet's `-Filter` over piping to `Where-Object` on large sets.
- **Guard a value that must not change.** Declare it with `Set-Variable -Name Pi -Value 3.14159 -Option ReadOnly`, or `-Option Constant` for one that can never be reassigned or removed. An accidental write then fails instead of changing the value.
- **Keep secrets out of source, and never `Invoke-Expression` untrusted input.** Accept credentials as a `[PSCredential]` parameter with the `[Credential()]` attribute rather than calling `Get-Credential` inside a reusable function, so a caller can pass one they already hold, and take other sensitive values as `[securestring]`. Guard state-changing commands with `ShouldProcess` (see [Functions](Functions.md)); the wider rules live in the [Security](../Security.md) baseline.
- **Read cross-platform environment values through .NET when provider behavior is not required.** Prefer `[Environment]::GetEnvironmentVariable('NAME')` for process environment reads that should behave the same on every platform. Use `$env:NAME` when you specifically need the PowerShell environment provider.

## Toolchain

The PowerShell rules are the source of truth. The toolchain checks them in CI with configurations derived from those rules:

- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** is the linter and formatter. Its settings derive from the PowerShell rules. Use the formatter rather than formatting code by hand.
- **[Pester](https://pester.dev/)** is the test framework; test files are named `*.Tests.ps1`. See [PowerShell Testing](Testing.md) for module test layouts.
