---
title: Engineering Taste
description: Engineering judgment for decisions that the standards do not resolve.
---

# Engineering Taste

When standards do not resolve a decision, engineering judgment applies. These defaults guide that judgment.

## Simplicity over cleverness

- The simplest solution that solves the problem wins. Prefer a clear solution over code that requires extra explanation.
- Write for the next reader. Assume they have no local context, whether they are a teammate, an agent, or you.

## Leave it better, but stay in scope

- Improve clarity in the area you change, for example through a better name or removal of a dead branch.
- Keep cleanup in scope. Focused changes are easier to review and revert. File unrelated cleanup as a follow-up.

## Don't build what you don't need

- Do not add speculative generality or an abstraction with a single caller. Build only what the current deliverable needs.
- Prefer a proven, general-purpose tool before building a custom tool.

## Understand before you change

- Read the existing code and its context before changing it. The reasons for a design may not be clear from the code alone.
- If you cannot explain why the current code exists, do not replace it.

## Weigh reversibility

- Make reversible decisions quickly.
- Decisions that are irreversible or expensive to reverse need a second perspective and a written rationale. See [Principles → make change easy](Principles/Software-Design.md#make-change-easy-then-make-the-easy-change).

## When still unsure

Use the three criteria: does this make the system **easier**, does it move **faster**, and does it stay **safe**? If a choice weakens one criterion, state the trade-off and decide deliberately.
