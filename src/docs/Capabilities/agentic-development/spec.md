---
title: Spec
description: Requirements for refresh-first, index-first agentic development through canonical documentation, memory, and thin pointers.
---

# Agentic Development — Spec

## Premise

An agent does useful work only when it knows which project it is serving, which standards apply, and what the team has already learned. That context MUST be project-scoped, durable, reviewable, and readable by humans and agents alike. The project boundary is the GitHub organization — `github.com/MSXOrg`, `github.com/PSModule`, and any other organization that adopts the framework, on any GitHub host.

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
- Thin repository pointer files: a required `AGENTS.md` router, and a route to it for every client that cannot read it.
- Path-scoped rule files, reserved for local caveats that cannot live in repository or central documentation.
- The shared tool layer agents call out to, and how each runtime declares it.
- Named intents that package recurring workflows as pointers to canonical procedure.
- Advisory automation that publishes judgement without taking authority.
- Coordination between humans and agents on platform artifacts.
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
- **Thin pointer files.** Product repositories MUST carry an `AGENTS.md` at the repository root that routes an agent from the repository's own files outward to the organization documentation, any inherited ecosystem documentation, and memory. It MUST be limited to that route list and the repository's own coordinates. It MUST NOT duplicate standards, workflow stages, or reusable process knowledge, and MUST NOT carry build commands, contribution mechanics, or workspace bootstrap steps, each of which has an owning file of its own.
- **Refresh-first, index-first workflow discovery.** After every canonical context repository passes the freshness gate, a human or agent MUST be able to follow the docs root index to Ways of Working, the canonical Workflow, and the procedure for the current stage.
- **Stage resolution from work.** Agents MUST infer the current stage from the prompt and current artifacts. Explicit task language MAY shortcut to the matching stage, but the shortcut MUST resolve to the canonical documentation.
- **One process source.** Skills, commands, named agents, and tool-specific instruction files MUST NOT redefine Workflow stages. A client convenience MAY link to a stage procedure and add only runtime mechanics.
- **Segmentation before loading.** An agent MUST segment work by host, organization, repository, path, and task before loading project standards or memory. The repository router MUST supply the coordinates that make this possible by naming its host and organization. The instruction to segment belongs to the user-global bootstrap, which runs before any repository file is read; a per-repository file MUST NOT restate it.
- **Client routes.** A runtime that cannot read `AGENTS.md` under its own filename MUST be given a route file — `.claude/CLAUDE.md`, `.github/copilot-instructions.md`, or the equivalent path for that runtime. A route file MUST contain only a pointer to `AGENTS.md` plus, at most, genuinely runtime-specific configuration that cannot be expressed as documentation. It MUST NOT restate standards, describe workflow behavior, or repeat the reading order. Duplication is a property of content rather than of filenames: a route holds nothing that can drift, so the number of route files is unconstrained while their contents are strictly limited. [Agentic Development](../../Ways-of-Working/Agentic-Development.md#which-agent-files-a-repository-carries) names the exact set an MSX repository carries; an adopting organization MAY carry a different set for the runtimes it uses.
- **Reading order and authority order are distinct.** An agent MUST read nearest context first, in the order the repository router defines. Precedence on conflict MUST run the opposite way: repository-local files MAY add nuance and narrow exceptions but MUST NOT override an organization or inherited ecosystem standard unless that standard permits a local exception, and memory MUST NOT override documentation.
- **Deterministic context resolution.** Agents MUST resolve context in layers: system and client policy, user preferences, the repository router, the context-repository freshness gate, repository context, path-scoped repository rules, organization docs, any inherited ecosystem docs, organization memory, then current task context.
- **Local-first availability.** The docs and memory repositories SHOULD be available locally in a predictable workspace so agents can read them without relying on search or web access.
- **Fresh context before use.** Every canonical context repository MUST be fetched and exactly synchronized with its remote default branch before its contents are read. Dirty, locally ahead, diverged, wrong-branch, or unreachable repositories MUST stop context resolution rather than fall back to stale content.
- **Working checkouts are not context sources.** Canonical context MUST be read from the context repository clones that passed the freshness gate. A working checkout of a `docs` or `memory` repository — one cloned in order to change it rather than to be governed by it — MUST NOT be used as a context source, whatever path it occupies, because it sits outside the gate: nothing fetches it, and a superseded page in it is readable rather than missing, so the failure is silent. A reader MAY establish whether any checkout is current with `git rev-list --left-right --count HEAD...origin/<default-branch>` after fetching, which reports commits ahead and behind without changing the working tree.
- **Refresh once per session, not once per machine.** The freshness gate MUST run at the start of every agent session, in every runtime. A workspace that was synchronized at some earlier point MUST NOT be treated as current, because elapsed time is not a state the agent can observe. The refresh MUST be idempotent, so that running it when nothing has changed is cheap and silent; a refresh that is expensive or noisy at steady state gets bypassed, and a bypassed gate is worse than none because the workspace still appears synchronized.
- **Memory is scoped by horizon.** Memory MUST separate entries that apply organization-wide, entries that apply to one repository, and notes that apply only to the task in hand. Session-scoped notes MUST NOT be shared: they MUST be excluded from the repository's history so that a scratchpad cannot be inherited as knowledge. Making a session note durable MUST be a deliberate act of promotion, which is where the entry is checked for whether it is actually true.
- **Durable memory is committed as it is written.** A memory entry MUST be committed and pushed when it is written, one commit per discrete lesson, so that no remembered thing depends on a session ending cleanly.
- **One tool layer, declared per runtime.** Where agents use external tools, the set of tool servers MUST be defined once as a logical layer and each runtime MUST declare that same set in its own native configuration format. A runtime MUST NOT define tools of its own that other runtimes lack, because a capability available in one client and absent in another makes the documented procedure conditional on which client is running it.
- **Named intents stay pointer-based.** A packaged shortcut for a recurring workflow — however a runtime names it — MUST resolve to the canonical documentation for that workflow and MUST contain only the runtime mechanics needed to get there. It MUST NOT restate the procedure, since a shortcut that carries a copy of the process becomes a second, silently diverging definition of it.
- **Advice and authority are separate.** An automated agent MAY analyse work and publish its conclusion as advice on the artifact under review. It MUST NOT be the thing that decides: it MUST NOT overwrite a human's decision, MUST NOT re-apply a decision a human has changed, and MUST NOT commit to the branch it is advising on. Its output is an input to the review, not a substitute for it.
- **Coordination happens on durable artifacts.** Where agents and humans coordinate, they MUST do so through the platform's own artifacts — issues, labels, and pull requests — rather than through a channel that leaves no trace in the repository. Intent MUST be separable from implementation: the issue states *what* is wanted and *why*, and the pull request proposes *how*, so that a rejected implementation does not discard the intent.
- **Reviewed knowledge changes.** Changes to the `docs` repository MUST happen through pull requests. Changes to memory MAY be lighter-weight, but MUST remain versioned in git.
- **No cross-project bleed.** An agent working in one organization MUST NOT apply another organization's standards or memory unless the current task explicitly asks for cross-organization work.
- **Traceable memory.** Memory entries SHOULD identify the context they came from and SHOULD be short, factual, and linked to the relevant issue, pull request, document, or repository when one exists.

## Success criteria

- An agent working in `github.com/PSModule/<repo>` reads PSModule docs and memory, not another organization's rules.
- An agent working in `github.com/MSXOrg/<repo>` resolves `github.com/MSXOrg/docs` and `github.com/MSXOrg/memory` as the canonical project context.
- An agent working in `<host>/<org>/<repo>` for any adopting organization resolves `<host>/<org>/docs` and `<host>/<org>/memory` as the canonical project context, with no change to the framework.
- A new product repository can adopt the framework by adding a router and the client routes that reach it, without copying standards or memory pages.
- An agent reads the repository's own README and CONTRIBUTING before it reads an organization standard, and still applies the organization standard when the two disagree.
- A human can start at `docs/index.md` or `memory/index.md` and navigate to the same context an agent uses.
- A human or agent can follow `docs/index.md` → Ways of Working → Workflow → the current stage procedure without knowing a file path in advance.
- A prompt such as `Review this PR <link>` reaches the Review procedure directly, while `Make this issue <description>` reaches Define, without a parallel process definition.
- A missing, dirty, locally ahead, diverged, wrong-branch, or unreachable canonical context repository stops discovery before any context index is read.
- A working checkout of a `docs` repository present on disk is not read as canonical context, and a reader can tell a current checkout from a stale one before trusting either.
- Updating a standard in `docs` changes the canonical guidance without editing every repository.
- Capturing a recurring lesson in `memory` makes it available to later agents working in the same organization.

## Context resolution contract

The framework uses this normative reading order:

1. **System and client policy** — non-project instructions imposed by the agent runtime.
2. **User-global preferences** — the human operator's baseline style and risk posture.
3. **Repository router** — `AGENTS.md` identifies the host, organization, and the context sources below, in the order they are read.
4. **Freshness gate** — fetch every canonical context repository and stop unless each clean default-branch checkout exactly matches its remote head.
5. **Repository context** — README, CONTRIBUTING, local docs, and narrow repository exceptions.
6. **Path-scoped repository rules** — local rules that apply to the files being read, generated, reviewed, or edited.
7. **Organization documentation** — the `docs` repository for the resolved organization: start at `docs/index.md`, traverse to Ways of Working and Workflow, resolve the current stage, then load the relevant standards, specs, and designs.
8. **Inherited ecosystem documentation** — where the organization inherits from a broader standard set, the layer it inherits from.
9. **Organization memory** — start at `memory/index.md`, then load relevant lessons, gotchas, and active context.
10. **Current task context** — issue, pull request, prompt, branch, diff, diagnostics, terminal output, and open files; use these artifacts to re-evaluate the stage after each handoff.

This is the order in which context is **read**, nearest first. It is not the order in which conflicts are **resolved**. A repository-local file MAY refine a standard but MUST NOT contradict it unless that standard explicitly allows a local exception; an organization standard governs its own repositories and MAY adjust an inherited ecosystem default for them; and memory MUST NOT override documentation.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [Memory Repository Template](memory-template.md) — the concrete scaffold every organization's canonical `memory` repository instantiates.
- [MCP Servers](mcp-servers.md) — how one logical tool layer is declared across runtimes.
- [Runtime Integration](runtime-integration.md) — what a runtime supplies to be supported, and why process is never part of it.
- [Plugin Distribution](plugin-distribution.md) — how named intents stay pointers to documentation.
- [Agent Interaction](agent-interaction.md) — issues, labels, and pull requests as the coordination substrate.
- [Advisory Agents](advisory-agents.md) — the pattern for automation that advises without deciding.
- [Conformance](conformance.md) — how a repository is measured against this spec.
- [Agentic Development](../../Ways-of-Working/Agentic-Development.md) — the existing way-of-working standard this framework operationalizes.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — how specs and designs are written and kept evergreen.
- [Open Knowledge Format](../../Dictionary/index.md#open-knowledge-format) — the Markdown and frontmatter model used for knowledge pages.
