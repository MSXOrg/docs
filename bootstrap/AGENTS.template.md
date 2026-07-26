# MSX workspace

The single starting point for any agent, in any repository. Before doing anything else, make sure the central workspace exists locally, then read from it.

## First — bootstrap the workspace

The workspace is a git-isolated clone of the central repositories under `~/.msx`. Set it up (idempotent — clones what is missing, attempts to fast-forward the rest):

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
}
pwsh (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1')
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
