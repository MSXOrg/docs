---
title: Spec
description: Requirements for the VS Code extension framework — an opt-in, GitHub-native pipeline that builds, tests, versions, packages, and publishes a VS Code extension from a single settings file.
---

# VS Code Extension Framework — Spec

## Premise

The framework automates the shared lifecycle of a VS Code extension. It compiles
and bundles the source, tests it against a real editor, and runs lint and type
checks. It resolves the version, packages a VSIX, and publishes it for
installation.

Contributors maintain the extension's code and tests. The framework runs the
build, test, version, package, and publication stages on GitHub without a local
release procedure. A repository opts into the shared pipeline instead of
defining its own. Merging an eligible pull request publishes a release.

The framework is the VS Code counterpart to the module and container pipelines.
It defines one shared lifecycle for all adopting extension repositories. An
extension inherits a working build, test, and release path from the template.

### Principles

This capability follows the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Version-controlled workflows and settings define the pipeline, version decision, and extension configuration. A GUI action or a manual packaging command does not define them.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** The pull request is the decision point. Its review gate approves the code and the resulting release. An owned bump label overrides the valid effective default, including shared policy and supported caller inputs. The decision and its source are recorded.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** The lifecycle is the stable core. Extension-specific settings select host versions, the operating-system matrix, and publish targets. An additional publish destination uses a configured step within the same pipeline.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** The pipeline runs read-only by default. Only the stage that creates the release has write access, and only for the scope it needs.

## Scope

This capability applies to repositories whose released artifact is a **VS Code extension**.
The artifact is a VSIX package for VS Code and compatible hosts (VS Code
Insiders, Cursor, VSCodium). It governs a repository when merging produces an installable
VS Code extension that another consumer uses by version.

**In scope:** compiling and bundling the extension, testing it on a real editor
host, linting and type-checking, computing its version, packaging the VSIX,
publishing and distributing that VSIX, keeping the extension's dependencies
current, and building the extension's own documentation.

**Out of scope:** the extension's *features and behavior* belong to the
extension's own spec in its repository.
[Release Management](../release-management/spec.md) governs versioning and release
mechanics. [Merge Automation](../merge-automation/spec.md) defines the checks that
gate a merge. [Dependency Updates](../dependency-updates/spec.md) keeps
dependencies current.

A plain Node package that is not a VS Code extension is outside this scope.
Documentation for a specific extension lives in that extension's repository.
The shared capability owns the framework requirements and design.

## Requirements

- **Opt-in from a template.** A new extension starts from a template repository and inherits the whole pipeline. A repository adopts the framework with a short caller and a settings file. It never copies the pipeline.
- **A single extension settings file with secure, working defaults.** One version-controlled settings file configures extension-specific behavior. With a valid release decision, zero extension-specific configuration MUST produce a correct build, test, and VSIX. Build, test, and release settings have documented defaults and supported caller overrides under [Smart defaults, local overrides](../../Ways-of-Working/Principles/Software-Design.md#smart-defaults-local-overrides). The effective release default follows Release Management.
- **A reproducible, self-contained bundle.** The framework compiles the extension into one self-contained bundle with no unbundled runtime dependencies. The same commit always produces the same output.
- **Tested on a real host.** The pipeline tests the extension against a real VS Code host on every declared supported host version and operating system. Tests exercise the exact bundle in the released VSIX, never a separately compiled copy.
- **A static quality gate.** The pipeline lints and type-checks every change. It stops on any error. It validates quality at pull-request time, before merge.
- **Built once, shipped once.** The canonical release identity and validated native extension version MUST be resolved before Build. Build stamps the native version into the manifest. The pipeline tests and publishes the same packaged VSIX unchanged. The GitHub Release records the canonical/native mapping. Destination-native numbers need not be textually identical. Build, test, and release MUST NOT diverge.
- **Policy-driven, semantic versioning.** Versioning follows [Release Management](../release-management/spec.md): an explicit owned bump label overrides the valid effective `DefaultBump`; without a bump label, the documented default supplies the level. Invalid settings and conflicting owned labels MUST fail the required PR check and block merge. `release:skip` prevents publication, and `release:prerelease` MAY use the resolved explicit or default bump. The version is [SemVer](https://semver.org/) and is derived automatically — never hand-edited in the manifest.
- **An installable artifact on every release.** Each release attaches an installable VSIX to its [GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases). Each release includes an immutable reference. A user MUST be able to install a specific released version without a marketplace account.
- **Optional marketplace publication.** When configured, the pipeline also publishes the same VSIX to an extension marketplace (the VS Code Marketplace and/or Open VSX). Marketplace publication is opt-in and MUST NOT be a prerequisite for the GitHub-Release install path.
- **A prerelease from an open pull request.** A prerelease VSIX MUST be obtainable from an open pull request for tests before merge. It never becomes the latest stable version.
- **A named status check per merge-blocking stage.** Every stage that must hold a pull request surfaces a named status check, so [Merge Automation](../merge-automation/spec.md) can gate the merge on it.
- **Documentation travels with the extension.** Each extension's user documentation lives in its own repository. The framework builds and publishes that documentation. There is no separate internal-versus-user split. Framework documentation belongs to the shared capability.
- **Dependencies kept current.** The extension's pinned dependencies — npm packages and pinned Actions — are kept current and secure through [Dependency Updates](../dependency-updates/spec.md).
- **Standard GitHub primitives only.** The framework uses pull requests, labels, releases, environments, and GitHub Actions. It uses no external release tooling beyond `gh` and the editor's own packaging and publishing CLIs.

## Success criteria

- A repository created from the template with a valid release decision produces a successful build, a passing test run, and a packaged VSIX. No extension-specific configuration is required.
- An eligible merged PR produces a GitHub Release whose canonical version reflects the resolved bump and whose unchanged VSIX uses the recorded native version mapping. Omitting a bump label uses the valid effective default; invalid settings and conflicting owned labels fail required CI before merge.
- The tests that gate the release exercise the exact VSIX that is released, on every supported host version and operating system.
- On a managed VSIX route, a change outside the artifact/consumer scope carrying `release:skip` runs its checks without publication. An unmanaged route has no release metadata or labels.
- A user installs any released version from its canonical GitHub Release without a marketplace account; enabled marketplaces publish the unchanged VSIX under its recorded native version/channel mapping.
- An open pull request can publish a prerelease VSIX for testing that never becomes the latest stable version, and it is cleaned up when the pull request closes.
- Adopting the framework in a new extension is a short caller plus a settings file — the pipeline itself is never copied into the repository.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Release Management](../release-management/spec.md) — the versioning and release mechanics this framework drives.
- [Dependency Updates](../dependency-updates/spec.md) — how the extension's dependencies stay current.
- [Merge Automation](../merge-automation/spec.md) — how the framework's status checks gate the merge.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — capability requirements and repository-local extension documentation.
- [TypeScript](../../Coding-Standards/TypeScript.md) — the language standard extensions are written to.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md) — how the pipeline that delivers this is authored.
