---
title: Performance
description: Scale with the input, measure before optimizing, clarity first.
---

# Performance

Write code that scales with its input. Measure before you optimize. Preserve clarity unless measurements show a required performance improvement.

## Correct and clear first

- Make it correct, make it clear, then make it fast — in that order. Most code is never the bottleneck.
- Avoid premature optimization. Optimizing code outside performance-critical paths adds complexity without addressing measured bottlenecks.

## Know the cost

- Be aware of algorithmic complexity. An O(n²) pattern, such as copying a collection on every loop iteration, has a cost that grows faster than its input. Code acceptable for ten items can be too slow for ten thousand.
- Choose a data structure that matches the access pattern: a set for membership, a map for lookup, a list for ordered iteration.
- Append to a growable structure. Do not rebuild an immutable one on each pass.

## Push work down and out

- Filter as close to the source as possible. Let the database, API, or provider filter before the data crosses a boundary, rather than fetching everything and discarding most of it.
- Stream large data sets instead of loading them entirely into memory.
- Do work once. Move computations that do not change outside loops. Cache results that are expensive to recompute and safe to reuse.

## Measure, don't guess

- Profile before you optimize. Measure time by operation to identify bottlenecks rather than select optimizations from assumptions alone.
- Optimize the hot path, then measure again to confirm the improvement.
