---
title: Testing
description: Prove supported behavior through real entry points and APIs, with justified test doubles and honest coverage.
---

# Testing

Tests are the executable specification. They define the intended behavior, prove it was built, and catch the day it breaks. This page owns the testing policy; language standards and agent skills build on it or link to it rather than define another one.

## Test supported behavior

Tests MUST assert observable functionality and public contracts through supported entry points: functions, commands, and APIs. Exercise the real implementation with controlled inputs and independently established expected results. A behavior-preserving refactor MUST NOT break tests merely because implementation text or internal structure changed.

Do not add assertions whose only purpose is detecting source, documentation, or workflow edits: required phrases, headings, source-string searches, structural snapshots, or drift checks that freeze implementation shape. Linting, formatting, static analysis, link validation, and builds remain separate safeguards; this rule does not remove them.

An independent expected result for a public functional contract is valid. So is testing a product whose supported behavior is change detection. Invoke a link checker or index generator on temporary fixture inputs and assert its output, exit code, or resulting files; do not search its source or policy prose merely to enforce an edit.

## Test-first

Define the test when you define the behavior. Writing the test first forces you to design the interface from the caller's side, and it gives you an unambiguous definition of done: the test passes.

For logic with branches, edge cases, or anything involving money, time, or security — red-green-refactor is the default. For trivial glue code, judgment applies; dogma does not.

