---
title: Branching and Merging
description: Delivery-leaf topic branches, pull-request-only integration, and merge models.
---

# Branching and Merging

Protected branches accept changes only through pull requests.
Small topic branches keep reviews focused and the history readable.

## Topic branches

- Repository delivery uses short-lived branches, one per Task or Bug, each in its own [worktree](Git-Worktrees.md).
  Epic and PBI aggregates do not own branches, and an operational Task has no branch.
  Create a branch from the default branch unless a different base is explicitly given.
  An agent follows the same default.
- Name branches `<type>/<issue>-<short-slug>`, e.g. `feat/42-pagination` or `fix/99-null-context`. The type matches the change type.
- Keep branches short-lived. Long-lived branches diverge further from their base and are harder to merge.

## Pull requests only

- Do not push directly to protected branches. Use a pull request for every change, including a one-line fix.
- A pull request targets the branch from which its topic branch was created.
  A branch from the default branch merges into that branch.
  In the promotion model, a branch from `dev` targets `dev`, not `main`.
  Redirect the target only when that is explicitly intended.
- Automated checks pass before human review begins.
  Run these checks first so reviewers assess decisions rather than issues that CI can detect.
  This is [shift left](Principles/Engineering-Practices.md#shift-left).
- Keep pull requests small and focused: one deliverable, reviewable in a single pass.

## Stacked pull requests

Use a stack when several reviewable changes depend on one another and cannot merge independently.
Each layer remains one Task or Bug, one branch, and one pull request.
The stack records their dependency and order.
Independent changes use separate branches from the default branch instead.

Build the stack from its destination upward:

| Layer | Branch from | Pull request targets | Becomes ready |
| --- | --- | --- | --- |
| First | The default branch, or another explicitly chosen destination | The branch it was created from | First |
| Later | The immediately preceding layer's branch | The immediately preceding layer's branch | After every preceding layer has merged and this layer has been refreshed |

Every layer follows the ordinary [Contribution Workflow](Contribution-Workflow.md):

1. **Plan the dependency.** Give each layer its own Task or Bug issue. Add a native blocked-by edge from every dependent leaf to its prerequisite as described in [Issue Relationships](Issues/Process/Relationships.md#execution-order); prose, sub-issue order, and stack position do not create the gate.
2. **Open every layer as a draft.** After the initial commit, push the branch and open its pull request immediately. Use the standard user-facing title and description from [PR Format](PR-Format.md); do not add stack position or an internal branch name to the title.
3. **Link the stack in Related references.** Add fully qualified pull request links for the immediate dependency and dependent to the applicable section's `Related references` block, using `Depends on Owner/Repo#N` and `Followed by Owner/Repo#N`. Each pull request closes only its own Task or Bug.
4. **Keep each delta isolated.** The pull request diff against its current base contains only that layer's change. Run its tests, checks, and automated review even when an earlier layer already exercised the combined code.
5. **Make one layer ready at a time.** Only the lowest unmerged layer is marked ready and given auto-merge. Every later layer stays draft, even when its current checks are green.
6. **Advance after merge.** When the lowest layer merges, refresh the next branch against the merged target.
   Retarget its pull request to that target and verify that the diff still contains only its intended change.
   Run CI and the automated review loop again before marking it ready.
7. **Merge bottom-up.** Repeat the refresh, retarget, validation, and readiness steps for each remaining layer. Never merge a later layer into an earlier branch to bypass the order; that collapses the review boundaries the stack exists to preserve.

If an earlier layer changes during review, update each dependent branch in order from the closest layer outward. Recheck every diff after the update so a conflict resolution or rewritten base does not silently move work between layers.

## Merge models

The repository's deployment needs determine its merge model:

- **Single-branch (trunk).** One protected branch, always deployable. Topic branches squash-merge into it for a linear history. Suited to applications and libraries that release from the trunk.
- **Promotion (multi-environment).** Changes flow through environment branches (for example `dev` → `main`), each promotion gated by an approval. Suited to infrastructure where environments deploy in sequence.

The choice follows [repository segmentation](Repository-Segmentation.md): an app and an infrastructure stack use separate models.

### The standing promotion pull request

A repository on the promotion model MAY keep a **standing draft pull request** from the integration branch to the production branch.
The pull request is the release candidate.
Its diff shows the exact integrated changes not yet promoted and defines the promotion under review.

- **One long-lived pull request, not one per promotion.** Merging it promotes the changes.
  A replacement draft opens immediately to keep the candidate visible.
- **Draft is the resting state.** Mark it ready when the integrated state is deemed promotable.
  This starts review and any promotion gate.
- **Its description is the promotion note.** The description records the promoted changes for the destination's operators.
- **Its release metadata follows the target route.** When the route invokes [Release Management](../Capabilities/release-management/spec.md), the pull request's `Release decisions` block records the production decision.
  The version bump comes from its explicit owned bump label or the valid effective `DefaultBump`.
  The effective configuration includes shared defaults, repository settings, and supported caller overrides.
  The versions of the bundled changes do not determine the bump.
  A route without that invocation omits the block and all `release:*` labels.

The standing pull request provides one view of the difference between the integrated and production states.
It suits repositories with deliberate promotion gates.
It adds unnecessary work where every merge already releases the change.

## Required checks and auto-merge

The protected branch's ruleset defines the conditions each pull request must satisfy before merge.
These include **required status checks**, **required approvals**, and any other configured requirement, such as conversation resolution or signed commits.
A pull request cannot merge until all required conditions are satisfied, regardless of its readiness state.
The ruleset configuration lives in repository settings.
Written requirements do not configure or enforce those settings.

Use auto-merge by default.
A ready pull request with auto-merge enabled squash-merges only after every required condition is satisfied.
There is no need to wait and manually select merge.

### Who approves

The required-approval ruleset must require an approval from an identity that is neither the pull request's author nor the built-in Actions identity:

- **The author must not be the approver.** The ruleset requires that no change is approved by the identity that wrote it; the author's identity — human or agent — cannot satisfy it.
- **The Actions bot must not be the approver.** A review from the workflow token (`GITHUB_TOKEN`, the `github-actions[bot]` identity) must not satisfy the requirement. The approval must come from a **separate identity** — a distinct GitHub App with its own installation token, or a person's token — provisioned with least privilege for the reviewer role.
- **Agents may approve.** An agent acting as reviewer may submit the approving review, provided it runs under that separate identity and did not author the change.

Separate author and reviewer identities apply least privilege and separation of duties to the merge gate ([Principles](Principles/index.md)).
One identity cannot both author a change and approve it for merge.

## A readable history

- Squash-merge a topic branch so each merged change is one coherent commit on the protected branch.
- Delete branches after merge.
- Commit messages are direct and descriptive. See [Commit Conventions](Commit-Conventions.md).
