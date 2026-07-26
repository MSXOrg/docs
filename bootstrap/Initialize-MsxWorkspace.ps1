#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Clone or update canonical project context repositories in a git-isolated workspace under $HOME.

.DESCRIPTION
    The single starting point for every agent. It ensures the central
    documentation and memory repositories for each configured project exist
    locally under one dedicated workspace, so an agent reads current canonical
    context regardless of which repository it is working in.

    The workspace is deliberately kept separate from the repositories an agent
    works in:

    - Each docs repository uses a bare backing repository plus a canonical clean
      default-branch worktree. Topic branches use separate worktrees.
    - Each memory repository remains a simple default-branch checkout.
    - Every checkout gets repository-local git config only. Nothing here modifies
      global git config or the working product repository.
    - The script synchronizes context but never writes or pushes repository content.

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

.EXAMPLE
    $projects = @(
        @{
            Name = 'PSModule'
            Path = 'projects/PSModule'
            DocsUrl = 'https://github.com/PSModule/docs.git'
            MemoryUrl = 'https://github.com/PSModule/memory.git'
        }
    )
    ./Initialize-MsxWorkspace.ps1 -Project $projects
    Installs a project's docs and memory under a project-specific workspace path.

.OUTPUTS
    [pscustomobject] with Repository, Path, BackingPath, and Changes for each
    workspace repository.
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
    [string] $UserEmail = 'MariusStorhaug@users.noreply.github.com',

    # Projects whose canonical docs and memory repositories must be synchronized.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [hashtable[]] $Project = @(
        @{
            Name = 'MSXOrg'
            Path = ''
            DocsUrl = 'https://github.com/MSXOrg/docs.git'
            MemoryUrl = 'https://github.com/MSXOrg/memory.git'
        }
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((-not $PSBoundParameters.ContainsKey('UserName')) -or (-not $PSBoundParameters.ContainsKey('UserEmail'))) {
    Write-Warning "Using part of the default maintainer identity ($UserName <$UserEmail>). Pass both -UserName and -UserEmail to set your own repository-local author identity."
}

function Sync-ContextRemote {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $GitPath,

        [Parameter(Mandatory)]
        [string] $RepositoryUrl,

        [Parameter()]
        [switch] $Bare
    )

    if (-not $PSCmdlet.ShouldProcess($GitPath, 'Fetch canonical remote state')) {
        return
    }

    [string[]] $gitRoot = if ($Bare) { @("--git-dir=$GitPath") } else { @('-C', $GitPath) }
    $allBranchesRefspec = '+refs/heads/*:refs/remotes/origin/*'
    $fetchRefspecs = @(& git @gitRoot config --get-all remote.origin.fetch)
    if ($LASTEXITCODE -notin @(0, 1)) {
        throw "git config remote.origin.fetch failed for '$GitPath' (exit $LASTEXITCODE)."
    }
    if ($allBranchesRefspec -notin $fetchRefspecs) {
        & git @gitRoot config --add remote.origin.fetch $allBranchesRefspec
        if ($LASTEXITCODE -ne 0) {
            throw "Could not configure remote tracking branches for '$GitPath' (exit $LASTEXITCODE)."
        }
    }

    & git @gitRoot fetch origin --prune --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "git fetch failed for '$GitPath' (exit $LASTEXITCODE). Check access to $RepositoryUrl."
    }
    & git @gitRoot remote set-head origin --auto | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot detect the remote default branch for '$GitPath'. Check origin before using this context."
    }

    $defaultRef = (& git @gitRoot symbolic-ref --quiet --short refs/remotes/origin/HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot resolve the remote default branch for '$GitPath'. Repair origin/HEAD before using this context."
    }
    return [pscustomobject]@{
        DefaultRef = $defaultRef
        DefaultBranch = $defaultRef -replace '^origin/', ''
        RemoteHead = (& git @gitRoot rev-parse $defaultRef | Out-String).Trim()
    }
}

