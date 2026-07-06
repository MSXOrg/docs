---
title: Organization Standard
description: What every initiative organization must define centrally so humans and agents share the same expectations.
---

# Organization Standard

An MSX initiative organization is a collection of repositories that share one way of working. The organization standard defines the shared contract: what every repository can expect from the organization, where the source of truth lives, and which files must be managed consistently.

This page owns the **why** and **what**. Initiative repositories own the implementation design: how they distribute files, which automation enforces the contract, and how exceptions are handled.

## Required organization docs

Each initiative must have a central documentation repository that defines its implementation guidance. The central docs answer how the initiative applies MSX standards to its own repositories.

The initiative docs must describe:

- Repository types used by the initiative.
- Required files for each repository type.
- Managed-file source locations and update workflow.
- Required custom properties, labels, branch protection, and review rules.
- How humans and agents discover the relevant standards before making changes.
- How initiative-specific exceptions are requested and reviewed.

The MSX docs remain the ecosystem-level source of truth. Initiative docs may specialize, but must not contradict this site.

## Required organization file standards

Every initiative organization must define standards for these shared file families:

| File family | Standard owns |
| --- | --- |
| Community health files | Code of conduct, contribution guide, support policy, security policy, and license expectations. |
| Repository context | README defaults, documentation ownership, and repository metadata expectations. |
| Review workflow | Pull request template, review routing, CODEOWNERS, labels, and change-type conventions. |
| Supply chain | Dependabot configuration, dependency update labels, security update behavior, and review expectations. |
| Linters and enforcement | Linter configuration derived from the written standards. |
| Agent context | Instructions, prompts, hooks, and any repository-local agent guidance. |
| Release automation | Release notes, changelog categorization, and release workflow defaults where applicable. |

These standards must be written down before broad alignment work starts. File alignment without a written standard only spreads local preference faster.

## Repository-local files are the enforceable surface

GitHub's special organization `.github` repository can provide fallback community files, but it is not the MSX enforcement model. Repository-local files are still required because they are what humans, agents, linters, Dependabot, CODEOWNERS, release workflows, and pull requests actually read and review.

Use organization-level `.github` fallbacks only as a convenience, never as the only copy of a required standard file.

## Managed files

Shared files should be managed from a central source and delivered to repositories through pull requests. Direct pushes to repository default branches are not the standard path.

A managed-file system must:

- Keep source files in one central repository for the initiative.
- Preserve relative paths exactly as they should appear in target repositories.
- Create or update repository-local files by pull request.
- Make ownership clear in the pull request body.
- Avoid creating duplicate pull requests for the same managed branch.
- Log which repositories changed, which were already aligned, and which failed.
- Never silently delete previously distributed files without an explicit cleanup decision.

PSModule currently explores this through `PSModule/Distributor`. That repository is an implementation example for the PSModule initiative, not the MSX-wide design. Other initiatives may build a different distributor as long as it satisfies this standard.

## Mandatory and optional file sets

Organizations must distinguish mandatory files from optional or type-specific files.

| Kind | Meaning |
| --- | --- |
| Mandatory | Files that every applicable repository must carry, even without local subscription. |
| Global optional | Files available to all repository types, but still selected intentionally. |
| Type-specific | Files that apply only to a repository type, such as a PowerShell module, GitHub Action, Terraform module, or docs repo. |
| Repository-specific | Local files that are intentionally owned by one repository and not managed centrally. |

Security, contribution, conduct, support, dependency update, and license files are candidates for mandatory file sets. Linter settings, agent instructions, and workflow defaults may be global or type-specific depending on the initiative.

## Linter configuration ownership

The written standard defines the rule. The linter configuration enforces the rule.

Most linter configuration belongs under `.github/linters/`, because super-linter and similar workflow tooling read that path consistently. Examples include markdownlint, codespell, textlint, and PSScriptAnalyzer settings.

Some tools require repository-root configuration because their own config discovery works that way. Examples include Prettier or language package-manager files. When a root config is required, document why in the initiative guidance.

Do not change a linter config to make a warning disappear unless the written standard changes with it.

## Agent and human alignment

Humans and agents must read the same standards. Do not create a separate hidden agent process that contradicts the public docs.

Agent files are allowed when they point to, summarize, or operationalize the central standard. They must not become a second source of truth.

## Where this connects

- [Repository Standard](Repository-Standard.md) — the repository-level contract every repository must satisfy.
- [Documentation Model](Documentation-Model.md) — why specs own why and what, while designs own implementation.
- [Dependency Updates](../Capabilities/dependency-updates/spec.md) — the supply-chain update capability every repository inherits.
- [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — workflow authoring and enforcement rules.
