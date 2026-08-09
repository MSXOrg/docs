---
title: Code Ownership
description: The three-layer model behind CODEOWNERS — permission, ownership, and enforcement — how the file is resolved and where it is read from, and why ownership without enforcement is decorative.
---

# Code Ownership

`CODEOWNERS` is one of the most misread files in a repository. It looks like an access
control list and behaves like a mailing list. Getting that wrong produces two failure
modes that are hard to spot: a team believing it has locked a path it has not, and a
"required" owner review that never appears because the mapped team was silently
ineligible.

The model is three layers that MUST be kept separate.

## Three layers

| Layer | Mechanism | Question it answers |
| --- | --- | --- |
| **Permission** | Repository and team roles | Who *can* push and merge? |
| **Ownership** | `CODEOWNERS` | Who is *asked to review* a given path? |
| **Enforcement** | Branch protection or a ruleset | Is an owner's approval *required* to merge? |

`CODEOWNERS` is a **review-assignment** mechanism. It grants no access whatsoever. An
owner MUST already hold write access — as a user, or as a team that is **visible and has
write access on the repository**, even where every member of that team already holds
write access by some other route. A user or team that does not meet that bar is silently
not assigned, and that silence is the single most common reason a required owner review
never materializes.

Ownership therefore narrows who is accountable for a path without widening who can write
to it, which is [least privilege](Principles/Purpose-and-Direction.md#least-privilege)
expressed as review routing.

## One file per branch

A repository uses **one** `CODEOWNERS` file per branch. It may live in `.github/`, at the
repository root, or in `docs/`. Where more than one exists, GitHub uses the **first found
in that order** and ignores the rest — it does not merge them.

There is no nested or per-directory `CODEOWNERS`. Ownership for the whole tree is
expressed from that single file through path patterns, so different directories can have
different owners without scattering files through the repository.

The file is read from the **base branch of the pull request**, not from the head branch.
Two consequences follow, and both matter:

- A pull request cannot change its own reviewers. An edit to `CODEOWNERS` on a topic
  branch takes effect only once merged.
- Different branches may carry different owners, so a published-output branch can be
  owned separately from the default branch.

## Patterns

Patterns follow most [gitignore pattern rules](https://git-scm.com/docs/gitignore#_pattern_format),
followed by one or more owners.

```text
# Default owner for everything — lowest precedence, so it goes first.
*                     @MSXOrg/docs-maintainers

# Section owners. Later matches win, so specifics go below the default.
/src/docs/            @MSXOrg/docs-maintainers
/.github/             @MSXOrg/admins

# A directory anywhere in the tree.
**/diagrams/          @MSXOrg/docs-maintainers
```

The rules worth committing to memory:

- **Last match wins.** Ordering is significant; the most specific rule goes last. This is
  the opposite of most precedence intuitions and the most frequent authoring mistake.
- **Multiple owners on one line means any one of them satisfies** a required owner review
  — not all of them.
- **An owner-less pattern removes ownership** for that path, exempting it from a broader
  rule above.
- **Paths are case-sensitive**, including from case-insensitive filesystems.
- Unlike gitignore, `!` negation, `[ ]` character ranges, and `\#` escaping are **not**
  supported.
- Any invalid line is **skipped**, not fatal. The file must stay under 3 MB.
- Draft pull requests do not request owners; owners are notified when the pull request is
  marked ready for review — which fits the
  [draft-first workflow](Contribution-Workflow.md) exactly.

Map to **teams rather than individuals**. A team keeps the file stable as membership
changes and avoids a single point of failure, and any one member's approval satisfies the
requirement.

## Making it enforce

`CODEOWNERS` changes nothing at merge time until a rule requires it. Ownership without
enforcement is decorative: the file requests reviewers and a maintainer can merge past
them.

To make it bind, require review from code owners — in a branch protection rule, or, for
preference, in a **ruleset**. Rulesets are version-controlled, discoverable without admin
access, layerable, and can be defined **once at the organization level and applied across
many repositories**, which is what makes them the fleet-scale mechanism.

Two hazards MUST be closed:

1. **Own the owners file.** Give `/.github/` — or at minimum `/.github/CODEOWNERS` — an
   owner, so a change cannot weaken ownership without the current owners being asked.
   The base-branch rule above prevents a pull request removing its *own* reviewers, but
   not a merged change removing them for everyone afterwards.
2. **Check that the requirement is actually on.** A repository whose ruleset requires zero
   approving reviews and does not require owner review has a `CODEOWNERS` file that only
   suggests.

## Across many repositories

There is **no organization-wide `CODEOWNERS`**. The organization's `.github` repository
holds default community-health files — contributing guides, issue templates — but
`CODEOWNERS` is not one of them. It is always per-repository.

Ownership that spans repositories is therefore assembled from three parts, and all three
MUST be present:

1. A real, **visible team with write access** on every repository it owns.
2. A **per-repository `CODEOWNERS`** file, seeded from the repository template so a new
   repository starts owned rather than being retrofitted.
3. An **organization ruleset** requiring a pull request and code-owner review, so the file
   binds.

Define once, apply everywhere, keep it in source — the same pattern
[repository governance](../Capabilities/repository-governance/design.md) applies to branch
policy. Codifying the baseline file and the ruleset is what turns code ownership from a
per-repository chore into something that holds by default.

## Validate it

Because invalid lines are skipped silently, a `CODEOWNERS` file SHOULD be validated in
CI: that every named owner exists, holds access, and that every path intended to be owned
actually resolves to an owner. GitHub exposes the errors it found through the
[list CODEOWNERS errors](https://docs.github.com/en/rest/repos/repos#list-codeowners-errors)
endpoint, and community validators check ownership coverage as well as syntax.

A silently-skipped line is indistinguishable from a line that works until the day
somebody needed the review.

## References

- [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format)
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [List CODEOWNERS errors (REST)](https://docs.github.com/en/rest/repos/repos#list-codeowners-errors)

## Where this connects

- [Repository Standard](Repository-Standard.md) — the baseline files every repository exposes, of which `CODEOWNERS` is one.
- [Repository Governance](../Capabilities/repository-governance/design.md) — how rulesets are defined once and applied across the fleet.
- [Contribution Workflow](Contribution-Workflow.md) — why draft-first and owner notification fit together.
- [Review Etiquette](Review-Etiquette.md) — what an owner does once they have been asked.
- [Least privilege](Principles/Purpose-and-Direction.md#least-privilege) — the principle ownership serves without widening access.
