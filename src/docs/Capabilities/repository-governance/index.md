---
title: Repository Governance
description: How every repository in an organization is classified, protected, and continuously reconciled against the controls its classification declares.
---

# Repository Governance

Making "every repository is protected" true of every repository without anyone
checking: a repository declares **what kind of thing it is**, and that
declaration is the only input that decides which branch protections, required
checks, review gates, and required files apply to it.

Classification is data on the repository. Controls are organization-level
configuration that reads that data. Nothing is configured per repository, so
there is nothing per repository to drift.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for repository governance — classification-driven protection, a common baseline for every governed repository, explicit exemption, and continuous reconciliation. |
| [Design](design.md) | How repository governance is built — a multi-select type property, organization rulesets selected by type, and continuous drift detection with graded reconciliation. |
| [Repository Types](design-types.md) | The repository type catalogue — the branch-model types, the layering types, the exemption type, and the rules by which they compose. |

<!-- INDEX:END -->
