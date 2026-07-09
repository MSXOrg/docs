# Bootstrap

The single starting point for agents: a git-isolated local clone of the MSX central repositories under `~/.msx`, plus the instruction that sends every agent there first.

## Contents

- `Initialize-MsxWorkspace.ps1` — idempotent setup. Clones `MSXOrg/docs` and `MSXOrg/memory` under `~/.msx`, attempts to fast-forward them if present, and writes a repository-local git identity so the workspace never modifies the global git config.
- `AGENTS.template.md` — the user-global entry instruction. It bootstraps the workspace, then points the agent at the docs and memory. Install it once per machine (below).

## The model

- `~/.msx/docs` is **read context** — the ways of working, coding standards, and agent roles. Changes to it go through **pull requests**.
- `~/.msx/memory` is **append-only context** — durable notes and session history. Changes to it are **pushed to main**.

> **Prerequisite:** `MSXOrg/memory` is a private repository — the bootstrap needs access to it (and working github.com credentials) to clone or update memory.

Keeping the workspace separate and git-isolated means an agent reads the same docs and memory in every repository, and its commits there use the workspace identity rather than whatever the working repository or the global config happens to be set to.

## Install (once per machine)

Run the bootstrap:

```powershell
$docs = Join-Path $HOME '.msx/docs'
if ((Test-Path $docs) -and -not (Test-Path (Join-Path $docs '.git'))) {
    throw "$docs exists but is not a git repository. Remove it and re-run."
}
if (-not (Test-Path (Join-Path $docs '.git'))) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $docs) | Out-Null
    git clone https://github.com/MSXOrg/docs.git $docs
}
pwsh (Join-Path $docs 'bootstrap/Initialize-MsxWorkspace.ps1')
```

Wire it into the tools so it runs as the first instruction:

- **Claude Code** reads `CLAUDE.md`. Add an import to `~/.claude/CLAUDE.md`:

  ```text
  @~/.msx/docs/bootstrap/AGENTS.template.md
  ```

- **Copilot** reads `AGENTS.md` natively. Install the contents of `AGENTS.template.md` as your **user-level** Copilot instructions so it applies in every repository. Per-repository `AGENTS.md` files stay thin pointers to the central docs — don't put the bootstrap there.

## Identity

The script writes a repository-local git identity to each clone. The default is the maintainer's GitHub **noreply** identity, so no personal email is written into git config and commits still attribute to the maintainer. Override it with `-UserName` / `-UserEmail`, or point it at a dedicated agent account when one exists.

> **Override this if you are not the maintainer.** With the default, commits — including memory pushes to `main` — are attributed to the maintainer's account. Pass `-UserName` and `-UserEmail` (for example `-UserEmail 'you@users.noreply.github.com'`), or point the script at a dedicated agent account, so your commits are attributed correctly.
