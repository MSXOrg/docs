---
title: Performance
description: Scale with the input, measure before optimizing, clarity first.
---

# Performance

Write code that scales with its input, measure before optimizing, and never trade clarity for speed you don't need.

## Correct and clear first

- Make it correct, make it clear, then make it fast — in that order. Most code is never the bottleneck.
- Avoid premature optimization. Optimizing code that isn't hot adds complexity and buys nothing.

## Know the cost

- Be aware of algorithmic complexity. An O(n²) pattern in a loop — rebuilding a collection by copying it on every iteration — is fine for ten items and catastrophic for ten thousand.
- Choose a data structure that matches the access pattern: a set for membership, a map for lookup, a list for ordered iteration.
- Append to a growable structure; don't rebuild an immutable one on each pass.

## Push work down and out

- Filter as close to the source as possible. Let the database, API, or provider filter before the data crosses a boundary, rather than fetching everything and discarding most of it.
- Stream large data sets instead of loading them entirely into memory.
- Do work once. Hoist invariant computations out of loops, and cache results that are expensive to recompute and safe to reuse.

## Measure, don't guess

- Profile before optimizing. Intuition about bottlenecks is usually wrong — measure where the time actually goes.
- Optimize the hot path, then confirm the gain with a measurement rather than a hunch.
