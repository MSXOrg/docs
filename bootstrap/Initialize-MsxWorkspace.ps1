#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Clone or update canonical organization context repositories under $HOME.

.DESCRIPTION
    The single starting point for every agent. It ensures each configured
    canonical context repository exists at its preferred local path under one
    dedicated root, so an agent reads current canonical context regardless of
    which repository it is working in.

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
    Clones or synchronizes the canonical MSXOrg and PSModule context under the
    current user's home directory.

.EXAMPLE
    ./Initialize-MsxWorkspace.ps1 -Root /work -Verbose
    Uses a custom context root and logs each step.

.EXAMPLE
    $repositories = @(
        @{ Name = 'MSXOrg/docs'; Path = '.msxorg/docs'; Url = 'https://github.com/MSXOrg/docs.git'; Kind = 'docs' }
        @{ Name = 'MSXOrg/memory'; Path = '.msxorg/memory'; Url = 'https://github.com/MSXOrg/memory.git'; Kind = 'memory' }
    )
    ./Initialize-MsxWorkspace.ps1 -Repository $repositories
    Synchronizes an explicit repository set at explicit paths.

.OUTPUTS
    [pscustomobject] with Repository, Path, BackingPath, and Changes for each
    workspace repository.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # The root under which repository paths are resolved.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Root = $HOME,

    # The git author name written to each clone's local config.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserName = 'Marius Storhaug',

    # The git author email written to each clone's local config.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserEmail = 'MariusStorhaug@users.noreply.github.com',

    # Canonical context repositories and their paths relative to Root.
    [Parameter()]
    [Alias('Repository')]
    [ValidateNotNullOrEmpty()]
    [hashtable[]] $Repositories = @(
        @{
            Name = 'MSXOrg/docs'
            Path = '.msxorg/docs'
            Url = 'https://github.com/MSXOrg/docs.git'
            Kind = 'docs'
        }
        @{
            Name = 'MSXOrg/memory'
            Path = '.msxorg/memory'
            Url = 'https://github.com/MSXOrg/memory.git'
            Kind = 'memory'
        }
        @{
            Name = 'PSModule/Process-PSModule'
            Path = '.psmodule/process-psmodule'
            Url = 'https://github.com/PSModule/Process-PSModule.git'
            Kind = 'docs'
        }
        @{
            Name = 'PSModule/memory'
            Path = '.psmodule/memory'
            Url = 'https://github.com/PSModule/memory.git'
            Kind = 'memory'
        }
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((-not $PSBoundParameters.ContainsKey('UserName')) -or (-not $PSBoundParameters.ContainsKey('UserEmail'))) {
    Write-Warning "Using part of the default maintainer identity ($UserName <$UserEmail>). Pass both -UserName and -UserEmail to set your own repository-local author identity."
}

function Assert-ContextOrigin {
    param(
        [Parameter(Mandatory)]
        [string] $GitPath,

        [Parameter(Mandatory)]
        [string] $RepositoryUrl,

        [Parameter()]
        [switch] $Bare
    )

    [string[]] $gitRoot = if ($Bare) { @("--git-dir=$GitPath") } else { @('-C', $GitPath) }
    $originUrl = (& git @gitRoot remote get-url origin | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot resolve origin for '$GitPath'. Configure it as '$RepositoryUrl'."
    }
    if ($originUrl -ne $RepositoryUrl) {
        throw "Origin for '$GitPath' is '$originUrl', not canonical '$RepositoryUrl'. Repair it before using this context."
    }
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
    Assert-ContextOrigin -GitPath $GitPath -RepositoryUrl $RepositoryUrl -Bare:$Bare
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
    $remoteHead = (& git @gitRoot rev-parse $defaultRef | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $remoteHead) {
        throw "Cannot resolve remote head '$defaultRef' for '$GitPath'."
    }
    return [pscustomobject]@{
        DefaultRef = $defaultRef
        DefaultBranch = $defaultRef -replace '^origin/', ''
        RemoteHead = $remoteHead
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

$repositoryNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$contextRepositories = foreach ($repositoryDefinition in $Repositories) {
    foreach ($key in @('Name', 'Path', 'Url', 'Kind')) {
        if (-not $repositoryDefinition.ContainsKey($key) -or $null -eq $repositoryDefinition[$key]) {
            throw "Repository definitions require Name, Path, Url, and Kind. Missing '$key'."
        }
    }

    $repositoryName = ([string] $repositoryDefinition.Name).Trim()
    if (-not $repositoryName) {
        throw 'Repository Name must not be empty.'
    }
    if (-not $repositoryNames.Add($repositoryName)) {
        throw "Repository definitions require unique names. Duplicate: '$repositoryName'."
    }

    $repositoryPath = ([string] $repositoryDefinition.Path).Trim()
    $pathSegments = @($repositoryPath -split '[\\/]' | Where-Object { $_ -and $_ -ne '.' })
    if (
        -not $pathSegments -or
        [IO.Path]::IsPathRooted($repositoryPath) -or
        '..' -in $pathSegments
    ) {
        throw "Repository Path '$repositoryPath' must be a non-empty safe path relative to Root."
    }
    $repositoryPath = $pathSegments -join [IO.Path]::DirectorySeparatorChar

    $kind = ([string] $repositoryDefinition.Kind).Trim().ToLowerInvariant()
    if ($kind -notin @('docs', 'memory')) {
        throw "Repository Kind for '$repositoryName' must be 'docs' or 'memory', not '$kind'."
    }

    [pscustomobject]@{
        Name = $repositoryName
        Kind = $kind
        RelativePath = $repositoryPath
        Url = [string] $repositoryDefinition.Url
        Changes = if ($kind -eq 'docs') { 'pull requests' } else { 'repository policy' }
    }
}

$occupiedPaths = foreach ($repository in $contextRepositories) {
    [pscustomobject]@{
        Repository = $repository.Name
        Path = $repository.RelativePath
    }
    if ($repository.Kind -eq 'docs') {
        [pscustomobject]@{
            Repository = "$($repository.Name) backing"
            Path = "$($repository.RelativePath).git"
        }
        [pscustomobject]@{
            Repository = "$($repository.Name) migration backup"
            Path = "$($repository.RelativePath).simple-clone-backup"
        }
    }
}
for ($left = 0; $left -lt $occupiedPaths.Count; $left++) {
    $leftPath = ($occupiedPaths[$left].Path -replace '\\', '/').Trim('/').ToLowerInvariant()
    for ($right = $left + 1; $right -lt $occupiedPaths.Count; $right++) {
        $rightPath = ($occupiedPaths[$right].Path -replace '\\', '/').Trim('/').ToLowerInvariant()
        $collision = (
            $leftPath -eq $rightPath -or
            $leftPath.StartsWith("$rightPath/", [StringComparison]::Ordinal) -or
            $rightPath.StartsWith("$leftPath/", [StringComparison]::Ordinal)
        )
        if ($collision) {
            throw "Repository paths overlap: '$($occupiedPaths[$left].Path)' and '$($occupiedPaths[$right].Path)'."
        }
    }
}

$formerPaths = @{
    'MSXOrg/docs' = '.msx/docs'
    'MSXOrg/memory' = '.msx/memory'
    'PSModule/Process-PSModule' = '.msx/projects/PSModule/docs'
    'PSModule/memory' = '.msx/projects/PSModule/memory'
}
foreach ($repository in $contextRepositories) {
    if (-not $formerPaths.ContainsKey($repository.Name)) {
        continue
    }
    $formerPath = Join-Path $Root $formerPaths[$repository.Name]
    if (Test-Path -LiteralPath $formerPath) {
        $canonicalPath = Join-Path $Root $repository.RelativePath
        Write-Warning "Former context path '$formerPath' for '$($repository.Name)' will not be used. Bootstrap will refresh the canonical repository at '$canonicalPath'. Remove the former path only after verifying the canonical clone."
    }
}

foreach ($repository in $contextRepositories | Where-Object Kind -eq 'memory') {
    $memoryPath = Join-Path $Root $repository.RelativePath
    $memoryGitEntry = Join-Path $memoryPath '.git'
    if (Test-Path -LiteralPath $memoryGitEntry -PathType Leaf) {
        throw "Memory context '$memoryPath' is a worktree, but memory requires a simple checkout with a .git directory."
    }
    if (
        (Test-Path -LiteralPath $memoryPath) -and
        -not (Test-Path -LiteralPath $memoryGitEntry -PathType Container)
    ) {
        throw "Memory context '$memoryPath' is not a supported simple git checkout."
    }
}

foreach ($repository in $contextRepositories) {
    $contextPath = Join-Path $Root $repository.RelativePath
    $gitEntry = Join-Path $contextPath '.git'
    if ($repository.Kind -eq 'memory' -and (Test-Path -LiteralPath $gitEntry -PathType Container)) {
        Assert-ContextOrigin -GitPath $contextPath -RepositoryUrl $repository.Url
    } elseif ($repository.Kind -eq 'docs') {
        if (Test-Path -LiteralPath $gitEntry -PathType Container) {
            Assert-ContextOrigin -GitPath $contextPath -RepositoryUrl $repository.Url
        } elseif (Test-Path -LiteralPath $gitEntry -PathType Leaf) {
            $commonDir = (git -C $contextPath rev-parse --path-format=absolute --git-common-dir | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) {
                throw "Cannot resolve docs backing repository for '$contextPath'."
            }
            Assert-ContextOrigin -GitPath $commonDir -RepositoryUrl $repository.Url -Bare
        } elseif (Test-Path -LiteralPath "$contextPath.git") {
            Assert-ContextOrigin -GitPath "$contextPath.git" -RepositoryUrl $repository.Url -Bare
        }
    }
}

if ($PSCmdlet.ShouldProcess($Root, 'Create workspace root')) {
    [void] [IO.Directory]::CreateDirectory($Root)
}

$results = foreach ($repo in $contextRepositories) {
    $path = Join-Path $Root $repo.RelativePath
    if ($repo.Kind -eq 'memory') {
        $memoryGitEntry = Join-Path $path '.git'
        if (Test-Path -LiteralPath $memoryGitEntry -PathType Leaf) {
            throw "Memory context '$path' is a worktree, but memory requires a simple checkout with a .git directory."
        }
        if (-not (Test-Path -LiteralPath $memoryGitEntry -PathType Container)) {
            if (Test-Path -LiteralPath $path) {
                throw "Cannot clone memory into '$path': it exists but is not a supported simple git checkout."
            }
            if ($PSCmdlet.ShouldProcess($repo.Url, "Clone memory into '$path'")) {
                [void] [IO.Directory]::CreateDirectory((Split-Path -Parent $path))
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
    if (Test-Path -LiteralPath $gitEntry -PathType Container) {
        # Safe simple-clone migration: synchronize first, preserve all refs in a
        # new bare backing repository, and retain the old clone as a backup.
        $remote = Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false
        if (Test-Path -LiteralPath $expectedBackingPath) {
            throw "Cannot migrate '$path': backing path '$expectedBackingPath' already exists."
        }
        $backupPath = "$path.simple-clone-backup"
        if (Test-Path -LiteralPath $backupPath) {
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
                if (Test-Path -LiteralPath $expectedBackingPath) {
                    Remove-Item -LiteralPath $expectedBackingPath -Recurse -Force
                }
                throw "Migration preparation failed for '$path'; the original clone is unchanged. $($_.Exception.Message)"
            }

            $moved = $false
            try {
                if ($env:MSX_BOOTSTRAP_TEST_FAIL_DOCS_MOVE -eq '1') {
                    throw 'Injected migration move failure.'
                }
                Move-Item -LiteralPath $path -Destination $backupPath -ErrorAction Stop
                $moved = $true
                if ($env:MSX_BOOTSTRAP_TEST_FAIL_AFTER_DOCS_MOVE -eq '1') {
                    throw 'Injected post-move migration failure.'
                }
                git --git-dir=$expectedBackingPath worktree add --quiet $path $remote.DefaultBranch
                if ($LASTEXITCODE -ne 0) {
                    throw "Could not create canonical docs worktree '$path' (exit $LASTEXITCODE)."
                }
                Sync-ContextCheckout -Path $path -RepositoryUrl $repo.Url -Confirm:$false | Out-Null
            } catch {
                $activationError = $_
                $rollbackErrors = [Collections.Generic.List[string]]::new()
                if ($moved -and (Test-Path -LiteralPath $path)) {
                    git --git-dir=$expectedBackingPath worktree remove --force $path 2>$null
                    if ($LASTEXITCODE -ne 0) {
                        $rollbackErrors.Add("git worktree remove failed for '$path'.")
                    }
                    try {
                        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
                    } catch {
                        $rollbackErrors.Add("Could not remove partial worktree '$path': $($_.Exception.Message)")
                    }
                }
                if (
                    $moved -and
                    -not (Test-Path -LiteralPath $path) -and
                    (Test-Path -LiteralPath $backupPath)
                ) {
                    try {
                        Move-Item -LiteralPath $backupPath -Destination $path -ErrorAction Stop
                    } catch {
                        $rollbackErrors.Add("Could not restore '$backupPath' to '$path': $($_.Exception.Message)")
                    }
                }
                if (Test-Path -LiteralPath $expectedBackingPath) {
                    try {
                        Remove-Item -LiteralPath $expectedBackingPath -Recurse -Force -ErrorAction Stop
                    } catch {
                        $rollbackErrors.Add("Could not remove partial backing '$expectedBackingPath': $($_.Exception.Message)")
                    }
                }
                if ($rollbackErrors.Count -gt 0) {
                    throw "Migration activation and rollback both failed. $($rollbackErrors -join ' ') Original error: $($activationError.Exception.Message)"
                }
                throw "Migration activation failed for '$path'; the original clone is usable and partial backing removed. $($activationError.Exception.Message)"
            }
            Write-Warning "Migrated '$path' to bare+worktree layout. Verify it, then remove retained backup '$backupPath'."
        }
        $backingPath = $expectedBackingPath
    } elseif (Test-Path -LiteralPath $gitEntry -PathType Leaf) {
        $backingPath = (git -C $path rev-parse --path-format=absolute --git-common-dir | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw "Cannot resolve the backing repository for docs worktree '$path'."
        }
        $isBare = (git --git-dir=$backingPath rev-parse --is-bare-repository | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or $isBare -ne 'true') {
            throw "Docs worktree '$path' is not backed by a bare repository. Repair it before using context."
        }
    } elseif (Test-Path -LiteralPath $path) {
        throw "Cannot install docs at '$path': it exists but is not a supported git checkout."
    } else {
        $backingPath = $expectedBackingPath
        if (-not (Test-Path -LiteralPath $backingPath)) {
            if ($PSCmdlet.ShouldProcess($repo.Url, "Clone bare docs backing into '$backingPath'")) {
                [void] [IO.Directory]::CreateDirectory((Split-Path -Parent $backingPath))
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
