---
title: Pre-Commit
description: The generic local enforcement mechanism for every coding standard — the hook runs the standard's own tooling, mirrors the CI gate, and is pinned and kept current like any other dependency.
---

# Pre-Commit

Every per-language standard names a linter and a formatter. `pre-commit` is the
**generic mechanism that runs them all** before a commit is created, so a violation
surfaces on the contributor's machine rather than in CI minutes later.

This is [Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left)
applied to code. Pre-commit runs the merge-gate checks locally, before CI.

`pre-commit` MUST be configured in every repository that holds code, and running it
before committing is part of contributor setup rather than an optional refinement.

## The source of truth

The `.pre-commit-config.yaml` at the repository root is the source of truth for which
hooks run and at which versions. CI uses the **same** hooks to apply the same rules.
A local pass covers only the checks and inputs that local run examined.

Where a repository consumes a shared, centrally maintained configuration, the shared
config is authoritative and the repository pins it rather than copying it.

> The filename is `.pre-commit-config.yaml`, with the long extension. This is the one
> documented exception to the [`.yml` rule](YAML.md#use-yml-consistently): the tool
> recognizes no other name.

## Rules

| Rule | Requirement |
| --- | --- |
| Config committed | A `.pre-commit-config.yaml` lives at the repository root and is committed |
| Hooks enabled | Contributors run `pre-commit install` in every local checkout to enable the Git hook |
| Runs the standard's tooling | Every language present in the repository has a hook that runs that standard's linter and formatter |
| Pinned by immutable ref | Every `repo` is pinned by `rev` to a commit SHA, with the release tag as a trailing comment |
| Kept current | A `pre-commit` entry in `.github/dependabot.yml` keeps hook revisions up to date |
| Green before a PR | `pre-commit run --all-files` passes before a pull request is opened |
| Mirrored in CI | The same hooks run in CI as a required check; the local run does not replace CI |

## The hook runs the standard's own tooling

`pre-commit` MUST NOT define new rules. It runs the tool the relevant coding standard
already names. That standard remains the only owner of the rules.

| Standard | Tooling the hook runs |
| --- | --- |
| [PowerShell](PowerShell/index.md) | `PSScriptAnalyzer` |
| [Markdown](Markdown.md) | `markdownlint` |
| [YAML](YAML.md) | `yamllint` |
| [GitHub Actions](GitHub-Actions.md) | `actionlint`, `zizmor` |
| [Terraform](Terraform.md) | `terraform fmt`, `tflint` |
| [TypeScript](TypeScript.md) | `prettier`, `eslint` |

The per-language standard is authoritative for its rules; this table only maps each one
to the hook that enforces it locally. A hook whose configuration disagrees with its
standard is a bug in the hook.

## Contributor setup

Install the runner and wire the hook into the checkout:

```bash
pipx install pre-commit  # install the pre-commit runner
pre-commit install       # wire the hook into .git/hooks/pre-commit
```

Install the individual tools a repository's hooks invoke — `tflint`, `yamllint`,
`actionlint` — with the platform package manager, where the hook does not manage them
itself.

Before opening a pull request, run every hook across the whole repository rather than
only the staged files:

```bash
pre-commit run --all-files
```

Fix what it reports and re-run before pushing. A hook that only ever runs against staged
files leaves the rest of the repository drifting.

## Baseline configuration

Start from file-hygiene hooks and add one block per language present in the repository.
Pin every `repo` by `rev` to a commit SHA, with the release tag in a trailing comment —
the same [dependency-pinning](Dependencies.md) rule that applies to Actions and packages,
for the same reason: a tag can be moved, a SHA cannot.

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: 3e8a8703264a2f4a69428a0aa4dcb512790b2c8c # v6.0.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace

  # One block per language in the repository — each pinned by rev to a commit SHA.
```

Language-specific baselines build on this shape. Where a standard documents its own
hooks — the [Terraform pre-commit baseline](Terraform.md#tooling), for example — that
page is authoritative for them.

## Keeping revisions current

Pinned hooks need updates as standards and tools change. Add a `pre-commit` ecosystem
entry to `.github/dependabot.yml` so hook updates arrive as reviewable pull requests:

```yaml
- package-ecosystem: pre-commit
  directory: /
```

The default cadence is sufficient; no schedule override is needed.

## Enforcement and exceptions

CI runs the same hooks as a required check. Skipping the local run does not bypass CI.
`--no-verify` bypasses only the local hook.

Two deviations are allowed:

- A hook MAY be scoped with an `exclude` pattern to skip generated files or vendored
  trees. These files are not authored source, so authored-source formatting checks do not apply.
- `--no-verify` on a single commit is for genuine emergencies. It does not skip the gate,
  and the same checks run on the pull request.

Anything else is a change to the standard, made in a pull request against this
repository.

## Where this connects

- [Shift Left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left) — the principle this mechanism implements.
- [Continuous Delivery and Release](../Ways-of-Working/Continuous-Delivery-And-Release.md) — how local checks relate to integration, delivery, deployment, and release.
- [Code Layout](Code-Layout.md) — why formatting is automated rather than argued about in review.
- [Dependencies](Dependencies.md) — the pinning rule the `rev` pins follow.
- [Security](Security.md) — secret scanning as one of the hooks that runs here first.
