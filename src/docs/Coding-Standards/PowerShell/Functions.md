---
title: Functions
description: Advanced functions — CmdletBinding, typed and validated parameters, pipeline blocks, ShouldProcess, and required comment-based help.
---

# Functions

Functions are the primary unit of PowerShell. Write **advanced functions**, not basic ones — the advanced-function machinery gives callers `-Verbose`, `-ErrorAction`, `-WhatIf`, and discoverable help for free.

## Section structure

Every function body follows the same order, so any reader — or agent — knows where to look:

1. **Comment-based help**, first, inside the body.
2. **`[OutputType()]`** and **`[CmdletBinding()]`** (with `SupportsShouldProcess` when it mutates state).
3. **`param()`** block — mandatory parameters first.
4. **`begin` / `process` / `end`** blocks for pipeline functions; a single body otherwise.

```powershell
function Get-UserData {
    <#
        .SYNOPSIS
        Get a user by id.

        .DESCRIPTION
        Return the user record for the given id.

        .EXAMPLE
        Get-UserData -UserId 'jdoe'
        Returns the record for the user 'jdoe'.

        .OUTPUTS
        [PSCustomObject]
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param(
        # The unique identifier of the user.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $UserId,

        # Include deleted users in the result.
        [Parameter()]
        [switch] $IncludeDeleted
    )

    process {
        # ...
    }
}
```

## Parameters

- **Type every parameter** and validate at the boundary — `[Parameter(Mandatory)]`, `[ValidateSet(...)]`, `[ValidateNotNullOrEmpty()]` — so bad input is rejected early, not deep in the call stack.
- **Give every parameter a `[Parameter()]` attribute**, even when it carries no arguments — it is what turns the function advanced and where `Mandatory`, `ValueFromPipeline`, and the rest attach.
- **Attribute order**, each on its own line: `[Parameter()]`, then validation attributes, then `[ArgumentCompleter()]`, then `[Alias()]`, then the typed declaration.
- **Separate parameters with a blank line**, so each one's inline doc comment, attributes, and typed declaration read as a single block.
- **`[switch]` for boolean flags** — never a `[bool]` parameter.
- **Name every parameter set** with an intent-revealing name when a function has more than one mode; never `Default` or `__AllParameterSets`. Set `DefaultParameterSetName` to the most common intent.

## State changes and the pipeline

- **Guard mutations with `ShouldProcess`.** A function that creates, changes, or deletes state declares `[CmdletBinding(SupportsShouldProcess)]` and wraps the change in `if ($PSCmdlet.ShouldProcess(...))`, so `-WhatIf` and `-Confirm` work. Never add `SupportsShouldProcess` to read-only verbs (`Get`, `Test`, `Resolve`).
- **Design for the pipeline.** Functions that process collections accept `ValueFromPipeline` input and do the work in a `process` block, streaming output rather than buffering it.

## Errors and output

- **`throw` for terminating errors**; `Write-Error` only where the caller is expected to handle a non-terminating one.
- **Call cmdlets you mean to trap with `-ErrorAction Stop`** so they raise terminating, catchable errors. Native commands report failure through `$LASTEXITCODE`, not the error stream, so check it and `throw` yourself — or set `$PSNativeCommandUseErrorActionPreference = $true` on PowerShell 7.4+ so their non-zero exits honour `$ErrorActionPreference` too.
- **Put the whole transaction in the `try` block** rather than setting success flags to gate later code, and do not lean on `$?` — it reports only whether the last command considered itself successful, with no detail.
- **In a `catch`, copy `$_` into your own variable first**, before later commands overwrite it. The baseline rules — fail fast, never swallow — live in [Error Handling](../Error-Handling.md).

## Output streams

Send each kind of message to the stream built for it, so a caller can capture, redirect, or silence it:

- **Results** are objects on the output stream — emit them implicitly by naming the object on its own line; do **not** use `return $obj` to emit, and in a pipeline function emit from `process`, not `end`.
- **Emit one object type**, matching `[OutputType()]`.
- **`Write-Verbose`** for status a caller may want (`-Verbose`), **`Write-Debug`** for maintainer breadcrumbs (`-Debug`), and **`Write-Progress`** for progress that need not persist.
- **`Write-Warning`** and **`Write-Error`** for warnings and non-terminating errors.
- **`Write-Host`** only for `Show-` or `Format-` verbs or an interactive prompt — never for data another command might consume.

`[CmdletBinding()]` is what turns on the `-Verbose` and `-Debug` switches, so those streams reach the caller.

## Comment-based help (required)

Every function carries comment-based help, first inside the body, with sections in this order: `.SYNOPSIS` (one imperative sentence), `.DESCRIPTION`, at least one `.EXAMPLE` per behaviour, then `.INPUTS`, `.OUTPUTS` (matching `[OutputType()]`), `.NOTES`, `.LINK`. Document each parameter with an inline comment above it rather than a `.PARAMETER` block, and let comments explain *why*, not *what*.
