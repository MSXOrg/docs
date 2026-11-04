---
title: Dependencies
description: How dependencies are pinned and kept current — the locking spectrum from identity pins to floating latest, and the balance between update velocity and supply-chain exposure.
---

# Dependencies

Every consumed dependency adds useful functionality and becomes part of the [attack surface](Security.md#supply-chain). Examples include PowerShell modules, GitHub Actions, container base images, .NET packages, and Terraform providers. Decide **how tightly to pin it** and **how to update it**. Pinning determines acceptable version drift. The update policy determines how new versions arrive.

This is the ecosystem-agnostic standard; the per-tool standards apply it. [PowerShell → Version Constraints](PowerShell/Version-Constraints.md) expresses it for modules and packages, and [GitHub Actions → Pin actions according to ownership](GitHub-Actions.md#pin-actions-according-to-ownership) expresses it for Actions and reusable workflows. The [Dependency Updates](../Capabilities/dependency-updates/index.md) capability is the automation that keeps pins current.

## Two decisions, two axes

A pin has two independent parts; keep them separate.

- **Identity** — *which* artifact, proven. A name alone can be squatted, re-tagged, or repointed at new code, so an **identity pin** binds to immutable bytes: a module `GUID`, an Action or commit **SHA**, an image **digest**. It answers "is this the exact thing that was vetted?" and is orthogonal to the version.
- **Version tightness** — *which versions* of that artifact are acceptable, from an exact pin to floating latest.

The strongest control combines a verified identity **and** a deliberate version. Identity controls integrity. Version tightness controls the update velocity and risk described below.

Before you choose a pin, decide whether the dependency is needed. For modules and libraries built here, the default is to **avoid introducing a new third-party dependency when the capability can reasonably be implemented with PowerShell, the .NET base class library, or owned code**. Each external DLL, package, or module adds an update stream, trust boundary, and failure mode for the module's lifetime. Accept more implementation work when it reduces shipped dependencies and clarifies ownership.

## The locking spectrum

From tightest to loosest, each step trades safety for speed:

| Lock | What can change | Update velocity | Supply-chain exposure | Reproducible |
| --- | --- | --- | --- | --- |
| **Identity + exact** (`GUID` / SHA / digest, exact version) | Nothing until you re-pin | Only via a reviewed re-pin PR | **Lowest** — each change is reviewed | Yes |
| **Controlled owned major** (`@v8`) | Compatible stable releases from organization- or initiative-owned automation | Patch and minor releases roll out centrally | Low when only controlled release automation can move the tag | No |
| **Patch** (`x.y.*`) | Fix-level releases | Fixes arrive | Low | With a lockfile |
| **Minor** (`x.*`) | Additive features and fixes | Features and fixes arrive | Moderate | With a lockfile |
| **Major** (floor only, `>= x`) | Any version at or above the floor, including breaking releases | All eligible releases arrive | Higher | With a lockfile |
| **Latest / floating** (unpinned, `*`, a moving tag) | Anything, immediately | Immediate | **Highest** — newest code runs before anyone sees it | No |

## The balance

Both very loose pins and exact pins without updates create risk.

- **Too loose** (toward latest) maximizes update velocity but lets upstream releases change consumed code without review. A published version, including a **compromised** one, can run before consumer review. Builds stop being reproducible when two runs resolve different code. A malicious release or compromised package can therefore enter the build automatically.
- **Too tight** (an exact pin that never updates) maximizes version control but excludes later bug and **security** fixes. A disclosed advisory can identify a vulnerability in the pinned version. The old pin then delays adoption of the fix.

The required approach is to **control integrity and automate updates**, rather than select a pin and never change it:

1. **Pin tightly by default** — an identity pin plus a deliberate version, or a lockfile — so every build is reproducible and nothing changes unvetted. A controlled owned-major tag is the narrow exception for automation whose release path the organization or initiative operates.
2. **Automate updates** rather than depend on manual monitoring of upstream releases. The [Dependency Updates](../Capabilities/dependency-updates/index.md) bot opens one reviewed pull request per bump.
3. **Gate every update through CI and review.** Every update passes the repository's normal merge policy. Raise security advisories separately and prioritize them. After related changes are collected, resolve the repository release decision under [Release Management](../Capabilities/release-management/design.md) when the target route invokes it.

Automated updates keep tightly pinned dependencies current. CI and review verify each update. A controlled owned-major tag applies the same principle at the producer. Compatible releases pass the controlled release gate, then the major pointer distributes them centrally. This trades consumer-level reproducibility for coordinated rollout and is never valid for an external dependency.

## Update tracks — who each is for, and whether you need it

A "track" defines the updates a dependency can accept. You do **not** need every track in every repository. Choose one per dependency based on its source, compatibility risk, and consumer role.

| Track | Fits a dependency that… | Typical handling |
| --- | --- | --- |
| **Identity + exact** | runs with privilege or has a wide blast radius (Actions, base images), or must be byte-for-byte reproducible | the bot still opens the re-pin PR, but a human reviews every one — never auto-merged |
| **Controlled owned major** | is an Action or reusable workflow owned by the organization or initiative, with a compatible release line and centrally controlled release automation | release automation alone advances the major tag for patch and minor releases; a fleet campaign moves consumers to a breaking major |
| **Patch** | is trusted and whose patches are fixes you always want (most dependencies) | merge through the normal repository gate |
| **Minor** | is trusted and whose additive releases are safe to absorb | merge through the normal repository gate |
| **Major** | you actively co-evolve with and can absorb breaking changes for | human review before merge |
| **Latest / floating** | is used only for an ephemeral local experiment, never shipped or run in CI | not for shipped or CI-run code |

The consumer role and control of the source determine the mix:

- **Library or application.** A **library**, such as a module or Action others consume, declares the *widest range it is compatible with*. It usually declares a floor, rarely a ceiling, so consumers can select supported versions. An **application or end artifact**, such as a workflow, deployable, or CI pipeline, pins external dependencies to *exact resolved versions*. This provides reproducibility, while the updater supplies later versions. The controlled owned-major exception trades consumer-level reproducibility for central rollout only where the producer and release path are owned.
- **Source control and impact.** External sources stay toward identity + exact regardless of reputation. Owned automation may use a controlled major only when the organization or initiative operates the release gate and accepts the central rollout's impact.

The ecosystem default is to **identity-pin external code that runs (SHAs, digests)**. **Use controlled major tags only for owned automation. Libraries declare compatible version floors, and shipped artifacts use lockfiles. The [updater](../Capabilities/dependency-updates/index.md) opens reviewed pull requests.** Floating latest is unsuitable for shipped or CI-run code.

## Where this is implemented

- [PowerShell → Version Constraints](PowerShell/Version-Constraints.md) — the spectrum in NuGet version-range syntax and `#Requires` module specifications, including the module `GUID` identity pin.
- [GitHub Actions → Pin actions according to ownership](GitHub-Actions.md#pin-actions-according-to-ownership) and [Keep pinned actions current](GitHub-Actions.md#keep-pinned-actions-current) — immutable external SHA pins and controlled major tags for owned automation.
- [Security → Supply chain](Security.md#supply-chain) — why dependencies are attack surface.
- [Dependency Updates](../Capabilities/dependency-updates/index.md) — the automation that opens, labels, and routes the update pull requests.
