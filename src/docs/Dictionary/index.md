---
title: Dictionary
description: Shared vocabulary for the MSX ecosystem — the terms a reader or agent meets across these docs.
---

# Dictionary

Shared vocabulary for the MSX ecosystem: the terms that appear across this site, defined once so every reader — human or agent — reads them the same way. Ecosystem-specific terms link to the page that covers them in full.

## Terms

### Accelerate

The 2018 book by Nicole Forsgren, Jez Humble, and Gene Kim presenting the research behind the four delivery metrics — deployment frequency, lead time for changes, change failure rate, and time to restore service — and the finding that delivery speed and stability rise together rather than trading off.

### Agent

An AI participant that reads the same documentation as a human and acts on the platform — opening issues, proposing pull requests, and reviewing changes. See [Agentic Development](../Ways-of-Working/Agentic-Development.md).

### Anthropic API

The message-based HTTP API shape published by Anthropic for its models. Widely reimplemented, so it functions as a second de-facto interface alongside the OpenAI shape — which is why a client that abstracts over both is portable across providers.

### Baseline

The language-agnostic tier of the [Coding Standards](../Coding-Standards/index.md) — naming, layout, functions, testing, and security — that every repository inherits regardless of language.

### Capability

An independently versioned thing the ecosystem builds and runs, documented by a spec and a design. See [Capabilities](../Capabilities/index.md).

### CI/CD

Continuous integration and continuous delivery — automated build, test, and release triggered on every change, so quality is checked before a change lands.

### Clean Code

Robert C. Martin's treatment of code as something read far more often than it is written: intention-revealing names, small single-purpose functions, and structure that explains itself without commentary. See [Principles → Software design](../Ways-of-Working/Principles/Software-Design.md#clean-code).

### Coding Standard

A prescriptive rule set for how code is written, per language or technology, enforced by a linter derived from it. See [Coding Standards](../Coding-Standards/index.md).

### Continuous X

The family of always-on practices — continuous integration, delivery, documentation, and AI — that keep work flowing in small increments. See [Continuous Practices](../Ways-of-Working/Continuous-Practices.md).

### Conventional Commits

A commit-message convention that puts a machine-readable type and optional scope in the subject line — `feat(api): add pagination` — so tooling can derive version bumps and changelogs from history. This ecosystem derives the bump from a pull-request label instead; see [Commit Conventions](../Ways-of-Working/Commit-Conventions.md).

### Conway's Law

Melvin Conway's 1968 observation that a system's structure mirrors the communication structure of the organization that built it. The practical consequence is that team boundaries are an architectural decision, whether or not anyone treats them as one.

### Dependabot

GitHub's dependency-update service: it watches a repository's manifests and opens pull requests when a dependency has a newer version. See [Dependency Updates](../Capabilities/dependency-updates/design.md).

### Design

The *how* of a capability: the approach and the thing built, kept beside its spec. See the [Documentation Model](../Ways-of-Working/Documentation-Model.md).

### Directive

Guidance written to be declarative and directional — it states what must be true and the direction to move, and leaves the *how* to the doer. Standards, principles, and specs are written as directives.

### Dogfooding

Using what you build, in the way a user would, as part of building it. The ecosystem's own documentation and automation run on the standards this site publishes, so a rule that is unworkable is felt by its authors first.

### DORA

