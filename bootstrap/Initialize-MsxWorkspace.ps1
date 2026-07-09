#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Clone or update the MSX central workspace (docs + memory) in a git-isolated location under $HOME.

.DESCRIPTION
    The single starting point for every agent. It ensures the central
    documentation and memory repositories exist locally under one dedicated
    workspace, so an agent reads the same evergreen docs and the same prior
    memory regardless of which repository it is working in.

    The workspace is deliberately kept separate from the repositories an agent
    works in:

    - Each clone gets repository-local git config only. Nothing here modifies the
      global git config or the working repository's config; git still reads global
      and system config as usual, but this script writes only repository-local config.
    - Documentation (MSXOrg/docs) is context and is changed through pull requests
      only; this script never pushes its main branch.
    - Memory (MSXOrg/memory) is append-only context; notes are committed and
      pushed to main directly, without a pull request.

    The script is idempotent: it clones what is missing and fast-forwards what is
    already present.

.PARAMETER Root
    The workspace root under which 'docs' and 'memory' are placed. Defaults to ~/.msx.

.PARAMETER UserName
    The git author name written to each clone's local config.

.PARAMETER UserEmail
    The git author email written to each clone's local config.

.EXAMPLE
    ./Initialize-MsxWorkspace.ps1
    Clones missing repositories and fast-forwards existing ones under ~/.msx.

.EXAMPLE
    ./Initialize-MsxWorkspace.ps1 -Root /work/.msx -Verbose
    Uses a custom workspace root and logs each step.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string] $Root = (Join-Path $HOME '.msx'),

    [Parameter()]
    [string] $UserName = 'Marius Storhaug',

    [Parameter()]
    [string] $UserEmail = 'MariusStorhaug@users.noreply.github.com'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositories = @(
    [pscustomobject]@{ Name = 'docs'; Url = 'https://github.com/MSXOrg/docs.git'; Changes = 'pull requests' }
    [pscustomobject]@{ Name = 'memory'; Url = 'https://github.com/MSXOrg/memory.git'; Changes = 'push to main' }
)

New-Item -ItemType Directory -Force -Path $Root | Out-Null

$results = foreach ($repo in $repositories) {
    $path = Join-Path $Root $repo.Name
    if (Test-Path (Join-Path $path '.git')) {
        Write-Verbose "Updating $path"
        git -C $path fetch origin --quiet
        try {
            git -C $path pull --ff-only --quiet
        } catch {
            Write-Warning "Could not fast-forward '$path' (local changes?). Left as-is."
        }
    } else {
        if (Test-Path $path) {
            throw "Cannot clone into '$path': it exists but is not a git repository. Remove it or choose a different -Root."
        }
        Write-Verbose "Cloning $($repo.Url) into $path"
        git clone --quiet $repo.Url $path
    }

    # Isolated identity: write repository-local config only. Git still reads
    # global and system config; the script never writes to them.
    git -C $path config user.name $UserName
    git -C $path config user.email $UserEmail

    [pscustomobject]@{ Repository = $repo.Name; Path = $path; Changes = $repo.Changes }
}

$results | Format-Table -AutoSize
Write-Output 'MSX workspace ready. Read docs and memory here; docs change through pull requests, memory pushes to main.'
