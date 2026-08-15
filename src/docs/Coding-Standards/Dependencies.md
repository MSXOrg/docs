---
title: Dependencies
description: How dependencies are pinned and kept current — the locking spectrum from identity pins to floating latest, and the balance between update velocity and supply-chain exposure.
---

# Dependencies

Every consumed dependency — a PowerShell module, a GitHub Action, a container base image, a .NET package, a Terraform provider — is both a convenience and part of the [attack surface](Security.md#supply-chain). Depending on one is a single decision made twice: **how tightly to pin it** (how much version drift is acceptable) and **how it moves forward** (how new versions arrive). Getting the balance wrong in either direction has a cost.

This is the ecosystem-agnostic standard; the per-tool standards apply it. [PowerShell → Version Constraints](PowerShell/Version-Constraints.md) expresses it for modules and packages, and [GitHub Actions → Pin actions according to ownership](GitHub-Actions.md#pin-actions-according-to-ownership) expresses it for Actions and reusable workflows. The [Dependency Updates](../Capabilities/dependency-updates/index.md) capability is the automation that keeps pins current.

## Two decisions, two axes

A pin has two independent parts; keep them separate.

- **Identity** — *which* artifact, proven. A name alone can be squatted, re-tagged, or repointed at new code, so an **identity pin** binds to immutable bytes: a module `GUID`, an Action or commit **SHA**, an image **digest**. It answers "is this the exact thing that was vetted?" and is orthogonal to the version.
- **Version tightness** — *which versions* of that artifact are acceptable, from an exact pin to floating latest.

The strongest posture combines both: a verified identity **and** a deliberate version. Identity is the integrity control; tightness is the velocity-versus-risk control below.

Before choosing a pin, decide whether the dependency belongs at all. For modules and libraries built here, the default is to **avoid introducing a new third-party dependency when the capability can reasonably be implemented with PowerShell, the .NET base class library, or owned code**. Every external DLL, package, or module adds another update stream, trust boundary, and failure mode to carry for the lifetime of the module. Spend a bit more effort up front if that keeps the shipped surface smaller and the ownership clearer.

## The locking spectrum

From tightest to loosest, each step trades safety for speed:

| Lock | What can change | Update velocity | Supply-chain exposure | Reproducible |
| --- | --- | --- | --- | --- |
| **Identity + exact** (`GUID` / SHA / digest, exact version) | Nothing until you re-pin | Only via a reviewed re-pin PR | **Lowest** — nothing lands unvetted | Yes |
| **Controlled owned major** (`@v8`) | Compatible stable releases from organization- or initiative-owned automation | Patch and minor releases roll out centrally | Low when only controlled release automation can move the tag | No |
| **Patch** (`x.y.*`) | Fix-level releases | Fixes flow in | Low | With a lockfile |
| **Minor** (`x.*`) | Additive features and fixes | Features and fixes flow in | Moderate | With a lockfile |
| **Major** (floor only, `>= x`) | Anything from the floor up, including breaking releases | Everything flows in | Higher | With a lockfile |
| **Latest / floating** (unpinned, `*`, a moving tag) | Anything, immediately | Immediate | **Highest** — newest code runs before anyone sees it | No |

## The balance

Both ends are a risk; the standard is to avoid living at either extreme.

- **Too loose** (toward latest) maximizes velocity but hands control to the upstream. A newly published version — including a **compromised** one — runs before anyone reviews it, and the build stops being reproducible because two runs resolve different code. This is the classic supply-chain attack path: a malicious release, or a taken-over package, that lands automatically because nothing gated it.
- **Too tight** (a bare exact pin, never moved) maximizes control but rots. The dependency keeps shipping bug and **security** fixes you never take; a disclosed advisory turns yesterday's safe pin into today's vulnerability, and now the exact pin is the very thing stopping you from patching fast enough.

The resolution is not to pick a point and freeze — it is to **control integrity and automate the movement**:

1. **Pin tightly by default** — an identity pin plus a deliberate version, or a lockfile — so every build is reproducible and nothing changes unvetted. A controlled owned-major tag is the narrow exception for automation whose release path the organization or initiative operates.
2. **Automate updates** so currency never depends on a human watching upstream: the [Dependency Updates](../Capabilities/dependency-updates/index.md) bot opens one reviewed pull request per bump.
3. **Gate every update through CI and review** — patch and minor updates auto-merge on green checks; **major** updates require a human; security advisories are raised out of band and prioritized.

Tight pinning is safe *because* the updates are automated: the bot closes the currency gap and CI plus review close the vetting gap. A controlled owned-major tag applies the same principle at the producer: compatible releases pass the controlled release gate once, then the major pointer rolls them out centrally. It trades consumer-level reproducibility for coordinated rollout and is never valid for an external dependency.

## Update tracks — who each is for, and whether you need it

A "track" is how a given dependency is allowed to move. You do **not** need every track in every repository; choose one per dependency from what the source is, what it can break, and where you sit.

| Track | Fits a dependency that… | Typical handling |
| --- | --- | --- |
| **Identity + exact** | runs with privilege or has a wide blast radius (Actions, base images), or must be byte-for-byte reproducible | the bot still opens the re-pin PR, but a human reviews every one — never auto-merged |
| **Controlled owned major** | is an Action or reusable workflow owned by the organization or initiative, with a compatible release line and centrally controlled release automation | release automation alone advances the major tag for patch and minor releases; a fleet campaign moves consumers to a breaking major |
| **Patch** | is trusted and whose patches are fixes you always want (most dependencies) | auto-merge on green CI |
| **Minor** | is trusted and whose additive releases are safe to absorb | auto-merge on green CI (a repo may require review) |
| **Major** | you actively co-evolve with and can absorb breaking changes for | always human-reviewed |
| **Latest / floating** | is throwaway — an ephemeral local experiment, never shipped or run in CI | not for shipped or CI-run code |

Two questions decide the mix:

- **Are you a library or an application?** A **library** — a module or Action others consume — declares the *widest range it is compatible with* (a floor, rarely a ceiling) so it does not over-constrain its consumers. An **application or end artifact** — a workflow, a deployable, a CI pipeline — pins external dependencies to *exact resolved versions* for reproducibility and relies on the updater to move them. The controlled owned-major exception trades that consumer-level reproducibility for central rollout only where the producer and release path are owned.
- **How much control do you have over the source and release path, and how large is the blast radius?** External sources stay toward identity + exact regardless of reputation. Owned automation may use a controlled major only when the organization or initiative operates the release gate and accepts the central rollout blast radius.

The healthy default across the ecosystem: **identity-pin external code that runs (SHAs, digests), use controlled major tags only for owned automation, floor-declare what you are a library for, lockfile-pin what you ship, and let the [updater](../Capabilities/dependency-updates/index.md) auto-merge patch and minor while a human reviews major.** Floating latest remains unsuitable for shipped or CI-run code.

## Where this is implemented

- [PowerShell → Version Constraints](PowerShell/Version-Constraints.md) — the spectrum in NuGet version-range syntax and `#Requires` module specifications, including the module `GUID` identity pin.
- [GitHub Actions → Pin actions according to ownership](GitHub-Actions.md#pin-actions-according-to-ownership) and [Keep pinned actions current](GitHub-Actions.md#keep-pinned-actions-current) — immutable external SHA pins and controlled major tags for owned automation.
- [Security → Supply chain](Security.md#supply-chain) — why dependencies are attack surface.
- [Dependency Updates](../Capabilities/dependency-updates/index.md) — the automation that opens, labels, and routes the update pull requests.
