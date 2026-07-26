# MSX workspace

The single starting point for any agent, in any repository. Before doing anything else, make sure the central workspace exists locally, then read from it.

## First — bootstrap the workspace

The workspace is a git-isolated clone of the central repositories under `~/.msx`. Set it up before reading context. Existing context repositories must be clean, on their default branch, and exactly synchronized with the remote:

```powershell
$docs = Join-Path $HOME '.msx/docs'
if ((Test-Path $docs) -and -not (Test-Path (Join-Path $docs '.git'))) {
    throw "$docs exists but is not a git repository. Remove it and re-run."
}
if (-not (Test-Path (Join-Path $docs '.git'))) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $docs) | Out-Null
    git clone https://github.com/MSXOrg/docs.git $docs
    if ($LASTEXITCODE -ne 0) {
        throw "git clone of MSXOrg/docs failed (exit $LASTEXITCODE). Check network access and github.com credentials, then re-run."
    }
} else {
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
pwsh (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1')
if ($LASTEXITCODE -ne 0) {
    throw "MSX workspace synchronization failed. Do not read context until every repository is current."
}
```

This produces:

- `~/.msx/docs` — how work is done: ways of working, coding standards, and the agent workflow. The same content published at <https://msxorg.github.io/docs/>.
- `~/.msx/memory` — what has been learned before: durable notes and prior session context.

Each clone has repository-local git config only; it never modifies the global git config or the repository being worked in (git still reads them, but only repository-local config is written).

> `MSXOrg/memory` is private — the bootstrap needs access to it (and working github.com credentials) for the memory clone.

## Then — read before acting

1. Start at `~/.msx/docs/src/docs/index.md`.
2. Follow the Ways of Working index to `Workflow.md`.
3. Infer the current stage from the task and its artifacts, then read the linked stage procedure.
4. Read the relevant standards, repository context, and `~/.msx/memory`.

Clear task language may shortcut the index trail: `Review this PR <link>` enters Review, `Make this issue <description>` enters Define, and `Implement <issue>` enters Implement. The linked documentation owns each procedure; this file does not define a separate agent or skill.

## Two write rules

- **Docs change through pull requests.** Branch inside `~/.msx/docs` and open a pull request; never push its `main`.
- **Memory pushes to main.** Commit and push notes directly inside `~/.msx/memory`; no pull request.
