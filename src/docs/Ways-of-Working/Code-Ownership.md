---
title: Code Ownership
description: Permission, review assignment, and merge enforcement for repository code owners.
---

# Code Ownership

`CODEOWNERS` assigns reviewers to repository paths. It does not grant access or require approval before merge.
Confusing these roles can leave a path unprotected or prevent GitHub from
requesting the intended owner's review.

These three layers MUST remain separate.

## Three layers

| Layer | Mechanism | Question it answers |
| --- | --- | --- |
| **Permission** | Repository and team roles | Who *can* push and merge? |
| **Ownership** | `CODEOWNERS` | Who is *asked to review* a given path? |
| **Enforcement** | Branch protection or a ruleset | Is an owner's approval *required* to merge? |

`CODEOWNERS` is a **review-assignment** mechanism. It grants no access. An owner
MUST already have write access.

A team must be **visible and have write access to the repository**. This
requirement applies even when every member already has
write access through another route. GitHub silently omits users or teams that do
not meet these conditions. This omission can prevent a required owner-review
request.

Ownership assigns accountability for a path without granting write permission.
This separation applies [least privilege](Principles/Purpose-and-Direction.md#least-privilege)
to review routing.

## One file per branch

A repository uses **one** `CODEOWNERS` file per branch. It may live in `.github/`, at the
repository root, or in `docs/`. Where more than one exists, GitHub uses the **first found
in that order** and ignores the rest — it does not merge them.

There is no nested or per-directory `CODEOWNERS`. One file uses path patterns to
assign owners throughout the repository. Different directories can have different
owners without separate ownership files.

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

Pattern rules:

- **Last match wins.** Ordering is significant; the most specific rule goes last.
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

`CODEOWNERS` does not enforce approval unless a merge rule requires code-owner
review. Without that rule, the file requests reviewers but a maintainer can merge
without their approval.

Require review from code owners in a branch protection rule or, preferably, a
**ruleset**. Define rulesets in version-controlled configuration. They are
discoverable without admin access, and multiple rulesets can apply together.
Define them **once at the organization level and apply them across many
repositories**.

Two controls MUST be verified:

1. **Own the owners file.** Give `/.github/` — or at minimum `/.github/CODEOWNERS` — an
   owner, so a change cannot weaken ownership without the current owners being asked.
   The base-branch rule above prevents a pull request removing its *own* reviewers, but
   not a merged change removing them for everyone afterward.
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
   repository starts with declared owners.
3. An **organization ruleset** requiring a pull request and code-owner review, so the file
   requires owner approval before merge.

The baseline file and ruleset define ownership once in source and apply it across
repositories. [Repository governance](../Capabilities/repository-governance/design.md)
applies the same pattern to branch policy.

## Validate it

CI SHOULD validate a `CODEOWNERS` file because GitHub silently skips invalid lines.
Validation verifies that every named owner exists and has access, and that every
path intended to have an owner resolves to one. GitHub exposes errors through the
[list CODEOWNERS errors](https://docs.github.com/en/rest/repos/repos#list-codeowners-errors)
endpoint, and community validators check ownership coverage as well as syntax.

A silently skipped line can leave a path without its intended owner.

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
