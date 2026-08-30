# Bootstrap

`AGENTS.template.md` documents the repository-level `AGENTS.md` router. Copy
the fenced template into a repository root so agents start by locating and
synchronizing the canonical MSX documentation clone with Git.

Configure Git identity locally for each context clone with `git config
--local`; do not rely on global Git configuration.

The suggested repository-local router is:

```markdown
# AGENTS

Read in this order:

1. `README.md` — what this repository is and how it builds.
2. `.github/CONTRIBUTING.md` — how a change is made and reviewed here.
3. `docs/index.md` — this repository's own documentation.
4. `~/.msxorg/docs/src/docs/index.md` — the organization standards.

Read nearest first. A local file never overrides a standard.
```

Repository-local `AGENTS.md` files then route from local guidance to remote
organization guidance. Client-specific files such as `.claude/CLAUDE.md` and
`.github/copilot-instructions.md` point to that router rather than duplicating
it:

```markdown
# Claude Code
@../AGENTS.md
```

```markdown
Follow the instructions in [AGENTS.md](../AGENTS.md).
```

The shared `msxorg` Agent Plugin at
`~/.msxorg/docs/.github/plugin/marketplace.json` improves discoverability
without creating a second source of truth. Its skills are shallow pointers
from an intent to one canonical documentation page.
