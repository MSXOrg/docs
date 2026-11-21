---
title: Coding Standards
description: Shared coding rules and language-specific standards for every MSX repository.
---

# Coding Standards

The MSX coding standards have two tiers.
The **baseline** applies the [Principles](../Ways-of-Working/Principles/index.md) to code in every language.
It defines rules for naming, code layout, documentation, testing, and security.
The **per-language standards** add rules for a specific language or tool without contradicting the baseline.

These standards are prescriptive, and they are the source of truth: the relevant linter or formatter is the enforcement mechanism, and its configuration is derived from the standard — never the other way around. Wherever a rule can be checked mechanically, a linter derived from the standard enforces it in CI.

## Linter decision path

When a PSScriptAnalyzer rule reports an issue, follow this order:

1. **Fix the issue.**
2. **Reconsider the implementation approach or design.**
3. **If the implementation is correct only for this case, add one file-level suppression attribute at the top of that file.**
4. **If the implementation is correct for all applicable cases, update the linter settings (usually under `.github/linters`).**

```powershell
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
 'PSUseDeclaredVarsMoreThanAssignments', '',
 Justification = 'Required for Pester tests'
)]
```

## Contents

The baseline pages apply to all code and come first. The per-language standards follow and extend the baseline.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Naming](Naming.md) | Names that reveal intent, consistently, in every language. |
| [Code Layout](Code-Layout.md) | Structure, formatting, and file organization. |
| [Functions](Functions.md) | One responsibility, contracts in the signature, and validation at the boundary. |
| [Error Handling](Error-Handling.md) | Fail fast, never swallow, and write messages that help the next person. |
| [Documentation](Documentation.md) | Help that lives next to the code and explains the why. |
| [Natural Language](Natural-Language.md) | Language choice and en-US writing for user and developer interactions, documentation, comments, issues, pull requests, help, messages, and agent-facing text. |
| [Technical Writing Guide](Writing-Guide.md) | Use ASD-STE100 and en-US for reader-facing English. Find official sources and the format for each artifact. |
| [Testing](Testing.md) | Prove supported behavior through real entry points and APIs, with justified test doubles and honest coverage. |
| [Performance](Performance.md) | Scale with the input, measure before optimizing, clarity first. |
| [Security](Security.md) | Least privilege, secret hygiene, and the OWASP baseline. |
| [Dependencies](Dependencies.md) | How dependencies are pinned and kept current — the locking spectrum from identity pins to floating latest, and the balance between update velocity and supply-chain exposure. |
| [Pre-Commit](Pre-Commit.md) | The generic local enforcement mechanism for every coding standard — the hook runs the standard's own tooling, mirrors the CI gate, and is pinned and kept current like any other dependency. |
| [GitHub Actions](GitHub-Actions.md) | Workflow authoring — SHA pinning, least-privilege permissions, OIDC, secrets handling, a PowerShell-first scripting default, script extraction, and diagnostic logging. |
| [Markdown](Markdown.md) | GitHub Flavored Markdown authoring rules enforced by the shared markdownlint configuration. |
| [PowerShell](PowerShell/index.md) | Cross-platform PowerShell 7 — the conventions shared by every script, function, and class, with per-construct standards below. |
| [Terraform](Terraform.md) | Stack layout, version pinning, state and secrets, and the fmt/validate/tflint toolchain. |
| [TypeScript](TypeScript.md) | ES modules, strict-mode typing, pinned dependencies, and the Prettier/ESLint/Vitest toolchain for Node tooling and VS Code extensions. |
| [YAML](YAML.md) | One file extension, yamllint locally and in CI, narrowly scoped suppressions, and actionlint on top for workflow files. |

<!-- INDEX:END -->

## Two tiers

The **baseline** defines naming, code layout, functions, error handling, documentation, testing, performance, and security for every language.
Every repository inherits it.

The **per-language standards** define conventions, required tools, and reasons for one language or tool.
A PowerShell module, a Terraform stack, a GitHub Actions workflow, and a Markdown document each have specific conventions.
A per-language standard extends the baseline without contradicting it.
Where the rules overlap, the baseline rule applies and the per-language page adds the details.

## The one rule above the rules

> Code is read far more often than it is written.

Every standard supports code readability.
If a rule reduces readability, prioritize readability and review the rule.
Write for the next person or agent without local context.

## How standards evolve

Standards change when their purpose or requirements change.
If a standard no longer serves its purpose, change it through a pull request in this repository and record the reason.
A standard that cannot be justified should be removed.
