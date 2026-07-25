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

        .INPUTS
        None

        You can't pipe objects to Get-UserData.

        .OUTPUTS
        System.Management.Automation.PSCustomObject

        The user record for the requested UserId.
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

### `[OutputType]` and parameter sets

When every parameter set returns the same type, one `[OutputType]` with no scoping is correct. When different parameter sets return different types, scope each `[OutputType]` to its parameter set using the `ParameterSetName` argument — `[OutputType]` may appear multiple times on the same function, once per type/set combination:

```powershell
[OutputType([System.String],      ParameterSetName = 'By display name')]
[OutputType([System.IO.FileInfo], ParameterSetName = 'From file path')]
[CmdletBinding(DefaultParameterSetName = 'By display name')]
param(
    [Parameter(Mandatory, ParameterSetName = 'By display name')]
    [string] $DisplayName,

    [Parameter(Mandatory, ParameterSetName = 'From file path')]
    [string] $FilePath
)
```

The types listed in `[OutputType]` must match what `.OUTPUTS` documents in the comment-based help — they are the contract between the function and its callers.

## Parameters

- **Type every parameter** and validate at the boundary — `[Parameter(Mandatory)]`, `[ValidateSet(...)]`, `[ValidateNotNullOrEmpty()]` — so bad input is rejected early, not deep in the call stack.
- **Give every parameter a `[Parameter()]` attribute**, even when it carries no arguments — it is where `Mandatory`, `ValueFromPipeline`, and the rest attach, and it keeps every parameter declared the same way.
- **Attribute order**, each on its own line: `[Parameter()]`, then validation attributes, then `[ArgumentCompleter()]`, then `[Alias()]`, then the typed declaration.
- **Separate parameters with a blank line**, so each one's inline doc comment, attributes, and typed declaration read as a single block.
- **`[switch]` for boolean flags** — never a `[bool]` parameter.
- **Name every parameter set** with a prose phrase that states the caller's scenario — parameter set names appear verbatim in `Get-Help` syntax output and must read naturally to anyone calling the command. **Spaces are supported** and encouraged: `'By display name'`, `'From file path'`, `'As computer name'`, `'With credential'`, `'As session'`. Single-word PascalCase names (`ByName`, `ByPath`, `ByGuid`) are acceptable when the scenario is self-evident, but multi-word names with spaces read even better in help output. Never acceptable: `Default`, `__AllParameterSets`, `__DefaultParameterSet`, `ParameterSetA`, `Set1`, `Mode1`, or any name a caller would have to decode. `DefaultParameterSetName` on `[CmdletBinding()]` must name one of the declared parameter sets using the same prose convention and is never omitted when multiple sets exist.

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
- **Do not pass `-Verbose` or `-Debug` explicitly to internal calls** just because the current function was invoked with them. Common parameters are caller controls; write to the stream in the current function and let the caller decide which streams to show or capture.
- **`Write-Warning`** and **`Write-Error`** for warnings and non-terminating errors.
- **`Write-Host`** only for `Show-` or `Format-` verbs or an interactive prompt — never for data another command might consume.

`[CmdletBinding()]` is what turns on the `-Verbose` and `-Debug` switches, so those streams reach the caller.

## Comment-based help (required)

Every function carries comment-based help — including internal and private helpers, not only the public surface. It is what lets a reader or an agent understand what the function does and how to call it without reading its body, and a private helper needs that as much as a public command does. Put it first inside the body, with sections in this order: `.SYNOPSIS` (one imperative sentence), `.DESCRIPTION`, at least one `.EXAMPLE` per behaviour, then `.INPUTS`, `.OUTPUTS` (matching `[OutputType()]`), `.NOTES`, `.LINK`. Document each parameter with an inline comment above it rather than a `.PARAMETER` block, and let comments explain *why*, not *what*.

### `.INPUTS` and `.OUTPUTS`

**`.INPUTS`** documents **pipeline input only** — types accepted via `ValueFromPipeline` or `ValueFromPipelineByPropertyName` parameters. It does not document ordinary parameters.

**`.OUTPUTS`** documents what the function emits to the output stream. Must match `[OutputType()]`.

**Format for PlatyPS-generated docs:** type name on the first line, a blank line, then the description as a plain paragraph. PlatyPS v2 (`Microsoft.PowerShell.PlatyPS`) renders the first line as a `###` heading and the paragraph after the blank line as body text below it — producing clean, well-structured Markdown. Without the blank line, the description attaches directly below the heading with no separator; with 4-space indent it becomes a code block; with the type and description on the same line the entire sentence ends up inside the heading.

```powershell
.INPUTS
None

You can't pipe objects to Get-Example.

.INPUTS
System.String

The name of the user to look up, piped in.

.OUTPUTS
System.Management.Automation.PSCustomObject

The user record for the requested id.
```

> **Note:** The official `about_Comment_Based_Help` examples show `System.String. Description.` on one line — that format works in `Get-Help` output but causes MD026 violations and puts a full sentence inside a `###` heading when processed by PlatyPS v2. Use the blank-line format above for modules that use PlatyPS for documentation.

Rules that apply to both sections:

- Use the fully-qualified .NET type name (`System.String`, `System.Management.Automation.PSCustomObject`), not a PowerShell type accelerator (`[string]`, `[pscustomobject]`).
- When no parameters accept pipeline input, write `None` as the type with `You can't pipe objects to <CommandName>.` as the description paragraph (use the actual command name).
- Repeat the keyword once per type when multiple types are accepted or returned.
