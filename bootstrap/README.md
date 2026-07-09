# Bootstrap

The single starting point for agents: a git-isolated local clone of the MSX central repositories under `~/.msx`, plus the instruction that sends every agent there first.

## Contents

- `Initialize-MsxWorkspace.ps1` — idempotent setup. Clones `MSXOrg/docs` and `MSXOrg/memory` under `~/.msx`, fast-forwards them if present, and writes a repository-local git identity so the workspace never touches the global git config.
- `AGENTS.template.md` — the user-global entry instruction. It bootstraps the workspace, then points the agent at the docs and memory. Install it once per machine (below).

## The model

- `~/.msx/docs` is **read context** — the ways of working, coding standards, and agent roles. Changes to it go through **pull requests**.
- `~/.msx/memory` is **append-only context** — durable notes and session history. Changes to it are **pushed to main**.

Keeping the workspace separate and git-isolated means an agent reads the same docs and memory in every repository, and its commits there use the workspace identity rather than whatever the working repository or the global config happens to be set to.

## Install (once per machine)

Run the bootstrap:

```powershell
if (-not (Test-Path ~/.msx/docs)) { git clone https://github.com/MSXOrg/docs.git ~/.msx/docs }
pwsh ~/.msx/docs/bootstrap/Initialize-MsxWorkspace.ps1
```

Wire it into the tools so it runs as the first instruction:

- **Claude Code** reads `CLAUDE.md`. Add an import to `~/.claude/CLAUDE.md`:

  ```text
  @~/.msx/docs/bootstrap/AGENTS.template.md
  ```

- **Copilot** reads `AGENTS.md` natively. Use the contents of `AGENTS.template.md` as your user-level Copilot instructions, or copy it into a repository as `AGENTS.md`.

## Identity

The script writes a repository-local git identity to each clone (default: the maintainer's GitHub identity). Override it with `-UserName` / `-UserEmail`, or point it at a dedicated agent account when one exists.
