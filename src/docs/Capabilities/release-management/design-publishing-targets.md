---
title: Publishing Targets
description: The contract every publishing destination documents, with GitHub Releases as the reference target.
---

# Release Management — Publishing Targets

A **publishing target** is any destination that accepts a versioned artifact and serves it to consumers. The [release pipeline](design.md#the-pipeline) publishes to targets through one contract, so the process is the same whether a repository has one destination or five.

This page holds the contract and the targets that satisfy it. It is the boundary that lets a new destination be added without touching the [spec](spec.md).

## The contract

A target is described by six answers. They are the questions the release process needs answered in order to publish safely, and they are the questions that differ between destinations:

| Dimension | What it settles |
| --- | --- |
| **Version scheme** | the exact string form a version takes, and what the target accepts as valid |
| **Prerelease representation** | how a prerelease is expressed, and how the target sorts it relative to stable versions |
| **Immutability** | whether a published version can be replaced, and what happens on a repeated publish of the same version |
| **Unpublish** | whether a version can be withdrawn, what withdrawal does to existing consumers, and whether the version number becomes reusable |
| **Sliding tags** | whether the target supports mutable pointers such as `latest`, and how they are moved |
| **Release record** | where the durable, linkable evidence of the release lives |

A target MUST document all six before it is used. An undocumented dimension is a surprise waiting for the first failed release — most often around immutability, where publishing the same version twice is a success on one target and a hard error on another.

## Target summary

| Target | Version scheme | Prerelease | Immutable | Unpublish | Sliding tags | Release record |
| --- | --- | --- | --- | --- | --- | --- |
| **GitHub Releases** | `vMAJOR.MINOR.PATCH` git tag | SemVer suffix, flagged as prerelease | tag and assets are treated as immutable | delete is possible; treated as exceptional | yes — git tags | the Release itself |
| **PowerShell Gallery** | `MAJOR.MINOR.PATCH` module version | SemVer suffix on the module version | yes — a version is published once | unlist only; the version is never reusable | no | the gallery listing |
| **VS Code Marketplace** | `MAJOR.MINOR.PATCH` extension version | separate prerelease channel on the same version line | yes | unpublish removes the extension version | channel acts as the pointer | the marketplace listing |
| **NuGet** | `MAJOR.MINOR.PATCH` package version | SemVer suffix on the package version | yes | unlist only; the version is never reusable | no | the package listing |
| **Container registry** | `<image>:<version>` plus a content digest | SemVer suffix in the tag | the **digest** is immutable; the tag is not | tag or manifest deletion | yes — mutable tags | the digest |

Two patterns run through the table and shape how consumers are told to pin:

- **Version numbers are single-use.** On every target above, a published version number is spent. Withdrawal removes availability, not the reservation. A fix is therefore always a new version — never a re-publish of the old one, which is the same conclusion the pipeline reaches from [build-once](design.md#the-pipeline).
- **Only content addresses are truly immutable.** Where a target offers both a name and a digest, the digest is the reference and the name is the convenience.

## GitHub Releases — the reference target

GitHub Releases is the reference implementation: every repository governed by this capability publishes there, and a repository with no external artifact publishes there *only*. A target-specific concern is described relative to this one.

- **Version scheme.** A git tag `vMAJOR.MINOR.PATCH` on the release-branch commit. The tag is the artifact for Action, workflow, and source-distributed module repositories.
- **Prerelease.** The SemVer prerelease suffix, with the Release marked as a prerelease so it is excluded from *latest*.
- **Immutability.** The tag points at one commit and is not moved. Assets are uploaded once. A published version is never rewritten in place.
- **Unpublish.** A Release and its tag can be deleted, but doing so breaks consumers that resolved it, so it is reserved for a release that must not exist — a leaked secret, a legal removal — and the version number is not reused.
- **Sliding tags.** Supported as additional git tags, subject to the [sliding-tag rules](design.md#sliding-tags).
- **Release record.** The Release itself: the version as its name, the release note as its body, and the immutable reference to whatever was published elsewhere.

Because every release produces a GitHub Release, it is also the **join point** across targets: a release published to a registry or marketplace records its reference there, so one link answers *what shipped, in what version, and where it went*.

## Adding a target

1. Document the six contract dimensions above, in the summary table.
2. Confirm the target's immutability and prerelease behaviour are compatible with [SemVer](https://semver.org/) ordering. Where the target's native convention differs, the mapping is stated rather than assumed.
3. Add the publish step. It receives the already-built artifact and the already-resolved version, and it MUST be idempotent: publishing a version the target already holds is a success.
4. Include the target in the [all-or-nothing](design.md#publishing-targets) set, so a version cannot be present on some destinations and absent from others.

The spec does not change. That is the purpose of the contract.

## Where this connects

- [Spec](spec.md) — the requirements this design serves.
- [Design](design.md) — the pipeline that publishes to these targets.
- [Security](../../Coding-Standards/Security.md#supply-chain) — why consumers pin to immutable references.
