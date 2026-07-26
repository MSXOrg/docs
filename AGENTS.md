# Agent Instructions

## Main directive

Everything is a work in progress and can be updated and improved. Fix a small problem when it is directly in scope; register a larger or unrelated problem as an issue in the repository that owns it.

This repository belongs to `github.com/MSXOrg`.

## Install and synchronize the ecosystem

The agent workspace lives under `~/.msx`:

| Repository | Local path | Purpose | Change model |
| --- | --- | --- | --- |
| `MSXOrg/docs` | `~/.msx/docs.git` + `~/.msx/docs` | Bare backing repository plus clean readable main worktree for reviewed organization context. | Pull requests through topic worktrees only. |
| `MSXOrg/memory` | `~/.msx/memory` | Durable organization memory: prior decisions, gotchas, and reusable working knowledge. | Commit and push directly to `main`, per that repository's policy. |

From this repository, install missing context repositories and synchronize every existing clone before use:

```powershell
pwsh bootstrap/Initialize-MsxWorkspace.ps1 `
  -UserName '<github-user>' `
  -UserEmail '<github-noreply-email>'
```

Projects that add their own docs and memory provide plug-in coordinates without changing the synchronization implementation:

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
& ./bootstrap/Initialize-MsxWorkspace.ps1 -Project $projects
```

The bootstrap writes identity only to each context repository's local git configuration. It must succeed before any context is read; do not continue with missing, dirty, diverged, wrong-branch, unreachable, or stale context.

Use a dedicated worktree for every topic branch. Follow [Git Worktrees](src/docs/Ways-of-Working/Git-Worktrees.md) for the local layout and [Branching and Merging](src/docs/Ways-of-Working/Branching-and-Merging.md) for `<type>/<issue>-<slug>` branch names.

## Canonical context

- Docs root: [src/docs/index.md](src/docs/index.md)
- Organization memory: `~/.msx/memory/index.md`

## Before acting

1. Segment the work by host, organization, repository, path, and task.
2. Synchronize every canonical context repository to its remote default branch; stop if any context may be stale.
3. Start at the docs root index and follow [Ways of Working](src/docs/Ways-of-Working/index.md) to the canonical [Workflow](src/docs/Ways-of-Working/Workflow.md).
4. Infer the current stage from the task and its artifacts, then read the linked stage procedure.
5. Read [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md), relevant standards, and organization memory.
6. Apply path-specific local rules only when they match the files in scope.

## Working in this repository

1. Use [README.md](README.md) to understand what this repository is and how it builds.
2. Use [CONTRIBUTING.md](CONTRIBUTING.md) for its contribution and review contract.
3. Keep work reviewable with small, descriptive micro-commits.
4. Push every commit so the remote branch, CI, and draft pull request reflect current work.
5. Improve organization memory when a verified lesson is likely to matter again; commit and push MSXOrg memory directly to `main`.

This file owns bootstrap and repository-specific operating instructions. The linked documentation owns reusable process knowledge; this file does not redefine a workflow stage, coding standard, or review convention.
