# AGENTS

This file is installed as user-level agent instructions. It is the first
context route: it identifies the current organization's canonical `docs`
repository, makes that repository available locally, and directs the agent to
the repository's own `AGENTS.md`.

Ensure `~/.msxorg/docs` is a clean clone of
[`MSXOrg/docs`](https://github.com/MSXOrg/docs) before reading context:

```sh
git clone https://github.com/MSXOrg/docs.git ~/.msxorg/docs
```

If the clone already exists, use Git to fetch and fast-forward it to its
default branch. If the path is not a Git clone, or it has local changes or
local commits, stop and resolve that state rather than reading stale context.
Configure Git identity locally for each context clone; do not rely on global
Git configuration:

```sh
git -C ~/.msxorg/docs config --local user.name "<your name>"
git -C ~/.msxorg/docs config --local user.email "<your email>"
```

The repository's `AGENTS.md` is the context router. It reads local guidance
first — `README.md`, `.github/CONTRIBUTING.md`, and repository documentation —
then routes outward to the current organization guidance in
`~/.msxorg/docs/src/docs/index.md`. Client-specific files point to that router:

```markdown
# Claude Code
@../AGENTS.md
```

```markdown
Follow the instructions in [AGENTS.md](../AGENTS.md).
```

The first example is `.claude/CLAUDE.md`; the second is
`.github/copilot-instructions.md`. Other clients use the equivalent pointer
file they recognize. These files stay shallow so `AGENTS.md` remains the one
context route.

For faster discovery, install the shared `msxorg` Agent Plugin marketplace
from `~/.msxorg/docs/.github/plugin/marketplace.json`. Its skills are also
shallow pointers: each skill routes a coding, documentation, or
ways-of-working intent to one canonical page in `MSXOrg/docs`; skills do not
copy the guidance.
