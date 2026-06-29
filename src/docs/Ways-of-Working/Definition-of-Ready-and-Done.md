---
title: Definition of Ready and Done
description: The two checklists that bracket every piece of work.
---

# Definition of Ready and Done

Two checklists bracket every piece of work: one gates when it can start, the other gates when it can be called complete. Both are shared contracts, not personal preferences.

## Definition of Ready

An item is ready to be pulled into work when:

- It is at the right level — a single deliverable, not a bundle. See [Issue Hierarchy](Issue-Hierarchy.md).
- The intent is clear — the problem and the desired outcome are understood, written from the user's perspective.
- It has acceptance criteria — "done" is described and testable.
- It is sized to fit comfortably within one cycle of work.
- Dependencies and blockers are known.
- Open questions are resolved.

Ready gates *starting*, not scope. An item that isn't ready stays in the backlog and gets refined — it is not pulled in and figured out on the fly.

## Definition of Done

An item is done when:

- The acceptance criteria are met.
- The change is merged through a reviewed pull request.
- It conforms to the [Coding Standards](../Coding-Standards/index.md); linters and checks are green.
- Tests cover the behavior and pass.
- Documentation — README, in-code help, and this site — is updated in the same change.
- It is released or deployed, where that applies.
- No known regressions remain, and the issue is closed.

Done is binary. Skip a criterion only when it genuinely does not apply — a docs-only change has no deploy step. If "done" repeatedly needs exceptions, fix the definition rather than quietly lowering the bar.
