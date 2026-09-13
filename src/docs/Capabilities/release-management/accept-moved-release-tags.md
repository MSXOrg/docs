---
title: Accept Moved Release Tags
description: Refresh an owned moving release alias locally and configure Git to keep it current.
---

# Accept moved release tags

Use this guide when an MSX-owned producer intentionally publishes a moving Git
tag such as `v3` or `v3.4` and your local clone still resolves it to an older
release.

Do not use this procedure for exact version tags such as `v3.4.2`. Exact version
tags are immutable. A moved exact tag is a producer integrity incident, not a
normal update.

## Why an ordinary fetch can leave a stale tag

Git protects existing local tags from being overwritten. An ordinary
`git fetch` can therefore update branches while silently leaving a moving tag at
its old object. Fetching all tags explicitly can instead report:

```text
! [rejected]        v3 -> v3  (would clobber existing tag)
```

Both outcomes leave the consumer on the previous release until it accepts the
producer-owned alias movement explicitly.

## Refresh tags once

Before this command, preserve or rename any local-only tags you need. Pruning
tags removes local tags that do not exist on the remote, and force permits the
remote's tag values to replace local values.

```bash
git fetch --tags --force --prune --prune-tags
```

This refreshes moved aliases and removes tags deleted from the configured
remote. Review the fetch output before building or resolving a dependency.

## Keep owned aliases current

For a clone that should continuously accept the `origin` repository's controlled
tag aliases, inspect the current fetch refspec:

```bash
git config --get-all remote.origin.fetch
```

If the output does not already contain `+refs/tags/*:refs/tags/*`, add it once:

```bash
git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'
git config fetch.prune true
git config fetch.pruneTags true
```

The leading `+` allows the remote's tag namespace to update local tags
non-fast-forward. The prune settings remove local tag references no longer
present on the remote. Use this configuration only when `origin` is inside the
consumer's permitted trust boundary and the producer owns the moving aliases.

After configuration, a normal fetch from `origin` keeps branches and tags
aligned:

```bash
git fetch --prune origin
```

## Verify an alias

Compare the local tag object with the remote tag object:

```bash
git rev-parse refs/tags/v3
git ls-remote --refs origin refs/tags/v3
```

The first hash must equal the hash at the start of the second command's output.
Repeat with the actual alias, such as `v3.4`.

Then resolve the exact release and immutable source before use:

```bash
git show --no-patch --decorate refs/tags/v3
```

A CI job can perform the same comparison and fail when the local alias is stale.
Consumers outside the producer's trust boundary must use an exact immutable
version or commit SHA instead of configuring automatic tag movement.

## Where this connects

- [Release Management design](design.md#current-version-discovery-and-aliases) —
  when an owned alias can move.
- [Publishing Targets](design-publishing-targets.md#github-releases) — GitHub
  exact tags, moving aliases, and release records.
- [GitHub Actions](../../Coding-Standards/GitHub-Actions.md#pin-actions-according-to-ownership) —
  when an owned major tag is permitted.
