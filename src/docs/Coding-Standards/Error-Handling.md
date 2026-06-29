---
title: Error Handling
description: Fail fast, never swallow, and write messages that help the next person.
---

# Error Handling

How code behaves when something goes wrong is part of its contract. Errors are surfaced, specific, and actionable — never swallowed.

## Fail fast, fail loud

- Validate inputs and preconditions early, and raise immediately when they are violated. The sooner a problem surfaces, the cheaper it is to fix.
- A function that cannot fulfil its contract raises — it does not return a sentinel value that callers are free to ignore.

## Never swallow errors

- Don't catch an error only to discard it. An empty catch hides the failure and pushes the bug downstream, where it is far harder to diagnose.
- Catch only what you can handle. If you cannot recover, let the error propagate to a layer that can — or to the top, where it is logged and surfaced.

## Be specific

- Catch specific, typed errors rather than a blanket catch-all. A broad catch silently hides failures you never anticipated.
- Distinguish recoverable from fatal. Recoverable errors are handled in place; fatal ones stop the operation cleanly.

## Messages serve the next person

- An error message names what failed, the context it failed in, and — ideally — what to do about it. "Operation failed" helps no one; "cannot write to `<path>`: permission denied" does.
- Include enough context to diagnose without reproducing — identifiers, paths, and values. Never put secrets in a message or a log.

## Separate the channels

- Return values, diagnostics, warnings, and errors each travel on their own channel. Printing diagnostics where a caller expects data breaks composition and testing.
- Respect the caller's verbosity and output preferences rather than forcing your own.

## Clean up deterministically

- Resources — files, handles, connections, locks — are released on every path, success or failure. Use the language's structured cleanup: `finally`, `defer`, context managers, disposables.
