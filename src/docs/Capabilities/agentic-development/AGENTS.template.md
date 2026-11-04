---
title: AGENTS.md Template
description: The repository-level agent router template and the guidance for applying it.
---

# AGENTS.md Template

This document explains the repository-level `AGENTS.md` template. It is not
itself the router that agents load. Copy the contents of the fenced `markdown`
block into an `AGENTS.md` at the repository root.

The router reads repository-local guidance first, initiative-specific guidance
next, and central organization guidance last.

Before you use a linked repository, clone it locally. Keep its configuration
local to that clone. Update it from its remote before reading it.

Each runtime or development setup controls its documentation context checkout.
It owns clone, freshness, and local configuration mechanics. This portable
router does not define those mechanics.

Client-specific files such as `.claude/CLAUDE.md` and
`.github/copilot-instructions.md` point to the repository router.
The shared `msx` Agent Plugin from the `msxorg` marketplace provides skills that
point to canonical documentation pages.

````markdown
# AGENTS

Read in this order:

1. `README.md` — what this repository is and how it builds.
2. `.github/CONTRIBUTING.md` — repository-specific contribution instructions, when present.
3. `docs/index.md` — this repository's own documentation.
<!-- Add initiative-specific guidance here, after the local repository entries. -->
4. [MSXOrg/docs](https://github.com/MSXOrg/docs/) — the organization standards.

Clone each linked repository locally, keep its configuration local to that
clone, and update it before reading it.

````

Tailor the entries to real destinations. Keep the local contribution entry only
[when a local guide is needed](../../Ways-of-Working/Repository-Standard.md#contribution-guidance).
Otherwise, link to the initiative's required contribution source in its public
`.github` repository. If the source guide is blank, also
link to the shared
[Contribution Workflow](../../Ways-of-Working/Contribution-Workflow.md).
Report a missing required source file in the initiative's community repository.
Inherited community files are not included in clones, so a router uses a source
link rather than a nonexistent local path. Do not create a local contribution
file solely to fill the template.
