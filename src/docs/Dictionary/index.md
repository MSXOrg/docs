---
title: Dictionary
description: Shared vocabulary for the MSX ecosystem — the terms a reader or agent meets across these docs.
---

# Dictionary

Shared vocabulary for the MSX ecosystem: the terms that appear across this site, defined once so every reader — human or agent — reads them the same way. Ecosystem-specific terms link to the page that covers them in full.

## Terms

### Agent

An AI participant that reads the same documentation as a human and acts on the platform — opening issues, proposing pull requests, and reviewing changes. See [Agentic Development](../Ways-of-Working/Agentic-Development.md).

### Baseline

The language-agnostic tier of the [Coding Standards](../Coding-Standards/index.md) — naming, layout, functions, testing, and security — that every repository inherits regardless of language.

### Capability

An independently versioned thing the ecosystem builds and runs, documented by a spec and a design. See [Capabilities](../Capabilities/index.md).

### CI/CD

Continuous integration and continuous delivery — automated build, test, and release triggered on every change, so quality is checked before a change lands.

### Coding Standard

A prescriptive rule set for how code is written, per language or technology, enforced by a linter derived from it. See [Coding Standards](../Coding-Standards/index.md).

### Continuous X

The family of always-on practices — continuous integration, delivery, documentation, and AI — that keep work flowing in small increments. See [Continuous Practices](../Ways-of-Working/Continuous-Practices.md).

### Design

The *how* of a capability: the approach and the thing built, kept beside its spec. See the [Documentation Model](../Ways-of-Working/Documentation-Model.md).

### Directive

Guidance written to be declarative and directional — it states what must be true and the direction to move, and leaves the *how* to the doer. Standards, principles, and specs are written as directives.

### Git Worktree

A checkout of a branch in its own directory, backed by a single bare clone that every worktree shares — so several branches are checked out at once, each in its own folder. It is purely a *local development* convenience: it lets one person, a person and an agent, or several agents work on multiple issues in the same repository in parallel, with no stashing or branch-switching. It changes nothing about how a repository is built, reviewed, or shipped. See [Git Worktrees](../Ways-of-Working/Git-Worktrees.md).

### Initiative

A product that makes the vision real — a framework, a set of reusable actions, or an editor extension. See [Initiatives](../Initiatives/index.md).

### Least privilege

Every identity — human, agent, or workflow — gets only the permissions it needs, and nothing more. See [Principles → Least-privilege](../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).

### LTS

Long-Term Support — a release line maintained with fixes for an extended period. We target current LTS runtimes rather than legacy editions.

### Open Knowledge Format

OKF — a vendor-neutral format for representing knowledge as plain Markdown files with YAML frontmatter, one concept per file with its path as its identity, so the same file is readable by a human and parseable by an agent with no SDK in between. See the [OKF specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).

### Philosophy

The most stable tier of belief — *why* we exist and what we value: easy, fast, safe. It informs the [Principles](../Ways-of-Working/Principles/index.md).

### Practice

How we habitually act on a principle — concrete and evolving, such as pinning actions to a commit SHA. See [Principles](../Ways-of-Working/Principles/index.md).

### Principle

Something that is always true for us — rarely changing, sitting between philosophy and practice. See [Principles](../Ways-of-Working/Principles/index.md).

### Pull request

The unit of change and the decision point: proposed changes are reviewed, validated by CI, and approved before they merge. See [PR Format](../Ways-of-Working/PR-Format.md).

### SemVer

Semantic Versioning — a `MAJOR.MINOR.PATCH` scheme where the number communicates the kind of change a release contains.

### Shift Left

Move quality gates as early as possible — editor, pre-commit, and pull request — because the later a problem is caught, the more it costs. See [Principles → Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left).

### Spec

The *why* and *what* of a capability: the contract it fulfils, kept beside its design. See the [Documentation Model](../Ways-of-Working/Documentation-Model.md).

### Vision

The *why* of the whole ecosystem — make software delivery easy, fast, and safe. See the [Vision](../Vision/index.md).

### Ways of Working

The shared conventions for how work happens — workflow, issues, reviews, and the norms every contributor and agent follows. See [Ways of Working](../Ways-of-Working/index.md).

### Zensical

The static-site generator that builds this documentation from Markdown and publishes it to GitHub Pages.
