# MSX workspace

Read nearest first, prefer documentation over memory, and always use the newest version.

Everything is a work in progress and can be improved. Fix a small problem when it is directly in scope; register a larger or unrelated problem as an issue in the repository that owns it.

## First — refresh canonical context

Canonical context is repository-addressable. An agent may use a CLI, the web, published documentation, or a refreshed local clone. The preferred local clones are refreshed at the start of every session so stale context is never accepted silently.

```powershell
$contextRoot = if ($env:MSX_CONTEXT_ROOT) { $env:MSX_CONTEXT_ROOT } else { $HOME }
$msxDocsUrl = if ($env:MSXORG_DOCS_URL) { $env:MSXORG_DOCS_URL } else { 'https://github.com/MSXOrg/docs.git' }
$msxMemoryUrl = if ($env:MSXORG_MEMORY_URL) { $env:MSXORG_MEMORY_URL } else { 'https://github.com/MSXOrg/memory.git' }
$psmoduleDocsUrl = if ($env:PSMODULE_DOCS_URL) { $env:PSMODULE_DOCS_URL } else { 'https://github.com/PSModule/Process-PSModule.git' }
$psmoduleMemoryUrl = if ($env:PSMODULE_MEMORY_URL) { $env:PSMODULE_MEMORY_URL } else { 'https://github.com/PSModule/memory.git' }
$docs = Join-Path $contextRoot '.msxorg/docs'
$docsBacking = "$docs.git"
if ((Test-Path -LiteralPath $docs) -and -not (Test-Path -LiteralPath (Join-Path $docs '.git'))) {
    throw "$docs exists but is not a git repository. Reconcile it before using context."
}
if (-not (Test-Path -LiteralPath (Join-Path $docs '.git'))) {
    if (-not (Test-Path -LiteralPath $docsBacking)) {
        [void] [IO.Directory]::CreateDirectory((Split-Path -Parent $docs))
        git clone --bare $msxDocsUrl $docsBacking
        if ($LASTEXITCODE -ne 0) {
            throw "Bare clone of MSXOrg/docs failed (exit $LASTEXITCODE). Check network access and credentials."
        }
    }
    if ((git --git-dir=$docsBacking rev-parse --is-bare-repository) -ne 'true') {
        throw "$docsBacking exists but is not a bare repository."
    }
    if ((git --git-dir=$docsBacking remote get-url origin) -ne $msxDocsUrl) {
        throw "$docsBacking origin does not match canonical $msxDocsUrl."
    }
    $refspec = '+refs/heads/*:refs/remotes/origin/*'
    if ($refspec -notin @(git --git-dir=$docsBacking config --get-all remote.origin.fetch)) {
        git --git-dir=$docsBacking config --add remote.origin.fetch $refspec
        if ($LASTEXITCODE -ne 0) {
            throw "Could not configure $docsBacking."
        }
    }
    git --git-dir=$docsBacking fetch origin --prune --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Could not refresh $docsBacking. Do not use stale context."
    }
    git --git-dir=$docsBacking remote set-head origin --auto | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not detect the MSXOrg/docs default branch.'
    }
    $defaultRef = (git --git-dir=$docsBacking symbolic-ref --short refs/remotes/origin/HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve origin/HEAD in $docsBacking."
    }
    $defaultBranch = $defaultRef -replace '^origin/', ''
    $remoteHead = (git --git-dir=$docsBacking rev-parse $defaultRef | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve $defaultRef in $docsBacking."
    }
    $localRef = "refs/heads/$defaultBranch"
    $localHead = (git --git-dir=$docsBacking rev-parse --verify $localRef 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -eq 128) {
        git --git-dir=$docsBacking update-ref $localRef $remoteHead
    } elseif ($LASTEXITCODE -ne 0) {
        throw "Could not inspect $localRef in $docsBacking."
    } elseif ($localHead -ne $remoteHead) {
        git --git-dir=$docsBacking merge-base --is-ancestor $localHead $remoteHead
        if ($LASTEXITCODE -ne 0) {
            throw "$localRef is ahead or diverged in $docsBacking."
        }
        if ("branch $localRef" -in @(git --git-dir=$docsBacking worktree list --porcelain)) {
            throw "$localRef is checked out elsewhere. Update that worktree first."
        }
        git --git-dir=$docsBacking update-ref $localRef $remoteHead $localHead
    }
    if ($LASTEXITCODE -ne 0 -or (git --git-dir=$docsBacking rev-parse $localRef) -ne $remoteHead) {
        throw "$localRef is not exactly synchronized with $defaultRef."
    }
    git --git-dir=$docsBacking worktree add $docs $defaultBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create the canonical MSXOrg/docs worktree at $docs."
    }
} else {
    if ((git -C $docs remote get-url origin) -ne $msxDocsUrl) {
        throw "$docs origin does not match canonical $msxDocsUrl."
    }
    $refspec = '+refs/heads/*:refs/remotes/origin/*'
    if ($refspec -notin @(git -C $docs config --get-all remote.origin.fetch)) {
        git -C $docs config --add remote.origin.fetch $refspec
        if ($LASTEXITCODE -ne 0) {
            throw "Could not configure remote tracking branches for MSXOrg/docs (exit $LASTEXITCODE)."
        }
    }
    git -C $docs fetch origin --prune --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "git fetch of MSXOrg/docs failed (exit $LASTEXITCODE). Do not use stale context."
    }
    git -C $docs remote set-head origin --auto | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not detect the MSXOrg/docs default branch.'
    }
    $defaultRef = (git -C $docs symbolic-ref --short refs/remotes/origin/HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve origin/HEAD in $docs."
    }
    $defaultBranch = $defaultRef -replace '^origin/', ''
    $branch = (git -C $docs branch --show-current | Out-String).Trim()
    if ($branch -ne $defaultBranch) {
        throw "$docs is on '$branch', not '$defaultBranch'. Switch branches before using this context."
    }
    if (@(git -C $docs status --porcelain).Count -gt 0) {
        throw "$docs has uncommitted changes. Resolve them before using this context."
    }
    git -C $docs merge --ff-only --quiet $defaultRef
    if ($LASTEXITCODE -ne 0) {
        throw "MSXOrg/docs cannot fast-forward to $defaultRef. Do not use stale context."
    }
    if ((git -C $docs rev-parse HEAD) -ne (git -C $docs rev-parse $defaultRef)) {
        throw "$docs is not exactly synchronized with $defaultRef. Reconcile local commits before using this context."
    }
}
$repositories = @(
    @{ Name = 'MSXOrg/docs'; Path = '.msxorg/docs'; Url = $msxDocsUrl; Kind = 'docs' }
    @{ Name = 'MSXOrg/memory'; Path = '.msxorg/memory'; Url = $msxMemoryUrl; Kind = 'memory' }
    @{ Name = 'PSModule/Process-PSModule'; Path = '.psmodule/process-psmodule'; Url = $psmoduleDocsUrl; Kind = 'docs' }
    @{ Name = 'PSModule/memory'; Path = '.psmodule/memory'; Url = $psmoduleMemoryUrl; Kind = 'memory' }
)
& (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1') -Root $contextRoot -Repository $repositories
if ($LASTEXITCODE -ne 0) {
    throw 'Context synchronization failed. Do not read context until every repository is current.'
}
```

