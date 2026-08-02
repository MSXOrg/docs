---
title: Design
description: How the agentic development framework is built — OKF documentation, org memory, thin repo pointers, and deterministic context resolution.
---

# Agentic Development — Design

The behavior in the [spec](spec.md) is delivered by an organization-level documentation and memory pair, adopted by each product repository through thin pointer files. The design keeps project knowledge in one reviewed place, keeps working memory in one durable place, and lets each agent runtime adapt without copying process knowledge.

## Organization anatomy

The GitHub organization is the project boundary. The host distinguishes work from personal projects; the organization selects the project context.

```text
<host>/<org>/
  docs/      # canonical knowledge base; changes through pull requests
  memory/    # durable agent and team memory; versioned working knowledge
  <repo-a>/  # product or component repository
  <repo-b>/
```

Current project scopes follow the same shape:

| Host | Organization | Docs | Memory |
| --- | --- | --- | --- |
| `dnb.ghe.com` | `AI-Platform` | `AI-Platform/docs` | `AI-Platform/memory` |
| `github.com` | `MSXOrg` | `MSXOrg/docs` | `MSXOrg/memory` |
| `github.com` | `PSModule` | `PSModule/docs` | `PSModule/memory` |

## Repository roles

### `docs`

The `docs` repository is the canonical knowledge base. It owns:

- vision, principles, and ways of working;
- coding standards and documentation standards;
- framework and capability specs and designs;
- project glossary and onboarding;
- the canonical Workflow and its linked stage procedures.

Changes to `docs` happen through pull requests because this repository defines durable project intent.

### `memory`

The `memory` repository is the durable working-memory store. It owns:

- recurring gotchas and lessons learned;
- active project context that should survive a single chat session;
- workflow-stage working knowledge;
- issue, PR, and incident notes worth reusing;
- project-specific preferences that are factual rather than private user preference.

Memory pages stay short and factual. They are safe to read before work begins and safe to improve when a lesson is learned.

### Product repositories

Product repositories carry local context and thin pointers:

```text
<repo>/
  AGENTS.md                        # required: the router, and the only file with content
  .claude/
    CLAUDE.md                      # required: routes Claude Code — @../AGENTS.md
  .github/
    copilot-instructions.md        # required: routes the Copilot surfaces that need it
    instructions/
      <scope>.instructions.md      # exceptional: a path-scoped local caveat
  README.md
  CONTRIBUTING.md
  docs/
```

`AGENTS.md` and the routes that reach it are carried by every repository. A path-scoped instruction file appears only where a local caveat has nowhere better to live. The repository owns only repository-specific nuance: bootstrap entry points, build commands, contribution mechanics, architecture notes, local exceptions, and path-scoped rules. Cross-cutting standards remain in `docs`; reusable lessons remain in `memory`. Thin means "no duplicated reusable process," not "discard the local operating contract."

## OKF page model