function Sync-ContextCheckout {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $RepositoryUrl
    )

    $remote = Sync-ContextRemote -GitPath $Path -RepositoryUrl $RepositoryUrl -Confirm:$false
    if (-not $remote -or -not $PSCmdlet.ShouldProcess($Path, "Synchronize $($remote.DefaultBranch)")) {
        return $remote
    }

    $currentBranch = (git -C $Path branch --show-current | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "git branch --show-current failed for '$Path' (exit $LASTEXITCODE)."
    }
    if ($currentBranch -ne $remote.DefaultBranch) {
        throw "'$Path' is on '$currentBranch', not the default branch '$($remote.DefaultBranch)'. Switch branches before using this context."
    }

    $status = @(git -C $Path status --porcelain)
    if ($LASTEXITCODE -ne 0) {
        throw "git status failed for '$Path' (exit $LASTEXITCODE)."
    }
    if ($status.Count -gt 0) {
        throw "'$Path' has uncommitted changes. Commit, push, or remove them before using this context."
    }

    git -C $Path merge --ff-only --quiet $remote.DefaultRef
    if ($LASTEXITCODE -ne 0) {
        throw "Could not fast-forward '$Path' to '$($remote.DefaultRef)'. Resolve its diverged history before using this context."
    }
    $localHead = (git -C $Path rev-parse HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "git rev-parse HEAD failed for '$Path' (exit $LASTEXITCODE)."
    }
    if ($localHead -ne $remote.RemoteHead) {
        throw "'$Path' is not exactly synchronized with '$($remote.DefaultRef)'. Push or reconcile local commits before using this context."
    }
    return $remote
}

function Sync-BareDefaultBranch {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $BackingPath,

        [Parameter(Mandatory)]
        [pscustomobject] $Remote
    )

    $localRef = "refs/heads/$($Remote.DefaultBranch)"
    $localHead = (git --git-dir=$BackingPath rev-parse --verify $localRef 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -eq 128) {
        if ($PSCmdlet.ShouldProcess($localRef, "Create at $($Remote.RemoteHead)")) {
            git --git-dir=$BackingPath update-ref $localRef $Remote.RemoteHead
            if ($LASTEXITCODE -ne 0) {
                throw "Could not create bare docs branch '$localRef' in '$BackingPath'."
            }
        }
        return
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect bare docs branch '$localRef' in '$BackingPath'."
    }
    if ($localHead -eq $Remote.RemoteHead) {
        return
    }

    git --git-dir=$BackingPath merge-base --is-ancestor $localHead $Remote.RemoteHead
    if ($LASTEXITCODE -ne 0) {
        throw "Bare docs branch '$localRef' is ahead or diverged. Reconcile '$BackingPath' before creating its canonical worktree."
    }
    $worktreeState = @(git --git-dir=$BackingPath worktree list --porcelain)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect worktrees for '$BackingPath'."
    }
    if ("branch $localRef" -in $worktreeState) {
        throw "Bare docs branch '$localRef' is checked out in another worktree. Update that worktree before creating the canonical one."
    }
    if ($PSCmdlet.ShouldProcess($localRef, "Fast-forward to $($Remote.RemoteHead)")) {
        git --git-dir=$BackingPath update-ref $localRef $Remote.RemoteHead $localHead
        if ($LASTEXITCODE -ne 0) {
            throw "Could not fast-forward bare docs branch '$localRef' in '$BackingPath'."
        }
    }
}

function Set-ContextIdentity {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Email
    )

    if (-not $PSCmdlet.ShouldProcess($Path, 'Set repository-local git identity')) {
        return
    }
    git -C $Path config user.name $Name
    if ($LASTEXITCODE -ne 0) { throw "git config user.name failed for '$Path' (exit $LASTEXITCODE)." }
    git -C $Path config user.email $Email
    if ($LASTEXITCODE -ne 0) { throw "git config user.email failed for '$Path' (exit $LASTEXITCODE)." }
}

$repositories = foreach ($projectDefinition in $Project) {
    foreach ($key in @('Name', 'Path', 'DocsUrl', 'MemoryUrl')) {
        if (-not $projectDefinition.ContainsKey($key) -or $null -eq $projectDefinition[$key]) {
            throw "Project definitions require Name, Path, DocsUrl, and MemoryUrl. Missing '$key'."
        }
    }

    $projectName = [string] $projectDefinition.Name
    $projectPath = ([string] $projectDefinition.Path).Trim()
    if (-not $projectName.Trim()) {
        throw 'Project Name must not be empty.'
    }
    $pathSegments = @($projectPath -split '[\\/]' | Where-Object { $_ -and $_ -ne '.' })
    if ([IO.Path]::IsPathRooted($projectPath) -or '..' -in $pathSegments) {
        throw "Project Path '$projectPath' must be a safe path relative to the workspace root."
    }
    $projectPath = $pathSegments -join [IO.Path]::DirectorySeparatorChar

    $docsPath = if ($projectPath) { Join-Path $projectPath 'docs' } else { 'docs' }
    $memoryPath = if ($projectPath) { Join-Path $projectPath 'memory' } else { 'memory' }
    [pscustomobject]@{
        Name = "$projectName/docs"
        Project = $projectName
        ProjectPath = $projectPath
        Kind = 'docs'
        RelativePath = $docsPath
        Url = [string] $projectDefinition.DocsUrl
        Changes = 'pull requests'
    }
    [pscustomobject]@{
        Name = "$projectName/memory"
        Project = $projectName
        ProjectPath = $projectPath
        Kind = 'memory'
        RelativePath = $memoryPath
        Url = [string] $projectDefinition.MemoryUrl
        Changes = 'repository policy'
    }
}

