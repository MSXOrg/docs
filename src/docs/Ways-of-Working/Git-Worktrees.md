---
title: Git Worktrees
description: How agentic development is implemented locally — a bare-clone and worktree layout for working on several things at once.
---

# Git Worktrees

Git worktrees are how [agentic development](Agentic-Development.md) is implemented on a local machine. They are purely a **local development** convenience: a way for one person — or a person and an agent, or several agents — to work on multiple repository-delivery leaves at the same time, without stashing, committing half-finished work, or switching branches. They change nothing about how a repository is built, reviewed, or shipped — that still happens through branches and pull requests, exactly as it would with an ordinary clone.

All repositories are set up as **bare clones with worktrees**. Each repository-delivery Task or Bug gets its own worktree — an independent working directory for one branch — so parallel work never collides. Epic and PBI aggregates, and operational Tasks without repository artifacts, do not get worktrees.

## Why this matters: working agentically in parallel

The reason this layout is the default — not the occasional convenience it is in most projects — is **parallelism**. [Agentic development](Agentic-Development.md) does not proceed one delivery leaf at a time. A single developer can have several agents working at once, each on a different Task or Bug, alongside their own hands-on changes. Worktrees are what make running many streams at once safe instead of chaotic:

- **One worktree per repository-delivery Task or Bug, one agent per worktree.** Each agent gets its own working directory, its own branch, and its own uncommitted state. Two agents never write to the same checkout, so their edits cannot corrupt one another.
- **No stashing, no branch-switching, no waiting.** Because the worktrees are independent, the agent finishing Task #42 never disturbs the one still working on Bug #99 — and neither touches the clean canonical `<repo>/` worktree you read from. Nobody has to reach a clean tree before anyone else can move.
- **Fan out, then integrate.** A batch of independent delivery leaves can be started together — one worktree each — worked concurrently, and merged back one at a time through the normal [branch-and-PR flow](Branching-and-Merging.md) as each finishes.

In a single ordinary clone the opposite is forced: one branch checked out at a time, every human and agent contending for the same files, constant stashing and switching. Worktrees turn "several issues at once" from a hazard into the default working mode — which is what makes local agentic development practical at all.

## Why worktrees

| Problem with traditional clones              | How worktrees solve it                                    |
| -------------------------------------------- | --------------------------------------------------------- |
| Only one branch checked out at a time        | Each delivery leaf gets a worktree — parallel by default  |
| Switching branches requires clean state      | Worktrees are independent — no stashing or committing WIP |
| Agent work blocks human work on same repo    | Different worktrees, no interference                      |
| Default branch gets dirty during development | Canonical `<repo>/` worktree is always a clean reference   |

## Repository layout

```text
<workspace>/
├── <repo>.git/         # bare backing repository
├── <repo>/             # canonical default-branch worktree (always clean)
├── 42-add-pagination/  # worktree folder; branch: feat/42-add-pagination
└── 99-null-ref/        # worktree folder; branch: fix/99-null-ref
```

- **`<repo>.git/`** — the shared bare object store. All worktrees use this backing repository.
- **`<repo>/`** — the canonical default-branch worktree. Kept clean and exactly synchronized for reading, diffing, and comparisons. Never directly committed to.
- **`<N>-<slug>/`** — one worktree folder per repository-delivery Task or Bug in flight, named by issue number and a short slug. The folder is a concise local path; its branch uses the required `<type>/<issue>-<slug>` name, so the two names do not need to match.

For the central MSX context, this becomes `~/.msx/docs.git` plus the readable `~/.msx/docs` main worktree. Memory remains a simple checkout at `~/.msx/memory`.

## Remotes

Every repository has exactly two remotes (or one, if it is not a fork):

| Remote         | Points to                    | Required | Purpose                                          |
| -------------- | ---------------------------- | -------- | ------------------------------------------------ |
| **`origin`**   | The copy on the server       | Always   | Push branches, open PRs, CI runs against this.   |
| **`upstream`** | The parent repo (forks only) | Forks    | Track upstream changes, sync the default branch. |

No other remotes are added. This keeps the model simple and predictable for both humans and agents.

### How it works in practice

- **Non-fork repos** — only `origin` exists. Branches are pushed to `origin`, PRs are opened against `origin`.
- **Forked repos** — `origin` is the fork, `upstream` is the original repository. The default branch tracks `upstream` for syncing; feature branches are pushed to `origin` and PRs are opened from `origin` into `upstream`.

### Fetch configuration

Both remotes are configured with full refspecs so `git fetch --all --prune` keeps everything current:

```text
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*

[remote "upstream"]   # forks only
    fetch = +refs/heads/*:refs/remotes/upstream/*
```

## Setup (one-time per repository)

```powershell
# From the workspace root, clone the bare backing repository.
$repo = '<repo>'
git clone --bare "https://github.com/<owner>/$repo.git" "$repo.git"

# Configure fetch refspec (bare clones don't set this automatically)
git --git-dir="$repo.git" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

# Fetch remote branches
git --git-dir="$repo.git" fetch origin

# Determine the default branch
$defaultBranch = git --git-dir="$repo.git" symbolic-ref HEAD |
    ForEach-Object { $_ -replace 'refs/heads/', '' }

# Create the canonical default-branch worktree at the repository name.
git --git-dir="$repo.git" worktree add $repo $defaultBranch

# Set upstream tracking (prevents "Publish Branch" prompt in VS Code)
git --git-dir="$repo.git" config "branch.$defaultBranch.remote" origin
git --git-dir="$repo.git" config "branch.$defaultBranch.merge" "refs/heads/$defaultBranch"
```

> The [Checkout-GitHubRepo](https://github.com/MariusStorhaug/.dev/blob/main/.github/Checkout-GitHubRepo.ps1) script automates this for all repositories.

## Working on a delivery leaf

```powershell
# From the workspace root (where <repo>.git lives)
$repo = '<repo>'
$defaultBranch = git --git-dir="$repo.git" symbolic-ref HEAD |
    ForEach-Object { $_ -replace 'refs/heads/', '' }
$worktreeName = '42-add-pagination'
$branchName = 'feat/42-add-pagination'
git --git-dir="$repo.git" worktree add $worktreeName -b $branchName $defaultBranch

# Set upstream tracking (prevents "Publish Branch" prompt in VS Code)
git --git-dir="$repo.git" config "branch.$branchName.remote" origin
git --git-dir="$repo.git" config "branch.$branchName.merge" "refs/heads/$branchName"

# Open in VS Code
code $worktreeName
```

Then follow the normal Implement flow: initial commit → push → draft PR → build → finalize.

## Cleanup after merge

```powershell
# Remove the worktree
git --git-dir="${repo}.git" worktree remove 42-add-pagination

# Delete the local branch ref
git --git-dir="${repo}.git" branch -D feat/42-add-pagination

# Prune if needed (removes stale worktree references)
git --git-dir="${repo}.git" worktree prune
```

## Where this connects

- [Agentic Development](Agentic-Development.md) — the framework these worktrees implement locally, so several pieces of work run in parallel.
- [Branching and Merging](Branching-and-Merging.md) — the branch-per-delivery-leaf model each worktree holds.
- [Workflow](Workflow.md) — where creating a worktree fits in the flow from issue to delivery.
