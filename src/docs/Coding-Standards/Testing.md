---
title: Testing
description: Prove supported behavior through real entry points and APIs, with justified test doubles and honest coverage.
---

# Testing

Tests are executable specifications. They define intended behavior, verify its implementation, and detect regressions. This page owns the testing policy; language standards and agent skills build on it or link to it rather than define another one.

## Test supported behavior

Tests MUST assert observable functionality and public contracts through supported entry points: functions, commands, and APIs. Exercise the real implementation with controlled inputs and independently established expected results. A behavior-preserving refactor MUST NOT break tests merely because implementation text or internal structure changed.

Do not add assertions whose only purpose is detecting source, documentation, or workflow edits: required phrases, headings, source-string searches, structural snapshots, or drift checks that freeze implementation shape. Linting, formatting, static analysis, link validation, and builds remain separate safeguards; this rule does not remove them.

An independent expected result for a public functional contract is valid. So is testing a product whose supported behavior is change detection. Invoke a link checker or index generator on temporary fixture inputs and assert its output, exit code, or resulting files; do not search its source or policy prose merely to enforce an edit.

## Test-first

Define the test when you define the behavior. Write the test first to design the interface from the caller's perspective. A passing test provides an observable completion criterion.

For logic with branches, edge cases, or anything involving money, time, or security — red-green-refactor is the default. For trivial glue code, use engineering judgment.

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

A test can repeat an implementation error if it computes the expected value with the same algorithm. Reimplementing heading-to-anchor logic, for example, does not provide an independent anchor oracle. Both implementations can produce the same wrong anchor. Expected values come from sources the implementation cannot influence: the real consumer's library, a fixture from the real system, the published specification, or an independently developed implementation.

The same limit applies to [test doubles](#dont-mock-what-you-dont-own): neither a simulated dependency nor an assertion derived from the implementation independently establishes correctness.

Verify an external oracle's request and response before using its results. A wrong mode flag, expired token, or renamed field can produce an empty response. Assertions can then pass without examining the intended contract. Assert on the oracle too: an empty response is a failure of the check, not a pass (see [nothing checked is not a pass](#nothing-checked-is-not-a-pass)). When two independent oracles are available at low cost, compare their results.

## Nothing checked is not a pass

A universal assertion over an empty set is true. *All links resolve* holds when no links were found. *Every anchor exists* holds when the oracle returned nothing to compare against. A run with no examined inputs cannot establish behavior, even when it reports success.

Make the count part of the result: **a check fails when it checked nothing.** Count the units examined and treat zero as a failure. Report that the check found no inputs rather than that everything passed.

The count detects input-selection failures, such as a wrong root directory, an unintended filter, a glob that matches nothing, or an empty checkout. It also detects a query with no rows or an oracle with no response data. Such failures can leave the check with no examined units. The check reports that zero count as a failure.

Count meaningful examined units, not an adjacent proxy. An empty result can be a supported functional outcome, but test it with a controlled case and an independent expected result. Any scope-specific zero-count exception MUST document that real behavior; it cannot turn missing inputs or an unexecuted check into success.

## Prove the test can fail

Before you trust a new check, create a controlled case that violates the behavior it verifies. Confirm that the check fails and read its message. Then restore the valid behavior. If the check passes for the broken case, it does not verify the intended property.

A positive count establishes only that the check examined some input. It does not establish that the check examined the intended property. For example, preserving every source word during conversion does not prove that the converted links resolve. A controlled failure case verifies that the check detects the intended failure.

## Properties of a good test

- **Deterministic.** Use controlled inputs and stable observable contracts. Control time, ordering, and mutable state. Real network or API checks have explicit prerequisites and report external failures; do not hide them behind a passing fallback.
- **Isolated.** Each test prepares and cleans up its own state. Tests do not depend on each other or on run order.
- **Fast.** Keep local feedback fast. Slow tests increase the risk that developers omit them.
- **Readable.** A test is also documentation. Arrange–act–assert, one behavior per test, a name that states the expectation.
- **One reason to fail.** When a test breaks, its name and body should make the cause obvious.

## Coverage with judgment

Coverage shows which code the tests execute; it does not establish correctness by itself. High coverage of trivial code can still exclude risky branches. Focus coverage on logic, edge cases, and error handling rather than a percentage alone.

A metric must measure the intended property. A conversion that preserves every source word establishes verbatim text, not whether links in that text resolve. Review the conclusion separately from the reported count.

## When a bug escapes

A production bug exposes a gap in test coverage. First reproduce the failure with a test. Then confirm that the test passes with the fix. Keep the regression test so the same failure cannot return undetected.

## Tests run in CI

Every pull request runs the required local tests and validation gates before a human review begins. Run protected live-API checks in authorized environments on documented triggers, such as relevant changes or a risk-based schedule. A required protected check that could not execute remains an open gate, not a pass.

Review tests against the supported behavior and the evidence they establish, including justified test doubles and unexecuted coverage. Manual checks can be missed. Automate the appropriate checks. See [Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left).
