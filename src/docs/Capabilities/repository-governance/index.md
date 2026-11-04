---
title: Repository Governance
description: Repository classification, shared controls, and continuous comparison of declared and live configuration.
---

# Repository Governance

A repository declares its **type**. That declaration is the only input that
selects its branch protections, required checks, review gates, and required files.

Classification is repository data. Controls are shared organization-level
configuration that reads that data. Reconciliation compares each repository with
the controls its type requires.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for repository governance — classification-driven protection, a common baseline for every governed repository, explicit exemption, and continuous reconciliation. |
| [Design](design.md) | How repository governance is built — a multi-select type property, organization rulesets selected by type, and continuous drift detection with graded reconciliation. |
| [Repository Types](design-types.md) | The repository type catalogue — the branch-model types, the layering types, the exemption type, and the rules by which they compose. |

<!-- INDEX:END -->
