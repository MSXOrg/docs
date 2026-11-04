---
title: Messaging
description: "Write-Verbose for user-facing operational progress and normal troubleshooting; Write-Debug for developer-focused internals and deep diagnostics."
---

# Messaging

Choose between `Write-Verbose` and `Write-Debug` based on the audience and purpose of the message. The distinction helps operators and maintainers find the diagnostic information they need.

## The rule

- **Use `Write-Verbose`** for **user-facing** operational progress, decision summaries, and normal troubleshooting context. These messages help operators understand execution and diagnose operational issues.
- **Use `Write-Debug`** for **developer-focused** internals, deep diagnostics, low-level payload and transport details, internal state, and instrumentation. These messages serve code authors and maintainers, not operators.

## Examples

### Write-Verbose: operational progress and troubleshooting

These messages explain operational steps and their purpose without requiring knowledge of the implementation.

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

Verbose messages describe **operations**: repositories, deployments, workflows, and API calls.

### Write-Debug: internals and deep diagnostics

These messages serve code authors and maintainers. They expose implementation details that help diagnose internal failures.

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

Debug messages expose **implementation details**: payloads, headers, cache state, and internal variables. These details support diagnosis at the source-code level.

## Review checklist

Use these criteria to choose the stream:

1. **Use `Write-Verbose` for normal operational troubleshooting.**
   - Operators should understand it without reading source code.
   - It describes operational activity (workflow, deployment, repository, API call).
   - It describes an operation's result or the step that failed.

2. **Use `Write-Debug` for internal details and deep diagnostics.**
   - Only a code author or maintainer needs this information.
   - It exposes implementation details (payload, headers, internal variables, timing).
   - It explains execution paths and internal function state.

3. **If the audience remains unclear, prefer `Write-Verbose`.** This keeps troubleshooting context available at the normal operational level.

## Enabling messages at runtime

PowerShell controls visibility with built-in preference variables and common parameters. No code change is needed to show existing messages:

- **Show verbose messages:** run the command with the `-Verbose` switch, or set `$VerbosePreference = 'Continue'` before calling.
- **Show debug messages:** set `$DebugPreference = 'Continue'` before calling, or use the `-Debug` common parameter with cmdlets and advanced functions.

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

- **`Write-Information`** — user-facing information outside troubleshooting. Use it for important operational summaries that should always be visible without `-Verbose`. The default `$InformationPreference` is `SilentlyContinue`, which hides these messages. `-InformationAction Continue` displays them without changing the preference. For example, "Migration complete: 42 items processed."
- **`Write-Warning`** — a condition the operator should know about but that did not stop the operation; reserved for genuine warnings, not verbose narration.
- **`Write-Error`** — reports a non-terminating error by default. `-ErrorAction Stop` makes the error terminating. `$ErrorActionPreference = 'Stop'` does the same unless a command-level error action overrides it. Use `[PSCustomObject]` with `-TargetObject` for structured context, or supply an error record with `-ErrorRecord`.
- **Logging (event logs, files)** — persistent audit; separate from these streams and outside the scope of this standard.

Use each stream for its intended audience so operators and maintainers can find the messages they need.

The runtime behavior is defined in [PowerShell common parameters](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_commonparameters), [Write-Information](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/write-information), and [Write-Error](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/write-error).
