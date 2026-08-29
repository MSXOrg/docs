# Bootstrap

The bootstrap refreshes repository-addressable organization context before an agent reads it. Repository identity is authoritative; a CLI, the web, published documentation, or a refreshed local clone may deliver the content.

## Contents

- `Initialize-MsxWorkspace.ps1` — the idempotent freshness gate for configured context repositories.
- `AGENTS.template.md` — the user-global entry instruction and first-run seed.

## Canonical repositories

| Source repository | Entry file | Published documentation | Visibility | Preferred local clone |
| --- | --- | --- | --- | --- |
| [MSXOrg/docs](https://github.com/MSXOrg/docs) | `src/docs/index.md` | <https://msxorg.github.io/docs/> | Public | `~/.msxorg/docs` |
| `MSXOrg/memory` | `index.md` | None | Private | `~/.msxorg/memory` |
| [PSModule/Process-PSModule](https://github.com/PSModule/Process-PSModule) | `docs/index.md` | <https://psmodule.io/docs/Modules/Process-PSModule/> | Public | `~/.psmodule/process-psmodule` |
| `PSModule/memory` | `index.md` | None | Private | `~/.psmodule/memory` |

The documentation clones use a bare backing repository plus a clean default-branch worktree. The backing paths are `~/.msxorg/docs.git` and `~/.psmodule/process-psmodule.git`. Memory repositories remain simple checkouts.

Private memory requires authenticated access. Failure to clone or refresh either private repository stops context resolution instead of falling back to an older copy.

## Freshness gate

Run bootstrap at the start of every agent session. It:

1. validates every configured repository identity and collision-free relative path;
2. clones missing repositories;
3. fetches existing repositories and resolves their remote default branches;
4. requires clean default-branch checkouts at the exact fetched remote heads; and
5. writes repository-local git identity without modifying global git configuration.

A dirty, locally ahead, diverged, wrong-branch, noncanonical, or unreachable repository stops the gate. Context is read only after every selected repository succeeds.

## First installation

Install `AGENTS.template.md` as the user-global agent instruction and run its first PowerShell block. The seed refreshes `MSXOrg/docs`, then invokes the canonical bootstrap script from that refreshed repository for all four sources.

For Claude Code, route the user instruction to the refreshed template:

```text
@~/.msxorg/docs/bootstrap/AGENTS.template.md
```

Copilot reads user-level instructions natively. Repository `AGENTS.md` files stay thin routers and do not contain bootstrap logic.

## Repository configuration

The script accepts explicit repository coordinates. `Path` is relative to `Root`, which defaults to the current user's home directory.

```powershell
$repositories = @(
    @{ Name = 'MSXOrg/docs'; Path = '.msxorg/docs'; Url = 'https://github.com/MSXOrg/docs.git'; Kind = 'docs' }
    @{ Name = 'MSXOrg/memory'; Path = '.msxorg/memory'; Url = 'https://github.com/MSXOrg/memory.git'; Kind = 'memory' }
    @{ Name = 'PSModule/Process-PSModule'; Path = '.psmodule/process-psmodule'; Url = 'https://github.com/PSModule/Process-PSModule.git'; Kind = 'docs' }
    @{ Name = 'PSModule/memory'; Path = '.psmodule/memory'; Url = 'https://github.com/PSModule/memory.git'; Kind = 'memory' }
)
& ./Initialize-MsxWorkspace.ps1 -Repository $repositories
```

URLs are transport configuration, not repository identity. They may use any git transport that resolves the named source repository.

## Former `~/.msx/` layout

The former layout is never a fallback context source. When bootstrap finds one of these paths, it emits an actionable warning, leaves the path unchanged, and creates or refreshes the corresponding canonical clone:

| Former path | Canonical replacement |
| --- | --- |
| `~/.msx/docs` | `~/.msxorg/docs` |
| `~/.msx/memory` | `~/.msxorg/memory` |
| `~/.msx/projects/PSModule/docs` | `~/.psmodule/process-psmodule` |
| `~/.msx/projects/PSModule/memory` | `~/.psmodule/memory` |

Verify the canonical clone before removing a former path. This copy-and-diagnose approach avoids trusting stale content, moving dirty work, or repairing a checkout destructively.

Existing simple documentation clones already at a canonical path are migrated to the bare-plus-worktree layout only after they pass the freshness gate. The original clone is retained beside the new layout as `<path>.simple-clone-backup` for manual verification and removal. Unsafe layouts stop with recovery guidance.

## Writing context

Documentation changes use topic worktrees created from the relevant bare backing repository; never work in a canonical context worktree. Memory follows the selected private repository's own `AGENTS.md` and `CONTRIBUTING.md`.
