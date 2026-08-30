---
title: AGENTS.md Template
description: The repository-level agent router template and the guidance for applying it.
---

# AGENTS.md Template

This document explains the repository-level `AGENTS.md` template. It is not
itself the router that agents load. Copy the contents of the fenced `markdown`
block into an `AGENTS.md` at the repository root.

The router moves from the most specific guidance to the least specific:
repository-local guidance first, initiative-specific guidance next, and the
organization's central guidance last.
Each route names its source repository, entry file, published documentation,
and preferred local clone. An agent may use a CLI, the web, published
documentation, or a refreshed local clone. Clone and local configuration
mechanics belong to the runtime or development setup, not to this portable
router.

Client-specific files such as `.claude/CLAUDE.md` and
`.github/copilot-instructions.md` point to the repository router. The shared
`msxorg` Agent Plugin improves discoverability through skills that are shallow
pointers to canonical documentation pages.

````markdown
# AGENTS

Read nearest first and always use the newest version.

Read in this order:

1. `README.md` — what this repository is and how it builds.
2. `.github/CONTRIBUTING.md` — how a change is made and reviewed here.
3. `docs/index.md` — this repository's own documentation.
<!-- Add initiative-specific guidance here, after the local repository entries. -->
4. [MSXOrg/docs](https://github.com/MSXOrg/docs/) — organization standards;
   entry file `src/docs/index.md`; published at <https://msxorg.github.io/docs/>;
   preferred clone `~/.msxorg/docs`.

Use a CLI, the web, published documentation, or a refreshed local clone,
whichever provides the newest accessible source.

Repository-local guidance may add nuance but does not override organization or
inherited standards.

````

A PSModule repository inserts this initiative route before `MSXOrg/docs`:

```markdown
4. [PSModule/Process-PSModule](https://github.com/PSModule/Process-PSModule/) —
   PSModule process and standards; entry file `docs/index.md`; published at
   <https://psmodule.io/docs/Modules/Process-PSModule/>; preferred clone
   `~/.psmodule/process-psmodule`.
```