$occupiedPaths = foreach ($repository in $repositories) {
    [pscustomobject]@{
        Project = $repository.Project
        Repository = $repository.Name
        Path = $repository.RelativePath
    }
    if ($repository.Kind -eq 'docs') {
        if ($repository.ProjectPath) {
            [pscustomobject]@{
                Project = $repository.Project
                Repository = "$($repository.Project) root"
                Path = $repository.ProjectPath
            }
        }
        [pscustomobject]@{
            Project = $repository.Project
            Repository = "$($repository.Name) backing"
            Path = "$($repository.RelativePath).git"
        }
        [pscustomobject]@{
            Project = $repository.Project
            Repository = "$($repository.Name) migration backup"
            Path = "$($repository.RelativePath).simple-clone-backup"
        }
    }
}
for ($left = 0; $left -lt $occupiedPaths.Count; $left++) {
    $leftPath = ($occupiedPaths[$left].Path -replace '\\', '/').Trim('/').ToLowerInvariant()
    for ($right = $left + 1; $right -lt $occupiedPaths.Count; $right++) {
        if ($occupiedPaths[$left].Project -eq $occupiedPaths[$right].Project) {
            continue
        }
        $rightPath = ($occupiedPaths[$right].Path -replace '\\', '/').Trim('/').ToLowerInvariant()
        $collision = (
            $leftPath -eq $rightPath -or
            $leftPath.StartsWith("$rightPath/", [StringComparison]::Ordinal) -or
            $rightPath.StartsWith("$leftPath/", [StringComparison]::Ordinal)
        )
        if ($collision) {
            throw "Project workspace paths overlap: '$($occupiedPaths[$left].Path)' and '$($occupiedPaths[$right].Path)'."
        }
    }
}

if ($PSCmdlet.ShouldProcess($Root, 'Create workspace root')) {
    New-Item -ItemType Directory -Force -Path $Root | Out-Null
}

