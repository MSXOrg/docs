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

    The script is idempotent: it clones what is missing and synchronizes every
    existing context repository to the exact remote default-branch head. It stops
    before context is read when a repository is dirty, on another branch, locally
    ahead, diverged, or unavailable.

.EXAMPLE
    ./Initialize-MsxWorkspace.ps1
    Clones missing repositories and exactly synchronizes existing ones under ~/.msx.

.EXAMPLE
    ./Initialize-MsxWorkspace.ps1 -Root /work/.msx -Verbose
    Uses a custom workspace root and logs each step.

.OUTPUTS
    [pscustomobject] with Repository, Path, and Changes for each workspace repository.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # The workspace root under which 'docs' and 'memory' are placed.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Root = (Join-Path $HOME '.msx'),

    # The git author name written to each clone's local config.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserName = 'Marius Storhaug',

    # The git author email written to each clone's local config.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserEmail = 'MariusStorhaug@users.noreply.github.com'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((-not $PSBoundParameters.ContainsKey('UserName')) -or (-not $PSBoundParameters.ContainsKey('UserEmail'))) {
    Write-Warning "Using part of the default maintainer identity ($UserName <$UserEmail>). Pass both -UserName and -UserEmail to attribute your own commits (memory pushes to main)."
}

$repositories = @(
    [pscustomobject]@{ Name = 'docs'; Url = 'https://github.com/MSXOrg/docs.git'; Changes = 'pull requests' }
    [pscustomobject]@{ Name = 'memory'; Url = 'https://github.com/MSXOrg/memory.git'; Changes = 'push to main' }
)

if ($PSCmdlet.ShouldProcess($Root, 'Create workspace root')) {
    New-Item -ItemType Directory -Force -Path $Root | Out-Null
}

$results = foreach ($repo in $repositories) {
    $path = Join-Path $Root $repo.Name
    if (Test-Path (Join-Path $path '.git')) {
        if ($PSCmdlet.ShouldProcess($path, 'Fetch and synchronize default branch')) {
            Write-Verbose "Updating $path"
            $allBranchesRefspec = '+refs/heads/*:refs/remotes/origin/*'
            $fetchRefspecs = @(git -C $path config --get-all remote.origin.fetch)
            if ($LASTEXITCODE -notin @(0, 1)) {
                throw "git config remote.origin.fetch failed for '$path' (exit $LASTEXITCODE)."
            }
            if ($allBranchesRefspec -notin $fetchRefspecs) {
                git -C $path config --add remote.origin.fetch $allBranchesRefspec
                if ($LASTEXITCODE -ne 0) {
                    throw "Could not configure remote tracking branches for '$path' (exit $LASTEXITCODE)."
                }
            }

            git -C $path fetch origin --prune --quiet
            if ($LASTEXITCODE -ne 0) {
                throw "git fetch failed for '$path' (exit $LASTEXITCODE). Check network access and credentials for $($repo.Url)."
            }

            git -C $path remote set-head origin --auto | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Cannot detect the remote default branch for '$path'. Check origin before using this context."
            }
            $defaultRef = (git -C $path symbolic-ref --quiet --short refs/remotes/origin/HEAD | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "Cannot resolve the remote default branch for '$path'. Repair origin/HEAD before using this context."
            }
            $defaultBranch = $defaultRef -replace '^origin/', ''
            $currentBranch = (git -C $path branch --show-current | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "git branch --show-current failed for '$path' (exit $LASTEXITCODE)."
            }
            if ($currentBranch -ne $defaultBranch) {
                throw "'$path' is on '$currentBranch', not the default branch '$defaultBranch'. Switch branches before using this context."
            }

            $status = @(git -C $path status --porcelain)
            if ($LASTEXITCODE -ne 0) {
                throw "git status failed for '$path' (exit $LASTEXITCODE)."
            }
            if ($status.Count -gt 0) {
                throw "'$path' has uncommitted changes. Commit, push, or remove them before using this context."
            }

            git -C $path merge --ff-only --quiet $defaultRef
            if ($LASTEXITCODE -ne 0) {
                throw "Could not fast-forward '$path' to '$defaultRef'. Resolve its diverged history before using this context."
            }

            $localHead = (git -C $path rev-parse HEAD | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "git rev-parse HEAD failed for '$path' (exit $LASTEXITCODE)."
            }
            $remoteHead = (git -C $path rev-parse $defaultRef | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "git rev-parse '$defaultRef' failed for '$path' (exit $LASTEXITCODE)."
            }
            if ($localHead -ne $remoteHead) {
                throw "'$path' is not exactly synchronized with '$defaultRef'. Push or reconcile local commits before using this context."
            }
        }
    } else {
        if (Test-Path $path) {
            throw "Cannot clone into '$path': it exists but is not a git repository. Remove it or choose a different -Root."
        }
        if ($PSCmdlet.ShouldProcess($repo.Url, "Clone into '$path'")) {
            Write-Verbose "Cloning $($repo.Url) into $path"
            git clone --quiet $repo.Url $path
            if ($LASTEXITCODE -ne 0) {
                throw "git clone failed for $($repo.Url) (exit $LASTEXITCODE). Check access and credentials (MSXOrg/memory is private)."
            }
        }
    }

    # Isolated identity: write repository-local config only. Git still reads
    # global and system config; the script never writes to them.
    if ($PSCmdlet.ShouldProcess($path, 'Set repository-local git identity')) {
        git -C $path config user.name $UserName
        if ($LASTEXITCODE -ne 0) { throw "git config user.name failed for '$path' (exit $LASTEXITCODE)." }
        git -C $path config user.email $UserEmail
        if ($LASTEXITCODE -ne 0) { throw "git config user.email failed for '$path' (exit $LASTEXITCODE)." }
    }

    [pscustomobject]@{ Repository = $repo.Name; Path = $path; Changes = $repo.Changes }
}

$results
