---
title: Definition of Ready and Done
description: The two checklists that bracket every piece of work.
---

# Definition of Ready and Done

Three gates bracket every piece of work: one gates when it can start, one gates when it is ready for other people to review, and one gates when it can be called complete. All are shared contracts, not personal preferences.

## Definition of Ready

An item is ready to be pulled into work when:

- It is at the right level — a single deliverable, not a bundle. See [Issue Hierarchy](Issue-Hierarchy.md).
- The intent is clear — the problem and the desired outcome are understood, written from the user's perspective.
- It has acceptance criteria — "done" is described and testable.
- It is sized to fit comfortably within one cycle of work.
- Dependencies and blockers are known.
- Open questions are resolved.

Ready gates *starting*, not scope. An item that isn't ready stays in the backlog and gets refined — it is not pulled in and figured out on the fly.

## Definition of Ready for Review

A pull request stays a **draft** until it is genuinely ready for other people to spend attention on it. "Ready for review" is not "I started" or "please take a look" — it is a deliberate signal that the change is complete and self-reviewed, and that the only thing left is another perspective before merge. It gates the hand-off in the [Contribution Workflow](Contribution-Workflow.md).

A pull request is ready for review when:

- Every task in the linked issue's checklist is complete — or explicitly moved to a follow-up issue. No half-done work is left implicit.
- Dependencies are current — any dependency update the change relies on is already merged or included; nothing waits on a bump that has not landed yet.
- All required checks are green — not just tests that pass locally. CI is complete, not in progress.
- The automated review loop has converged — a clean [Copilot round](Contribution-Workflow.md#the-copilot-review-loop) with no unresolved review threads.
- The title, release-note description, and exactly one change-type label are finalized. See [PR Format](PR-Format.md).
- A linked issue exists.

If any item is open, the pull request stays a draft. Marking it ready with known-open work shifts the author's unfinished job onto reviewers — the opposite of what the signal means.

Once every item holds, hand the change off: mark it ready for review and enable auto-merge so it lands the moment review approves and the required checks stay green. See [Branching and Merging](Branching-and-Merging.md#required-checks-and-auto-merge).

## Definition of Done

An item is done when:

- The acceptance criteria are met.
- The change is merged through a reviewed pull request.
- It conforms to the [Coding Standards](../Coding-Standards/index.md); linters and checks are green.
- Tests cover the behavior and pass.
- The [evergreen specification](Documentation-Model.md#evergreen-and-evolutionary) for the affected capability describes the new behaviour — the spec leads, the code matches it.
- Documentation is updated in the same change — both owning-team docs (README, in-code help, and this site) and user-facing documentation.
- It is released or deployed, where that applies.
- No known regressions remain, and the issue is closed.

Done is binary. Skip a criterion only when it genuinely does not apply — a docs-only change has no deploy step. If "done" repeatedly needs exceptions, fix the definition rather than quietly lowering the bar.
