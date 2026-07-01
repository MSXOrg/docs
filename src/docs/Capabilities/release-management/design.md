---
title: Design
description: How release management is built — a shared reusable workflow that reads pull-request labels, computes the SemVer bump, and cuts the release.
---

# Release Management — Design

The behaviour in the [spec](spec.md) is delivered by a **shared reusable release
workflow**. A repository opts in with a short caller workflow and a small
`.github/release.config.yml`; everything else has a sensible default, so a
minimal caller plus a one-line path filter is enough to adopt it.

## Branching model

A **release branch** is any branch configured as a release target, each with a
**release type** — `stable` or `prerelease`.

- **Single branch (zero-config).** One release branch (the default branch)
  produces stable releases. Prereleases are opt-in via a PR label.
- **Multi-branch.** `dev` (prerelease) collects PRs and publishes a prerelease
  on every merge; `main` (stable) receives `dev`. Merging `dev → main` computes
  the stable version from the **latest stable release** plus the merge PR's bump
  label — the prerelease counter does not carry over.
- **Bundled releases.** A **staging branch** collects feature PRs; merging it to
  a release branch produces **exactly one** release for all bundled changes.

```yaml
# .github/release.config.yml
release-branches:
  - branch: main
    release-type: stable
  - branch: dev
    release-type: prerelease
```

## Version computation

- The bump comes from the PR label (`Major` / `Minor` / `Patch` / `NoRelease`),
  defaulting to `Patch`. Multiple SemVer labels, or a SemVer label with
  `NoRelease`, are **rejected**. For `workflow_dispatch`, the bump is an input.
- **First release** starts from a baseline (`v0.1.0` or `v1.0.0`). Pre-`1.0.0`
  breaking changes are `Minor` per [SemVer §4](https://semver.org/#spec-item-4);
  `Major` is never auto-detected pre-`1.0.0`.
- The tag is created on the commit now at the head of the release branch —
  squash, merge-commit, and rebase strategies alike.

## Prereleases

- **Branch-level** — a prerelease-type branch publishes on every push, using the
  branch name as the identifier: `v1.3.0-dev.1`, `v1.3.0-dev.2`, …
- **PR-level** — a prerelease label on an open PR publishes
  `v<base>-<identifier>.<counter>`: `base` is the next version from the PR's bump
  label, `identifier` is the normalised branch name, and `counter`
  auto-increments per push.
- Artifact-specific conventions replace the SemVer suffix where they exist
  (`-alpha.N` for npm, `.devN` for Python). Release candidates use `-rc.N`,
  auto-incrementing.
- **Cleanup** deletes prerelease tags, releases, and artifacts after the PR
  closes (configurable); stable releases are never touched.

## Path filtering

`.github/release.config.yml` declares `release-paths` as ordered include/exclude
globs (excludes win). The workflow **always runs** so validation executes on
every merge; only the release step is skipped when no artifact-affecting path
changed.

```yaml
release-paths:
  - "src/**"
  - "Dockerfile"
  - "action.yml"
  - "!docs/**"       # documentation-only changes never release
  - "!.github/**"    # CI/CD changes never release
```

## Release notes

The GitHub Release **name** is the version; the **body** depends on the trigger:
`# <PR title>` + description (merged PR), `# <first commit line>` + remainder
(direct push), or `# <summary>` + collected history (dispatch). The same note is
handed to [Downstream Release Propagation](../downstream-release-propagation/design.md).

## Release output

1. A git tag `vX.Y.Z` on the release-branch commit — always.
2. The published artifact where one lives outside git — a container image
   (`<image>:<version>` and `@<digest>`), a package in its registry. For Action,
   workflow, and module artifacts the tag itself **is** the artifact.
3. A GitHub Release whose name is the version, carrying the note and the
   immutable reference (digest, package version, or the tag).

## Configuration surface

| Surface | Where |
| --- | --- |
| Release branches + type | `.github/release.config.yml` |
| Bump label / prerelease / RC | PR label, or `workflow_dispatch` input |
| Path filter | `.github/release.config.yml` |
| Prerelease cleanup toggle | release config / workflow input |
| Publish target | reusable-workflow input + GitHub environment |

## Where this connects

- [Spec](spec.md) — the requirements this design delivers.
- [Downstream Release Propagation](../downstream-release-propagation/design.md) — consumes the release note and immutable reference.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md) — how the workflow itself is authored (SHA pins, least privilege, concurrency).
- [Security](../../Coding-Standards/Security.md#supply-chain) — why consumers pin to immutable references.
