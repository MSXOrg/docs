---
title: Coding Standards
description: The shared baseline every repository inherits, and the per-language standards that build on it.
---

# Coding Standards

Standards for code written anywhere in the MSX ecosystem, in two tiers. The **baseline** encodes the [Principles](../Ways-of-Working/Principles.md) at the level of day-to-day code — how it is named, laid out, documented, tested, and secured — and applies in every language. The **per-language standards** add the idioms of one language or tool on top, and never contradict the baseline.

These standards are prescriptive: a change is expected to follow them, and the relevant linter or formatter is the enforcement mechanism wherever one exists.

## Contents

The baseline pages apply to all code and come first; the per-language standards build on them and follow.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Naming](Naming.md) | Names that reveal intent, consistently, in every language. |
| [Code Layout](Code-Layout.md) | Structure, formatting, and file organization. |
| [Functions](Functions.md) | One responsibility, contracts in the signature, and validation at the boundary. |
| [Error Handling](Error-Handling.md) | Fail fast, never swallow, and write messages that help the next person. |
| [Documentation](Documentation.md) | Help that lives next to the code and explains the why. |
| [Testing](Testing.md) | The executable specification — test-first, locally runnable, deterministic. |
| [Performance](Performance.md) | Scale with the input, measure before optimizing, clarity first. |
| [Security](Security.md) | Least privilege, secret hygiene, and the OWASP baseline. |
| [GitHub Actions](GitHub-Actions.md) | Workflow authoring — SHA pinning, least-privilege permissions, OIDC, secrets handling, and script extraction. |
| [Markdown](Markdown.md) | GitHub Flavored Markdown authoring rules enforced by the shared markdownlint configuration. |
| [PowerShell](PowerShell.md) | Advanced functions, comment-based help, and error handling for cross-platform PowerShell. |
| [Terraform](Terraform.md) | Stack layout, version pinning, state and secrets, and the fmt/validate/tflint toolchain. |

<!-- INDEX:END -->

## Two tiers

The **baseline** applies in every language — naming, code layout, functions, error handling, documentation, testing, performance, and security. Every repository inherits it.

The **per-language standards** capture the idioms of one language or tool: the conventions, the toolchain that enforces them, and the rationale where it is not obvious. A PowerShell module, a Terraform stack, a GitHub Actions workflow, and a Markdown document each have idioms of their own. A per-language standard always builds on the baseline and never contradicts it — where they overlap, the baseline rule applies and the per-language page adds the specifics.

## The one rule above the rules

> Code is read far more often than it is written.

Every standard here serves that single fact. When a rule and readability disagree, readability wins — and the rule gets revisited. When in doubt, optimize for the next person (or agent) who has to understand the code cold.

## How standards evolve

Standards are evergreen, not frozen. When one stops serving us, we change it — in a pull request, against this repository, with the reasoning written down. A standard that cannot be justified is a standard that should be removed.
