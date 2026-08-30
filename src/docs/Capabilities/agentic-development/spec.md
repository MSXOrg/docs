---
title: Spec
description: Requirements for fresh, index-first agentic development through canonical documentation and thin pointers.
---

# Agentic Development — Spec

## Premise

An agent does useful work only when it knows which project it is serving, which standards apply, and what the team has already learned. That context MUST be project-scoped, durable, reviewable, and readable by humans and agents alike. The project boundary is the GitHub organization — `github.com/MSXOrg`, `github.com/PSModule`, and any other organization that adopts the framework, on any GitHub host.

Each organization identifies a canonical documentation repository:

- The documentation repository owns the reviewed knowledge base: vision, standards, workflows, specs, designs, glossary, onboarding, and project-wide rules. It may be named `docs`, such as `MSXOrg/docs`, or be the repository that owns an initiative's process and standards, such as `PSModule/Process-PSModule`.

Product repositories do not copy that knowledge. They carry thin pointer files that identify the organization context and direct agents to the relevant documentation repository before acting.

### Principles

This framework rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Documentation lives close to the thing it documents](../../Ways-of-Working/Principles/Engineering-Practices.md#documentation-lives-close-to-the-thing-it-documents).** Organization-wide ways of working live in the organization `docs` repository; repository-specific nuance lives in the repository.
- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Standards are plain files in git. Changes are reviewed, diffed, and reverted like code.
- **[Written once, referenced everywhere](../../Ways-of-Working/Principles/Software-Design.md#dry-with-judgment).** Agent instructions point to canonical docs rather than duplicating them.
- **[AI-first development](../../Ways-of-Working/Principles/AI-First-Development.md).** Humans create durable context; agents consume that context and leave useful improvements behind.

## Scope

Applies to any organization that wants a shared project knowledge base for agents across multiple repositories.

**In scope**

- Organization-level `docs` repository.
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

**Out of scope**

- A vendor-specific runtime implementation for one agent client.
- Secret storage, credential distribution, or production access management.
- Replacing issue tracking, pull requests, or code review.
- A central database or service for context retrieval.

## Requirements

- **Organization is the project boundary.** The framework MUST resolve project context from the Git host and organization before resolving repository-specific context.
- **Canonical documentation repository.** Each adopting organization MUST identify the repository that owns the reviewed knowledge base.
- **Predictable project context.** Repository-level agent instructions MUST identify the canonical documentation repository with a public repository pointer for each adopting organization.
- **OKF-style documents.** Knowledge documents MUST be Markdown files with YAML frontmatter, one primary concept per page, and stable paths that act as identity.
- **Small pages and indexes.** Documentation SHOULD prefer small pages, each folder SHOULD have an `index.md`, and indexes MUST let a human or agent navigate inward from the root.
- **Thin pointer files.** Product repositories MUST carry an `AGENTS.md` at the repository root that routes an agent from the repository's own files outward to the organization documentation and any inherited ecosystem documentation. It MUST be limited to that route list and the single context-preparation instruction defined by the template. It MUST NOT duplicate standards, workflow stages, or reusable process knowledge, and MUST NOT carry detailed synchronization procedures, build commands, or contribution mechanics.
- **Refresh-first, index-first workflow discovery.** After every canonical context repository passes the Git freshness gate, a human or agent MUST be able to follow the docs root index to Ways of Working, the canonical Workflow, and the procedure for the current stage.
- **Stage resolution from work.** Agents MUST infer the current stage from the prompt and current artifacts. Explicit task language MAY shortcut to the matching stage, but the shortcut MUST resolve to the canonical documentation.
- **One process source.** Skills, commands, named agents, and tool-specific instruction files MUST NOT redefine Workflow stages. A client convenience MAY link to a stage procedure and add only runtime mechanics.
- **Segmentation before loading.** An agent MUST segment work by host, organization, repository, path, and task before loading project standards. The active repository context supplies the coordinates that make this possible; a per-repository router MUST NOT restate them.
- **Client routes.** A runtime that cannot read `AGENTS.md` under its own filename MUST be given a route file — `.claude/CLAUDE.md`, `.github/copilot-instructions.md`, or the equivalent path for that runtime. A route file MUST contain only a pointer to `AGENTS.md` plus, at most, genuinely runtime-specific configuration that cannot be expressed as documentation. It MUST NOT restate standards, describe workflow behavior, or repeat the reading order. Duplication is a property of content rather than of filenames: a route holds nothing that can drift, so the number of route files is unconstrained while their contents are strictly limited. [Client behavior](design.md#client-behavior) names the exact set an MSX repository carries; an adopting organization MAY carry a different set for the runtimes it uses.
- **Reading order and authority order are distinct.** An agent MUST read nearest context first, in the order the repository router defines. Precedence on conflict MUST run the opposite way: repository-local files MAY add nuance and narrow exceptions but MUST NOT override an organization or inherited ecosystem standard unless that standard permits a local exception.
- **Deterministic context resolution.** Agents MUST resolve context in layers: system and client policy, user preferences, the repository router, the context-repository Git freshness gate, repository context, path-scoped repository rules, organization docs, any inherited ecosystem docs, then current task context.
- **Local-first availability.** The docs repository SHOULD be available locally in a predictable workspace so agents can read it without relying on search or web access.
- **Fresh context before use.** Every canonical context repository MUST be fetched and exactly synchronized with its remote default branch before its contents are read. Agents use Git directly; dirty, locally ahead, diverged, wrong-branch, or unreachable repositories MUST stop context resolution rather than fall back to stale content.
- **Working checkouts are not context sources.** Canonical context MUST be read from the documentation repository clone that passed the freshness gate. A working checkout of the `docs` repository — one cloned in order to change it rather than to be governed by it — MUST NOT be used as a context source, whatever path it occupies, because it sits outside the gate.
- **Synchronize once per session, not once per machine.** The freshness gate MUST run at the start of every agent session, in every runtime. A workspace that was synchronized at some earlier point MUST NOT be treated as current, because elapsed time is not a state the agent can observe. The agent MUST use Git to synchronize it or stop when the clone cannot be safely synchronized.
- **One tool layer, declared per runtime.** Where agents use external tools, the set of tool servers MUST be defined once as a logical layer and each runtime MUST declare that same set in its own native configuration format. A runtime MUST NOT define tools of its own that other runtimes lack, because a capability available in one client and absent in another makes the documented procedure conditional on which client is running it.
- **Named intents stay pointer-based.** A packaged shortcut for a recurring workflow — however a runtime names it — MUST resolve to the canonical documentation for that workflow and MUST contain only the runtime mechanics needed to get there. It MUST NOT restate the procedure, since a shortcut that carries a copy of the process becomes a second, silently diverging definition of it.
- **Advice and authority are separate.** An automated agent MAY analyse work and publish its conclusion as advice on the artifact under review. It MUST NOT be the thing that decides: it MUST NOT overwrite a human's decision, MUST NOT re-apply a decision a human has changed, and MUST NOT commit to the branch it is advising on. Its output is an input to the review, not a substitute for it.
- **Coordination happens on durable artifacts.** Where agents and humans coordinate, they MUST do so through the platform's own artifacts — issues, labels, and pull requests — rather than through a channel that leaves no trace in the repository. Intent MUST be separable from implementation: the issue states *what* is wanted and *why*, and the pull request proposes *how*, so that a rejected implementation does not discard the intent.
- **Reviewed knowledge changes.** Changes to the `docs` repository MUST happen through pull requests.
- **No cross-project bleed.** An agent working in one organization MUST NOT apply another organization's standards unless the current task explicitly asks for cross-organization work.

## Success criteria

- An agent working in `github.com/PSModule/<repo>` reads `github.com/PSModule/Process-PSModule` and inherited `github.com/MSXOrg/docs`.
- An agent working in `github.com/MSXOrg/<repo>` resolves `github.com/MSXOrg/docs` as the canonical project context.
- An agent working in `<host>/<org>/<repo>` for any adopting organization resolves its designated documentation repository as the canonical project context, with no change to the framework.
- A new product repository can adopt the framework by adding a router and the client routes that reach it, without copying standards pages.
- An agent reads the repository's own README and CONTRIBUTING before it reads an organization standard, and still applies the organization standard when the two disagree.
- A human or agent can follow `docs/index.md` → Ways of Working → Workflow → the current stage procedure without knowing a file path in advance.
- A prompt such as `Review this PR <link>` reaches the Review procedure directly, while `Make this issue <description>` reaches Define, without a parallel process definition.
- A missing, dirty, locally ahead, diverged, wrong-branch, or unreachable canonical context repository stops discovery before any context index is read.
- A working checkout of a `docs` repository present on disk is not read as canonical context, and a reader can tell a current checkout from a stale one before trusting either.
- Updating a standard in `docs` changes the canonical guidance without editing every repository.

## Context resolution contract

The framework uses this normative reading order:

1. **System and client policy** — non-project instructions imposed by the agent runtime.
2. **User-global preferences** — the human operator's baseline style and risk posture.
3. **Repository router** — `AGENTS.md` identifies the host, organization, and the context sources below, in the order they are read.
4. **Freshness gate** — fetch every canonical context repository and stop unless each clean default-branch checkout exactly matches its remote head.
5. **Repository context** — README, CONTRIBUTING, local docs, and narrow repository exceptions.
6. **Path-scoped repository rules** — local rules that apply to the files being read, generated, reviewed, or edited.
7. **Organization documentation** — the designated documentation repository for the resolved organization: start at its entry index, resolve the current stage, then load the relevant standards, specs, and designs.
8. **Inherited ecosystem documentation** — where the organization inherits from a broader standard set, the layer it inherits from.
9. **Current task context** — issue, pull request, prompt, branch, diff, diagnostics, terminal output, and open files; use these artifacts to re-evaluate the stage after each handoff.

This is the order in which context is **read**, nearest first. It is not the order in which conflicts are **resolved**. A repository-local file MAY refine a standard but MUST NOT contradict it unless that standard explicitly allows a local exception; an organization standard governs its own repositories and MAY adjust an inherited ecosystem default for them.

## Where this connects

- [Design](design.md) — how these requirements are delivered.
- [MCP Servers](mcp-servers.md) — how one logical tool layer is declared across runtimes.
- [Runtime Integration](runtime-integration.md) — what a runtime supplies to be supported, and why process is never part of it.
- [Plugin Distribution](plugin-distribution.md) — how named intents stay pointers to documentation.
- [Agent Interaction](agent-interaction.md) — issues, labels, and pull requests as the coordination substrate.
- [Advisory Agents](advisory-agents.md) — the pattern for automation that advises without deciding.
- [Conformance](conformance.md) — how a repository is measured against this spec.
- [Agentic Development](index.md) — the framework this specification defines.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — how specs and designs are written and kept evergreen.
- [Open Knowledge Format](../../Dictionary/index.md#open-knowledge-format) — the Markdown and frontmatter model used for knowledge pages.
