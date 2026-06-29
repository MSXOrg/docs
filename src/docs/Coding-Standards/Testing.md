---
title: Testing
description: The executable specification — test-first, locally runnable, deterministic.
---

# Testing

Tests are the executable specification. They define the behavior we want, prove we built it, and catch the day it breaks. They are written as part of the work — not bolted on afterward.

## Test-first

Define the test when you define the behavior. Writing the test first forces you to design the interface from the caller's side, and it gives you an unambiguous definition of done: the test passes.

For logic with branches, edge cases, or anything involving money, time, or security — red-green-refactor is the default. For trivial glue code, judgment applies; dogma does not.

See [Test-Driven Development](../Ways-of-Working/Principles.md#test-driven-development).

## Testable locally

A developer or an agent must be able to run the full suite **on their own machine** — no cloud resources, no special access, no secrets that cannot be mocked. If you cannot test it locally, you cannot reason about it in your editor, and the cost of every change goes up.

This is a design constraint, not a nicety. When building anything new, ask early: *can someone run this locally?* If the answer is no, the design is wrong.

## The test pyramid

Most tests should be fast and narrow; few should be slow and broad.

- **Unit** — the foundation. Fast, isolated, no I/O. The bulk of the suite.
- **Integration** — components together, real boundaries. Fewer, slower, higher-value.
- **End-to-end** — the whole system. Fewest of all; reserved for critical paths.

Inverting the pyramid — leaning on slow, brittle end-to-end tests — produces a suite that is painful to run and quick to be ignored.

## Properties of a good test

- **Deterministic.** Same input, same result, every time. A test that passes intermittently is worse than no test — it trains people to ignore failures. No reliance on wall-clock time, network, ordering, or shared mutable state.
- **Isolated.** Each test sets up and tears down its own world. Tests do not depend on each other or on run order.
- **Fast.** The inner loop is where engineering time is spent; slow tests get skipped.
- **Readable.** A test is also documentation. Arrange–act–assert, one behavior per test, a name that states the expectation.
- **One reason to fail.** When a test breaks, its name and body should make the cause obvious.

## Coverage with judgment

Coverage is a signal, not a goal. High coverage of trivial code while the hard branches go untested is a false comfort. Aim coverage at the code that carries risk — logic, edge cases, error handling — and don't chase a percentage for its own sake.

## When a bug escapes

A bug that reached production is a missing test. The fix is incomplete until a test reproduces the failure and then passes — so the same regression can never return silently. Fixing the source without closing the test gap leaves the next regression just as invisible.

## Tests run in CI

Every pull request runs the suite before a human review begins. Validation that depends on a reviewer remembering to check is validation that eventually fails. Automate it once; it protects every PR after. See [Shift Left](../Ways-of-Working/Principles.md#shift-left).
