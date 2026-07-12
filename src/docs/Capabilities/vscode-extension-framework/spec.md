---
title: Spec
description: Requirements for the VS Code extension framework — an opt-in, GitHub-native pipeline that builds, tests, versions, packages, and publishes a VS Code extension from a single settings file.
---

# VS Code Extension Framework — Spec

## Premise

A VS Code extension has a lifecycle that is the same for every extension:
compile the source into a bundle, test it against a real editor, lint and
type-check it, decide its version, package it into a VSIX, and publish that VSIX
so a user can install it. This framework automates that lifecycle end to end. A
contributor focuses on the extension's own code and tests; the framework builds,
tests, versions, packages, and ships it — driven entirely on the GitHub
platform, with no local release ritual. A repository *opts in* to the framework;
it does not re-invent the pipeline. Merging a pull request *is* releasing.

The framework is the VS Code counterpart to the module and container pipelines:
one behaviour, defined once and consumed by every extension repository, so a new
extension inherits a working build-test-release path on day one.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** The pipeline, the version decision, and the extension's configuration are version-controlled workflow and settings — never a GUI action or a hand-run packaging command.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point; its review gate approves the code *and* the release it produces, and the bump label records the versioning decision explicitly.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The lifecycle is the stable core; host versions, the operating-system matrix, and publish targets are extension-specific settings that slot in. A new publish destination is a configured step, not a new pipeline.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The pipeline runs read-only by default; only the stage that cuts the release holds write, and only the scope it needs.

## Scope

Applies to any repository whose released artifact is a **VS Code extension** — a
VSIX package for VS Code and compatible hosts (VS Code Insiders, Cursor,
VSCodium). One test decides applicability: **does merging produce an installable
VS Code extension that something else consumes by version?** If yes, this
capability governs how it is built and shipped.

**In scope:** compiling and bundling the extension, testing it on a real editor
host, linting and type-checking, computing its version, packaging the VSIX,
publishing and distributing that VSIX, keeping the extension's dependencies
current, and building the extension's own documentation.

**Out of scope:** the extension's *features and behaviour* — those belong to the
extension's own spec, in the extension's repository. The generic mechanics of
versioning and cutting a release are governed by
[Release Management](../release-management/spec.md); *which* checks gate a merge
by [Merge Automation](../merge-automation/spec.md); keeping dependencies current
by [Dependency Updates](../dependency-updates/spec.md). A plain Node package that
is not a VS Code extension is not in scope. Documentation for a specific
extension lives in that extension's repository; this capability documents the
framework itself.

## Requirements

- **Opt-in from a template.** A new extension starts from a template repository and inherits the whole pipeline. Adopting the framework is adding a short caller and a settings file, never copying a pipeline into the repo.
- **A single settings file with secure, working defaults.** Behaviour is configured in one version-controlled settings file. Zero configuration MUST produce a correct build, test, and VSIX; every setting defaults to a secure, sensible value and is overridable in that one place.
- **A reproducible, self-contained bundle.** The extension is compiled into a single self-contained bundle with no unbundled runtime dependencies; the same commit always produces the same output.
- **Tested on a real host.** The extension is tested against a real VS Code host, across the host versions and operating systems the extension declares as supported. Tests exercise the exact bundle that ships — never a separately compiled copy.
- **A static quality gate.** Every change is linted and type-checked, and the pipeline holds on any error. Quality is validated at pull-request time, not after merge.
- **Built once, shipped once.** The version is computed once, stamped into the manifest, and the same packaged VSIX is what is tested and what is published. Build, test, and release MUST NOT diverge.
- **Label-driven, semantic versioning.** Versioning follows [Release Management](../release-management/spec.md): the bump is a pull-request label (`Major` / `Minor` / `Patch` / `NoRelease`, defaulting to `Patch`), the version is [SemVer](https://semver.org/), and it is derived automatically — never hand-edited in the manifest.
- **An installable artifact on every release.** Each release produces an installable VSIX attached to its [GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases), together with an immutable reference. A user MUST be able to install a specific released version without a marketplace account.
- **Optional marketplace publication.** Where configured, the same VSIX is also published to an extension marketplace (the VS Code Marketplace and/or Open VSX). Marketplace publication is opt-in and MUST NOT be a prerequisite for the GitHub-Release install path.
- **A prerelease from an open pull request.** A prerelease VSIX MUST be obtainable from an open pull request for testing before merge, without being promoted to the latest stable version.
- **A named status check per merge-blocking stage.** Every stage that must hold a pull request surfaces a named status check, so [Merge Automation](../merge-automation/spec.md) can gate the merge on it.
- **Documentation travels with the extension.** Each extension's user documentation lives in its own repository and is built and published by the framework. There is no separate internal-versus-user split; the framework's own documentation is this capability.
- **Dependencies kept current.** The extension's pinned dependencies — npm packages and pinned Actions — are kept current and secure through [Dependency Updates](../dependency-updates/spec.md).
- **Standard GitHub primitives only.** Pull requests, labels, releases, environments, and GitHub Actions — no external release tooling beyond `gh` and the editor's own packaging and publishing CLIs.

## Success criteria

- Creating a repository from the template and pushing a first change yields a green build, a passing test run, and a packaged VSIX with no configuration written.
- A labelled pull request merged to a release branch produces a GitHub Release carrying an installable VSIX whose version matches the label's bump — a conflicting or ambiguous label set is rejected, never guessed.
- The tests that gate the release exercise the exact VSIX that is released, on every supported host version and operating system.
- A documentation-only or CI-only change runs its checks but produces no new version.
- A user installs any released version straight from its GitHub Release with no marketplace account; where marketplace publishing is enabled, that same version also appears in the marketplace.
- An open pull request can publish a prerelease VSIX for testing that never becomes the latest stable version, and it is cleaned up when the pull request closes.
- Adopting the framework in a new extension is a short caller plus a settings file — the pipeline itself is never copied into the repository.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Release Management](../release-management/spec.md) — the versioning and release mechanics this framework drives.
- [Dependency Updates](../dependency-updates/spec.md) — how the extension's dependencies stay current.
- [Merge Automation](../merge-automation/spec.md) — how the framework's status checks gate the merge.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why this spec holds only the why and the what, and why an extension's docs live in its own repo.
- [TypeScript](../../Coding-Standards/TypeScript.md) — the language standard extensions are written to.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md) — how the pipeline that delivers this is authored.
