---
title: Repository Standard
description: The baseline files and behaviours every repository must expose so it is understandable, secure, and maintainable.
---

# Repository Standard

A repository is the smallest unit of ownership in the MSX ecosystem. It must explain what it is, how to contribute, how security is handled, how dependencies are kept current, and which standards govern its automation.

This page defines the repository-level contract. Initiative documentation defines implementation details such as exact file templates, managed-file source paths, and rollout automation.

## Required files

Every repository must carry the files that make it understandable and governable on its own.

| File | Requirement |
| --- | --- |
| `README.md` | Explains the repository purpose, current capabilities, and where to find deeper docs. |
| `LICENSE` | States the legal terms for reuse and redistribution. |
| `CONTRIBUTING.md` | Explains how to contribute or links to the initiative contribution guide. |
| `SECURITY.md` | Explains supported versions and private vulnerability reporting. |
| `SUPPORT.md` | Explains where users ask for help. |
| `CODE_OF_CONDUCT.md` | Defines expected community behaviour. |
| `.github/dependabot.yml` | Configures dependency and supply-chain update pull requests. |
| `.github/CODEOWNERS` | Routes reviews to responsible owners. |
| `.github/pull_request_template.md` | Guides contributors to provide change type, impact, validation, and links. |
| `.github/release.yml` | Defines release-note categories where GitHub releases are generated. |
| `.github/linters/*` | Stores linter configuration derived from the written standards. |
| `.gitattributes` | Defines Git file handling defaults. |
| `.gitignore` | Defines files that should not enter version control. |

Repository types may require additional files. For example, a PowerShell module may require `.github/PSModule.yml`, while a GitHub Action may require `action.yml`.

## README defaults

The README is the repository front door. It must be short enough to stay current and specific enough that a human or agent can understand the repository before reading source code.

A README should include:

- What the repository is.
- What it currently does.
- How to install or use the artifact, if applicable.
- Where generated or detailed documentation lives.
- How to contribute or where to find contribution guidance.
- Status if the repository is a placeholder, archive, experiment, or in progress.

Do not leave template placeholders such as `{{ NAME }}`, `{{ DESCRIPTION }}`, `YourModuleName`, or fake example commands in a repository README after the initial setup commit.

## Dependency and supply-chain defaults

Every repository that has external dependencies must configure automated update pull requests. Dependabot is the default GitHub-native mechanism unless the initiative documents a different implementation.

At minimum, repositories with GitHub Actions must include a `github-actions` ecosystem entry. Repositories with language, package, container, or infrastructure dependencies must include the relevant ecosystems too.

Dependency update pull requests must:

- Use labels that identify the dependency category and ecosystem.
- Keep update-level labels separate from release-bump labels.
- Pass the same CI and review gates as human-authored changes.
- Keep SHA-pinned actions pinned to immutable commit SHAs with a version comment when possible.
- Be reviewed before merge, even when auto-merge is allowed for low-risk updates.

See [Dependency Updates](../Capabilities/dependency-updates/spec.md) for the central requirements.

## Linter configuration defaults

Linter configuration must be repository-local when the CI job reads it from the repository. Most shared linter configs live under `.github/linters/`.

Examples:

| Config | Typical location |
| --- | --- |
| markdownlint | `.github/linters/.markdown-lint.yml` |
| codespell | `.github/linters/.codespellrc` |
| textlint | `.github/linters/.textlintrc` |
| PSScriptAnalyzer | `.github/linters/.powershell-psscriptanalyzer.psd1` |
| actionlint | `.github/linters/actionlint.yml` |
| zizmor | `.github/linters/zizmor.yaml` |

When a tool only discovers config at the repository root, keep it there and document why. The written standard still owns the rule; the config is the derived enforcement.

## Pull request defaults

Repository pull requests must use the PR Manager style for title and description when a release note may be generated from the PR.

Default title pattern:

```text
<Icon> [<Change type>]: <User-facing outcome>
```

The description should lead with user-facing impact, then issue links when available, then user-facing change sections, with technical details at the bottom.

Repository templates may be simpler than the full PR Manager body, but they must gather enough information to reconstruct it.

## Managed files

A repository must treat centrally managed files as owned by the initiative, not by local preference. If a managed file needs to change, update the managed source and let automation open repository pull requests.

Local changes to managed files are allowed only as a temporary exception and should be reconciled back into the managed source.

Managed-file pull requests should clearly say:

- Which system produced the PR.
- Which files are managed.
- Where to propose changes to the source files.
- Whether files were created, overwritten, or left unmanaged.

## Initiative implementation guidance

The central standard deliberately stops at the requirement level. Initiative repositories own implementation design.

An initiative should document:

- Which repository types it uses.
- Which files are mandatory for each type.
- Which files are optional subscriptions.
- Which files are generated or managed.
- Which custom properties, labels, and teams are required.
- How the distributor or equivalent automation discovers repositories.
- How exceptions are approved.

For example, PSModule can define its module-specific managed files in `PSModule/docs` and implement distribution in `PSModule/Distributor`. MSX only defines that such a standard and distribution path must exist.

## Where this connects

- [Organization Standard](Organization-Standard.md) — what an initiative organization must define centrally.
- [README-Driven Context](Readme-Driven-Context.md) — why the README is the front door.
- [PR Format](PR-Format.md) — the PR Manager-style title and description format.
- [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — workflow and automation standards.
- [Dependency Updates](../Capabilities/dependency-updates/spec.md) — supply-chain update requirements.
