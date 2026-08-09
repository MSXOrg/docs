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
- Required custom properties, namespace-qualified automation label sets, branch
  protection, and review rules.
- How humans and agents discover the relevant standards before making changes.
- How initiative-specific exceptions are requested and reviewed.

The MSX docs remain the ecosystem-level source of truth. Initiative docs may specialize, but must not contradict this site.

## Required organization file standards

Every initiative organization must define standards for these shared file families:

| File family | Standard owns |
| --- | --- |
| Community health files | Code of conduct, contribution guide, support policy, security policy, and license expectations. |
| Repository context | README defaults, documentation ownership, and repository metadata expectations. |
| Review workflow | Pull request template, review routing, CODEOWNERS, namespace-qualified automation label sets, and change-type conventions. |
| Supply chain | Dependabot configuration, namespace-qualified dependency update labels, security update behavior, and review expectations. |
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

Which set applies to a repository is derived from its classification rather than decided per repository, so that adding a repository requires classifying it and nothing else. The classification mechanism, the per-type required-file matrix, and the composition rules for a repository that is more than one type are defined by [Repository Governance](../Capabilities/repository-governance/spec.md).

## Enforcement is continuous

A standard is only in force where the organization can tell whether it is being met. Writing the standard down, distributing the files once, and assuming the result persists produces an organization that believes it is aligned and cannot demonstrate it — repositories are created outside the distribution path, settings are changed by hand, and files are edited locally, none of which announces itself.

So every organization-level standard must be paired with a way of observing its state across repositories, and every observed deviation must be either corrected or recorded as a deliberate exemption. Silent deviation is the only outcome that is not allowed, because it is indistinguishable from compliance until something depends on it.

This is the reconciliation loop described in [Repository Governance](../Capabilities/repository-governance/design.md#drift-detection-and-reconciliation): the declared state is the source of truth, the observed state is measured against it, and the difference is a finding that names its own remedy.

## Linter configuration ownership

The written standard defines the rule. The linter configuration enforces the rule.

Most linter configuration belongs under `.github/linters/`, because super-linter and similar workflow tooling read that path consistently. Examples include markdownlint, codespell, textlint, and PSScriptAnalyzer settings.

Some tools require repository-root configuration because their own config discovery works that way. Examples include Prettier or language package-manager files. When a root config is required, document why in the initiative guidance.

Do not change a linter config to make a warning disappear unless the written standard changes with it.

## Agent and human alignment

Humans and agents must read the same standards. Do not create a separate hidden agent process that contradicts the public docs.

Agent files are allowed when they point to, summarize, or operationalize the central standard. They must not become a second source of truth.

The repository-level entry point is `AGENTS.md`, as defined by [Agentic Development](Agentic-Development.md#which-agent-files-a-repository-carries). Agent runtimes do not agree on a filename, so a repository also carries a route file for each client that reads a different one. A route holds a pointer to the router and, at most, genuinely runtime-specific configuration — never a duplicated standard or workflow. The same limit applies to any organization-level instruction setting an agent vendor offers: use it for organization-wide preferences, never as a second copy of a standard.

## Where this connects

- [Repository Standard](Repository-Standard.md) — the repository-level contract every repository must satisfy.
- [Repository Type Property](Repository-Type-Property.md) — the concrete `Type` custom-property mechanism that implements "repository types" and "required custom properties, branch protection" from this page.
- [Repository Governance](../Capabilities/repository-governance/index.md) — the classification, ruleset, required-file, exemption, and reconciliation machinery that puts this standard in force.
- [Repository Segmentation](Repository-Segmentation.md) — where a repository's boundary falls, which is what gets classified.
- [Automation Labels](Automation-Labels.md) — the label vocabulary organization automation reads and writes.
- [Documentation Model](Documentation-Model.md) — why specs own why and what, while designs own implementation.
- [Dependency Updates](../Capabilities/dependency-updates/spec.md) — the supply-chain update capability every repository inherits.
- [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — workflow authoring and enforcement rules.
