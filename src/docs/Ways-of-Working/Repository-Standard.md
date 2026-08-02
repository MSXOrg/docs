---
title: Repository Standard
description: The baseline files and behaviours every repository must expose so it is understandable, secure, and maintainable.
---

# Repository Standard

A repository is the smallest unit of ownership in the MSX ecosystem. It must explain what it is, how to contribute, how security is handled, how dependencies are kept current, and which standards govern its automation.

The Repository Standard is the default for every repository across the MSX Enterprise, regardless of initiative, organization, or technology. It defines the baseline contract a repository must meet to be understandable, secure, and maintainable on its own.

Initiative standards operate at the same altitude as this standard, not beneath it. An initiative such as PSModule adds to and adjusts these defaults for its repository types rather than merely implementing them. A repository inherits every rule this standard sets unless its initiative explicitly changes it; where an initiative standard adds or overrides a rule, the initiative standard governs that initiative's repositories.

This page defines the repository-level contract. Initiative documentation defines implementation details such as exact file templates, managed-file source paths, and rollout automation.

## Required files

Every repository must carry the files that make it understandable and governable on its own.

| File | Requirement |
| --- | --- |
| `README.md` | Acts as the repository start page: purpose, value, access, first mental model, and where to go next. |
| `LICENSE` | States the legal terms for reuse and redistribution. |
| `CONTRIBUTING.md` | Explains how to contribute or links to the initiative contribution guide. |
| `SECURITY.md` | Explains supported versions and private vulnerability reporting. |
| `SUPPORT.md` | Explains where users ask for help. |
| `CODE_OF_CONDUCT.md` | Defines expected community behaviour. |
| `AGENTS.md` | Cross-tool agent router at the repository root: a short ordered list of where to read, from this repository's own files outward to the initiative and central documentation, then to memory. |
| `.claude/CLAUDE.md` | Routes Claude Code to the router with a single `@../AGENTS.md` import. |
| `.github/copilot-instructions.md` | Routes the Copilot surfaces that do not read `AGENTS.md` to the router. |
| `.github/dependabot.yml` | Configures ecosystem-appropriate dependency-update pull requests. The `github-actions` ecosystem is expected in virtually every repository; add the language, package, container, or infrastructure ecosystems the repository actually develops in. |
| `.github/CODEOWNERS` | Routes reviews to responsible owners. |
| `.github/pull_request_template.md` | Scaffolds pull requests in the MSX [PR Format](PR-Format.md) (PR Manager) style — an icon + change-type + user-facing-outcome title, user-facing description sections, an optional technical-details block, and a related-issues block. |
| `.gitattributes` | Normalizes line endings and declares text/binary handling so the repository can be developed and built consistently on Linux, macOS, and Windows. |
| `.gitignore` | Ignores files that must never be committed, tailored to the repository's ecosystem: operating-system files, editor and developer-tooling files, language and test-harness artifacts, and all local build outputs and files created during build and test. |

Repository types may require additional files. For example, a PowerShell module may require `.github/PSModule.yml`, while a GitHub Action may require `action.yml`.

`AGENTS.md` is the only agent file that carries the reading order. `.claude/CLAUDE.md` and `.github/copilot-instructions.md` exist because those clients read their own filenames; each holds a route to the router and, at most, genuinely runtime-specific configuration such as permission scopes — never a reading order, a workflow, or a standard. A path-scoped `.github/instructions/*.instructions.md` file is exceptional, added only for a local caveat that cannot live in `README.md`, `CONTRIBUTING.md`, or central documentation. See [Agentic Development](Agentic-Development.md#which-agent-files-a-repository-carries).

## README defaults

The README is the repository start page. It brings a reader in, gives them the first useful mental model, and then points them to the right deeper surface. It must be short enough to stay current and specific enough that a human or agent can understand the repository before reading source code.

A README answers these questions, in this order:

| Question | README responsibility |
| --- | --- |
| What is it? | Name the product or artifact and its scope. |
| Why should I care? | State the value or problem it solves. |
| How do I get it? | Show the shortest install, download, import, or usage entry point. |
| How does it work? | Give a concise introduction to the main capability or operating model. |
| How do I get more info? | Point to the documentation surface that owns the details. |

Do not use the README as a community-file index. Assume readers can find standard repository files such as `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`, and `CODE_OF_CONDUCT.md` through GitHub's UI and repository conventions. The README should mention them only when the repository has an unusual rule that readers must know before using the product.

Do not repeat repository-sidebar information in prose. If GitHub already exposes the repository description, deployments, releases, or site URL, the README may rely on those surfaces unless the information is necessary to answer the start-page questions.

Do not leave template placeholders such as `{{ NAME }}`, `{{ DESCRIPTION }}`, `YourModuleName`, or fake example commands in a repository README after the initial setup commit.

## Product documentation defaults

The README is not the complete product manual. Important product documentation belongs in a documentation surface that can grow without bloating the start page.

Default expectations by repository type:

| Repository type | Documentation default |
| --- | --- |
| PowerShell modules | Product docs live under `docs/` and are published to GitHub Pages or the initiative's module documentation site. The README stays short and points there. |
| Libraries, services, CLIs, and applications | Product docs live under `docs/` and are published when the product needs more than a small README. |
| GitHub Actions | The README is the main documentation surface because GitHub Actions users expect inputs, outputs, permissions, and examples next to `action.yml`. |
| Reusable workflows | The README is the main documentation surface because callers need workflow interface, permissions, secrets, and examples in the repository. |
| Documentation repositories | The published site is the product. The repository README explains what the source repository is and how it is laid out, and points to `CONTRIBUTING.md` for the authoring conventions and the local build. |

Initiative docs define the implementation: exact folder layout, publishing workflow, URL convention, and which repositories are exceptions. MSX defines the expectation that product docs have an owner and that README pages stay small.

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

Linter configuration is applied only when the repository actually uses the linter; it is not a mandatory baseline file. Where a linter is used and its CI job reads configuration from the repository, that configuration must be repository-local. Most shared linter configs live under `.github/linters/`.

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

The description should lead with user-facing impact, continue with user-facing change sections, include optional technical details after those sections, and end with the related-issues block. It closes one scoped Task or Bug as required by [PR Format](PR-Format.md), with any additional closing links limited to issues the session-end convergence sweep shows are fully delivered by the same diff.

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

The central standard deliberately stops at the requirement level, and initiative standards operate at the same altitude rather than beneath it: an initiative adds to and adjusts these defaults for its repository types, and a repository inherits every rule this standard sets unless its initiative explicitly changes it. Where an initiative standard adds or overrides a rule, the initiative standard governs that initiative's repositories. Within that relationship, initiative repositories own implementation design.

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
- [Agentic Development](Agentic-Development.md) — which agent files a repository carries and why the entry point is a pointer.
- [Repository Type Property](Repository-Type-Property.md) — the `Type` custom property that classifies a repository and drives which type-specific files and controls apply.
- [README-Driven Context](Readme-Driven-Context.md) — why the README is the front door.
- [PR Format](PR-Format.md) — the PR Manager-style title and description format.
- [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — workflow and automation standards.
- [Dependency Updates](../Capabilities/dependency-updates/spec.md) — supply-chain update requirements.
