---
title: Module Requirements
description: Valid `#Requires -Modules` version specifications — minimum, major-lock (with the `N.*` wildcard), exact, and GUID identity pinning — with an executable proof.
---

# Module Requirements

How a script or test file declares the modules it needs, and how tightly it constrains their versions. Dependencies are declared with [`#Requires -Modules`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_requires); the value is a module name or a **module-specification hashtable**. This page is the reference for the version-specification forms and which to choose. It builds on [Security → Supply chain](../Security.md#supply-chain) (the *why*) and the per-construct rules in [Scripts](Scripts.md) and [Functions](Functions.md) (the *where*).

## Valid version specifications

| Intent | `#Requires -Modules` value | Resolves to | Use when |
| --- | --- | --- | --- |
| Any version | `'Pester'` or `@{ ModuleName = 'Pester' }` | any installed version | almost never — only when literally any version works |
| **Minimum** (floor) | `@{ ModuleName = 'Pester'; ModuleVersion = '6.0.0' }` | highest installed **≥ 6.0.0** | **default** — lets patches, minors, and majors flow in |
| **Major lock** (floor + wildcard ceiling) | `@{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }` | highest installed **6.x** (≥ 6.0.0, < 7.0.0) | a new major would break you — test frameworks are the typical case |
| Ceiling only | `@{ ModuleName = 'Pester'; MaximumVersion = '6.*' }` | highest installed **≤ 6.x** (also accepts 5.x, 4.x …) | avoid — no floor, so older majors also satisfy it |
| **Exact** | `@{ ModuleName = 'Pester'; RequiredVersion = '6.0.0' }` | exactly **6.0.0** | avoid unless strict reproducibility demands it — fragile (breaks the moment that exact build isn't present) |
| + Identity | add `GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'` to any of the above | additionally requires that module **GUID** | optional, stricter — anti-name-squat; independent of the version |

## Why `MaximumVersion = '6.*'` is valid (and the sentinel `6.999.999` is not needed)

The three version keys are **not** the same type on `Microsoft.PowerShell.Commands.ModuleSpecification`:

- `ModuleVersion` (minimum) and `RequiredVersion` (exact) are parsed as `[System.Version]` — **no wildcards**.
- `MaximumVersion` is a **`string`** — specifically so it can carry a wildcard. `MaximumVersion = '6.*'` is valid and idiomatic; it means "any `6.x`". A sentinel upper bound like `6.999.999` works too but is unnecessary.

Other rules:

- `RequiredVersion` **cannot** be combined with `ModuleVersion` or `MaximumVersion`. To express a range, use `ModuleVersion` (floor) **and** `MaximumVersion` (ceiling) together.
- A **major lock** needs both bounds: `MaximumVersion = '6.*'` alone still accepts 5.x and below, so pair it with `ModuleVersion = '6.0.0'`.
- `GUID` pins module *identity*, which is orthogonal to the version — a wrong GUID blocks even a version match, and omitting it is fine. It is a supply-chain control, not part of the version lock (see [Security → Supply chain](../Security.md#supply-chain)).
- Requirements are enforced by the engine at **parse/discovery time**: if no installed module satisfies the specification, the script is not run at all.

## An entry script that reports a verdict imports its modules itself

`#Requires -Modules` is the right way for a **test file, a module, or a function library** to declare what it needs. It is the wrong way for an **entry script whose exit code is the answer** — a test gate, a validation script, a hook — because the declaration can cost the script that exit code.

```powershell
# gate.ps1
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }
Write-Output 'ran'
exit 7
```

```console
$ pwsh -NoProfile -File gate.ps1
ran
$ echo $LASTEXITCODE
0
```

The script runs to completion and executes its `exit`; only the code is lost. A gate written this way reports success no matter what it found — and because the failure is invisible in a passing run, it is caught only by [proving the check can fail](../Testing.md#prove-the-test-can-fail).

Import the module instead, with the same range the specification would have carried:

```powershell
Import-Module -Name Pester -MinimumVersion 6.0.0 -MaximumVersion 6.*
```

What was observed, and what was not:

- It reproduces with Pester — name form and hashtable form, version `5.8.0` and `6.0.1` alike. It did **not** reproduce with `PSScriptAnalyzer`, `PSReadLine`, `Microsoft.PowerShell.PSResourceGet`, `Microsoft.PowerShell.Management`, or a throwaway module written for the test, all of which return the code the script asked for.
- `#Requires -Version` is not involved; only the `-Modules` parameter is.
- `pwsh -Command ". ./gate.ps1"` — the form [GitHub Actions](../GitHub-Actions.md) uses for `shell: pwsh` — collapses every non-zero exit to `1` whether or not the declaration is present, so a CI step still fails. The false green belongs to `pwsh -File`, which is how a person runs the script by hand.
- Why it is specific to one module is **not known**. The rule above is therefore written as a shape to avoid, not as a claim about how `#Requires` works.

The `#Requires -Modules` lines inside `*.Tests.ps1` files stay as they are. Pester runs a test file as a container, not as an entry script, so no exit code is at stake there.

## Choosing the tightness (risk appetite)

Match the constraint to how much drift you can safely absorb:

- **Modules** — declare a **minimum** by default so security patches flow in; **major-lock** (`ModuleVersion` + `MaximumVersion = 'N.*'`) a dependency whose next major would break you; avoid **exact** pins. Add a `GUID` only when identity assurance is required.
- **GitHub Actions / container images** — pin to an immutable **commit SHA** / **digest**, not a moving tag (see [Security → Supply chain](../Security.md#supply-chain) and [GitHub Actions](../GitHub-Actions.md)).
- Keep pins current with automated update PRs — see [Dependency Updates](../../Capabilities/dependency-updates/index.md).

## Proof

Every row above is backed by an executable Pester test, [`tests/Requires-Modules.Tests.ps1`](https://github.com/MSXOrg/docs/blob/main/tests/Requires-Modules.Tests.ps1). It writes a one-line `#Requires` script for each case, runs it in a child PowerShell, and asserts whether the requirement resolves — using the installed Pester as the sample module, so it is independent of the exact `6.x` version.

```powershell
Invoke-Pester -Path ./tests/Requires-Modules.Tests.ps1
```

It proves, among the eleven cases:

- The **major lock** (`ModuleVersion = 'N.0.0'; MaximumVersion = 'N.*'`) resolves to the installed `N.x`.
- The **wildcard ceiling is enforced** — a ceiling below the floor is unsatisfiable (so `6.*` genuinely blocks 7.x).
- An **exact** `RequiredVersion` that isn't installed does **not** resolve (why exact pins are fragile).
- A **wrong GUID** blocks an otherwise-matching module, while **omitting** the GUID still resolves (identity is optional and orthogonal to version).
- An **explicit `Import-Module`** returns the exit code the script asked for, and a **`#Requires -Modules` declaration does not** — the last three cases run a child script that prints `RAN` and exits `7`, and assert on the child process's real exit code, so a case cannot pass because the script never ran.
