# MSX workspace

The single starting point for any agent, in any repository. Before doing anything else, make sure the central workspace exists locally, then read from it.

## First — bootstrap the workspace

The workspace is a git-isolated clone of the central repositories under `~/.msx`. Set it up (idempotent — clones what is missing, fast-forwards the rest):

```powershell
if (-not (Test-Path ~/.msx/docs)) { git clone https://github.com/MSXOrg/docs.git ~/.msx/docs }
pwsh ~/.msx/docs/bootstrap/Initialize-MsxWorkspace.ps1
```

This produces:

- `~/.msx/docs` — how work is done: ways of working, coding standards, and agent roles. The same content published at <https://msxorg.github.io/docs/>.
- `~/.msx/memory` — what has been learned before: durable notes and prior session context.

Each clone has repository-local git config only; it never modifies the global git config or the repository being worked in (git still reads them, but only repository-local config is written).

## Then — read before acting

1. Read the relevant pages under `~/.msx/docs` for the task at hand.
2. Read `~/.msx/memory` for prior decisions, pitfalls, and context.

## Two write rules

- **Docs change through pull requests.** Branch inside `~/.msx/docs` and open a pull request; never push its `main`.
- **Memory pushes to main.** Commit and push notes directly inside `~/.msx/memory`; no pull request.
