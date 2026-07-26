# MSX workspace

The single starting point for any agent, in any repository. Before doing anything else, make sure the central workspace exists locally, then read from it.

## Main directive

Everything is a work in progress and can be updated and improved. Fix a small problem when it is directly in scope; register a larger or unrelated problem as an issue in the repository that owns it.

## First — bootstrap the workspace

The workspace is a git-isolated clone of the central repositories under `~/.msx`. Set it up before reading context. Existing context repositories must be clean, on their default branch, and exactly synchronized with the remote:

```powershell
$workspaceRoot = if ($env:MSX_WORKSPACE_ROOT) { $env:MSX_WORKSPACE_ROOT } else { Join-Path $HOME '.msx' }
$docsUrl = if ($env:MSX_DOCS_URL) { $env:MSX_DOCS_URL } else { 'https://github.com/MSXOrg/docs.git' }
$memoryUrl = if ($env:MSX_MEMORY_URL) { $env:MSX_MEMORY_URL } else { 'https://github.com/MSXOrg/memory.git' }
$docs = Join-Path $workspaceRoot 'docs'
$docsBacking = "$docs.git"
if ((Test-Path $docs) -and -not (Test-Path (Join-Path $docs '.git'))) {
    throw "$docs exists but is not a git repository. Remove it and re-run."
}
if (-not (Test-Path (Join-Path $docs '.git'))) {
    if (-not (Test-Path $docsBacking)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $docs) | Out-Null
        git clone --bare $docsUrl $docsBacking
        if ($LASTEXITCODE -ne 0) {
            throw "Bare clone of MSXOrg/docs failed (exit $LASTEXITCODE). Check network access and credentials."
        }
    }
    if ((git --git-dir=$docsBacking rev-parse --is-bare-repository) -ne 'true') {
        throw "$docsBacking exists but is not a bare repository."
    }
    if ((git --git-dir=$docsBacking remote get-url origin) -ne $docsUrl) {
        throw "$docsBacking origin does not match canonical $docsUrl."
    }
    $refspec = '+refs/heads/*:refs/remotes/origin/*'
    if ($refspec -notin @(git --git-dir=$docsBacking config --get-all remote.origin.fetch)) {
        git --git-dir=$docsBacking config --add remote.origin.fetch $refspec
        if ($LASTEXITCODE -ne 0) { throw "Could not configure $docsBacking." }
    }
    git --git-dir=$docsBacking fetch origin --prune --quiet
    if ($LASTEXITCODE -ne 0) { throw "Could not refresh $docsBacking. Do not use stale context." }
    git --git-dir=$docsBacking remote set-head origin --auto | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not detect the MSXOrg/docs default branch." }
    $defaultRef = (git --git-dir=$docsBacking symbolic-ref --short refs/remotes/origin/HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve origin/HEAD in $docsBacking." }
    $defaultBranch = $defaultRef -replace '^origin/', ''
    $remoteHead = (git --git-dir=$docsBacking rev-parse $defaultRef | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve $defaultRef in $docsBacking." }
    $localRef = "refs/heads/$defaultBranch"
    $localHead = (git --git-dir=$docsBacking rev-parse --verify $localRef 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -eq 128) {
        git --git-dir=$docsBacking update-ref $localRef $remoteHead
    } elseif ($LASTEXITCODE -ne 0) {
        throw "Could not inspect $localRef in $docsBacking."
    } elseif ($localHead -ne $remoteHead) {
        git --git-dir=$docsBacking merge-base --is-ancestor $localHead $remoteHead
        if ($LASTEXITCODE -ne 0) { throw "$localRef is ahead or diverged in $docsBacking." }
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
    if ((git -C $docs remote get-url origin) -ne $docsUrl) {
        throw "$docs origin does not match canonical $docsUrl."
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
    if ($LASTEXITCODE -ne 0) { throw "Could not detect the MSXOrg/docs default branch." }
    $defaultRef = (git -C $docs symbolic-ref --short refs/remotes/origin/HEAD | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve origin/HEAD in $docs." }
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
$projects = @(
    @{
        Name = 'MSXOrg'
        Path = ''
        DocsUrl = $docsUrl
        MemoryUrl = $memoryUrl
    }
    # Add project-specific entries when this template is adopted there:
    # @{
    #     Name = 'PSModule'
    #     Path = 'projects/PSModule'
    #     DocsUrl = 'https://github.com/PSModule/docs.git'
    #     MemoryUrl = 'https://github.com/PSModule/memory.git'
    # }
)
& (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1') -Root $workspaceRoot -Project $projects
if ($LASTEXITCODE -ne 0) {
    throw "Context synchronization failed. Do not read context until every project is current."
}
```

Keep the MSXOrg entry and add only the additional project coordinates required by repositories that inherit this template. Every project reuses the same synchronization and validation implementation.

This produces:

- `~/.msx/docs.git` — bare backing repository for central docs.
- `~/.msx/docs` — clean, readable main worktree containing ways of working, standards, and workflow guidance.
- `~/.msx/memory` — what has been learned before: durable notes and prior session context.

Each clone has repository-local git config only; it never modifies the global git config or the repository being worked in (git still reads them, but only repository-local config is written).

> `MSXOrg/memory` is private — the bootstrap needs access to it (and working github.com credentials) for the memory clone.

## Then — read before acting

1. Start at `~/.msx/docs/src/docs/index.md`.
2. Follow the Ways of Working index to `Workflow.md`.
3. Infer the current stage from the task and its artifacts, then read the linked stage procedure.
4. Read the relevant standards, repository context, and `~/.msx/memory`.

Clear task language may shortcut the index trail: `Review this PR <link>` enters Review, `Make this issue <description>` enters Define, and `Implement <issue>` enters Implement. The linked documentation owns each procedure; this file does not define a separate agent or skill.

## Work in the selected repository

1. Read its `README.md` to understand the repository and its build.
2. Read its `CONTRIBUTING.md` for the contribution and review contract.
3. Use a dedicated worktree and the branch naming defined by the canonical Ways of Working.
4. Make small, descriptive micro-commits and push every commit so remote state, CI, and the draft pull request stay current.
5. Capture verified reusable lessons in organization memory, following that repository's own instructions.

## Two write rules

- **Docs change through topic worktrees and pull requests.** Create a topic worktree from `~/.msx/docs.git`; never branch or work inside the canonical `~/.msx/docs` main worktree.
- **Memory follows repository policy.** Read the selected memory repository's `AGENTS.md` and `CONTRIBUTING.md` before writing.
