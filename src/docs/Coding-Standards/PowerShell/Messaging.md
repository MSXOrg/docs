---
title: Messaging
description: "Write-Verbose for user-facing operational progress and normal troubleshooting; Write-Debug for developer-focused internals and deep diagnostics."
---

# Messaging

Choose between `Write-Verbose` and `Write-Debug` based on the audience and purpose of the message. This distinction clarifies intent for maintainers, improves discoverability for operators, and keeps diagnostic output focused.

## The rule

- **Use `Write-Verbose`** for **user-facing** operational progress, decision summaries, and normal troubleshooting context — information that helps operators understand execution flow and diagnose issues at the normal operational level.
- **Use `Write-Debug`** for **developer-focused** internals, deep diagnostics, low-level payload and transport details, internal state, and instrumentation — information for the author and maintainers of the code, not operators.

## Examples

### Write-Verbose: operational progress and troubleshooting

These messages help an operator understand *what is happening* and *why*, without needing to know the implementation details.

```powershell
# Progress narration — what step is running
Write-Verbose "Retrieving repository metadata from GitHub..."

# Decision summary — what the code decided and why
Write-Verbose "Found 3 matching repositories; filtering to 1 owned by the org"

# Outcome — what succeeded or failed at the user-visible level
Write-Verbose "Successfully cloned repository to $DestinationPath"

# Configuration recap — what settings are in use
Write-Verbose "Using authentication method: Personal Access Token"
```

Verbose messages stay at a **business level**: they talk about repositories, deployments, workflows, API calls — things an operator cares about.

### Write-Debug: internals and deep diagnostics

These messages are for the code author and maintainers. They expose the implementation details that help diagnose why something went wrong *internally*.

```powershell
# Payload details — the raw data moving through the code
Write-Debug "Request body: $($RequestBody | ConvertTo-Json -Depth 10)"

# Internal state — variables and computed values
Write-Debug "Resolved repository ID to: $RepoID"
Write-Debug "Cache hit: $CacheHit; items in cache: $($Cache.Count)"

# Low-level transport details — HTTP headers, raw responses
Write-Debug "Response header 'X-RateLimit-Remaining': $($Response.Headers['X-RateLimit-Remaining'])"

# Instrumentation — timing, counters, flow paths
Write-Debug "Processed $ProcessedCount of $TotalCount items (elapsed: $ElapsedMs ms)"
Write-Debug "Taking fallback branch: condition was $Condition"
```

Debug messages expose **plumbing**: they talk about payloads, headers, cache state, internal variables — details that only make sense in the context of reading the code.

## Review checklist

When writing messages, ask:

1. **Is this message useful at normal troubleshooting level?** ✓ Use `Write-Verbose`
   - Operators should understand it without reading source code.
   - It describes *what* is happening at the business level (workflow, deployment, repository, API call).
   - It helps answer "what did my operation do?" or "where did it fail?".

2. **Is this an internal/deep diagnostic detail?** ✓ Use `Write-Debug`
   - Only a code author or maintainer needs this information.
   - It exposes implementation details (payload, headers, internal variables, timing).
   - It helps answer "why did the code take this path?" or "what is the state inside this function?".

3. **Am I unsure?** Prefer `Write-Verbose` — it's safer to be slightly more verbose at the normal level than to hide troubleshooting context that operators need.

## Enabling messages at runtime

PowerShell controls visibility with built-in preference variables — no code change needed to see messages:

- **Show verbose messages:** run the command with the `-Verbose` switch, or set `$VerbosePreference = 'Continue'` before calling.
- **Show debug messages:** set `$DebugPreference = 'Continue'` before calling the command (no `-Debug` switch exists; use the preference).

Example:

```powershell
# Operator runs the command with -Verbose to see operational context
Get-Repository -Owner 'MyOrg' -Name 'MyRepo' -Verbose

# Or sets the preference for all calls in the session
$VerbosePreference = 'Continue'
Get-Repository -Owner 'MyOrg' -Name 'MyRepo'

# In a script, enable debug messages
$DebugPreference = 'Continue'
Invoke-RepositoryOperation
```

## Relationship to other messaging

This standard covers the two main diagnostic channels. For context:

- **`Write-Information`** — user-facing but outside the troubleshooting spectrum. Use it for important operational summaries that should always be visible (not gated by `-Verbose`), e.g., "Migration complete: 42 items processed."
- **`Write-Warning`** — a condition the operator should know about but that did not stop the operation; reserved for genuine warnings, not verbose narration.
- **`Write-Error`** (terminating) — a failure that stops execution; emit structured errors with `[PSCustomObject]` or `-ErrorRecord` for discoverability.
- **Logging (event logs, files)** — persistent audit; separate from these streams and outside the scope of this standard.

Reserve the verbose and debug streams for their intended audiences, and keep messages at the right level so operators and maintainers can both find what they need.
