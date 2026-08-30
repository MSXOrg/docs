# AGENTS.template.md

This document explains the repository-level `AGENTS.md` template. It is not
itself the router that agents load. Copy the contents of the fenced `markdown`
block into an `AGENTS.md` at the repository root.

The router sends agents to repository-local guidance first, then to the
organization's canonical documentation clone. Prepare that clone with Git
using `git clone https://github.com/MSXOrg/docs.git ~/.msxorg/docs`, or
`git -C ~/.msxorg/docs fetch --prune origin` and
`git -C ~/.msxorg/docs pull --ff-only` when it already exists. Use it only
when it is clean and synchronized with its remote default branch.

Configure Git identity locally for each context clone with
`git -C <clone> config --local user.name "<your name>"` and
`git -C <clone> config --local user.email "<your email>"`; do not rely on
global Git configuration.

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
4. `~/.msxorg/docs/src/docs/index.md` — the organization standards.

Read nearest first. A local file never overrides a standard.
````