$results = foreach ($repo in $repositories) {
    $path = Join-Path $Root $repo.RelativePath
    if ($repo.Kind -eq 'memory') {
        if (-not (Test-Path (Join-Path $path '.git'))) {
            if (Test-Path $path) {
                throw "Cannot clone memory into '$path': it exists but is not a git repository."
            }
            if ($PSCmdlet.ShouldProcess($repo.Url, "Clone memory into '$path'")) {
                New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
                git clone --quiet $repo.Url $path
                if ($LASTEXITCODE -ne 0) {
                    throw "git clone failed for $($repo.Url) (exit $LASTEXITCODE). Check access and credentials."
                }
            }
        }
        Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false | Out-Null
        Set-ContextIdentity -Path $path -Name $UserName -Email $UserEmail -Confirm:$false
        [pscustomobject]@{
            Repository = $repo.Name
            Path = $path
            BackingPath = $null
            Changes = $repo.Changes
        }
        continue
    }

    $expectedBackingPath = "$path.git"
    $backingPath = $null
    $gitEntry = Join-Path $path '.git'
    if (Test-Path $gitEntry -PathType Container) {
        # Safe simple-clone migration: synchronize first, preserve all refs in a
        # new bare backing repository, and retain the old clone as a backup.
        $remote = Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false
        if (Test-Path $expectedBackingPath) {
            throw "Cannot migrate '$path': backing path '$expectedBackingPath' already exists."
        }
        $backupPath = "$path.simple-clone-backup"
        if (Test-Path $backupPath) {
            throw "Cannot migrate '$path': backup path '$backupPath' already exists. Reconcile it first."
        }
        if ($PSCmdlet.ShouldProcess($path, "Migrate simple clone to '$expectedBackingPath'")) {
            $sourceRefs = @(git -C $path for-each-ref '--format=%(refname) %(objectname)' refs/heads refs/tags)
            if ($LASTEXITCODE -ne 0) {
                throw "Could not inventory branches and tags in '$path' before migration."
            }
            try {
                git clone --bare --quiet $path $expectedBackingPath
                if ($LASTEXITCODE -ne 0) {
                    throw "Could not create bare backing repository '$expectedBackingPath' (exit $LASTEXITCODE)."
                }
                git --git-dir=$expectedBackingPath remote set-url origin $repo.Url
                if ($LASTEXITCODE -ne 0) {
                    throw "Could not set origin on '$expectedBackingPath' (exit $LASTEXITCODE)."
                }
                Sync-ContextRemote -GitPath $expectedBackingPath -RepositoryUrl $repo.Url -Bare -Confirm:$false | Out-Null
                $backingRefs = @(git --git-dir=$expectedBackingPath for-each-ref '--format=%(refname) %(objectname)' refs/heads refs/tags)
                if ($LASTEXITCODE -ne 0 -or (Compare-Object $sourceRefs $backingRefs)) {
                    throw "Bare backing repository '$expectedBackingPath' did not preserve every local branch and tag."
                }
            } catch {
                if (Test-Path $expectedBackingPath) {
                    Remove-Item -LiteralPath $expectedBackingPath -Recurse -Force
                }
                throw "Migration preparation failed for '$path'; the original clone is unchanged. $($_.Exception.Message)"
            }

            Move-Item -LiteralPath $path -Destination $backupPath
            try {
                if ($env:MSX_BOOTSTRAP_TEST_FAIL_AFTER_DOCS_MOVE -eq '1') {
                    throw 'Injected post-move migration failure.'
                }
                git --git-dir=$expectedBackingPath worktree add --quiet $path $remote.DefaultBranch
                if ($LASTEXITCODE -ne 0) {
                    throw "Could not create canonical docs worktree '$path' (exit $LASTEXITCODE)."
                }
                Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false | Out-Null
            } catch {
                if (Test-Path $path) {
                    git --git-dir=$expectedBackingPath worktree remove --force $path 2>$null
                    Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue
                }
                if (-not (Test-Path $path) -and (Test-Path $backupPath)) {
                    Move-Item -LiteralPath $backupPath -Destination $path
                }
                if (Test-Path $expectedBackingPath) {
                    Remove-Item -LiteralPath $expectedBackingPath -Recurse -Force
                }
                throw "Migration activation failed for '$path'; the original clone was restored and partial backing removed. $($_.Exception.Message)"
            }
            Write-Warning "Migrated '$path' to bare+worktree layout. Verify it, then remove retained backup '$backupPath'."
        }
        $backingPath = $expectedBackingPath
    } elseif (Test-Path $gitEntry -PathType Leaf) {
        $backingPath = (git -C $path rev-parse --path-format=absolute --git-common-dir | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw "Cannot resolve the backing repository for docs worktree '$path'."
        }
        $isBare = (git --git-dir=$backingPath rev-parse --is-bare-repository | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or $isBare -ne 'true') {
            throw "Docs worktree '$path' is not backed by a bare repository. Repair it before using context."
        }
    } elseif (Test-Path $path) {
        throw "Cannot install docs at '$path': it exists but is not a supported git checkout."
    } else {
        $backingPath = $expectedBackingPath
        if (-not (Test-Path $backingPath)) {
            if ($PSCmdlet.ShouldProcess($repo.Url, "Clone bare docs backing into '$backingPath'")) {
                New-Item -ItemType Directory -Path (Split-Path -Parent $backingPath) -Force | Out-Null
                git clone --bare --quiet $repo.Url $backingPath
                if ($LASTEXITCODE -ne 0) {
                    throw "Bare clone failed for $($repo.Url) (exit $LASTEXITCODE)."
                }
            }
        }
        $isBare = (git --git-dir=$backingPath rev-parse --is-bare-repository | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or $isBare -ne 'true') {
            throw "Docs backing path '$backingPath' is not a bare repository."
        }
        $remote = Sync-ContextRemote -GitPath $backingPath -RepositoryUrl $repo.Url -Bare -Confirm:$false
        Sync-BareDefaultBranch -BackingPath $backingPath -Remote $remote -Confirm:$false
        if ($PSCmdlet.ShouldProcess($path, 'Create canonical docs worktree')) {
            git --git-dir=$backingPath worktree add --quiet $path $remote.DefaultBranch
            if ($LASTEXITCODE -ne 0) {
                throw "Could not create canonical docs worktree '$path' (exit $LASTEXITCODE)."
            }
        }
    }

    Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false | Out-Null
    Set-ContextIdentity -Path $path -Name $UserName -Email $UserEmail -Confirm:$false
    [pscustomobject]@{
        Repository = $repo.Name
        Path = $path
        BackingPath = $backingPath
        Changes = $repo.Changes
    }
}

$results
