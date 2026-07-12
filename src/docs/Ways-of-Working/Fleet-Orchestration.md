---
title: Fleet Orchestration
description: How one change is rolled out across many repositories — a campaign of branches, pull requests, and review loops tracked entirely on GitHub.
---

# Fleet Orchestration

How a single change is applied across many repositories at once — a *campaign*.
Each repository gets its own branch, pull request, and review loop; the campaign
is the coordination layer that keeps them moving and visible.

This is the multi-repository "how". Inside each repository the change follows the
ordinary [Contribution Workflow](Contribution-Workflow.md) — draft first, the
Copilot review loop, then people — on a branch created per
[Git Worktrees](Git-Worktrees.md). Fleet orchestration adds nothing to that loop;
it repeats it across a fleet and tracks the whole set.

The defining rule: **the state of a campaign lives on GitHub**, on the issues and
pull requests themselves — never in a local file or database. Anyone, or any
tool, can read and drive a campaign with the GitHub CLI alone.

## When to use it

- Use it when the *same* change must land in *many* repositories: a shared
  workflow or dependency bump rolled out to every consumer, a convention applied
  fleet-wide, or a mechanical migration.
- For a change in a single repository, there is no campaign — just follow the
  [Contribution Workflow](Contribution-Workflow.md).

## The campaign

A campaign is one change rolled out across a set of repositories. Each
repository's slice of the change is a **work item**: a tracking issue, a pull
request, or both. A campaign has a short, stable **slug** (for example
`process-psmodule-v6`) that names it everywhere.

## State lives on GitHub

There is no orchestration database. Every fact needed to resume, hand off, or
audit a campaign is stored on GitHub, in two layers.

### Built-in properties come first

If GitHub already models a fact, that property *is* the state — it is never
copied into a label, because duplicated state drifts.

| Fact | GitHub property |
| --- | --- |
| Work item exists | the issue or pull request itself |
| Who holds it | `assignees` |
| Work in progress | pull request is a **draft** |
| Ready for a human | pull request is **not** a draft |
| CI health | the status-check rollup |
| Review outcome | `reviewDecision` and unresolved review threads |
| Mergeability | `mergeable` / merge-state status |
| Done | pull request **merged**; tracking issue **closed** |
| Issue ↔ PR link | the pull request's closing references (`Fixes #n`) |

"Ready for review" is the draft flag flipping off; "done" is the merge. The two
signals people care about most are native, and are set by the same act that does
the work — [marking ready](Contribution-Workflow.md) and merging.

### Process labels fill the gap

Only two label namespaces are added, for state GitHub has no property for. Both
are ordinary project-management words — not tool- or agent-specific — so a person
with the web UI, an agent, or a separate automation system all read them the
same way.

| Label | Purpose |
| --- | --- |
| `campaign:<slug>` | Groups every work item in one campaign across all repositories. The cross-repository join key. Exactly one per item. |
| `stage:queued` | Identified, not started (typically a tracking issue with no pull request yet). |
| `stage:in-progress` | Actively being changed; the assignee owns it. |
| `stage:blocked` | Needs a human decision or a manual, off-platform action before it can proceed. |

Rules: `campaign:<slug>` is mandatory on every work item; at most one `stage:*`
label applies at a time; and `stage:*` may be dropped once a pull request carries
the signal itself (a ready pull request needs no `stage` label, but
`stage:blocked` stays explicit because "a human must act" has no built-in
equivalent). Slugs are lowercase and hyphenated.

## Effective status

A campaign view shows one **effective status** per work item, derived purely from
the two layers above — no guessing. The first matching rule wins.

| # | Effective status | Condition |
| --- | --- | --- |
| 1 | Merged | pull request is merged |
| 2 | Blocked | `stage:blocked`, or the merge state is dirty/conflicting |
| 3 | Changes requested | review decision is changes-requested, or unresolved review threads remain |
| 4 | Ready for review | pull request is not a draft and not merged |
| 5 | CI failing | checks are failing on a draft |
| 6 | In review | draft with at least one review and CI not failing |
| 7 | In progress | draft with no review yet, or `stage:in-progress` |
| 8 | Queued | tracking issue open, no pull request yet |

Terminal and attention states (merged, blocked, changes requested, ready) rank
above transient progress states, because an explicit act — marking ready, or
flagging blocked — is a stronger signal than in-flight checks.

## The flow

Each repository moves through the same lifecycle. Every transition is a concrete
GitHub action, so the resulting state is always re-derivable.

```mermaid
flowchart TD
    Q[Queued: tracking issue] --> P[Open PR as draft]
    P --> R[Contribution Workflow: Copilot review loop]
    R -->|needs a human decision| B[Blocked]
    B -->|unblocked| R
    R -->|loop clean| Y[Mark ready for review]
    Y --> M[Human review and merge]
    M --> D[Tracking issue closed]
```

1. **Queue the work.** Create a tracking issue per repository, labelled
   `campaign:<slug>` and `stage:queued`, following the
   [Issue Format](Issue-Format.md). The whole fleet starts as *Queued*.
