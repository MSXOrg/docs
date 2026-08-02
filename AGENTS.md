# Agent Instructions

## Main directive

Everything is a work in progress and can be updated and improved. Fix a small problem when it is directly in scope; register a larger or unrelated problem as an issue in the repository that owns it.

This repository belongs to `github.com/MSXOrg`. It is the central documentation for the MSX ecosystem, so the standards a repository would normally read from elsewhere are authored here, in `src/docs/`.

## First — bootstrap and gate

The agent workspace lives under `~/.msx`:

| Repository | Local path | Purpose | Change model |
| --- | --- | --- | --- |
| `MSXOrg/docs` | `~/.msx/docs.git` + `~/.msx/docs` | Bare backing repository plus clean readable main worktree for reviewed organization context. | Pull requests through topic worktrees only. |
| `MSXOrg/memory` | `~/.msx/memory` | Durable organization memory: prior decisions, gotchas, and reusable working knowledge. | Commit and push directly to `main`, per that repository's policy. |

Install missing context repositories and synchronize every existing clone before use:

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

Segment the work by host, organization, repository, path, and task before loading standards or memory.

## Then — read outward, nearest first

1. [README.md](README.md) — what this repository is and how it builds.
2. [CONTRIBUTING.md](CONTRIBUTING.md) — how a change is made and reviewed here.
3. [src/docs/index.md](src/docs/index.md) — this repository's own documentation, which is also the ecosystem's central documentation. Follow [Ways of Working](src/docs/Ways-of-Working/index.md) to the canonical [Workflow](src/docs/Ways-of-Working/Workflow.md), infer the current stage from the task and its artifacts, and read that stage procedure and the standards it names.
4. `~/.msx/memory/index.md` — organization memory, read last.

Working in another MSXOrg repository inserts that repository's own files at steps 1 to 3 and resolves the standards from `~/.msx/docs`. Working in an initiative such as `PSModule` reads that initiative's governing documentation before this one.

Read nearest first, but a local file never overrides a standard, and memory never overrides documentation. See [Agentic Development](src/docs/Ways-of-Working/Agentic-Development.md#which-agent-files-a-repository-carries).

## Working in this repository

1. Use a dedicated worktree for every topic branch. Follow [Git Worktrees](src/docs/Ways-of-Working/Git-Worktrees.md) for the local layout and [Branching and Merging](src/docs/Ways-of-Working/Branching-and-Merging.md) for `<type>/<issue>-<slug>` branch names.
2. Keep work reviewable with small, descriptive micro-commits.
3. Push every commit so the remote branch, CI, and draft pull request reflect current work.
4. Run `pwsh .github/scripts/Update-DocumentationIndex.ps1` after adding or renaming a page, and `pwsh .github/scripts/Test-DocumentationLink.ps1` before opening a pull request.
5. Improve organization memory when a verified lesson is likely to matter again; commit and push MSXOrg memory directly to `main`.

This file routes and carries this repository's operating nuance. The linked documentation owns reusable process knowledge; this file does not redefine a workflow stage, coding standard, or review convention.
