---
title: Engineering Taste
description: The judgment that takes over when the standards run out.
---

# Engineering Taste

Standards cover the common cases. When they run out, judgment takes over. These are the defaults for the decisions no rule can make for you.

## Simplicity over cleverness

- The simplest solution that solves the problem wins. Clever code impresses once and confuses forever.
- Optimize for the next person to read the code. Assume they have no context — it might be a teammate, an agent, or you in six months.

## Leave it better, but stay in scope

- When you touch an area, leave it a little clearer than you found it — a better name here, a removed dead branch there.
- Don't go hunting for unrelated cleanup. A focused change is easy to review and safe to revert; a sprawling one is neither. File the follow-up instead.

## Don't build what you don't need

- No over-engineering, no speculative generality, no abstraction with a single caller. Build for the requirement in front of you.
- Reach for a general-purpose, proven tool before building a bespoke one. Boring and well-understood beats novel and clever.

## Understand before you change

- Read the existing code and its context before changing it. Most code is the way it is for a reason that isn't visible at first glance.
- If you can't explain why the current code exists, you're not ready to replace it.

## Weigh reversibility

- Reversible decisions are cheap — make them quickly and move on.
- Irreversible or expensive-to-undo decisions deserve more care: a second perspective and a written rationale. See [Principles → make change easy](Principles/Software-Design.md#make-change-easy-then-make-the-easy-change).

## When still unsure

Fall back to the three words: does this make the system **easier**, let us move **faster**, and keep us **safe**? If a choice trades one away, say so out loud and decide deliberately.
