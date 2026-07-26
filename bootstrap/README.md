# Bootstrap

The single starting point for agents: a git-isolated local clone of the MSX central repositories under `~/.msx`, plus the instruction that sends every agent there first.

## Contents

- `Initialize-MsxWorkspace.ps1` — idempotent setup. Clones `MSXOrg/docs` and `MSXOrg/memory` under `~/.msx`, requires existing clones to exactly match their remote default branches, and writes a repository-local git identity so the workspace never modifies the global git config.
- `AGENTS.template.md` — the user-global entry instruction. It bootstraps the workspace, then points the agent at the docs and memory. Install it once per machine (below).

## The model

- `~/.msx/docs` is **read context** — the ways of working, coding standards, and agent workflow. Changes to it go through **pull requests**.
- `~/.msx/docs.git` is the bare backing repository for the readable, clean `~/.msx/docs` main worktree.
- `~/.msx/memory` is **durable context** — notes and session history governed by that repository's contribution policy.
- `~/.msx/projects/<project>/docs.git` and `docs/` provide the same bare+main-worktree model for optional project docs; `memory/` remains a simple checkout.

> **Prerequisite:** `MSXOrg/memory` is a private repository — the bootstrap needs access to it (and working github.com credentials) to clone or update memory.

Before either repository is used, bootstrap fetches it and requires a clean checkout on the remote default branch at the exact remote head. A dirty, locally ahead, diverged, wrong-branch, or unreachable context repository stops bootstrap; stale context is never treated as a successful fallback.

Keeping the workspace separate and git-isolated means an agent reads the same docs and memory in every repository, and its commits there use the workspace identity rather than whatever the working repository or the global config happens to be set to.

The loaded `AGENTS.md` points to the roots; discovery happens in documentation. Start at `~/.msx/docs/src/docs/index.md`, follow Ways of Working to Workflow, infer the current stage, and read the linked procedure. Clear task language can shortcut stage selection, but no skill or instruction file owns a separate copy of the process.

## Install (once per machine)

Run the bootstrap:

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
    $branch = (git -C $docs branch --show-current | Out-String).Trim()
    if ($branch -ne 'main') {
        throw "$docs is on '$branch', not 'main'. Switch branches before using this context."
    }
    if (@(git -C $docs status --porcelain).Count -gt 0) {
        throw "$docs has uncommitted changes. Resolve them before using this context."
    }
    git -C $docs merge --ff-only --quiet origin/main
    if ($LASTEXITCODE -ne 0) {
        throw "MSXOrg/docs cannot fast-forward to origin/main. Do not use stale context."
    }
    if ((git -C $docs rev-parse HEAD) -ne (git -C $docs rev-parse origin/main)) {
        throw "$docs is not exactly synchronized with origin/main. Reconcile local commits before using this context."
    }
}
$projects = @(
    @{
        Name = 'MSXOrg'
        Path = ''
        DocsUrl = $docsUrl
        MemoryUrl = $memoryUrl
    }
)
& (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1') -Root $workspaceRoot -Project $projects
if ($LASTEXITCODE -ne 0) {
    throw "MSX workspace synchronization failed. Do not read context until every repository is current."
}
```

## Add project context

The default project is MSXOrg. A repository in another project declares additional docs and memory coordinates in its agent installation chapter and passes them to the same bootstrap:

```powershell
$projects = @(
    @{
        Name = 'MSXOrg'
        Path = ''
        DocsUrl = 'https://github.com/MSXOrg/docs.git'
        MemoryUrl = 'https://github.com/MSXOrg/memory.git'
    }
    @{
        Name = 'PSModule'
        Path = 'projects/PSModule'
        DocsUrl = 'https://github.com/PSModule/docs.git'
        MemoryUrl = 'https://github.com/PSModule/memory.git'
    }
)
& (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1') -Project $projects
```

Each plug-in uses the same fail-closed freshness validation. `Path` is relative to `~/.msx`, so projects can choose a collision-free location without forking the bootstrap.

Existing clean simple docs clones are migrated automatically. The original clone is retained beside the new layout as `docs.simple-clone-backup` for manual verification and removal. Existing docs worktrees backed by another bare path are reused in place. Dirty, ahead, diverged, wrong-branch, conflicting-path, or otherwise unsafe layouts stop with actionable guidance before conversion.

Docs changes use topic worktrees created from `~/.msx/docs.git`; never branch or work inside the canonical `~/.msx/docs` main worktree.

Wire it into the tools so it runs as the first instruction:

- **Claude Code** reads `CLAUDE.md`. Add an import to `~/.claude/CLAUDE.md`:

  ```text
  @~/.msx/docs/bootstrap/AGENTS.template.md
  ```

- **Copilot** reads `AGENTS.md` natively. Install the contents of `AGENTS.template.md` as your **user-level** Copilot instructions so it applies in every repository. Per-repository `AGENTS.md` files stay thin pointers to the central docs — don't put the bootstrap there.

## Identity

The script writes a repository-local git identity to each clone. The default is the maintainer's GitHub **noreply** identity, so no personal email is written into git config and commits still attribute to the maintainer. Override it with `-UserName` / `-UserEmail`, or point it at a dedicated agent account when one exists.

> **Override this if you are not the maintainer.** With the default, commits — including memory pushes to `main` — are attributed to the maintainer's account. Pass `-UserName` and `-UserEmail` (for example `-UserEmail 'you@users.noreply.github.com'`), or point the script at a dedicated agent account, so your commits are attributed correctly.
