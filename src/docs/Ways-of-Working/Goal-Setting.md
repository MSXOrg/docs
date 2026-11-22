---
title: Goal-Setting Framework
description: Mission, OKRs, and Initiatives define strategy above repository Epics.
---

# Goal-Setting Framework

MSX uses an OKR-based framework to connect strategy to delivery work. The hierarchy connects the organization's purpose to individual deliverables in GitHub issues.

## Layers

| Layer          | Lives in                                     | Purpose                                                                                      |
| -------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Mission**    | Pinned issue in the org `.github` repository | The org's reason to exist — *make great software delivery the default: easy, fast, and safe* |
| **OKR**        | Sub-issues of the Mission                    | Qualitative objectives + measurable key results                                             |
| **Initiative** | Sub-issues of an OKR                         | An organization-level effort to improve a Key Result                                        |

## Why OKRs and not KPIs

- **Objectives** describe an ambitious qualitative outcome from the consumer's perspective.
- **Key Results** measure progress toward the Objective. They guide incentives without prescribing how contributors reach the outcome.

An OKR tells contributors, users, and agents which outcome their work can support. See [Principles](Principles/index.md) for the rationale.

## Current OKRs

OKRs are sub-issues of the Mission issue in the organization's `.github` repository. They express the organization's continuing goals:

- Every developer — and every agent — ships with confidence.
- Automation handles mechanical work so people can focus on judgment.
- AI contributes reliably to the work.

## From strategy to delivery

Mission, OKR, and Initiative define strategy **above Epic**. An Initiative links to the repository Epics that deliver its outcome. Each participating repository owns its own Epic. The canonical [Issue Hierarchy](Issues/Types/Hierarchy.md) owns all decomposition and delivery semantics from Epic downward.

```text
Mission (org-level, evergreen)
└── OKR (qualitative objective + key results)
    └── Initiative (concrete bet to move a KR)
        ├── Epic (repository A)
        └── Epic (repository B)
```

The arrow from Initiative to Epic is a strategy-to-delivery link, not a replacement for the native relationships inside a repository. Epic and lower issue types follow the [Issue Planning](Issues/Process/Planning.md) and [Issue Relationships](Issues/Process/Relationships.md) guidance.
