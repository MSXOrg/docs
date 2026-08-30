# AGENTS.template.md

This document explains the user-level `AGENTS.md` template. It is not itself
the router that agents load. Install the contents of the fenced `markdown`
block as user-level agent instructions.

The template establishes the canonical MSX documentation context before a
repository's own instructions are read. It uses Git directly, requires a
clean and synchronized clone, and keeps Git identity configuration local to
that clone rather than relying on global configuration.

The repository's `AGENTS.md` then routes from local guidance to organization
guidance. Client-specific files such as `.claude/CLAUDE.md` and
`.github/copilot-instructions.md` point to that router. The shared `msxorg`
Agent Plugin improves discoverability through skills that are shallow pointers
to canonical documentation pages.

````markdown
# AGENTS

Ensure `~/.msxorg/docs` is a clean clone of
[`MSXOrg/docs`](https://github.com/MSXOrg/docs) before reading context:

```sh
# Run this only when the clone is absent.
git clone https://github.com/MSXOrg/docs.git ~/.msxorg/docs

# Run these commands for an existing or newly created clone.
git -C ~/.msxorg/docs fetch --prune origin
git -C ~/.msxorg/docs pull --ff-only
git -C ~/.msxorg/docs status --porcelain
git -C ~/.msxorg/docs config --local user.name "<your name>"
git -C ~/.msxorg/docs config --local user.email "<your email>"
```

Use the clone only when it is clean and synchronized with its remote default
branch. If the path is not a Git clone, or it has local changes, local
commits, a different branch, or a diverged history, stop and resolve that
state rather than reading stale context. Do not rely on global Git
configuration.

Read the repository's `AGENTS.md` next. It reads local guidance first —
`README.md`, `.github/CONTRIBUTING.md`, and repository documentation — then
routes outward to the current organization guidance in
`~/.msxorg/docs/src/docs/index.md`.

For faster discovery, install the shared `msxorg` Agent Plugin marketplace
from `~/.msxorg/docs/.github/plugin/marketplace.json`. Its skills route
coding, documentation, and ways-of-working intents to one canonical page in
`MSXOrg/docs`; skills do not copy the guidance.
````
