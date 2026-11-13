---
title: Version Constraints
description: "Express module and package version constraints as NuGet version ranges — the canonical notation across PSResourceGet, .NET package references, and (mapped) #Requires and module manifests."
---

# Version Constraints

A version constraint specifies which dependency versions are acceptable. PowerShell exposes several interfaces: an `Install-PSResource` call, a `#Requires` line, a module manifest, or a `.csproj`. These interfaces do not all accept the same string. Express constraints in **one** notation: the [NuGet version range](https://learn.microsoft.com/nuget/concepts/package-versioning#version-ranges). The install tooling ([PSResourceGet](https://learn.microsoft.com/powershell/module/microsoft.powershell.psresourceget/)) and .NET package references use it natively. It follows [SemVer](https://semver.org/) and makes minimums, maximums, exact pins, and ranges explicit for review.

The [Dependencies](../Dependencies.md) standard defines the locking spectrum and the balance between update speed and supply-chain risk. PowerShell constraint syntax extends the [PowerShell standard](index.md), builds on [Security → Supply chain](../Security.md#supply-chain), and pairs with [Dependency Updates](../../Capabilities/dependency-updates/index.md) for pin maintenance.

## The rule

- **State every module or package version constraint as a NuGet version range, in explicit interval brackets** — `[6.0.0, )`, `[6.0.0, 7.0.0)`, `[6.0.0]` — never a bare number.
- **Never write a bare version as a constraint.** A bare `6.0.0` means different things on different interfaces. It is a *minimum* for .NET package references but the *exact* required version for PSResourceGet (see [the bare-version trap](#the-bare-version-trap)). Brackets keep the meaning consistent.
- **Choose the lock deliberately** — exact, patch, minor, major, or latest — from the [locking spectrum](#the-locking-spectrum-in-powershell). Tighter constraints favor safety over update speed; looser constraints favor update speed with less validation. The [Dependencies](../Dependencies.md) standard explains the balance.
- **Declare a compatibility floor in a module** (`ModuleVersion`, `[6.0.0, )`) so you do not over-constrain your consumers. **Use strict pins for application and CI installs** for reproducibility, and let the updater change the pins. Reserve the exact pin for strict reproducibility, not as a way to avoid updates.
- **Keep pins current** with automated update pull requests — see [Dependency Updates](../../Capabilities/dependency-updates/index.md).

## NuGet version-range syntax

The interval notation, from the [NuGet reference](https://learn.microsoft.com/nuget/concepts/package-versioning#version-ranges):

| Range | Meaning | Notes |
| --- | --- | --- |
| `[6.0.0, )` | `x ≥ 6.0.0` | minimum, inclusive — **the default** |
| `(6.0.0, )` | `x > 6.0.0` | minimum, exclusive |
| `[6.0.0]` | `x = 6.0.0` | exact pin |
| `(, 6.0.0]` | `x ≤ 6.0.0` | maximum, inclusive |
| `(, 6.0.0)` | `x < 6.0.0` | maximum, exclusive |
| `[6.0.0, 7.0.0)` | `6.0.0 ≤ x < 7.0.0` | **major lock** — any `6.x` |
| `[6.0.0, 7.0.0]` | `6.0.0 ≤ x ≤ 7.0.0` | closed range |
| `(6.0.0, 7.0.0)` | `6.0.0 < x < 7.0.0` | open range |

A square bracket `[ ]` includes the endpoint; a parenthesis `( )` excludes it. Follow the NuGet guidance on upper bounds. Do not cap a dependency you do not own unless you know of an incompatibility. An unnecessary upper bound prevents consumers from getting fixes. Set an upper bound when the next major version is incompatible. Test frameworks such as Pester are typical cases.

## The locking spectrum in PowerShell

PowerShell can express every point of the [locking spectrum](../Dependencies.md#the-locking-spectrum). The module `GUID` is the **identity pin**, independently of the version. It checks declared module identity, not package contents or publisher authenticity, and combines with any row below. The remaining rows set version constraints, from strictest to least strict:

| Lock | NuGet range (PSResourceGet, `PackageReference`) | `#Requires` / `RequiredModules` |
| --- | --- | --- |
| **Identity** | not a version; matches declared module identity | add `GUID = '<module-guid>'` to any row |
| **Exact** | `[6.1.2]` | `RequiredVersion = '6.1.2'` |
| **Patch** (any `6.1.x`) | `[6.1.0, 6.2.0)` | `ModuleVersion = '6.1.0'; MaximumVersion = '6.1.*'` |
| **Minor** (any `6.x`) | `[6.0.0, 7.0.0)` | `ModuleVersion = '6.0.0'; MaximumVersion = '6.*'` |
| **Major** (floor, `≥ 6.0.0`) | `[6.0.0, )` | `ModuleVersion = '6.0.0'` |
| **Latest** | omit `-Version`; `*` in `PackageReference` | a bare name, `@{ ModuleName = 'Pester' }` |

- **Identity + exact** is the strictest constraint. The pin does not change until the bot proposes an update and a human reviews it. Pair the `GUID` with `RequiredVersion`, or with a lockfile-resolved install, for the strictest identity and version constraint.
- **Patch** and **minor** are the normal update choices. They accept fixes and, for minor, additive features, but exclude new major versions.
- **Major**, a minimum with no maximum, accepts breaking releases. Use it when the consumer changes with the dependency. Expect the [updater](../../Capabilities/dependency-updates/index.md) to route those pull requests through the normal review gate.
- **Latest** accepts the newest version without prior validation or reproducibility. Avoid it for anything shipped or run in CI (see [Dependencies → the balance](../Dependencies.md#the-balance)).

## Where the range applies directly

### Installing and restoring — PSResourceGet

`Install-PSResource`, `Find-PSResource`, `Save-PSResource`, and `Update-PSResource` take the range on `-Version`, as does the `version` field of a `-RequiredResource` hashtable or a `-RequiredResourceFile` manifest:

```powershell
# any 6.x — the standard shape for a tool that breaks across majors
Install-PSResource -Name Pester -Version '[6.0.0, 7.0.0)' -TrustRepository

# floor only — highest available >= 8.0.0
Install-PSResource -Name Az -Version '[8.0.0, )' -TrustRepository
```

A restore manifest states the same range per resource:

```powershell
@{
    Pester           = @{ version = '[6.0.0, 7.0.0)'; repository = 'PSGallery' }
    PSScriptAnalyzer = @{ version = '[1.22.0, )';     repository = 'PSGallery' }
}
```

#### The bare-version trap

In PSResourceGet, a **bare version means the exact required version, not a minimum**. `Install-PSResource -Name Pester -Version '6.0.0'` installs *only* `6.0.0`; it does not accept `6.0.1`. For a minimum, write the range `-Version '[6.0.0, )'`. Brackets keep the constraint's meaning consistent across interfaces.

### Building — .NET package references

A binary module, or a build or test project, references NuGet packages with the same range syntax in `PackageReference`:

```xml
<PackageReference Include="YamlDotNet" Version="[16.0.0, 17.0.0)" />
```

Here a bare `Version="16.0.0"` is a *minimum* under NuGet semantics. The same bare version means "minimum" to the build and "exact" to PSResourceGet. Brackets remove the ambiguity.

## `#Requires` and module manifests

`#Requires -Modules` and a manifest's `RequiredModules` do **not** accept a NuGet range string. They take a [module-specification hashtable](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_requires) with typed keys. `ModuleVersion` (minimum) and `RequiredVersion` (exact) parse as `[version]`. `MaximumVersion` is a string that also accepts the `N.*` wildcard. The [spectrum table](#the-locking-spectrum-in-powershell) gives the keys for each lock. [Module Requirements](Requires-Modules.md) provides the full reference and executable proof, with these constraints:

- `RequiredVersion` cannot be combined with `ModuleVersion` or `MaximumVersion`. A range needs the floor **and** ceiling keys together; the exact pin stands alone.
- `MaximumVersion` is **inclusive** and understands the `N.*` wildcard, so a major lock is `MaximumVersion = '6.*'` — every `6.x`, nothing in `7` — with no `6.999.999` sentinel.
- The module `GUID` pins **identity**, independently of the version. It is a supply-chain control, not part of the version constraint (see [Security → Supply chain](../Security.md#supply-chain)). Add it to any lock.
- The `#Requires -Version` statement and a manifest's `PowerShellVersion` are **not** package ranges — each is a single minimum engine version (the target is PowerShell 7). Leave them as a bare version: `#Requires -Version 7.0`.

## Not a version range — pin by digest

Ranges are for packages resolved from a gallery. Dependencies that are not gallery packages are pinned differently: **external GitHub Actions and container images pin to an immutable commit SHA or image digest** — an [identity pin](../Dependencies.md#two-decisions-two-axes) — never a moving tag or a range. Organization- or initiative-owned Actions may use the controlled major-tag exception in the [GitHub Actions standard](../GitHub-Actions.md#pin-actions-according-to-ownership). See [Security → Supply chain](../Security.md#supply-chain).
