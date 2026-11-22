---
title: Functions
description: Advanced functions — CmdletBinding, typed and validated parameters, pipeline blocks, ShouldProcess, and required comment-based help.
---

# Functions

Functions are the primary unit of PowerShell. Write **advanced functions**, not basic ones. Advanced functions give callers `-Verbose`, `-ErrorAction`, and discoverable help. State-changing functions also support `-WhatIf`.

## Section structure

Every function body follows this order so readers and agents can find each section:

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

If every parameter set returns the same type, use one `[OutputType]` without scope. If parameter sets return different types, scope each `[OutputType]` to its parameter set with `ParameterSetName`. Repeat `[OutputType]` once per type/set combination as needed:

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

The types in `[OutputType]` must match the types that `.OUTPUTS` documents in the comment-based help. Together they define the function's output contract.

## Parameters

- **Type every parameter** and validate input at the boundary with `[Parameter(Mandatory)]`, `[ValidateSet(...)]`, or `[ValidateNotNullOrEmpty()]`. Reject invalid input before the function processes it.
- **Give every parameter a `[Parameter()]` attribute**, even when it has no arguments. Use it for `Mandatory`, `ValueFromPipeline`, and other parameter metadata. This gives every parameter a consistent declaration.
- **Attribute order**, each on its own line: `[Parameter()]`, then validation attributes, then `[ArgumentCompleter()]`, then `[Alias()]`, then the typed declaration.
- **Separate parameters with a blank line**. Keep each parameter's inline doc comment, attributes, and typed declaration together as one block.
- **`[switch]` for boolean flags** — never a `[bool]` parameter.
- **Name every parameter set** with a prose phrase that states the caller's scenario. Parameter set names appear verbatim in `Get-Help` syntax output and must be clear to callers. **Spaces are supported** and encouraged: `'By display name'`, `'From file path'`, `'As computer name'`, `'With credential'`, `'As session'`. Single-word PascalCase names (`ByName`, `ByPath`, `ByGuid`) are acceptable when the scenario is self-evident. Multi-word names with spaces improve readability in help output.

  Never use `Default`, `__AllParameterSets`, `__DefaultParameterSet`, `ParameterSetA`, `Set1`, `Mode1`, or a name whose purpose is unclear. `DefaultParameterSetName` on `[CmdletBinding()]` must name one of the declared parameter sets with the same prose convention. Always include it when multiple sets exist.

## State changes and the pipeline

- **Guard mutations with `ShouldProcess`.** A function that creates, changes, or deletes state declares `[CmdletBinding(SupportsShouldProcess)]`. It wraps the change in `if ($PSCmdlet.ShouldProcess(...))` so `-WhatIf` and `-Confirm` work. Never add `SupportsShouldProcess` to read-only verbs (`Get`, `Test`, `Resolve`).
- **Design for the pipeline.** Functions that process collections accept `ValueFromPipeline` input and do the work in a `process` block. Emit each result as it becomes available rather than buffering the output.

## Errors and output

- **`throw` for terminating errors**; `Write-Error` only where the caller is expected to handle a non-terminating one.
- **Call cmdlets whose failures you need to catch with `-ErrorAction Stop`** so they raise terminating errors. Native commands report failure through `$LASTEXITCODE`, not the error stream. Inspect that value and `throw` on failure. On PowerShell 7.4+, you can instead set `$PSNativeCommandUseErrorActionPreference = $true` so non-zero exits honor `$ErrorActionPreference`.
- **Put the whole transaction in the `try` block** rather than setting success flags to control later code. Do not rely on `$?`. It reports only whether the last command considered itself successful, with no detail.
- **In a `catch`, copy `$_` into your own variable first**, before later commands overwrite it. The baseline rules — fail fast, never swallow — live in [Error Handling](../Error-Handling.md).

## Output streams

Send each message to its designated stream so callers can capture, redirect, or suppress it:

- **Results** are objects on the output stream. Emit them implicitly by naming the object on its own line. Do **not** use `return $obj` to emit. In a pipeline function, emit from `process`, not `end`.
- **Emit one object type**, matching `[OutputType()]`.
- **`Write-Verbose`** for status a caller may want (`-Verbose`), **`Write-Debug`** for maintainer diagnostics (`-Debug`), and **`Write-Progress`** for progress that need not persist.
- **Do not pass `-Verbose` or `-Debug` explicitly to internal calls** just because the current function was invoked with them. Common parameters are caller controls; write to the stream in the current function and let the caller decide which streams to show or capture.
- **`Write-Warning`** and **`Write-Error`** for warnings and non-terminating errors.
- **`Write-Host`** only for `Show-` or `Format-` verbs or an interactive prompt — never for data another command might consume.

`[CmdletBinding()]` enables the `-Verbose` and `-Debug` switches so callers can control those streams.

## Comment-based help (required)

Every function carries comment-based help, including internal and private helpers. The help explains what the function does and how to call it without access to the implementation.

Put the help first inside the body. Use these sections in order: `.SYNOPSIS` (one imperative sentence), `.DESCRIPTION`, at least one `.EXAMPLE` per behavior, then `.INPUTS`, `.OUTPUTS` (matching `[OutputType()]`), `.NOTES`, `.LINK`. Document each parameter with an inline comment above it rather than a `.PARAMETER` block. Comments explain *why*, not *what*.

Every public function in a module built with the PSModule framework uses its generated online reference URL as the first `.LINK` entry. The canonical URL is an absolute HTTPS URL on the module's published documentation host. It always ends in `/`: `https://<published-documentation-host>/<ModuleName>/Functions/<Function-Name>/` or, for a grouped command, `https://<published-documentation-host>/<ModuleName>/Functions/<Group>/<Function-Name>/`. A private helper links to the published public function it supports.

### `.INPUTS` and `.OUTPUTS`

**`.INPUTS`** documents **pipeline input only** — types accepted via `ValueFromPipeline` or `ValueFromPipelineByPropertyName` parameters. It does not document ordinary parameters.

**`.OUTPUTS`** documents what the function emits to the output stream. Must match `[OutputType()]`.

**Format for PlatyPS-generated docs:** put the type name on the first line. Add a blank line, then a plain description paragraph. PlatyPS v2 (`Microsoft.PowerShell.PlatyPS`) renders the first line as a `###` heading and the description as body text. The blank line separates the heading from the paragraph. A 4-space indent turns the description into a code block. If the type and description share a line, PlatyPS puts the entire sentence in the heading.

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

- **Include a description for every entry**. The type name alone is not sufficient. The description should state the pipeline input (for `.INPUTS`) or the return value (for `.OUTPUTS`) in plain language, rather than restate the type name.
- Use the fully-qualified .NET type name (`System.String`, `System.Management.Automation.PSCustomObject`), not a PowerShell type accelerator (`[string]`, `[pscustomobject]`).
- When no parameters accept pipeline input, write `None` as the type with `You can't pipe objects to <CommandName>.` as the description paragraph (use the actual command name).
- Repeat the keyword once per type when multiple types are accepted or returned.