The refresh creates:

- `~/.msxorg/docs` — `MSXOrg/docs`; entry file `src/docs/index.md`; published at <https://msxorg.github.io/docs/>.
- `~/.msxorg/memory` — private `MSXOrg/memory`; entry file `index.md`.
- `~/.psmodule/process-psmodule` — `PSModule/Process-PSModule`; entry file `docs/index.md`; published at <https://psmodule.io/docs/Modules/Process-PSModule/>.
- `~/.psmodule/memory` — private `PSModule/memory`; entry file `index.md`.

The corresponding `*.git` paths back the documentation worktrees. Memory remains a simple checkout. Repository-local git configuration is written only in these clones.

If the former `~/.msx/` layout exists, bootstrap reports every recognized path, ignores its contents, creates or refreshes the canonical organization-named clone, and retains the former path for manual verification and removal. Dirty or stale canonical clones stop context resolution.

## Then — read before acting

1. Segment the work by host, organization, repository, path, and task.
2. Read the selected repository's `AGENTS.md` route.
3. Follow repository context outward to the applicable documentation sources.
4. Resolve the current Workflow stage and read its canonical procedure.
5. Read relevant private memory last.

A repository router identifies source repositories and entry files. Use the newest accessible source through a CLI, the web, published documentation, or a refreshed preferred clone; no one delivery method is mandatory.

## Work in the selected repository

1. Read its `README.md`.
2. Read its `CONTRIBUTING.md`.
3. Use a dedicated worktree and the canonical branch naming.
4. Make small descriptive commits and push each commit.
5. Capture verified reusable lessons in the applicable memory repository.

Documentation changes use topic worktrees created from the source repository's preferred bare clone, such as `~/.msxorg/docs.git` or `~/.psmodule/process-psmodule.git`. Memory follows its repository's own contribution policy.
