---
title: Version Constraints
description: "Express module and package version constraints as NuGet version ranges — the canonical notation across PSResourceGet, .NET package references, and (mapped) #Requires and module manifests."
---

# Version Constraints

A version constraint says *which versions of a dependency are acceptable*. PowerShell offers several places to state one — an `Install-PSResource` call, a `#Requires` line, a module manifest, a `.csproj` — and they do not all take the same string. Rather than learn a different dialect for each, express every constraint in **one** notation: the [NuGet version range](https://learn.microsoft.com/nuget/concepts/package-versioning#version-ranges). It is the native syntax of the install tooling ([PSResourceGet](https://learn.microsoft.com/powershell/module/microsoft.powershell.psresourceget/)) and of .NET package references, it follows [SemVer](https://semver.org/), and it makes intent — a floor, a ceiling, an exact pin, a range — explicit and reviewable.

This page is the PowerShell implementation of the [Dependencies](../Dependencies.md) standard: the locking spectrum and the update-velocity-versus-supply-chain-risk balance are argued there; this page is how you express each point of that spectrum in PowerShell. It sits under the [PowerShell standard](index.md), builds on [Security → Supply chain](../Security.md#supply-chain), and pairs with [Dependency Updates](../../Capabilities/dependency-updates/index.md), which keeps pins current.

## The rule

- **State every module or package version constraint as a NuGet version range, in explicit interval brackets** — `[6.0.0, )`, `[6.0.0, 7.0.0)`, `[6.0.0]` — never a bare number.
- **Never write a bare version as a constraint.** A bare `6.0.0` means different things on different surfaces — a *minimum* to .NET package references, but the *exact* required version to PSResourceGet (see [the bare-version trap](#the-bare-version-trap)) — so the same string silently changes meaning. Brackets say one thing everywhere.
- **Choose the lock deliberately** — exact, patch, minor, major, or latest — from the [locking spectrum](#the-locking-spectrum-in-powershell); tighter is safer but slower to update, looser is faster but less vetted. The [Dependencies](../Dependencies.md) standard argues the balance.
- **Declare a compatibility floor in a module** (`ModuleVersion`, `[6.0.0, )`) so you do not over-constrain your consumers; **pin tight what an application or CI installs** for reproducibility, and let the updater move it. Reserve the exact pin for strict reproducibility, not as a way to avoid updates.
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

A square bracket `[ ]` includes the endpoint; a parenthesis `( )` excludes it. Follow the NuGet guidance on ceilings: do not cap a dependency you do not own unless you know of an incompatibility — an unnecessary upper bound holds consumers back from fixes — but *do* bound a dependency whose next major would break you. A test framework such as Pester is the typical case.

## The locking spectrum in PowerShell

PowerShell can express every point of the [locking spectrum](../Dependencies.md#the-locking-spectrum). The module `GUID` is the **identity pin** — orthogonal to the version, it binds to the exact module and combines with any row below; the rest set version tightness, tightest first:

| Lock | NuGet range (PSResourceGet, `PackageReference`) | `#Requires` / `RequiredModules` |
| --- | --- | --- |
| **Identity** | not a version — pins *which* module | add `GUID = '<module-guid>'` to any row |
| **Exact** | `[6.1.2]` | `RequiredVersion = '6.1.2'` |
| **Patch** (any `6.1.x`) | `[6.1.0, 6.2.0)` | `ModuleVersion = '6.1.0'; MaximumVersion = '6.1.*'` |
| **Minor** (any `6.x`) | `[6.0.0, 7.0.0)` | `ModuleVersion = '6.0.0'; MaximumVersion = '6.*'` |
| **Major** (floor, `≥ 6.0.0`) | `[6.0.0, )` | `ModuleVersion = '6.0.0'` |
| **Latest** | omit `-Version`; `*` in `PackageReference` | a bare name, `@{ ModuleName = 'Pester' }` |

- **Identity + exact** is the tightest — the pin never drifts; the bot proposes each re-pin and a human reviews it. Pair the `GUID` with `RequiredVersion`, or with a lockfile-resolved install, for the strongest supply-chain posture.
- **Patch** and **minor** are the everyday tracks: let fixes (and, for minor, additive features) flow while a new major is held back.
- **Major** — a floor with no ceiling — accepts breaking releases; use it where you actively co-evolve with the dependency, and expect the [updater](../../Capabilities/dependency-updates/index.md) to route those as human-reviewed `update:major` pull requests.
- **Latest** pulls whatever is newest, unvetted and non-reproducible — avoid it for anything shipped or run in CI (see [Dependencies → the balance](../Dependencies.md#the-balance)).

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

PSResourceGet diverges from NuGet on one point: a **bare version is treated as the exact required version, not a minimum**. `Install-PSResource -Name Pester -Version '6.0.0'` installs *only* `6.0.0` — it will not accept `6.0.1`. To get a minimum you must write the range, `-Version '[6.0.0, )'`. This is exactly why the rule forbids bare versions: always use brackets, and the constraint reads the same on every surface.

### Building — .NET package references

A binary module, or a build or test project, references NuGet packages with the same range syntax in `PackageReference`:

```xml
<PackageReference Include="YamlDotNet" Version="[16.0.0, 17.0.0)" />
```

Here a bare `Version="16.0.0"` is a *minimum* — NuGet's own semantics — the mirror image of the PSResourceGet trap: the very same string means "minimum" to the build and "exact" to the installer. Brackets remove the ambiguity.

## `#Requires` and module manifests

`#Requires -Modules` and a manifest's `RequiredModules` do **not** accept a NuGet range string. They take a [module-specification hashtable](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_requires) whose keys are typed: `ModuleVersion` (minimum) and `RequiredVersion` (exact) parse as `[version]`, while `MaximumVersion` is a string that also accepts the `N.*` wildcard. The [spectrum table](#the-locking-spectrum-in-powershell) gives the keys for each lock, and [Module Requirements](Requires-Modules.md) is the full reference with an executable proof; the rules that constrain them:

- `RequiredVersion` cannot be combined with `ModuleVersion` or `MaximumVersion`. A range needs the floor **and** ceiling keys together; the exact pin stands alone.
- `MaximumVersion` is **inclusive** and understands the `N.*` wildcard, so a major lock is `MaximumVersion = '6.*'` — every `6.x`, nothing in `7` — with no `6.999.999` sentinel.
- The module `GUID` pins **identity**, orthogonal to the version: a supply-chain control, not part of the version constraint (see [Security → Supply chain](../Security.md#supply-chain)). Add it to any lock.
- The `#Requires -Version` statement and a manifest's `PowerShellVersion` are **not** package ranges — each is a single minimum engine version (we target PowerShell 7). Leave them as a bare version: `#Requires -Version 7.0`.

## Not a version range — pin by digest

Ranges are for packages resolved from a gallery. Dependencies that are not gallery packages are pinned differently: **GitHub Actions and container images pin to an immutable commit SHA or image digest** — an [identity pin](../Dependencies.md#two-decisions-two-axes) — never a moving tag or a range. See [Security → Supply chain](../Security.md#supply-chain) and [GitHub Actions](../GitHub-Actions.md).
