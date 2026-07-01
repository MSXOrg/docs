---
title: Spec
description: Requirements for dependency updates — pinned dependencies kept current and secure through reviewed, released update pull requests.
---

# Dependency Updates — Spec

## Premise

Every repository pins dependencies by version — Action SHAs, image digests,
package versions, provider constraints. Those pins age: a newer version fixes a
bug the repository still carries, and a disclosed advisory turns a safe pin into
a vulnerability. Keeping them current MUST be automatic and driven on the GitHub
platform, producing ordinary pull requests that are reviewed and released
through the same gate as any change — never a side channel that bypasses review.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles.md):

- **[Everything as Code](../../Ways-of-Working/Principles.md#everything-as-code).** What is checked and how often is version-controlled configuration, not a manual audit.
- **[Decision before change](../../Ways-of-Working/Principles.md#decision-before-change).** Every update is a pull request; its review gate approves the bump and the release it produces.
- **[Least-privilege](../../Ways-of-Working/Principles.md#least-privilege).** The updater and any auto-merge automation carry only the permissions they need.
- **[Extensible by default](../../Ways-of-Working/Principles.md#extensible-by-default).** Adding a package ecosystem is a configuration entry, not new machinery.

## Scope

Any repository that pins external dependencies: Action and workflow SHAs,
container base images, language packages and lockfiles, Terraform providers and
modules. Two questions are asked of every pin — **currency** (is a newer version
available?) and **security** (does the pinned version carry a known advisory?).

## Requirements

- **Automatic checking.** Version currency is checked on a schedule; security advisories trigger updates out of band. No human watches upstream releases.
- **One reviewed PR per update.** Each update is a pull request that passes the full CI gate before merge; nothing is applied unreviewed.
- **Two labelled dimensions.** Every update PR is labelled with its category and ecosystem, and with the dependency's own version-change level.
- **Labels MUST NOT collide with release versioning.** The label that signals the *dependency's* version level MUST NOT reuse the release-bump labels (`Major` / `Minor` / `Patch` / `NoRelease`). A dependency update is artifact-affecting and therefore *produces a release*; sharing one label set across the two dimensions would bump this repository's version off the wrong signal.
- **SHA pins stay immutable.** An Action or workflow update rewrites the pin to the new commit SHA with the version as a trailing comment.
- **Security first.** Security updates are prioritised over scheduled version updates.

## Success criteria

- An outdated or vulnerable pin produces a labelled pull request with no human trigger.
- No dependency PR merges without passing the same checks as any other PR.
- The dependency's version level is legible from labels without opening the diff, and never changes this repository's release bump by itself.

## Where this connects

- [Design](design.md) — the label scheme, the updater, and the auto-merge policy.
- [Release Management](../release-management/spec.md) — the versioning update PRs feed into, and the bump labels these must not reuse.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#keep-pinned-actions-current) — keeping pinned Actions current.
