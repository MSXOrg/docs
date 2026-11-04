---
title: Module Requirements
description: Valid `#Requires -Modules` version specifications — minimum, major-lock (with the `N.*` wildcard), exact, and GUID identity pinning — with an executable proof.
---

# Module Requirements

Scripts and test files declare module dependencies with [`#Requires -Modules`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_requires). The value is a module name or a **module-specification hashtable**. This page defines the version-specification forms and when to use them. [Security → Supply chain](../Security.md#supply-chain) explains the rationale. [Scripts](Scripts.md) and [Functions](Functions.md) define placement within each construct.

## Valid version specifications

| Intent | `#Requires -Modules` value | Resolves to | Use when |
| --- | --- | --- | --- |
| Any version | `'Pester'` or `@{ ModuleName = 'Pester' }` | any installed version | almost never; only when every version is compatible |
| **Minimum** (floor) | `@{ ModuleName = 'Pester'; ModuleVersion = '6.0.0' }` | highest installed **≥ 6.0.0** | **default**; accepts patches, minor releases, and major releases |
| **Major lock** (floor + wildcard ceiling) | `@{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }` | highest installed **6.x** (≥ 6.0.0, < 7.0.0) | the next major is incompatible; test frameworks are a typical case |
| Ceiling only | `@{ ModuleName = 'Pester'; MaximumVersion = '6.*' }` | highest installed **≤ 6.x** (also accepts 5.x, 4.x …) | avoid; older majors also satisfy it because there is no minimum |
| **Exact** | `@{ ModuleName = 'Pester'; RequiredVersion = '6.0.0' }` | exactly **6.0.0** | avoid unless strict reproducibility requires it; fails if that exact build is not installed |
| + Identity | add `GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'` to any of the above | additionally requires that module **GUID** | optional, stricter identity assurance against name squatting; independent of the version |

## Why `MaximumVersion = '6.*'` is valid (and the sentinel `6.999.999` is not needed)

The three version keys are **not** the same type on `Microsoft.PowerShell.Commands.ModuleSpecification`:

- `ModuleVersion` (minimum) and `RequiredVersion` (exact) are parsed as `[System.Version]` — **no wildcards**.
- `MaximumVersion` is a **`string`** so it can contain a wildcard. `MaximumVersion = '6.*'` is valid and means "any `6.x`". A sentinel upper bound such as `6.999.999` also works but is unnecessary.

Other rules:

- `RequiredVersion` **cannot** be combined with `ModuleVersion` or `MaximumVersion`. To express a range, use `ModuleVersion` (floor) **and** `MaximumVersion` (ceiling) together.
- A **major lock** needs both bounds: `MaximumVersion = '6.*'` alone still accepts 5.x and below, so pair it with `ModuleVersion = '6.0.0'`.
- `GUID` pins module *identity*, independently of the version. An incorrect GUID blocks even a matching version; omission is allowed. It is a supply-chain control, not part of the version lock (see [Security → Supply chain](../Security.md#supply-chain)).
- Requirements are enforced by the engine at **parse/discovery time**: if no installed module satisfies the specification, the script is not run at all.

## An entry script that reports a verdict imports its modules itself

`#Requires -Modules` declares dependencies for a **test file, a module, or a function library**. Do not use it in an **entry script whose exit code reports a verdict**, such as a test gate, validation script, or hook. The declaration can prevent the process from returning the script's exit code.

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

The script completes and executes its `exit`, but the process returns the wrong exit code. A gate written this way reports success even when its checks fail. [Proving the check can fail](../Testing.md#prove-the-test-can-fail) reveals the error, which is not visible in a passing run.

Import the module instead, with the same range the specification would have carried:

```powershell
Import-Module -Name Pester -MinimumVersion 6.0.0 -MaximumVersion 6.*
```

What was observed, and what was not:

- It reproduces with Pester in name form and hashtable form, with both version `5.8.0` and `6.0.1`. It did **not** reproduce with `PSScriptAnalyzer`, `PSReadLine`, `Microsoft.PowerShell.PSResourceGet`, `Microsoft.PowerShell.Management`, or a temporary module created for the test. These return the script's requested exit code.
- `#Requires -Version` is not involved; only the `-Modules` parameter is.
- `pwsh -Command ". ./gate.ps1"`, the form [GitHub Actions](../GitHub-Actions.md) uses for `shell: pwsh`, collapses every non-zero exit to `1` with or without the declaration. A CI step still fails. The false-success result affects `pwsh -File`, which a person uses to run the script directly.
- The cause of the module-specific behavior is **not known**. The rule identifies a script structure to avoid; it does not explain how `#Requires` works.

The `#Requires -Modules` lines inside `*.Tests.ps1` files stay as they are. Pester runs a test file as a container, not as an entry script, so there is no entry-script exit code to preserve.

## Choosing the tightness (risk appetite)

Match the constraint to the dependency changes the consumer can accept:

- **Modules** — declare a **minimum** by default so security patches remain available. **Major-lock** (`ModuleVersion` + `MaximumVersion = 'N.*'`) a dependency whose next major is incompatible. Avoid **exact** pins. Add a `GUID` only when identity assurance is required.
- **External GitHub Actions / container images** — pin to an immutable **commit SHA** / **digest**, not a moving tag. Organization- or initiative-owned Actions may use the [controlled major-tag exception](../GitHub-Actions.md#pin-actions-according-to-ownership) (see [Security → Supply chain](../Security.md#supply-chain)).
- Keep pins current with automated update PRs — see [Dependency Updates](../../Capabilities/dependency-updates/index.md).

## Proof

The executable Pester test [`tests/Requires-Modules.Tests.ps1`](https://github.com/MSXOrg/docs/blob/main/tests/Requires-Modules.Tests.ps1) covers each row above. It writes a one-line `#Requires` script for each case and runs it in a child PowerShell. It asserts whether the requirement resolves, using the installed Pester as the sample module. The test is independent of the exact `6.x` version.

```powershell
Invoke-Pester -Path ./tests/Requires-Modules.Tests.ps1
```

It proves, among the eleven cases:

- The **major lock** (`ModuleVersion = 'N.0.0'; MaximumVersion = 'N.*'`) resolves to the installed `N.x`.
- The **wildcard ceiling is enforced** — a ceiling below the floor is unsatisfiable (so `6.*` genuinely blocks 7.x).
- An **exact** `RequiredVersion` that is not installed does **not** resolve.
- A **wrong GUID** blocks an otherwise-matching module, while **omitting** the GUID still resolves. Identity is optional and independent of version.
- An **explicit `Import-Module`** returns the script's requested exit code, and a **`#Requires -Modules` declaration does not**. The last three cases run a child script that prints `RAN` and exits `7`. They assert on the child process's actual exit code, so a case cannot pass because the script never ran.
