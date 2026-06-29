---
title: Coding Standards
description: Language-agnostic standards every repository in the ecosystem inherits.
---

# Coding Standards

Language-agnostic standards for code written anywhere in the MSX ecosystem. They encode the [Principles](../Ways-of-Working/Principles.md) at the level of day-to-day code: how it is named, laid out, documented, tested, and secured.

These standards are the **shared baseline**. Each ecosystem repository may extend them with language- or framework-specific rules — a PowerShell module, a Terraform module, and a GitHub Action each have idioms of their own — but none of them contradict what is written here.

## Contents

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

<!-- INDEX:END -->

## The one rule above the rules

> Code is read far more often than it is written.

Every standard here serves that single fact. When a rule and readability disagree, readability wins — and the rule gets revisited. When in doubt, optimize for the next person (or agent) who has to understand the code cold.

## How standards evolve

Standards are evergreen, not frozen. When one stops serving us, we change it — in a pull request, against this repository, with the reasoning written down. A standard that cannot be justified is a standard that should be removed.