DevOps Research and Assessment — the research program behind the four delivery metrics popularized by [Accelerate](#accelerate) and the annual State of DevOps reports. On this site DORA always means that research, never the EU financial-sector regulation of the same acronym.

### Extreme Programming

XP — the agile method that pushes feedback loops to their limit: test-first development, continuous integration, pair programming, small releases, and collective ownership. Several practices treated as standard here originated there.

### Front Matter

The YAML block at the top of a Markdown file, delimited by `---`, carrying metadata about the page rather than content. Every page on this site declares `title` and `description`. See the [Markdown standard](../Coding-Standards/Markdown.md).

### Git

The distributed version-control system every repository in the ecosystem uses. Its content-addressed history is what makes an immutable commit SHA a usable pin.

### Git Worktree

A checkout of a branch in its own directory, backed by a single bare clone that every worktree shares — so several branches are checked out at once, each in its own folder. It is purely a *local development* convenience: it lets one person, a person and an agent, or several agents work on multiple issues in the same repository in parallel, with no stashing or branch-switching. It changes nothing about how a repository is built, reviewed, or shipped. See [Git Worktrees](../Ways-of-Working/Git-Worktrees.md).

### Golden Circle

Simon Sinek's ordering of *why*, *how*, and *what* — start from purpose, then approach, then output. It is the shape of this site's own layering: [Vision](../Vision/index.md) and [Principles](../Ways-of-Working/Principles/index.md) before standards, standards before specifications.

### GTD

Getting Things Done — David Allen's method for keeping commitments out of your head and in a trusted system: capture everything, clarify what it is, and review regularly. The reasoning behind [park](../Ways-of-Working/Session-Interactions.md#park) and [spin-off](../Ways-of-Working/Session-Interactions.md#spin-off) is the same.

### Initiative

A product that makes the vision real — a framework, a set of reusable actions, or an editor extension. See [Initiatives](../Initiatives/index.md).

### JSON

JavaScript Object Notation — the ubiquitous data-interchange format. Preferred over YAML for machine-generated data, where YAML's whitespace significance and implicit typing are liabilities rather than conveniences.

### Kanban

A flow-based method: visualize the work, limit work in progress, and manage flow rather than assign it in fixed batches. Its central claim is that finishing work matters more than starting it.

### Lean Software Development

Mary and Tom Poppendieck's translation of lean manufacturing to software: eliminate waste, build quality in, decide as late as responsibly possible, and deliver as fast as possible. Small batches and fast feedback come from here.

### Least privilege

Every identity — human, agent, or workflow — gets only the permissions it needs, and nothing more. See [Principles → Least-privilege](../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).

### LTS

Long-Term Support — a release line maintained with fixes for an extended period. Current LTS runtimes are the target rather than legacy editions.

### Markdown

The lightweight markup language every document in the ecosystem is written in — readable as plain text, renderable as a site, and diffable in review. See the [Markdown standard](../Coding-Standards/Markdown.md).

### MCP

Model Context Protocol — an open protocol for exposing tools, data, and prompts to an AI client over a defined interface, so a capability is implemented once and consumed by any compliant client rather than reimplemented per runtime.

### Mermaid

A text-based diagram syntax rendered at build time, so a diagram lives in the Markdown source, is reviewed as a diff, and never drifts from the page that explains it.

### OKRs

Objectives and Key Results — a goal-setting method pairing a qualitative objective with a small set of measurable results. See [Goal Setting](../Ways-of-Working/Goal-Setting.md).

### Open Knowledge Format

OKF — a vendor-neutral format for representing knowledge as plain Markdown files with YAML frontmatter, one concept per file with its path as its identity, so the same file is readable by a human and parseable by an agent with no SDK in between. See the [OKF specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).

### Open Plugin Spec

A vendor-neutral description of an agent plugin — its instructions, skills, and tools — so the same plugin is installable in more than one runtime without being rewritten for each. See [Plugin Distribution](../Capabilities/agentic-development/plugin-distribution.md).

### OpenAI API

The HTTP API shape published by OpenAI for its models. Reimplemented widely enough to function as a de-facto interface, which is why many clients and proxies speak it regardless of which provider is behind them.

### OpenAPI

The standard, machine-readable description of an HTTP API — endpoints, schemas, and responses — in a versioned document. It is what makes an [API-first](../Ways-of-Working/Principles/Software-Design.md#api-first) contract something a consumer can pin rather than infer.

### Philosophy

The most stable tier of belief — the *why* behind the work and what it values: easy, fast, safe. It informs the [Principles](../Ways-of-Working/Principles/index.md).

### Practice

The habitual way of acting on a principle — concrete and evolving, such as pinning actions to a commit SHA. See [Principles](../Ways-of-Working/Principles/index.md).

### Principle

Something that is always true across the ecosystem — rarely changing, sitting between philosophy and practice. See [Principles](../Ways-of-Working/Principles/index.md).

### Pull request

The unit of change and the decision point: proposed changes are reviewed, validated by CI, and approved before they merge. See [PR Format](../Ways-of-Working/PR-Format.md).

### Release vs Deployment

Two separate events routinely conflated. A **deployment** puts a build somewhere; a **release** makes it available to users. Keeping them separate is what allows deploying continuously while releasing on a decision. See [Continuous Delivery and Release](../Ways-of-Working/Continuous-Delivery-And-Release.md).

### Scrum

The iteration-based agile framework: fixed-length sprints, a product backlog, and defined roles and ceremonies. Referenced here for its vocabulary — backlog, refinement, increment — rather than adopted wholesale.

### SemVer

Semantic Versioning — a `MAJOR.MINOR.PATCH` scheme where the number communicates the kind of change a release contains.

### Shift Left

Move quality gates as early as possible — editor, pre-commit, and pull request — because the later a problem is caught, the more it costs. See [Principles → Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left).

### Spec

The *why* and *what* of a capability: the contract it fulfils, kept beside its design. See the [Documentation Model](../Ways-of-Working/Documentation-Model.md).

### SRE

Site Reliability Engineering — the discipline of running production systems with engineering rather than operations practices: explicit reliability targets, error budgets, and the expectation that toil is automated away. Its framing of a slow response as a reliability failure informs [Observability](../Ways-of-Working/Observability.md).

### Team Topologies

Matthew Skelton and Manuel Pais's model of four team types — stream-aligned, platform, enabling, and complicated-subsystem — and three interaction modes, used to design team boundaries deliberately rather than inherit them. A direct answer to [Conway's Law](#conways-law).

### TOML

Tom's Obvious Minimal Language — a configuration format with unambiguous types and no significant whitespace. This site's own configuration is TOML.

### Vision

The *why* of the whole ecosystem — make software delivery easy, fast, and safe. See the [Vision](../Vision/index.md).

### Ways of Working

The shared conventions for how work happens — workflow, issues, reviews, and the norms every contributor and agent follows. See [Ways of Working](../Ways-of-Working/index.md).

### YAML

A human-readable data-serialization format used for workflows, configuration, and page front matter. Its whitespace significance and implicit typing make it easy to write incorrectly, which is why it is linted rather than reviewed by eye. See the [YAML standard](../Coding-Standards/YAML.md).

### Zensical

The static-site generator that builds this documentation from Markdown and publishes it to GitHub Pages.
