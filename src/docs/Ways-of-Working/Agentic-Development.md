---
title: Agentic Development
description: How ways of working, standards, and documentation are authored once and consumed by both humans and agents.
---

# Agentic Development

How the ecosystem's ways of working, coding standards, and documentation are authored — and how both humans and agents consume them. The documentation defines how work is done; agent configuration *references* that documentation, never the other way around.

## Premise

Process knowledge — how to open an issue, how to review a pull request, how Terraform is written — belongs in documentation, written once for two audiences. The temptation is to encode it as a tool-specific "skill" or instruction file, tightly coupled to one agent's format and scattered across repositories. That inverts the relationship and guarantees drift: the same rule, copied into many tool files, disagrees with itself the moment one copy changes.

The specification fixes the direction of the dependency. The docs are the **stable core** that states how work is done. Agent configuration files are **thin pointers** to those docs — the same pages a new team member would read. Adding or swapping an agent runtime means writing new pointers, not rewriting process knowledge.

## Principles

This spec rests on the [Principles](Principles/index.md). Four apply directly:

- **Written once, referenced everywhere.** A standard, a process, or a convention is defined in exactly one place and linked from everywhere else. Agent config, repository docs, and tool integrations point to that definition — they never duplicate it. This is [DRY](Principles/Software-Design.md#dry-with-judgment) applied to process knowledge.
- **[Documentation lives close to the thing it documents](Principles/Engineering-Practices.md#documentation-lives-close-to-the-thing-it-documents).** Repo-specific context lives in the repository; cross-cutting guidance lives in the org-level docs and is referenced by its canonical URL. An agent always reads the repository's own context first.
- **[AI-first development](Principles/AI-First-Development.md).** Humans create context — in issues, docs, and decisions — and agents act on it. Because agents are trained to read documentation, keeping standards in documentation form serves both audiences with a single artifact; no separate "agent manual" exists.
- **[Extensible by default](Principles/Software-Design.md#extensible-by-default).** Ways of working and standards are the stable core. Coding agents are adapters that plug in. The system is pluggable: the docs do not change when a new runtime is added — only a new integration layer is written.

## Architecture

Agent configuration files are **pointers, not process containers**. They identify canonical context and may retain the bootstrap steps and repository-specific operating instructions an agent needs before it can reach that context. They do not select a persona, copy workflow stages, or restate standards. Documentation lives where it belongs — repo-specific context in each repository's `README.md`, `CONTRIBUTING.md`, and `docs/`; cross-cutting guidance in the org-level documentation site.

When an agent receives work, it follows the same documentation trail a human can follow:

```mermaid
flowchart TD
  task["Agent receives work"] --> pointer["1 Read AGENTS.md<br/>resolve project docs + memory roots"]
  pointer --> refresh["2 Refresh every context repository<br/>stop unless exactly synchronized"]
  refresh --> root["3 Read docs/index.md"]
  root --> ways["4 Follow Ways of Working index"]
  ways --> workflow["5 Read Workflow"]
  workflow --> stage["6 Infer the current stage<br/>read its procedure"]
  stage --> context["7 Read relevant standards,<br/>repository context, and memory"]
  context --> work["Act and follow stage handoffs"]
```

Refresh is a gate before traversal, not a best-effort background step. After it passes, the indexes are the default discovery mechanism. [Workflow](Workflow.md) owns the process and routes the work to a [stage procedure](Workflow-Stages/index.md); the stage page then points to the standards and artifacts it consumes. A clear prompt such as `Review this PR <link>` may shortcut directly through the Workflow routing table, but it does not create a second process definition. **Local files never replace central standards — they layer specifics on top.**

## Where documentation lives

Documentation is not collected into a single repository. Each page is authored and maintained where it naturally belongs:

| Scope | Home | Examples |
| --- | --- | --- |
| **Cross-cutting** — ways of working, coding standards, capabilities | The org-level documentation site | This site: <https://msxorg.github.io/docs/> |
| **Repo-specific** — architecture, setup, domain context | The repository that owns it | `README.md`, `CONTRIBUTING.md`, `docs/` |

This split follows [Repository Segmentation](Repository-Segmentation.md) and [README-Driven Context](Readme-Driven-Context.md): the README is the front door of a repository, and the org-level site is the front door of the ecosystem.

## How an agent runtime plugs in

Each repository carries an `AGENTS.md` that points to the organization documentation and memory root indexes. A `CLAUDE.md` or other client adapter may import that pointer and add only the small amount of genuinely tool-specific configuration, such as permission scopes or path matching, that cannot live in ordinary documentation.

Any new runtime follows the same pattern, regardless of vendor:

- A **context pointer** that identifies the canonical docs and memory root indexes.
- Optional **keyword shortcuts** that route a clearly stated task to the matching [Workflow stage](Workflow.md#find-the-current-stage) without copying its procedure.
- **Tool-specific settings** — permissions, model selection, and the like.

There is no separate process surface for Define, Implement, or Review. If a client exposes a skill, command, named agent, or other convenience, it links to the canonical stage page and adds no process knowledge. When a new runtime is adopted, only this thin integration layer is added.

## Distribution

The two non-documentation layers have different distribution models:

- **The canonical process** lives in [Workflow](Workflow.md), which links to ordinary documentation pages for each [stage procedure](Workflow-Stages/index.md).
- **Per-repository pointer files** — `AGENTS.md`, the `CLAUDE.md` that imports it, and any path-scoped local-rule adapters — are seeded from a template repository and kept current across existing repositories by a sync mechanism.

Process knowledge is never added to a distributed config file. If an agent needs the branch strategy, it goes in [Branching and Merging](Branching-and-Merging.md) or the repo's `CONTRIBUTING.md`; if it needs a coding convention, it goes in the relevant [coding standard](../Coding-Standards/index.md). The config file only points — it never defines.

## The workspace bootstrap

The **user-global** entry file is a thin **bootstrap**, not a copy of the docs. Each runtime auto-loads its own user-level file — Copilot from its user instructions, Claude Code from `~/.claude/CLAUDE.md` (which imports the same instructions) — and its first instruction is to make the central workspace present locally, then start at the root indexes. This is distinct from the per-repository `AGENTS.md` and `CLAUDE.md`, which remain thin pointers to the same roots.

The workspace is a git-isolated clone of the central repositories under `~/.msx`:

- `~/.msx/docs` — this documentation, read as local files. Changes to it go through pull requests.
- `~/.msx/memory` — durable notes and prior session context. Changes to it are pushed to main.

Each clone carries repository-local git config only, so the workspace never modifies the global git config or the repository the agent is working in — git still reads them, but only repository-local config is written. Before context is read, [`bootstrap/Initialize-MsxWorkspace.ps1`](https://github.com/MSXOrg/docs/blob/main/bootstrap/Initialize-MsxWorkspace.ps1) clones missing repositories and requires every existing context repository to be clean, on its remote default branch, and exactly synchronized with the remote head. Any update failure stops context resolution rather than allowing stale guidance or memory.

The workspace makes the *central* context present locally; the same local-first stance shapes how each working repository is laid out. Repositories are cloned as [git worktrees](Git-Worktrees.md) — one working directory per branch — so a person and an agent, or several agents, can work on multiple issues in the same repository at once without stashing or switching branches.

## Where this connects

- [Git Worktrees](Git-Worktrees.md) — how this framework is implemented on a local machine, so several pieces of work run in parallel.
- [Documentation Model](Documentation-Model.md) — the discipline this specification follows.
- [Principles](Principles/index.md) — the beliefs this specification rests on, including the three-layer agent context model.
- [README-Driven Context](Readme-Driven-Context.md) — why the repository's own context comes first.
- [Coding Standards](../Coding-Standards/index.md) — the cross-cutting standards agents pick up in the central layer.
