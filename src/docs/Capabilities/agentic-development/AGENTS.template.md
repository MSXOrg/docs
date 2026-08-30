---
title: AGENTS.md Template
description: The repository-level agent router template and the guidance for applying it.
---

# AGENTS.md Template

This document explains the repository-level `AGENTS.md` template. It is not
itself the router that agents load. Copy the contents of the fenced `markdown`
block into an `AGENTS.md` at the repository root.

The router sends agents to repository-local guidance first, then to the
organization's canonical documentation repository through its public URL.
Before using a linked repository, clone it locally, keep its configuration local
to that clone, and update it from its remote.
Agentic runtimes and local development may materialize that repository in any
context checkout they control. Clone, freshness, and local configuration
mechanics belong to that runtime or development setup, not to this portable
router.

Client-specific files such as `.claude/CLAUDE.md` and
`.github/copilot-instructions.md` point to the repository router. The shared
`msxorg` Agent Plugin improves discoverability through skills that are shallow
pointers to canonical documentation pages.

````markdown
# AGENTS

Read in this order:

1. `README.md` — what this repository is and how it builds.
2. `.github/CONTRIBUTING.md` — how a change is made and reviewed here.
3. `docs/index.md` — this repository's own documentation.
4. [MSXOrg/docs](https://github.com/MSXOrg/docs/) — the organization standards.

Clone each linked repository locally, keep its configuration local to that
clone, and update it before reading it.
````
