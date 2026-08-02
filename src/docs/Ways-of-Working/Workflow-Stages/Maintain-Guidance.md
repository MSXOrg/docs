---
title: Maintain Workflow Guidance
description: Maintain the canonical Workflow stage procedures and the thin repository pointers that lead to them.
---

# Maintain Workflow Guidance

Maintain the canonical [Workflow](../Workflow.md), the stage procedures in this section, and the per-repository pointer files that lead to the documentation root. Every pointer file stays thin. This maintenance path keeps the indexes, workflow, procedures, and pointers coherent; it does not encode process knowledge in configuration.

## Enter this maintenance path when

Create a new workflow stage, update an existing stage, review workflow discoverability, or refactor a bloated agent file back into a thin pointer to the documentation root.

## Flow

### 1. Gather requirements

1. Identify the stage — its entry condition, job, handoff, and boundary.
2. Identify the docs pages that govern the stage; confirm they exist.
3. Identify what the stage must **not** do — boundaries prevent scope creep.

### 2. Author the description

Write the stage as a page in this section, following the shape of its siblings: front matter (`title`, `description`), a one-paragraph purpose and boundary, entry condition, input, numbered flow, operating rules, and a "Where this connects" list.

- **Link, don't inline.** If a standard exists in the docs, link to it — never paste it in.
- **Procedural, not conversational.** Numbered imperatives, no filler.
- **Keyword-rich description.** The front-matter `description` is the discovery surface.

### 3. Keep pointers thin

A repository never carries a copy of the workflow. Its `AGENTS.md` — with the `CLAUDE.md` that imports it, and any optional adapter the repository has taken on — points to these pages and adds only repo-specific nuance and the genuinely tool-specific settings (permission scopes, model choice) that cannot be expressed as a pointer. When a new runtime is adopted, add a thin pointer only where that runtime cannot read `AGENTS.md`; do not move process knowledge into it. See [Agentic Development](../Agentic-Development.md#which-agent-files-a-repository-carries).

### 4. Validate

1. Front-matter YAML parses cleanly.
2. Every link resolves, and the body duplicates no doc content.
3. The stage is added to the navigation so its index row generates.

## Operating rules

1. Docs are the source of truth. If a standard is missing, propose adding it to the docs — do not embed it in an agent.
2. One stage, one job and handoff. Distinct stages use distinct pages.
3. Update the navigation when adding or removing a stage.

## Where this connects

- [Agentic Development](../Agentic-Development.md) — the pointer model this maintains.
- [Documentation Model](../Documentation-Model.md) — how these pages stay evergreen.
