---
title: Design
description: Architecture and implementation model for making GitHub PowerShell-native through modules, actions, and gap-closing workflows.
---

# Design

## Capability model

The model combines two tracks:

- Build it: implement missing behavior using available GitHub and ecosystem APIs.
- Advocate it: document and escalate platform-native features that require vendor support.

## Architecture components

1. Module collection
   - reusable PowerShell modules grouped by domain (language helpers, data formats, networking, security, API clients)
2. Automation collection
   - reusable GitHub Actions for prepare, build, test, lint, document, publish, and release stages
3. Orchestration framework
   - Process-PSModule pipeline to drive module lifecycle and release behavior
4. Parity gap backlog
   - capability gaps mapped to either implementation or advocacy tracks

## Operating pattern

- Keep component-level details in initiative/module docs.
- Keep reusable architecture and decision rationale here.
- Link initiative pages to this capability as canonical context.

## Current canonical references

- PSModule initiative overview: ../../Initiatives/PSModule.md
- Process-PSModule framework: ../../Frameworks/Process-PSModule/index.md
- Coding standards baseline: ../../Coding-Standards/index.md

## Planned evolution

- Add a capability-level parity matrix with status per gap.
- Track implementation maturity for each build-it stream.
- Add explicit ownership and review cadence for advocacy items.
