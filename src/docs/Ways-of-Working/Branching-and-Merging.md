---
title: Branching and Merging
description: Delivery-leaf topic branches, pull-request-only integration, and merge models.
---

# Branching and Merging

How changes move from a working branch into a protected branch. The model is small branches, pull-request-only integration, and a history that stays readable.

## Topic branches

- Repository delivery happens on short-lived branches — one per Task or Bug, each in its own [worktree](Git-Worktrees.md). Epic and PBI aggregates do not own branches, and an operational Task has no branch. A branch is cut from the default branch unless a different base is explicitly given; an agent follows the same default.
- Name branches `<type>/<issue>-<short-slug>`, e.g. `feat/42-pagination` or `fix/99-null-context`. The type matches the change type.
- Branches stay short-lived. The longer a branch lives, the further it diverges and the harder it is to merge.

## Pull requests only

- Protected branches are never pushed to directly. Every change arrives through a pull request — even a one-line fix.
- A pull request targets the branch its topic branch was cut from. A branch off the default branch merges back into it; in the promotion model a branch off `dev` targets `dev`, not `main`. Redirect the target only when that is explicitly intended.
- A pull request is green before review begins. Automated checks run first, so reviewers spend their attention on judgment rather than on catching what CI catches. This is [shift left](Principles/Engineering-Practices.md#shift-left).
- Keep pull requests small and focused: one deliverable, reviewable in a single pass.

## Stacked pull requests

Use a stack when several reviewable changes depend on one another and cannot land independently. Each layer remains one Task or Bug, one branch, and one pull request; the stack only records their dependency and order. Independent changes use separate branches from the default branch instead.

Build the stack from its destination upward:

| Layer | Branch from | Pull request targets | Becomes ready |
| --- | --- | --- | --- |
| First | The default branch, or another explicitly chosen destination | The branch it was cut from | First |
| Later | The immediately preceding layer's branch | The immediately preceding layer's branch | After every preceding layer has landed and this layer has been refreshed |

Every layer follows the ordinary [Contribution Workflow](Contribution-Workflow.md):

1. **Plan the dependency.** Give each layer its own Task or Bug issue. Add a native blocked-by edge from every dependent leaf to its prerequisite as described in [Issue Relationships](Issues/Process/Relationships.md#execution-order); prose, sub-issue order, and stack position do not create the gate.
2. **Open every layer as a draft.** After the initial commit, push the branch and open its pull request immediately. Use the standard user-facing title and description from [PR Format](PR-Format.md); do not add stack position or an internal branch name to the title.
3. **Link the stack in Technical Details.** Add fully qualified pull request links for the immediate dependency and dependent, using `Depends on Owner/Repo#N` and `Followed by Owner/Repo#N`. Each pull request closes only its own Task or Bug.
4. **Keep each delta isolated.** The pull request diff against its current base contains only that layer's change. Run its tests, checks, and automated review even when an earlier layer already exercised the combined code.
5. **Make one layer ready at a time.** Only the lowest unmerged layer is marked ready and given auto-merge. Every later layer stays draft, even when its current checks are green.
6. **Advance after merge.** When the lowest layer lands, refresh the next branch against the landed target, retarget its pull request to that target, and verify that the diff still contains only its intended change. Run CI and the automated review loop again before marking it ready.
7. **Merge bottom-up.** Repeat the refresh, retarget, validation, and readiness steps for each remaining layer. Never merge a later layer into an earlier branch to bypass the order; that collapses the review boundaries the stack exists to preserve.

If an earlier layer changes during review, update each dependent branch in order from the closest layer outward. Recheck every diff after the update so a conflict resolution or rewritten base does not silently move work between layers.

## Merge models

Two models, chosen by the repository's deployment shape:

- **Single-branch (trunk).** One protected branch, always deployable. Topic branches squash-merge into it for a linear history. Suited to applications and libraries that release from the trunk.
- **Promotion (multi-environment).** Changes flow through environment branches (for example `dev` → `main`), each promotion gated by an approval. Suited to infrastructure where environments deploy in sequence.

The choice follows from [repository segmentation](Repository-Segmentation.md): an app and an infrastructure stack don't share a model.

### The standing promotion pull request

A repository on the promotion model MAY keep a **standing draft pull request** from the integration branch to the production branch, held open permanently rather than opened per promotion. The pull request is the release candidate: it always shows the exact set of changes that are integrated but not yet promoted, and its diff is the promotion under review.

- **One long-lived pull request, not one per promotion.** Merging it promotes; a new draft opens immediately, so the candidate view is never absent.
- **Draft is the resting state.** It is marked ready when the integrated state is deemed promotable, which is what turns review and any promotion gate on.
- **Its description is the promotion note.** Assembled from the changes it carries, it is the record of what a promotion contained, written for whoever operates the destination.
- **The resolved release policy decides the production version.** Promotion is a release like any other, so the version comes from an explicit owned `release:` bump label on this pull request when present, otherwise from the configured `DefaultBump` — never from the versions of the changes it bundles ([release management](../Capabilities/release-management/spec.md)).

The value is continuous visibility: at any moment, the difference between what is integrated and what is live is one link. It suits repositories where promotion is a deliberate, gated event and costs more than it returns where every merge already ships.

## Required checks and auto-merge

A branch ruleset on the protected branch defines the merge requirements every pull request must satisfy before it can land — the **required status checks**, the **required approvals**, and any others the ruleset enforces (for example conversation resolution or signed commits). These are the required steps: a pull request that has not satisfied all of them cannot land, however it was marked. The ruleset is configured on the repository (in its settings), not in these files; this section defines what it must enforce.

Auto-merge is the default way changes land. When a ready pull request has auto-merge enabled, it squash-merges the moment every one of those requirements is satisfied — and not before. No one watches the pull request waiting to click merge.

### Who approves

The required-approval ruleset must require an approval from an identity that is neither the pull request's author nor the built-in Actions identity:

- **The author must not be the approver.** The ruleset requires that no change is approved by the identity that wrote it; the author's identity — human or agent — cannot satisfy it.
- **The Actions bot must not be the approver.** A review from the workflow token (`GITHUB_TOKEN`, the `github-actions[bot]` identity) must not satisfy the requirement. The approval must come from a **separate identity** — a distinct GitHub App with its own installation token, or a person's token — provisioned with least privilege for the reviewer role.
- **Agents may approve.** An agent acting as reviewer may submit the approving review, provided it runs under that separate identity and did not author the change.

This is least privilege and separation of duties applied to the merge gate ([Principles](Principles/index.md)): the power to write a change and the power to approve it live in different identities, so no single identity can both author and land a change unreviewed.

## A readable history

- Squash-merge a topic branch so each merged change is one coherent commit on the protected branch.
- Delete branches after merge. Stale branches are noise.
- Commit messages are direct and descriptive. See [Commit Conventions](Commit-Conventions.md).
