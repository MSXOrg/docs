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
- **Attribute order**, each on its own line: `[Parameter()]`, then validation attributes, then `[ArgumentCompleter()]`, then `[Alias()]`, then the typed declaration.
- **`[switch]` for boolean flags** — never a `[bool]` parameter.
- **Name every parameter set** with an intent-revealing name when a function has more than one mode; never `Default` or `__AllParameterSets`. Set `DefaultParameterSetName` to the most common intent.

## State changes and the pipeline

- **Guard mutations with `ShouldProcess`.** A function that creates, changes, or deletes state declares `[CmdletBinding(SupportsShouldProcess)]` and wraps the change in `if ($PSCmdlet.ShouldProcess(...))`, so `-WhatIf` and `-Confirm` work. Never add `SupportsShouldProcess` to read-only verbs (`Get`, `Test`, `Resolve`).
- **Design for the pipeline.** Functions that process collections accept `ValueFromPipeline` input and do the work in a `process` block, streaming output rather than buffering it.

## Errors and output

- **`throw` for terminating errors**; `Write-Error` only where the caller is expected to handle a non-terminating one.
- **Emit one object type**, matching `[OutputType()]`; never `Write-Host` data another command might consume.

## Comment-based help (required)

Every public function carries comment-based help, first inside the body, with sections in this order: `.SYNOPSIS` (one imperative sentence), `.DESCRIPTION`, at least one `.EXAMPLE` per behaviour, then `.INPUTS`, `.OUTPUTS` (matching `[OutputType()]`), `.NOTES`, `.LINK`. Document each parameter with an inline comment above it rather than a `.PARAMETER` block, and let comments explain *why*, not *what*.