See [Test-Driven Development](../Ways-of-Working/Principles/Engineering-Practices.md#test-driven-development).

## Testable locally

A developer or an agent MUST have a fast, credential-free local inner loop. Exercise pure logic directly and use real implementations with isolated local dependencies where feasible. Document the local command and setup so someone can reason about behavior in their editor without cloud access.

The local loop is not a claim that every external integration was tested. Identify [protected live-API checks](#protected-live-api-checks) separately, with their prerequisites and execution evidence. Do not require slow remote calls for logic that can be exercised directly.

## The test pyramid

Choose the narrowest test that proves the behavior using the real implementation. Keep feedback fast without substituting a mock for a contract that needs an actual API.

- **Unit** — exercise logic directly through its supported interface, with controlled inputs.
- **Integration** — exercise real components together through commands and actual APIs in safe, isolated local, test, or sandbox environments.
- **End-to-end** — exercise critical workflows through the system's supported entry points, with the wider resource and setup cost made explicit.

These levels describe scope, not a required ratio of mocked unit tests. Prefer real implementations and actual APIs by default; keep broad checks focused on behavior the narrower checks cannot establish.

## Don't mock what you don't own

Mocks and fakes are justified exceptions, not the default. Record why a safe real case is not feasible, which boundary is simulated, and what the test does and does not prove. Controlled simulation can cover dangerous, unavailable, or rate-limited failure modes without performing unsafe calls.

When a test double is necessary, prefer the owned boundary rather than inventing the vendor's behavior. A fake proves how the caller handles the simulated response; it does not prove that the external API, authentication, or deployed integration works. Where that external contract matters, require a separately identified real-API check rather than treating the fake as integration evidence.

## Protected live-API checks

Real network checks are allowed. Use designated test or sandbox endpoints, least-privilege test identities, controlled inputs, and stable observable contracts. Identify the protected checks separately from the credential-free local loop.

- **Prerequisites and authorization.** Document the environment, credential source, opt-in command, required approvals, and safe resource scope. Never embed secrets in code, fixtures, logs, or evidence. A test grants no permission: production writes and unsafe, destructive, or paid calls require explicit scoped authorization and are never defaults.
- **Isolation and cleanup.** Create or reserve resources isolated to the run. Clean them up on success and failure; report cleanup failures and remaining resources rather than hiding them.
- **Execution and evidence.** Record the command, tested environment, examined cases, result, and safe evidence in the Task or PR. Distinguish a functional failure from an unavailable prerequisite, authentication failure, rate limit, or network outage.

Missing credentials, approvals, resources, or a live run mean **unexecuted coverage**, not a passing integration check. Report skipped or blocked checks and their reason explicitly. Local or simulated success cannot close that evidence gap.

## The oracle must be independent

A test proves nothing when it computes the expected value the same way the code computes the actual one. If a function derives anchors from headings, and the test reimplements that same derivation to check it, both are free to be wrong together and the suite stays green forever. The expected value has to come from somewhere the implementation cannot influence: the library the real consumer runs, a fixture recorded from the real system, the published specification, or a second implementation written independently.

The same limit applies to [test doubles](#dont-mock-what-you-dont-own): neither a simulated dependency nor an assertion derived from the implementation independently establishes correctness.

When the oracle is an external tool or service, confirm it is answering the question you think you asked. A wrong mode flag, an expired token, or a renamed field can turn a rich response into an empty one — and every assertion built on it into a vacuous truth. So assert on the oracle too: an empty response is a failure of the check, not a pass (see [nothing checked is not a pass](#nothing-checked-is-not-a-pass)). Where two independent oracles are available cheaply, agreeing them once is worth more than trusting either.

## Nothing checked is not a pass

Every assertion over an empty set is true. *All links resolve* holds trivially when no links were found. *Every anchor exists* holds when the oracle returned nothing to compare against. A check that iterates over nothing and reports success is not a check — it is a claim with no content behind it, and it is indistinguishable from a working one at a glance.

So make the count part of the result: **a check fails when it checked nothing.** Count the units examined and treat zero as a failure, with a message that says the check found nothing rather than that everything is fine.

This costs three lines next to the exit, and it covers a whole class at once — the wrong root directory, a filter that matches more than intended, a glob that missed, an empty checkout, a query that returned no rows, an oracle that answered with an empty response. None of those need to be anticipated individually. Each one drives the count to zero, and zero is a failure.

Count meaningful examined units, not an adjacent proxy. An empty result can be a supported functional outcome, but test it with a controlled case and an independent expected result. Any scope-specific zero-count exception MUST document that real behavior; it cannot turn missing inputs or an unexecuted check into success.

## Prove the test can fail

A check that has never failed has not been checked. Before trusting a new one, make it red on purpose: break the behavior it guards, confirm it fails, read the message it produces, then restore. If breaking the behavior leaves the check green, the check is decoration.

Counting is not a substitute for this. A healthy count only says the check examined something — not that it examined the right property. A conversion that reports every word of the source survived has a large denominator and still says nothing about whether the links in that text resolve. An empty check is caught by counting; a check measuring the wrong thing is caught only by breaking the thing it claims to guard and watching what happens.

## Properties of a good test

- **Deterministic.** Use controlled inputs and stable observable contracts. Control time, ordering, and mutable state. Real network or API checks have explicit prerequisites and report external failures; do not hide them behind a passing fallback.
- **Isolated.** Each test sets up and tears down its own world. Tests do not depend on each other or on run order.
- **Fast.** The inner loop is where engineering time is spent; slow tests get skipped.
- **Readable.** A test is also documentation. Arrange–act–assert, one behavior per test, a name that states the expectation.
- **One reason to fail.** When a test breaks, its name and body should make the cause obvious.

## Coverage with judgment

Coverage is a signal, not a goal. High coverage of trivial code while the hard branches go untested is a false comfort. Aim coverage at the code that carries risk — logic, edge cases, error handling — and don't chase a percentage for its own sake.

Watch for a number that measures something adjacent to what you actually care about. A conversion reporting that every word of the source survived tells you the text is verbatim; it says nothing about whether the links inside that text resolve. The measurement is honest and the conclusion drawn from it is not — which is why the reassuring ones deserve the most scrutiny.

## When a bug escapes

A bug that reached production is a missing test. The fix is incomplete until a test reproduces the failure and then passes — so the same regression can never return silently. Fixing the source without closing the test gap leaves the next regression just as invisible.

## Tests run in CI

Every pull request runs the required local tests and validation gates before a human review begins. Run protected live-API checks in authorized environments on documented triggers, such as relevant changes or a risk-based schedule. A required protected check that could not execute remains an open gate, not a pass.

Review tests against the supported behavior and the evidence they establish, including justified test doubles and unexecuted coverage. Validation that depends on a reviewer remembering to run it eventually fails; automate the appropriate checks. See [Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left).
