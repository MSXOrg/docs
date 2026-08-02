---
title: Spec
description: Requirements for refresh-first, index-first agentic development through canonical documentation, memory, and thin pointers.
---

# Agentic Development — Spec

## Premise

An agent does useful work only when it knows which project it is serving, which standards apply, and what the team has already learned. That context MUST be project-scoped, durable, reviewable, and readable by humans and agents alike. The project boundary is the GitHub organization: `dnb.ghe.com/AI-Platform`, `github.com/MSXOrg`, `github.com/PSModule`, and any future organization that adopts the framework.

Each organization owns two canonical repositories:

- `docs` — the reviewed knowledge base: vision, standards, workflows, specs, designs, glossary, onboarding, and project-wide rules.
- `memory` — the durable agent working memory: lessons learned, recurring gotchas, active context, workflow-stage knowledge, and project-specific operating notes.

Product repositories do not copy that knowledge. They carry thin pointer files that identify the organization context and direct agents to the relevant `docs` and `memory` roots before acting.

### Principles

This framework rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Documentation lives close to the thing it documents](../../Ways-of-Working/Principles/Engineering-Practices.md#documentation-lives-close-to-the-thing-it-documents).** Organization-wide ways of working live in the organization `docs` repository; repository-specific nuance lives in the repository.
- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Standards and memory are plain files in git. Changes are reviewed, diffed, and reverted like code.
- **[Written once, referenced everywhere](../../Ways-of-Working/Agentic-Development.md#principles).** Agent instructions point to canonical docs and memory rather than duplicating them.
- **[AI-first development](../../Ways-of-Working/Principles/AI-First-Development.md).** Humans create durable context; agents consume that context and leave useful improvements behind.

## Scope

Applies to any organization that wants a shared project knowledge base and memory store for agents across multiple repositories.

**In scope**

- Organization-level `docs` and `memory` repositories.
- Markdown documents with YAML frontmatter, following the [Open Knowledge Format](../../Dictionary/index.md#open-knowledge-format) model.
- Thin repository pointer files: a required `AGENTS.md`, and the optional client adapters that import or follow it.
- Refresh-first, index-first discovery from canonical context repositories to the Workflow and its stage procedures.
- Deterministic context resolution by host, organization, repository, path, and task.
- Human-reviewed changes to canonical knowledge through pull requests.
- Durable agent memory that can be shared by every person and agent working in the organization.

**Out of scope**

- A vendor-specific runtime implementation for one agent client.
- Secret storage, credential distribution, or production access management.
- Replacing issue tracking, pull requests, or code review.
- A central database or service for context retrieval.

## Requirements

- **Organization is the project boundary.** The framework MUST resolve project context from the Git host and organization before resolving repository-specific context.
- **Canonical docs repository.** Each adopting organization MUST have a `docs` repository that owns the reviewed knowledge base.
- **Canonical memory repository.** Each adopting organization MUST have a `memory` repository that owns durable project memory and agent working knowledge.
- **Pluggable project context.** The bootstrap MUST accept project-specific docs and memory coordinates and collision-free relative workspace paths without requiring a fork of its synchronization logic.
- **OKF-style documents.** Knowledge and memory documents MUST be Markdown files with YAML frontmatter, one primary concept per page, and stable paths that act as identity.
- **Small pages and indexes.** Documentation and memory SHOULD prefer small pages, each folder SHOULD have an `index.md`, and indexes MUST let a human or agent navigate inward from the root.
- **Thin pointer files.** Product repositories MUST carry an `AGENTS.md` that identifies the organization context and links to the canonical docs and memory root indexes. It MAY retain agent-only bootstrap steps and repository-specific operating instructions needed to reach or safely change that context. It MUST NOT duplicate standards, workflow stages, or reusable process knowledge.
- **Refresh-first, index-first workflow discovery.** After every canonical context repository passes the freshness gate, a human or agent MUST be able to follow the docs root index to Ways of Working, the canonical Workflow, and the procedure for the current stage.
- **Stage resolution from work.** Agents MUST infer the current stage from the prompt and current artifacts. Explicit task language MAY shortcut to the matching stage, but the shortcut MUST resolve to the canonical documentation.
- **One process source.** Skills, commands, named agents, and tool-specific instruction files MUST NOT redefine Workflow stages. A client convenience MAY link to a stage procedure and add only runtime mechanics.
- **Segmentation before loading.** Local agent files MUST instruct agents to segment work by host, organization, repository, path, and task before loading project standards or memory.
- **Client adapters.** Tool-specific files such as `CLAUDE.md`, `.github/copilot-instructions.md`, and `.github/instructions/*.instructions.md` MAY add runtime-specific loading or path rules, but MUST point back to the same canonical roots and MUST NOT define workflow behavior. An adapter is OPTIONAL, and a repository SHOULD add one only when a runtime surface it relies on does not read `AGENTS.md`, because a second file repeating the same pointer drifts from it. This requirement is deliberately broader than [Agentic Development](../../Ways-of-Working/Agentic-Development.md#which-agent-files-a-repository-carries), which states which files an MSX repository carries by default; an adopting organization MAY carry whichever adapters its own runtimes require.
- **Deterministic context resolution.** Agents MUST resolve context in layers: system and client policy, user preferences, repository pointer, context-repository freshness gate, organization docs, organization memory, repository context, path-specific rules, then current task context.
- **Local-first availability.** The docs and memory repositories SHOULD be available locally in a predictable workspace so agents can read them without relying on search or web access.
- **Fresh context before use.** Every canonical context repository MUST be fetched and exactly synchronized with its remote default branch before its contents are read. Dirty, locally ahead, diverged, wrong-branch, or unreachable repositories MUST stop context resolution rather than fall back to stale content.
- **Reviewed knowledge changes.** Changes to the `docs` repository MUST happen through pull requests. Changes to memory MAY be lighter-weight, but MUST remain versioned in git.
- **No cross-project bleed.** An agent working in one organization MUST NOT apply another organization's standards or memory unless the current task explicitly asks for cross-organization work.
- **Traceable memory.** Memory entries SHOULD identify the context they came from and SHOULD be short, factual, and linked to the relevant issue, pull request, document, or repository when one exists.

## Success criteria

- An agent working in `github.com/PSModule/<repo>` reads PSModule docs and memory, not MSXOrg or AI-Platform rules.
- An agent working in `github.com/MSXOrg/<repo>` resolves `github.com/MSXOrg/docs` and `github.com/MSXOrg/memory` as the canonical project context.
- An agent working in `dnb.ghe.com/AI-Platform/<repo>` resolves `dnb.ghe.com/AI-Platform/docs` and `dnb.ghe.com/AI-Platform/memory` as the canonical project context.
- A new product repository can adopt the framework by adding pointer files without copying standards or memory pages.
- A human can start at `docs/index.md` or `memory/index.md` and navigate to the same context an agent uses.
- A human or agent can follow `docs/index.md` → Ways of Working → Workflow → the current stage procedure without knowing a file path in advance.
- A prompt such as `Review this PR <link>` reaches the Review procedure directly, while `Make this issue <description>` reaches Define, without a parallel process definition.
- A missing, dirty, locally ahead, diverged, wrong-branch, or unreachable canonical context repository stops discovery before any context index is read.
- Updating a standard in `docs` changes the canonical guidance without editing every repository.
- Capturing a recurring lesson in `memory` makes it available to later agents working in the same organization.

## Context resolution contract

The framework uses this normative resolution order:

1. **System and client policy** — non-project instructions imposed by the agent runtime.
2. **User-global preferences** — the human operator's baseline style and risk posture.
3. **Repository pointer** — `AGENTS.md` identifies the host, organization, canonical docs root, memory root, and repository-local nuance.
4. **Freshness gate** — fetch every canonical context repository and stop unless each clean default-branch checkout exactly matches its remote head.
5. **Organization docs** — start at `docs/index.md`, traverse to Ways of Working and Workflow, resolve the current stage, then load the relevant standards, specs, and designs.
6. **Organization memory** — start at `memory/index.md`, then load relevant lessons, gotchas, and active context.
7. **Repository context** — README, CONTRIBUTING, local docs, and narrow repository exceptions.
8. **Path-specific rules** — scoped local rules that apply to the files being read, generated, reviewed, or edited.
9. **Current task context** — issue, pull request, prompt, branch, diff, diagnostics, terminal output, and open files; use these artifacts to re-evaluate the stage after each handoff.

A lower layer MAY refine a higher layer, but MUST NOT contradict it unless the higher layer explicitly allows a local exception.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Memory Repository Template](memory-template.md) — the concrete scaffold every organization's canonical `memory` repository instantiates.
- [Agentic Development](../../Ways-of-Working/Agentic-Development.md) — the existing way-of-working standard this framework operationalizes.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — how specs and designs are written and kept evergreen.
- [Open Knowledge Format](../../Dictionary/index.md#open-knowledge-format) — the Markdown and frontmatter model used for knowledge pages.
