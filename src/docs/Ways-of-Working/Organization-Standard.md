---
title: Organization Standard
description: What every initiative organization must define centrally so humans and agents share the same expectations.
---

# Organization Standard

An MSX initiative organization contains repositories that share one way of working. Each repository can expect a shared source of truth and files that the organization must manage consistently.

Organization requirements cover the **why** and **what**. Initiative repositories own the implementation design: how they distribute files, which automation enforces the contract, and how exceptions are handled.

## Required organization docs

Each initiative must have a central documentation repository that defines its implementation guidance. The central docs answer how the initiative applies MSX standards to its own repositories.

The initiative docs must describe:

- The target audiences and jobs the initiative serves, including how repositories [declare or specialize that audience](Readme-Driven-Context.md#target-audience).
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
| Community health files | Central code of conduct, support policy, security policy, and initiative contribution guidance. |
| Issue intake | Central issue forms and issue-template configuration defaults, where the organization wants a shared intake model. |
| Organization profile | The public organization introduction and any assets it uses. |
| Repository context | README defaults, documentation ownership, and repository metadata expectations. |
| Review workflow | Canonical PR-format guidance, review routing, CODEOWNERS, namespace-qualified automation label sets, and change-type conventions. |
| Supply chain | Dependency update configuration, security update behavior, and review expectations. |
| Linters and enforcement | Linter configuration derived from the written standards. |
| Agent context | Organization settings plus repository-local instructions, prompts, hooks, and agent guidance. |
| Release automation | Release notes, changelog categorization, and release workflow defaults where applicable. |

These standards must be documented before organization-wide alignment work starts. Without a written standard, file alignment distributes local preferences rather than agreed rules.

## Community files are organization defaults

Community policies are organization-wide commitments, not repository-specific
configuration. Each initiative organization MUST provide its code of conduct,
security policy, support policy, and shared contribution guide as defaults in
its public `.github` repository. Ordinary repositories inherit these defaults
unless genuine repository-specific content or a documented exception requires
a local community file.

Store every organization community default under the `.github/` directory of
the special `.github` repository:

| File | Purpose |
| --- | --- |
| `.github/CODE_OF_CONDUCT.md` | Defines expected community behavior. |
| `.github/SECURITY.md` | Defines supported versions and private vulnerability reporting. |
| `.github/SUPPORT.md` | Defines where users ask for help. |
| `.github/CONTRIBUTING.md` | Owns the initiative's common contribution instructions. The file is required even when blank. |

The contribution source file MAY be blank. Its absence is a missing required
organization default, not a reason to create placeholder copies in consumer
repositories.

A repository MAY retain a local community file only for genuine
repository-specific content or a documented policy exception. The local file
takes precedence. A policy exception and its owner MUST be documented in the
initiative guidance; repository-specific contribution instructions follow the
[conditional contribution rule](Repository-Standard.md#contribution-guidance).

PR authoring follows the [Repository Standard's no-PR-template-file
policy](Repository-Standard.md#no-pr-template-files) and canonical [PR Format](PR-Format.md).
PR templates are not organization defaults or eligible local exceptions.

An organization MAY also provide shared issue-intake defaults in the same
repository:

| File or directory | Purpose |
| --- | --- |
| `.github/ISSUE_TEMPLATE/` | Provides shared issue forms and template configuration for consistent issue intake. |

When supplied, these defaults apply through GitHub's fallback. They are not
additional files for consumers to copy or subscribe to. Local contribution
guidance follows
[Repository Standard](Repository-Standard.md#contribution-guidance). A repository
MAY provide local issue templates for genuine repository-specific intake or a
documented exception.

The same repository MAY publish `profile/README.md` as the public organization
profile and MAY keep its supporting assets under `media/`. Neither surface is
inherited by repositories.

The special `.github` repository has a purpose-specific local baseline:
`README.md`, `AGENTS.md`, its client routes, `.gitattributes`, and `.gitignore`.
Those files explain and govern the defaults repository and are not distributed
as organization defaults. Repository ownership, dependency updates, release
configuration, and license terms remain repository-specific and are added only
when the defaults repository itself needs them. The
[Repository Governance design](../Capabilities/repository-governance/design.md#organization-defaults-repository)
owns the complete structure and distribution behavior.

## Repository-local context is the enforceable surface

Every ordinary repository still carries the context that cannot be inferred
from an organization default: its `README.md` and `AGENTS.md` with its client
routes. A local contribution guide carries only needed repository-specific
instructions or a documented exception; inherited guidance does not require a
local file. Contribution guidance links to canonical [PR Format](PR-Format.md).
Automation configuration, ownership, and repository-specific
legal terms remain repository-local where the
[Repository Standard](Repository-Standard.md) requires them. The special
`.github` repository uses the purpose-specific baseline above.

## Managed files

Centrally managed repository-local files are delivered through pull requests. Organization community defaults are reviewed in their source repository and inherited, not distributed as local copies. Direct pushes to repository default branches are not the standard path.

A managed-file system must:

- Keep source files in one central repository for the initiative.
- Preserve relative paths exactly as they should appear in target repositories.
- Create or update repository-local files by pull request.
- Make ownership clear in the pull request body.
- Avoid creating duplicate pull requests for the same managed branch.
- Log which repositories changed, which were already aligned, and which failed.
- Never silently delete previously distributed files without an explicit cleanup decision.

The `PSModule/Distributor` example refers to the [Distributor repository](https://github.com/MSXOrg/Distributor). Its documentation describes a managed-file distribution design for the PSModule initiative, not the MSX-wide design. Other initiatives may use a different distributor if it satisfies this standard.

## Mandatory and optional file sets

Organizations must distinguish mandatory files from optional or type-specific files.

| Kind | Meaning |
| --- | --- |
| Mandatory | Files that every applicable repository must carry, even without local subscription. |
| Global optional | Files available to all repository types, but still selected intentionally. |
| Type-specific | Files that apply only to a repository type, such as a PowerShell module, GitHub Action, Terraform module, or docs repo. |
| Repository-specific | Local files that are intentionally owned by one repository and not managed centrally. |

Repository-local context, dependency updates, ownership, license terms, and
type-specific files are candidates for mandatory file sets. Contribution files
follow the conditional rule rather than an unconditional local-file requirement.
Required organization community defaults are mandatory in their source home;
repositories use supplied defaults through GitHub's fallback unless local content
is needed under the community-file rule above. Linter
settings, agent instructions, and workflow defaults may be global or
type-specific depending on the initiative.

Classification selects the applicable file sets instead of a separate per-repository decision. [Repository Governance](../Capabilities/repository-governance/spec.md) defines the classification mechanism, per-type required-file matrix, and composition rules for repositories with multiple types.

## Enforcement is continuous

Every organization-level standard must have a way to observe compliance across repositories. A one-time file distribution does not establish continued alignment. Repository creation outside the distribution path, manual setting changes, and local file edits can each cause drift.

The organization must either correct each observed deviation or record it as a deliberate exemption. An unreported deviation must not be treated as compliance.

The [Repository Governance reconciliation loop](../Capabilities/repository-governance/design.md#drift-detection-and-reconciliation) compares observed repository state with the declared source of truth. Each difference produces a finding with a remedy.

## Linter configuration ownership

The written standard defines the rule. The linter configuration enforces the rule.

Most linter configuration belongs under `.github/linters/`, because super-linter and similar workflow tooling read that path consistently. Examples include markdownlint, codespell, textlint, and PSScriptAnalyzer settings.

Some tools require repository-root configuration because their own config discovery works that way. Examples include Prettier or language package-manager files. When a root config is required, document why in the initiative guidance.

Do not change a linter config to make a warning disappear unless the written standard changes with it.

## Agent and human alignment

Humans and agents must read the same standards. Do not create a separate hidden agent process that contradicts the public docs.

Agent files are allowed when they point to, summarize, or operationalize the central standard. They must not become a second source of truth.

The repository-level entry point is `AGENTS.md`, as defined by [Agentic Development](../Capabilities/agentic-development/design.md#client-behavior). A repository also carries a route file for each client that reads a different filename. A route contains a pointer to the router and, at most, genuinely runtime-specific configuration. It never duplicates a standard or workflow. The same limit applies to organization-level instruction settings from agent vendors. Use them for organization-wide preferences, never as a second copy of a standard.

The `.github/copilot-instructions.md` route in the special `.github`
repository applies to that repository only. Organization-wide Copilot
instructions are configured in the organization settings and point to the
canonical standards.

## Where this connects

- [Repository Standard](Repository-Standard.md) — the repository-level contract every repository must satisfy.
- [Repository Type Property](Repository-Type-Property.md) — the concrete `Type` custom-property mechanism for repository types, required custom properties, and branch protection.
- [Repository Governance](../Capabilities/repository-governance/index.md) — the classification, ruleset, required-file, exemption, and reconciliation machinery that enforces organization requirements.
- [Repository Segmentation](Repository-Segmentation.md) — where a repository's boundary falls, which is what gets classified.
- [Automation Labels](Automation-Labels.md) — the label vocabulary organization automation reads and writes.
- [Documentation Model](Documentation-Model.md) — why specs own why and what, while designs own implementation.
- [Dependency Updates](../Capabilities/dependency-updates/spec.md) — the supply-chain update capability every repository inherits.
- [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — workflow authoring and enforcement rules.
