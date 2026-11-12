---
title: Maintain Workflow Guidance
description: Maintain the canonical Workflow stage procedures and the thin repository pointers that lead to them.
---

# Maintain Workflow Guidance

Maintain the canonical [Workflow](../Workflow.md), its stage procedures, and the per-repository pointer files that lead to the documentation root. Every pointer file stays thin. This maintenance path keeps the indexes, workflow, procedures, and pointers coherent; it does not encode process knowledge in configuration.

## Enter this maintenance path when

Create a workflow stage, update a stage, review workflow discoverability, or replace duplicate process instructions in an agent file. The replacement is a thin pointer to the documentation root.

## Flow

### 1. Gather requirements

1. Identify the stage — its entry condition, job, handoff, and boundary.
2. Identify the docs pages that govern the stage; confirm they exist.
3. Identify what the stage must **not** do — boundaries prevent scope creep.

### 2. Author the description

Write the stage as a page in this section with the same structure as the other stages. Include front matter (`title`, `description`), a one-paragraph purpose and boundary, entry condition, input, numbered flow, operating rules, and a "Where this connects" list.

- **Link to the source.** If a standard exists, link to it. Do not copy its content into the procedure.
- **Procedural, not conversational.** Numbered imperatives, no filler.
- **Keyword-rich description.** The front-matter `description` is the discovery surface.

### 3. Keep pointers thin

A repository never carries a copy of the workflow. Its `AGENTS.md` and client routes identify documentation destinations; they do not copy the workflow. Repository-specific instructions belong in `README.md`, a local contribution guide [when needed](../Repository-Standard.md#contribution-guidance), and the repository's own `docs/`. The router points to those sources or to inherited contribution guidance; it does not repeat their content. When the repository adopts another runtime, add a route under the filename that runtime reads. Keep process definitions out of the route. See [Agentic Development](../../Capabilities/agentic-development/design.md#client-behavior).

### 4. Validate

1. Verify that front-matter YAML parses.
2. Verify that every link resolves and that the body duplicates no documentation.
3. Add the stage to navigation so its index row generates.

## Operating rules

1. Docs are the source of truth. If a standard is missing, propose adding it to the docs — do not embed it in an agent.
2. One stage, one job and handoff. Distinct stages use distinct pages.
3. Update the navigation when adding or removing a stage.

## Where this connects

- [Agentic Development](../../Capabilities/agentic-development/index.md) — the pointer model this maintains.
- [Documentation Model](../Documentation-Model.md) — evergreen workflow guidance.
