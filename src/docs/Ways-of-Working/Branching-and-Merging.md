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
- A pull request is green before review begins. Automated checks run first, so reviewers spend their attention on judgment rather than on catching what CI catches. This is [shift left](Principles/Engineering-Practices.md#shift-left).
- Keep pull requests small and focused: one deliverable, reviewable in a single pass.

## Merge models

Two models, chosen by the repository's deployment shape:

- **Single-branch (trunk).** One protected branch, always deployable. Topic branches squash-merge into it for a linear history. Suited to applications and libraries that release from the trunk.
- **Promotion (multi-environment).** Changes flow through environment branches (for example `dev` → `main`), each promotion gated by an approval. Suited to infrastructure where environments deploy in sequence.

The choice follows from [repository segmentation](Repository-Segmentation.md): an app and an infrastructure stack don't share a model.

## Required checks and auto-merge

A branch ruleset on the protected branch defines the **required status checks** and the **required approval** every pull request must satisfy before it can merge. These are the required steps: a pull request that has not passed all of them cannot land, however it was marked. The ruleset is configured on the repository (in its settings), not in these files; this section defines what it must enforce.

Auto-merge is the default way changes land. When a ready pull request has auto-merge enabled, it squash-merges the moment the required checks are green and the required approval is in place — and not before. No one watches the pull request waiting to click merge.

### Who approves

The required approval comes from an identity that is **not** the pull request's author and **not** the built-in Actions identity:

- **Author is not approver.** The required approval never comes from the identity that wrote the change. GitHub prevents a user from approving their own pull request, and the required-approval ruleset ensures the author's identity — human or agent — cannot satisfy the merge gate.
- **Not the GitHub Actions bot.** A review submitted with the workflow token (`GITHUB_TOKEN`, the `github-actions[bot]` identity) does not count toward a required approval, and that app cannot approve a pull request it opened. The approval therefore comes from a **separate identity** — a distinct GitHub App with its own installation token, or a person's token — provisioned with least privilege for the reviewer role.
- **Agents may approve.** An agent acting as reviewer may submit the approving review, as long as it runs under that separate identity and did not author the change.

This is least privilege and separation of duties applied to the merge gate ([Principles](Principles/index.md)): the power to write a change and the power to approve it live in different identities, so no single identity can both author and land a change unreviewed.

## A readable history

- Squash-merge a topic branch so each merged change is one coherent commit on the protected branch.
- Delete branches after merge. Stale branches are noise.
- Commit messages are direct and descriptive. See [Commit Conventions](Commit-Conventions.md).