Both `docs` and `memory` use the [Open Knowledge Format](../../Dictionary/index.md#open-knowledge-format) style: Markdown with YAML frontmatter, one concept per page, paths as stable identity, and indexes as navigation maps.

Minimum page frontmatter:

```yaml
---
title: Agentic Development
description: One-line description of the page.
---
```

Memory pages MAY add scope-oriented metadata when it helps agents filter context:

```yaml
---
title: GitHub Actions cache gotchas
description: Reusable notes for cache failures and permissions.
scope: project
tags:
  - github-actions
  - cache
  - gotcha
---
```

The body stays concise. If a page grows into multiple concepts, split it and link through the nearest `index.md`.

## Indexes as the mindmap

Indexes are the navigation layer. An agent starts at the root index, reads descriptions, then drills inward until it reaches the relevant page.

```text
docs/
  index.md
  Ways-of-Working/index.md
  Ways-of-Working/Workflow.md
  Ways-of-Working/Workflow-Stages/index.md
  Coding-Standards/index.md
  Capabilities/index.md
  Capabilities/agentic-development/index.md

memory/
  index.md
  agents/index.md
  knowledge/index.md
  gotchas/index.md
```

Every index describes what sits below it. Generated indexes are preferred where tooling exists; manually maintained indexes are acceptable when the memory repository is intentionally lightweight.

## Context resolution flow

```mermaid
flowchart TD
  start["Agent receives task"] --> policy["System and client policy"]
  policy --> user["User-global preferences"]
  user --> pointer["Read AGENTS.md pointer"]
  pointer --> locate["Resolve host, org, docs, and memory roots"]

  locate --> host{"Which project scope?"}
  host -->|"dnb.ghe.com / AI-Platform"| aip["AI-Platform context"]
  host -->|"github.com/MSXOrg"| msx["MSXOrg context"]
  host -->|"github.com/PSModule"| psmodule["PSModule context"]

  aip --> refresh["Refresh selected docs + memory<br/>stop unless exactly synchronized"]
  msx --> refresh
  psmodule --> refresh
  refresh --> repo["Read README, CONTRIBUTING,<br/>and local docs"]
  repo --> path["Apply path-scoped local rules"]
  path --> initiative["Read the initiative's<br/>governing documentation"]
  initiative --> docs["Read central docs index"]
  docs --> workflow["Follow indexes to Workflow"]

  workflow --> stage["Infer current stage<br/>read canonical procedure"]
  stage --> memory["Read memory last"]
  memory --> task["Read issue, PR, branch, diff, diagnostics, and open files"]
  task --> act["Act and follow stage handoffs"]

  act --> newpath{"New file path touched?"}
  newpath -->|"Yes"| path
  newpath -->|"No"| done["Respond, commit, or open PR"]
```

Resolution is deterministic. If the active repository remote is `github.com/PSModule/Json`, the selected project context is `PSModule`; if it is `github.com/MSXOrg/docs`, the selected project context is `MSXOrg`. Multi-root workspaces use the active file, explicit user prompt, current terminal directory, or branch repository to select the project. Ambiguity is resolved by asking the user before acting.

## Pointer files

`AGENTS.md` is the cross-runtime router. It identifies the project, carries the bootstrap steps and local nuance an agent needs before it can reach context, and then sends the reader outward in a fixed order. It routes to the discovery trail, not to a stage-specific tool file.

```markdown
# Agent Instructions

This repository belongs to `github.com/MSXOrg`.

Before changing files:

1. Segment the work by host, organization, repository, path, and task.
2. Refresh every canonical context repository and stop unless each exactly matches its remote default branch.

Then read outward, nearest first:

1. `README.md` — what this repository is and how it builds.
2. `CONTRIBUTING.md` — how a change is made and reviewed here.
3. `docs/` — this repository's own documentation, when it has any.
4. The initiative's governing documentation — the standards for this family of repositories.
5. The central documentation — `docs/index.md`, then the Ways of Working index to Workflow; infer the current stage and read that procedure and the standards it names.
6. Memory — `memory/index.md`, read last.

Apply path-scoped local rules for the files being changed. Read nearest first, but
a local file never overrides a standard, and memory never overrides documentation.

This file routes; it does not define process knowledge.
```

The index trail is the default. A clear prompt can shortcut stage discovery: `Review this PR <link>` enters Review, `Make this issue <description>` enters Define, and `Implement <issue>` enters Implement. These phrases are routing hints interpreted by [Workflow](../../Ways-of-Working/Workflow.md#find-the-current-stage), not commands with independent procedures.

> **Reading order vs. conflict precedence** — the router reads the repository's own files first and widens outward, because nearest context is cheapest and most specific. Precedence runs the other way: repository files add nuance and narrow exceptions and never silently override an organization standard unless that standard permits a local exception, and memory never overrides documentation.

`.claude/CLAUDE.md` is a single import:

```markdown
@../AGENTS.md
```

Claude Code accepts either `./CLAUDE.md` or `./.claude/CLAUDE.md` as the project file, and resolves a relative import against the file that contains it — so from `.claude/`, the router is `../AGENTS.md`. Writing `@AGENTS.md` there would resolve to `.claude/AGENTS.md` and silently load nothing.

`.github/copilot-instructions.md` has the same shape, for the Copilot surfaces that do not read `AGENTS.md`:

```markdown
Follow the instructions in [AGENTS.md](../AGENTS.md).
```

That is the entire file. It holds no reading order, no workflow, and no standard, so there is nothing in it that can fall out of step with the router. Any future runtime is handled the same way: give it a route under whatever filename it reads, and leave the content in `AGENTS.md`.

Path-scoped instruction files are reserved for local rules that cannot live centrally because they apply only to a repository path, and only when the rule does not belong in `README.md` or `CONTRIBUTING.md` instead. They never define workflow stages.

## Local workspace

A local bootstrap makes central context predictable:

```text
~/.msx/
  docs.git/                    # MSXOrg/docs bare backing repository
  docs/                        # clean MSXOrg/docs main worktree
  memory/                      # simple MSXOrg/memory checkout
  projects/
    PSModule/
      docs.git/                # optional project docs backing repository
      docs/                    # optional project docs main worktree
      memory/                  # optional project memory checkout
```

The bootstrap clones missing repositories and fetches every existing context repository before use. Each clone must be clean, checked out on the remote default branch, and exactly equal to the fetched remote head. A dirty, locally ahead, diverged, wrong-branch, or unreachable clone stops context resolution; the agent does not use a possibly stale local copy. Bootstrap writes repository-local git configuration only.

MSXOrg is the default project. Additional projects plug in a name, relative workspace path, docs URL, and memory URL. For example, PSModule can use `projects/PSModule/{docs,memory}` beneath the same workspace while reusing the identical synchronization and validation path. Repository agent files retain this small coordinate block because it is required before project documentation can be reached; the reusable bootstrap behavior remains central.

## Memory writing rules

Agents write memory only when a lesson is likely to matter again. Good memory is:

- short and factual;
- scoped to the organization;
- linked to the issue, PR, repository, or document that proves it;
- free of secrets, credentials, and private personal notes;
- updated or removed when it becomes wrong.

Session-specific notes stay out of durable memory unless they become reusable project knowledge.

## Client behavior

Different clients load different files, but the framework keeps the same dependency direction. A client that reads `AGENTS.md` needs no file of its own; a client that does not gets a route to it.

| Client | Reads | Behavior |
| --- | --- | --- |
| Cross-client agents | `AGENTS.md` | Read the router, then follow its order outward from the repository to the organization documentation and memory. |
| Claude Code | `.claude/CLAUDE.md` | Imports `../AGENTS.md` and adds nothing else. |
| Copilot Chat in VS Code, and the Copilot cloud agent | `AGENTS.md` | Read `AGENTS.md` natively, including its freshness gate. Path-scoped `.github/instructions/*.instructions.md` files still apply when their `applyTo` pattern matches a file being read, generated, reviewed, or edited. |
| Copilot surfaces without `AGENTS.md` support | `.github/copilot-instructions.md` | Copilot Chat on GitHub.com, Visual Studio, JetBrains, Eclipse, and Copilot code review outside GitHub.com read this file. It routes them to the router and adds nothing else. |
| Copilot code review | Head-branch instructions | Reads repository instructions, agent instructions, and skills from the pull request's **head** branch, not the base branch. |

Because Copilot code review reads the head branch, a pull request that changes `AGENTS.md`, an adapter, or a path-scoped instruction file also changes the instructions used to review that pull request. Those files are therefore reviewed by a human on their own merits, and an automated approval is never treated as independent of them. What this means for repositories that accept outside contributions is still open — see [MSXOrg/docs#123](https://github.com/MSXOrg/docs/issues/123).

## Failure modes

| Failure | Design response |
| --- | --- |
| Repository does not identify its organization context | Infer from remote URL; ask when ambiguous. |
| A docs or memory clone is missing or cannot synchronize | Bootstrap or repair it, then retry. Stop context resolution until every canonical context repository passes the freshness gate. |
| Pointer file duplicates central standards | Replace duplicated content with a route during review. A client file holds a pointer, not a copy. |
| A skill, command, named agent, or instruction file defines a workflow stage | Delete the duplicate procedure and link to Workflow or its stage page. |
| Memory conflicts with docs | Docs win; memory is corrected or removed. |
| Two organizations are open in one workspace | Select by active repository; ask before cross-project changes. |
| A client ignores one pointer format | Add a route file under the filename that client reads, containing only a pointer to `AGENTS.md`. |
| A repository file contradicts an organization standard | The standard governs. Narrow the local file to the exception the standard permits, or change the standard. |

## Adoption path

1. Create or identify the organization `docs` repository.
2. Create or identify the organization `memory` repository, using the [Memory Repository Template](memory-template.md) as the starting scaffold.
3. Add `docs/index.md` and `memory/index.md` as the two root maps.
4. Add the canonical Workflow and linked stage procedures to `docs`.
5. Add starter memory sections to `memory`.
6. Add the `AGENTS.md` router to each product repository, plus a route for every client that cannot read it.
7. Add a bootstrap that keeps local docs and memory clones present and exactly synchronized before use.
8. Review new work for pointer discipline: facts live once, links point to them.

## Where this connects

- [Spec](spec.md) — the requirements this design delivers.
- [Memory Repository Template](memory-template.md) — the concrete scaffold every organization's canonical `memory` repository instantiates.
- [Agentic Development](../../Ways-of-Working/Agentic-Development.md) — the way-of-working standard this framework implements.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why spec and design are split.
- [README-Driven Context](../../Ways-of-Working/Readme-Driven-Context.md) — why local repository context remains the front door.