2. **Branch and open a draft.** Create a worktree and branch
   ([Git Worktrees](Git-Worktrees.md)), then open a **draft** pull request that
   closes the tracking issue, per [PR Format](PR-Format.md). Set
   `stage:in-progress`.
3. **Apply the change and run the loop.** Make the change and take the pull
   request through the [Contribution Workflow](Contribution-Workflow.md) —
   the Copilot review loop — exactly as any single-repository change. The
   [Implement](../Agents/implement.md) and [Reviewer](../Agents/reviewer.md)
   agent roles apply unchanged.
4. **Flag blockers, don't stall the fleet.** If an item needs a human decision or
   an off-platform action, set `stage:blocked` with a note and move on to the next
   repository.
5. **Mark ready only when the loop is clean.** When Copilot has no more feedback
   and CI is green, mark the pull request ready for review per the
   [Definition of Ready and Done](Definition-of-Ready-and-Done.md). The draft
   flag flips and the item becomes *Ready for review*.
6. **Human review and merge land it.** Merging closes the tracking issue via its
   `Fixes #n` link. The campaign's job is to get every pull request to *Ready*;
   [Branching and Merging](Branching-and-Merging.md) governs how it merges.

## The dashboard

A campaign is watched through a **dashboard** — a deterministic projection of
GitHub state, not a store of its own. A script enumerates the campaign's work
items (`campaign:<slug>` across the owners), reads each pull request's built-in
properties, computes the effective status, and renders a page. It can regenerate
on an interval so the view refreshes as GitHub changes; deleting it loses
nothing, because GitHub is the source of truth.

Typical columns: effective status, repository, work item (linked), draft/ready,
CI, review decision and open-thread count, assignee, the latest progress note,
and last-updated. Rows sort by status then repository name, so the items needing
attention group together. *Ready for review* appears the instant a pull request
is marked ready; *Merged* the instant it merges.

A local `JSON` snapshot may be written as a cache for other tools, and a static
`HTML` page rendered for viewing — both are disposable projections, regenerated
from GitHub at will. A database is deliberately avoided: it would become a second
source of truth that drifts.

## Progress notes

To record *what* is being done — narration, not a state change — post a comment
on the work item and, when the pipeline stage changes, move the `stage:*` label.
The dashboard surfaces the latest comment as the item's note. Setting a status is
a deterministic label-and-comment write, so it is scripted; the judgement of
*which* status applies is the only human or agent decision.

## Driving it by hand or from another system

Because all state is on GitHub and the labels are generic:

- **A person** can run a whole campaign from the GitHub UI — filter by
  `campaign:<slug>`, read each pull request's draft and merge state, move
  `stage:*` labels, and merge.
- **An automated system** — a scheduled workflow, a different agent framework, or
  a teammate's tooling — can enumerate the work with one query and pick up any
  item. The state is portable and self-describing.

If an automated run stops midway, nothing is lost: the board is complete, every
in-flight pull request shows its true state, and anyone can finish the job. This
resilience is the reason state is kept on GitHub rather than in a private store.

## Command reference

The mechanics are ordinary GitHub CLI calls, so they are easy to script or run by
hand. Labels and comments use the issues API, which serves issues and pull
requests alike.

```powershell
# enumerate a campaign's pull requests across an owner
gh search prs --owner <owner> --label "campaign:<slug>" `
  --json number,repository,title,url,isDraft,state

# read one pull request's authoritative state
gh pr view <n> --repo <owner>/<repo> --json `
  isDraft,state,reviewDecision,statusCheckRollup,mergeStateStatus,assignees

# set the pipeline stage (remove the others first) and add a progress note
gh api -X POST   repos/<owner>/<repo>/issues/<n>/labels -f "labels[]=stage:blocked"
gh api -X DELETE repos/<owner>/<repo>/issues/<n>/labels/stage:in-progress
gh api -X POST   repos/<owner>/<repo>/issues/<n>/comments -f body="<note>"

# ready for review — the native "ready for a human" signal
gh pr ready <n> --repo <owner>/<repo>
```

## Worked example: Process-PSModule and Pester 6

A concrete campaign from the [PSModule](../Initiatives/PSModule.md) initiative:
adopt the latest Process-PSModule reusable workflow across every consumer, add
the Pester version requirement to the test files, and migrate the tests.

- **Slug:** `process-psmodule-v6`.
- **Discover the fleet:** find consumers of the reusable workflow with a code
  search for its `uses:` reference, then queue a tracking issue in each.
- **Per repository:** bump the workflow pin, add the
  `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }`
  requirement to each `*.Tests.ps1`, migrate the tests, and take the pull request
  through the [Contribution Workflow](Contribution-Workflow.md).
- **Track it:** every issue and pull request carries `campaign:process-psmodule-v6`;
  the dashboard shows the fleet advancing from *Queued* to *Merged*.

## What this is not

- **Not a database.** Any `JSON` or `HTML` is a disposable projection of GitHub.
- **Not agent-specific.** The model stays fully operable by people and non-agent
  tools; nothing in it depends on a particular assistant.
- **Not a shared label store.** Labels are per-repository; the `campaign:<slug>`
  string is the shared contract, created in each participating repository.
