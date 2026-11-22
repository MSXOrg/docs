---
title: Git Worktrees
description: Local repository-delivery workspaces use bare clones and an independent worktree for each Task or Bug.
---

# Git Worktrees

Git worktrees support [agentic development](../Capabilities/agentic-development/index.md) on a local machine.
They provide separate working directories for **local development**, whether the participants are people, agents, or both.
Participants can work on multiple repository-delivery leaves without stashing, committing unfinished work, or switching branches in a shared checkout.
Worktrees do not change how a repository is built, reviewed, or delivered.
Delivery still uses branches and pull requests, as with an ordinary clone.

Repository-delivery workspaces use **bare clones with worktrees**.
Each repository-delivery Task or Bug has its own worktree: an independent working directory for one branch.
This keeps participants' uncommitted changes in separate directories.
Epic and PBI aggregates, operational Tasks without repository artifacts, and canonical documentation context clones do not get worktrees.

## Why this matters: working agentically in parallel

The layout supports **parallelism** in [agentic development](../Capabilities/agentic-development/index.md).
A developer can run several agents on separate Tasks or Bugs while also making their own changes.
Worktrees isolate each participant's working directory:

- **One worktree per repository-delivery Task or Bug, one agent per worktree.** Each agent gets its own working directory, its own branch, and its own uncommitted state. Two agents never write to the same checkout, so their edits cannot corrupt one another.
- **No stashing, no branch-switching, no waiting.** The agent finishing Task #42 does not alter the working directory for Bug #99.
  Neither participant edits the clean canonical `<repo>/` worktree used for reference.
  One participant's uncommitted changes do not prevent another from continuing.
- **Fan out, then integrate.** Start independent delivery leaves in parallel, with one worktree each.
  Integrate each completed leaf through the normal [branch-and-PR flow](Branching-and-Merging.md).

A single ordinary checkout has one branch checked out at a time.
Participants who share it also share files and uncommitted changes.
Worktrees avoid that contention by providing separate checkouts for concurrent delivery work.

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
- **`<repo>/`** — the canonical default-branch worktree.
  Keep it clean and exactly synchronized for reading, diffing, and comparisons.
  Never commit directly to it.
- **`<N>-<slug>/`** — one worktree folder per active repository-delivery Task or Bug, named by issue number and a short slug.
  The folder is a concise local path.
  Its branch uses the required `<type>/<issue>-<slug>` name, so the two names do not need to match.

Canonical documentation context uses a normal Git clone at a location chosen by
the runtime or development setup and is not part of this worktree topology. The
bare-clone layout applies to delivery repositories only.

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

> The [Checkout-GitHubRepo](https://github.com/MariusStorhaug/.dev/blob/main/.github/Checkout-GitHubRepo.ps1) script — in a private repository, so the link resolves only for the maintainer — automates this for all repositories.

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

- [Agentic Development](../Capabilities/agentic-development/index.md) — the framework these worktrees implement locally, so several pieces of work run in parallel.
- [Branching and Merging](Branching-and-Merging.md) — the branch-per-delivery-leaf model each worktree holds.
- [Workflow](Workflow.md) — where creating a worktree fits in the flow from issue to delivery.
