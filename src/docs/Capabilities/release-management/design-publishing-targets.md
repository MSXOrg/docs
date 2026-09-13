---
title: Publishing Targets
description: Destination contracts for version mapping, prereleases, immutability, withdrawal, aliases, constraints, and release records.
---

# Release Management — Publishing Targets

A **publishing target** accepts a versioned artifact or release record and makes
it available to consumers. The [release lifecycle](design.md#build-verify-and-publish)
passes every target the same frozen version, retained artifact, note envelope,
and release-intent identity.

Targets differ in native version syntax, prerelease channels, deletion, and
consumer resolution. This page makes those differences explicit so adding a
destination does not change the [release-management specification](spec.md).

## Publishing-target contract

Every target documents seven dimensions:

| Dimension | What it settles |
| --- | --- |
| **Version scheme** | The native coordinate and its one-to-one mapping from canonical SemVer. |
| **Prerelease representation** | How prerelease identity and ordering map to the target's syntax or channel. |
| **Immutability** | Which reference cannot change and what a repeated publication does. |
| **Withdrawal** | The strongest supported hide, unlist, yank, or delete operation and whether existing consumers retain access. |
| **Alias families** | Whether `latest`, major, or minor moving references can be represented and reconciled. |
| **Version constraints** | Whether consumers can express native ranges or need a producer-controlled alias. |
| **Release record** | Where the durable, linkable destination evidence is stored. |

A target MUST answer all seven before it is enabled. It MUST also define:

- how an idempotent retry verifies that an existing coordinate identifies the
  recorded artifact;
- whether target-native state can be read back after publication;
- how canonical stable or prerelease state maps to target-native state; and
- which evidence proves publication or withdrawal.

Distinct canonical releases MUST NOT map to one native coordinate. A collision
or stable/prerelease mismatch fails before publication. Target deletion never
frees a canonical version or prerelease identifier for reuse.

## Target summary

| Target | Version scheme | Prerelease | Immutable reference | Withdrawal | Alias families | Native constraints | Release record |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **GitHub Releases** | Exact `vMAJOR.MINOR.PATCH` or prerelease tag | SemVer suffix and native prerelease flag | Protected exact tag, source commit, and asset digest | Delete or mark unavailable; coordinate remains reserved | `latest`, major, minor as optional Git tags; native Latest separately | No range resolver | GitHub Release and durable release intent |
| **PowerShell Gallery** | `MAJOR.MINOR.PATCH` module version | SemVer suffix | Published module version | Unlist; downloads already held remain; version is not reusable | None | NuGet ranges through PSResourceGet; mapped manifest constraints | Gallery listing joined from GitHub Release |
| **NuGet** | `MAJOR.MINOR.PATCH` package version | SemVer suffix | Published package version and package hash | Unlist or deprecate; version is not reusable | None | NuGet version ranges | Package listing joined from GitHub Release |
| **VS Code Marketplace** | Marketplace-compatible extension version mapped from canonical SemVer | Separate prerelease channel and flag | Published extension version | Unpublish where permitted; version is not reusable | Native stable/prerelease channel selection, not release aliases | No consumer-selected SemVer range | Marketplace listing joined from GitHub Release |
| **Container registry** | Version tag plus content digest | SemVer suffix in exact tag | Manifest or image digest | Delete tag or manifest where permitted; reservation remains | `latest`, major, minor as optional tags | No range resolver | Registry digest joined from GitHub Release |

Two rules apply to every row:

- **Coordinates are single-use.** Withdrawal changes availability or
  recommendation, not ownership. A corrected artifact always receives a new
  version.
- **Completion is an outcome, not a claim of transactional publication.** One
  target may expose content before another fails. Durable per-target progress
  keeps the release incomplete until all required targets succeed, then lets a
  retry resume safely.

## GitHub Releases

GitHub Releases is the reference target and the cross-target join point. Every
repository governed by this capability creates a GitHub Release; a repository
with no external artifact publishes there only. External target coordinates and
evidence are linked from the same release record.

### GitHub version and prerelease mapping

Stable versions use an exact tag:

```text
vMAJOR.MINOR.PATCH
```

Prereleases preserve the canonical suffix:

```text
vMAJOR.MINOR.PATCH-series.N
```

The Release's native prerelease flag MUST agree with the canonical version.
GitHub's native **Latest** selection is advertising state, not release authority.
It is updated only after durable completion and MUST NOT include prereleases or
withdrawn releases.

### GitHub immutability

An exact version tag identifies the fixed source revision. Assets are uploaded
from the retained artifact and verified by fingerprint. A repeated publish is
successful only when the existing tag, assets, and release record match the
frozen release intent.

Repositories enable GitHub's immutable-release protection where the platform
supports it. Shared automation reconciles and verifies that setting rather than
assuming repository policy remained unchanged. Until setting reconciliation is
implemented, exact tags and assets remain immutable by MSX policy but lack the
full intended platform enforcement.

### GitHub withdrawal

GitHub permits a Release and tag to be deleted, but deletion does not erase
clones, caches, downloads, or durable lifecycle history. The withdrawal record
therefore remains authoritative and the version remains permanently reserved.
Deletion is used only where the approved withdrawal operation and repository
policy require it.

Replaying a withdrawn intent does not recreate the Release or tag. Current
discovery and native Latest are reconciled to the greatest remaining eligible
completed stable release.

### GitHub aliases and constraints

Optional Git tags represent the closed `latest`, major, and minor alias families.
They are separate from exact version tags and can move only through
[alias reconciliation](design.md#current-version-discovery-and-aliases).
Consumers must explicitly accept moved owned tags; see
[Accept moved release tags](accept-moved-release-tags.md).

Git references do not resolve SemVer range expressions. A major or minor
boundary therefore requires the corresponding producer alias. External
consumers use an exact commit SHA or another immutable fingerprint rather than a
moving tag.

### GitHub release record

The GitHub Release contains the contributor-authored note, publication envelope,
fixed source, and links to every destination coordinate. The durable release
intent remains the authority for lifecycle state, including partial publication,
retirement, withdrawal, alias reconciliation, and announcements.

## PowerShell Gallery

### PowerShell Gallery version and prerelease mapping

The module manifest and gallery coordinate use canonical SemVer without the
leading `v`. A prerelease suffix is retained where the gallery and module
manifest permit it. Mapping validation runs before publication so a native
version cannot collide with another canonical release.

### PowerShell Gallery immutability and withdrawal

A published module version is immutable. Retrying succeeds only when the
existing listing and package hash identify the recorded artifact. The gallery
supports unlisting rather than reclaiming a version; existing consumers and
caches can still hold it, and the coordinate remains permanently reserved.

### PowerShell Gallery aliases and constraints

The gallery does not offer producer-controlled moving release aliases.
PSResourceGet accepts NuGet version ranges, and module manifests map supported
bounds into their native fields. Consumers follow
[PowerShell Version Constraints](../../Coding-Standards/PowerShell/Version-Constraints.md)
rather than placing a range-like string in a field that accepts only one
version.

### PowerShell Gallery release record

The gallery listing and package hash are recorded as destination evidence. The
GitHub Release links the gallery coordinate to the canonical source, notes, and
cross-target release intent.

## NuGet

### NuGet version and prerelease mapping

The package version uses canonical SemVer without a leading `v`, including its
prerelease suffix. The adapter rejects any normalization or server behavior that
would make two canonical identifiers address one native package version.

### NuGet immutability and withdrawal

A published package version is immutable and single-use. An idempotent retry
checks the existing package hash. NuGet unlisting or deprecation changes
discovery and guidance but does not remove packages already restored, and the
version remains reserved.

### NuGet aliases and constraints

NuGet has no producer-controlled moving alias for package versions. Consumers
express supported movement with native
[NuGet version ranges](../../Coding-Standards/PowerShell/Version-Constraints.md).
An exact package version remains the immutable release coordinate.

### NuGet release record

The package listing, content hash, and withdrawal or deprecation state are
destination evidence. The GitHub Release is the human-readable join point.

## VS Code Marketplace

The [VS Code Extension Framework design](../vscode-extension-framework/design.md)
owns the detailed VSIX and marketplace behavior.

### VS Code Marketplace version and prerelease mapping

Stable extension versions map directly to the marketplace-compatible version in
the VSIX manifest. The marketplace represents prereleases through its separate
prerelease channel and `--pre-release` publication flag, including the
framework's odd-minor convention. The adapter records the canonical prerelease
and native extension version together and MUST guarantee a one-to-one mapping.

### VS Code Marketplace immutability and withdrawal

A published extension version is immutable and single-use. Marketplace
unpublication is applied where permitted, but cannot recall installed VSIX
files or make the canonical version reusable.

### VS Code Marketplace aliases and constraints

Stable and prerelease marketplace channels influence update discovery but are
not the release-management `latest`, major, or minor alias families. The
marketplace does not expose consumer-selected SemVer ranges for extension
updates. Consumers that need an exact immutable artifact use the VSIX attached
to the GitHub Release.

### VS Code Marketplace release record

The marketplace listing and native channel state are destination evidence. The
GitHub Release always contains the same VSIX and joins the canonical release to
optional Marketplace or Open VSX publication.

## Container registries

### Container registry version and prerelease mapping

An exact canonical version maps to an image tag, while the published manifest or
image digest identifies immutable content. Prerelease suffixes remain part of
the exact version tag.

### Container registry immutability and withdrawal

Registry tags are mutable; digests are not. Publication records both and treats
the digest as artifact identity. An idempotent retry succeeds only when the
exact version tag resolves to the recorded digest. Deleting a tag or manifest
does not free the canonical release version or prove that cached content
disappeared.

### Container registry aliases and constraints

Optional tags can implement the `latest`, major, and minor alias families.
Reconciliation updates each enabled tag to the digest of the greatest eligible
matching release. Container references do not evaluate SemVer ranges, so
consumers use a controlled producer alias inside the allowed trust boundary or
pin a digest.

### Container registry release record

The registry digest and exact tag are destination evidence. The GitHub Release
links that digest to source, notes, verification, and lifecycle state.

## Adding a target

1. Document all seven contract dimensions and add the target to the summary.
2. Define a total, collision-free mapping from canonical stable and prerelease
   versions to native coordinates and flags.
3. Define the immutable identity and read-back check used by idempotent retry.
4. Define the strongest supported withdrawal behavior and its limitations.
5. State which, if any, alias families and native constraints consumers can use.
6. Define publication, withdrawal, and reconciliation evidence.
7. Add the adapter to the required destination set so durable completion and
   phase-aware recovery include it.

The target receives an already built and verified artifact. It does not choose a
version, rebuild content, rewrite the note snapshot, or mark the overall release
complete by itself.

## Where this connects

- [Spec](spec.md) — the normative release and target requirements.
- [Design](design.md) — durable state, publication, recovery, discovery, and
  consumer policy.
- [Accept moved release tags](accept-moved-release-tags.md) — local Git
  configuration for consumers of owned aliases.
- [Security](../../Coding-Standards/Security.md#supply-chain) — immutable
  references and supply-chain controls.
