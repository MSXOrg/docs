---
title: Branching and Merging
description: Topic branches, pull-request-only integration, and merge models.
---

# Branching and Merging

How changes move from a working branch into a protected branch. The model is small branches, pull-request-only integration, and a history that stays readable.

## Topic branches

- Work happens on short-lived branches cut from the default branch — one per issue. Each gets its own [worktree](Git-Worktrees.md).
- Name branches `<type>/<issue>-<short-slug>`, e.g. `feat/42-pagination` or `fix/99-null-context`. The type matches the change type.
- Branches stay short-lived. The longer a branch lives, the further it diverges and the harder it is to merge.

## Pull requests only

- Protected branches are never pushed to directly. Every change arrives through a pull request — even a one-line fix.
- A pull request is green before review begins. Automated checks run first, so reviewers spend their attention on judgment rather than on catching what CI catches. This is [shift left](Principles.md#shift-left).
- Keep pull requests small and focused: one deliverable, reviewable in a single pass.

## Merge models

Two models, chosen by the repository's deployment shape:

- **Single-branch (trunk).** One protected branch, always deployable. Topic branches squash-merge into it for a linear history. Suited to applications and libraries that release from the trunk.
- **Promotion (multi-environment).** Changes flow through environment branches (for example `dev` → `main`), each promotion gated by an approval. Suited to infrastructure where environments deploy in sequence.

The choice follows from [repository segmentation](Repository-Segmentation.md): an app and an infrastructure stack don't share a model.

## A readable history

- Squash-merge a topic branch so each merged change is one coherent commit on the protected branch.
- Delete branches after merge. Stale branches are noise.
- Commit messages are direct and descriptive. See [Commit Conventions](Commit-Conventions.md).
