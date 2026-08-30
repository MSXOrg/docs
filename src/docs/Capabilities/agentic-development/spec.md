---
title: Spec
description: Requirements for fresh, index-first agentic development through canonical documentation and thin pointers.
---

# Agentic Development — Spec

## Premise

An agent does useful work only when it knows which project it is serving, which standards apply, and what the team has already learned. That context MUST be project-scoped, durable, reviewable, and readable by humans and agents alike. The project boundary is the GitHub organization — `github.com/MSXOrg`, `github.com/PSModule`, and any other organization that adopts the framework, on any GitHub host.

Each organization identifies a canonical documentation source repository:

- The documentation source is the reviewed knowledge base: vision, standards, workflows, specs, designs, glossary, onboarding, and project-wide rules. It may be named `docs`, such as `MSXOrg/docs`, or be the repository that owns an initiative's process and standards, such as `PSModule/Process-PSModule`.

Product repositories do not copy that knowledge. They carry thin pointer files that identify the applicable documentation sources before acting.

### Principles

This framework rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Documentation lives close to the thing it documents](../../Ways-of-Working/Principles/Engineering-Practices.md#documentation-lives-close-to-the-thing-it-documents).** Organization-wide ways of working live in the organization's documentation source; repository-specific nuance lives in the repository.
- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Standards are plain files in git. Changes are reviewed, diffed, and reverted like code.
- **[Written once, referenced everywhere](../../Ways-of-Working/Principles/Software-Design.md#dry-with-judgment).** Agent instructions point to canonical docs rather than duplicating them.
- **[AI-first development](../../Ways-of-Working/Principles/AI-First-Development.md).** Humans create durable context; agents consume that context and leave useful improvements behind.

## Scope

Applies to any organization that wants a shared project knowledge base for agents across multiple repositories.

**In scope**

- Organization-level documentation source repositories.
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
- **Canonical documentation source.** Each adopting organization MUST identify the repository that owns its reviewed knowledge base.
- **Repository identity is authoritative.** A router MUST name each source as `<organization>/<repository>`. CLI, web, published-site, and refreshed-local-clone access are interchangeable delivery methods.
- **Predictable project context.** Repository-level agent instructions MUST identify each applicable public documentation source, its entry file, published documentation when available, and its preferred local clone.
- **OKF-style documents.** Knowledge documents MUST be Markdown files with YAML frontmatter, one primary concept per page, and stable paths that act as identity.
- **Small pages and indexes.** Documentation SHOULD prefer small pages, each folder SHOULD have an `index.md`, and indexes MUST let a human or agent navigate inward from the root.
- **Thin pointer files.** Product repositories MUST carry an `AGENTS.md` at the repository root that routes an agent from the repository's own files outward to organization and inherited ecosystem documentation. It MUST lead with `Read nearest first and always use the newest version.` and contain only the route list, source coordinates, access-neutral freshness instruction, and authority statement defined by the template. It MUST NOT duplicate standards, workflow stages, reusable process knowledge, detailed synchronization procedures, build commands, or contribution mechanics.
- **Freshness-first, index-first workflow discovery.** After every canonical source is resolved to its newest accessible version, a human or agent MUST be able to follow its entry index to the applicable workflow and current stage procedure.
- **Stage resolution from work.** Agents MUST infer the current stage from the prompt and current artifacts. Explicit task language MAY shortcut to the matching stage, but the shortcut MUST resolve to the canonical documentation.
- **One process source.** Skills, commands, named agents, and tool-specific instruction files MUST NOT redefine Workflow stages. A client convenience MAY link to a stage procedure and add only runtime mechanics.
- **Segmentation before loading.** An agent MUST segment work by host, organization, repository, path, and task before loading project standards. The active repository context supplies the coordinates that make this possible; a per-repository router MUST NOT restate them.
- **Client routes.** A runtime that cannot read `AGENTS.md` under its own filename MUST be given a route file — `.claude/CLAUDE.md`, `.github/copilot-instructions.md`, or the equivalent path for that runtime. A route file MUST contain only a pointer to `AGENTS.md` plus, at most, genuinely runtime-specific configuration that cannot be expressed as documentation. It MUST NOT restate standards, describe workflow behavior, or repeat the reading order. Duplication is a property of content rather than of filenames: a route holds nothing that can drift, so the number of route files is unconstrained while their contents are strictly limited. [Client behavior](design.md#client-behavior) names the exact set an MSX repository carries; an adopting organization MAY carry a different set for the runtimes it uses.
- **Reading order and authority order are distinct.** An agent MUST read nearest context first, in the order the repository router defines. Precedence on conflict MUST run the opposite way: repository-local files MAY add nuance and narrow exceptions but MUST NOT override an organization or inherited ecosystem standard unless that standard permits a local exception.
- **Deterministic context resolution.** Agents MUST resolve context in layers: system and client policy, user preferences, the repository router, source freshness, repository context, path-scoped repository rules, organization documentation, inherited ecosystem documentation, then current task context.
- **Predictable local availability.** Preferred clones SHOULD use organization-addressable paths. MSXOrg uses `~/.msxorg/docs`; PSModule uses `~/.psmodule/process-psmodule`.
- **Fresh context before use.** Agents MUST use the newest accessible source version. Remote CLI, web, and published documentation MAY satisfy this directly. A local clone MUST be fetched and exactly synchronized with its remote default branch before its contents are read. Dirty, locally ahead, diverged, wrong-branch, or unreachable local clones MUST stop local resolution rather than become stale fallbacks.
- **Working checkouts are not context sources.** A local context source MUST be the preferred clone that passed the freshness gate. A working checkout cloned to change the documentation MUST NOT be used as canonical context unless it independently passes the same gate.
- **Synchronize local clones once per session, not once per machine.** When a runtime uses preferred local clones, the freshness gate MUST run at the start of every agent session. A clone synchronized at an earlier point MUST NOT be treated as current.
- **One tool layer, declared per runtime.** Where agents use external tools, the set of tool servers MUST be defined once as a logical layer and each runtime MUST declare that same set in its own native configuration format. A runtime MUST NOT define tools of its own that other runtimes lack, because a capability available in one client and absent in another makes the documented procedure conditional on which client is running it.
- **Named intents stay pointer-based.** A packaged shortcut for a recurring workflow — however a runtime names it — MUST resolve to the canonical documentation for that workflow and MUST contain only the runtime mechanics needed to get there. It MUST NOT restate the procedure, since a shortcut that carries a copy of the process becomes a second, silently diverging definition of it.
- **Advice and authority are separate.** An automated agent MAY analyse work and publish its conclusion as advice on the artifact under review. It MUST NOT be the thing that decides: it MUST NOT overwrite a human's decision, MUST NOT re-apply a decision a human has changed, and MUST NOT commit to the branch it is advising on. Its output is an input to the review, not a substitute for it.
- **Coordination happens on durable artifacts.** Where agents and humans coordinate, they MUST do so through the platform's own artifacts — issues, labels, and pull requests — rather than through a channel that leaves no trace in the repository. Intent MUST be separable from implementation: the issue states *what* is wanted and *why*, and the pull request proposes *how*, so that a rejected implementation does not discard the intent.
- **Reviewed knowledge changes.** Changes to a canonical documentation source MUST happen through pull requests.
- **No cross-project bleed.** An agent working in one organization MUST NOT apply another organization's standards unless the current task explicitly asks for cross-organization work.

## Success criteria

- An agent working in `github.com/PSModule/<repo>` resolves `github.com/PSModule/Process-PSModule` and inherited `github.com/MSXOrg/docs`.
- An agent working in `github.com/MSXOrg/<repo>` resolves `github.com/MSXOrg/docs` as the canonical project context.
- An agent working in `<host>/<org>/<repo>` for any adopting organization resolves the documentation sources declared by its router, with no change to the framework.
- A new product repository can adopt the framework by adding a router and the client routes that reach it, without copying standards pages.
- An agent reads the repository's own `README.md` and `.github/CONTRIBUTING.md` before it reads an organization standard, and still applies the organization standard when the two disagree.
- A human or agent can follow `docs/index.md` → Ways of Working → Workflow → the current stage procedure without knowing a file path in advance.
- A prompt such as `Review this PR <link>` reaches the Review procedure directly, while `Make this issue <description>` reaches Define, without a parallel process definition.
- A dirty, locally ahead, diverged, wrong-branch, or unreachable preferred clone stops local discovery before any context index is read.
- A reader can distinguish a current preferred clone from a working checkout or stale clone before trusting it.
- Updating a standard in its source repository changes the canonical guidance without editing every repository.

## Context resolution contract

The framework uses this normative reading order:

1. **System and client policy** — non-project instructions imposed by the agent runtime.
2. **User-global preferences** — the human operator's baseline style and risk posture.
3. **Repository router** — `AGENTS.md` identifies the applicable source repositories and the order in which they are read.
4. **Freshness gate** — use the newest accessible source; when using a local clone, fetch it and stop local resolution unless its clean default-branch checkout exactly matches the remote head.
5. **Repository context** — README, CONTRIBUTING, local docs, and narrow repository exceptions.
6. **Path-scoped repository rules** — local rules that apply to the files being read, generated, reviewed, or edited.
7. **Organization documentation** — the designated documentation source for the resolved organization: start at its declared entry file, resolve the applicable workflow and current stage, then load relevant standards, specs, and designs.
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
