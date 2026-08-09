---
title: Goal-Setting Framework
description: Mission, OKRs, and Initiatives — the strategy above repository Epics.
---

# Goal-Setting Framework

MSX uses a lightweight OKR-based framework to connect strategic direction to day-to-day work. The hierarchy runs from the organization's reason to exist down to individual deliverables tracked in GitHub issues.

## Layers

| Layer          | Lives in                                     | Purpose                                                                                      |
| -------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Mission**    | Pinned issue in the org `.github` repository | The org's reason to exist — *make great software delivery the default: easy, fast, and safe* |
| **OKR**        | Sub-issues of the Mission                    | Qualitative objectives + measurable key results                                             |
| **Initiative** | Sub-issues of an OKR                         | A concrete organization-level bet to move a Key Result                                      |

## Why OKRs and not KPIs

- **Objectives** are qualitative, aspirational, and outside-in. They describe a state of the world we want to see.
- **Key Results** are measurements that confirm the Objective is being met. They drive incentive in the right direction without prescribing the path.

A good OKR is one that anyone — contributor, user, or agent — can read and immediately have ideas about how to contribute. See [Principles](Principles/index.md) for the full rationale.

## Current OKRs

OKRs are tracked as sub-issues of the Mission issue in the org `.github` repository. They evolve over time; the direction they encode stays constant:

- Every developer — and every agent — ships with confidence.
- Automation handles the mechanical, so human attention is spent on judgment.
- AI is a first-class, reliable contributor to the work.

## From strategy to delivery

Mission, OKR, and Initiative are the strategy layers. The strategy boundary sits **above Epic**: an Initiative links to the repository Epics that deliver its outcome, and each participating repository owns its own Epic. The canonical [Issue Hierarchy](Issues/Types/Hierarchy.md) owns all decomposition and delivery semantics from Epic downward.

```text
Mission (org-level, evergreen)
└── OKR (qualitative objective + key results)
    └── Initiative (concrete bet to move a KR)
        ├── Epic (repository A)
        └── Epic (repository B)
```

The arrow from Initiative to Epic is a strategy-to-delivery link, not a replacement for the native relationships inside a repository. Epic and lower issue types follow the [Issue Planning](Issues/Process/Planning.md) and [Issue Relationships](Issues/Process/Relationships.md) guidance.
