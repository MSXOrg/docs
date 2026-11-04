---
title: Error Handling
description: Fail fast, never swallow, and write messages that help the next person.
---

# Error Handling

Error handling is part of the code's contract. Code reports specific errors with recovery information instead of discarding failures.

## Fail fast, fail loud

- Validate inputs and preconditions early. Raise an error immediately for invalid input or an unsatisfied precondition. An early failure makes its cause easier to identify.
- A function that cannot fulfill its contract raises an error. It does not return a sentinel value that callers can ignore.

## Never swallow errors

- Do not catch an error only to discard it. An empty catch hides the failure. Failures discovered by later callers are harder to diagnose.
- Catch only what you can handle. If you cannot recover, let the error propagate to a layer that can handle it. If no layer can handle it, the top level logs and reports it.

## Be specific

- Catch specific, typed errors rather than all errors indiscriminately. A broad catch can hide unexpected failures.
- Distinguish recoverable errors from fatal errors. Handle recoverable errors in place. Stop the operation cleanly for fatal errors.

## Messages serve the next person

- An error message names the failure and its context. Ideally, it also states a recovery action. "Operation failed" provides no diagnosis; "cannot write to `<path>`: permission denied" identifies the cause.
- Include enough context to diagnose without reproducing — identifiers, paths, and values. Never put secrets in a message or a log.

## Separate the channels

- Send return values, diagnostics, warnings, and errors on separate channels. Diagnostics on a data channel break composition and testing.
- Respect the caller's verbosity and output preferences rather than forcing your own.

## Clean up deterministically

- Release resources — files, handles, connections, locks — on every path, success or failure. Use the language's structured cleanup: `finally`, `defer`, context managers, disposables.
