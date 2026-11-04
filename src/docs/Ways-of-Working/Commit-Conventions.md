---
title: Commit Conventions
description: How commit messages are written.
---

# Commit Conventions

Engineers and agents use commit messages in `git log` to understand what changed and why.
Use **direct, descriptive messages** that state the change or result.

## Rules

1. **State what was done or what the result is.** Imperative or declarative, both work.
2. **No conventional-commit prefixes.** No `fix:`, `feat:`, `docs:`, `chore:`, `refactor:`, etc.
   The PR records the change type; commit messages need no duplicate type prefix.
3. **No generic messages.** `Update for PR`, `WIP`, `fixes`, `more changes` — all forbidden.
   They do not identify the change.
4. **One logical change per commit.** If a change covers three unrelated concerns, make three commits.
5. **Reference issues by number when natural** — but don't force it. `Resolves Org/Repo#N` belongs in the PR description, not every commit message.

## Examples

### Good

- `Add reserved word validation to Lua parser`
- `Correct hex float parsing for negative exponents`
- `Update installation prerequisites in README`
- `Remove deprecated export command`
- `Switch pagination to link-header-based`
- `Add regression test for null session context`

### Bad

- `fix: parsing bug` — prefix + vague.
- `Update for PR` — meaningless.
- `WIP` — never commit work that needs a placeholder message; squash or amend first.
- `Refactor stuff` — vague.
- `Changes` — ø.

## Body (optional)

Use an optional body when a non-trivial change needs context.
Keep it short. Wrap at approximately 72 characters per line.

```text
Switch pagination to link-header-based

The previous page-number approach hardcoded the page size, which
breaks when the API returns the default. Link headers are what
the GitHub REST API documents as the supported pagination
mechanism.
```

## Why no conventional commits

MSX classifies changes at the PR level via labels and the change-type field.
For a release-bound PR, its description supplies the release note; commit messages do not.
Conventional-commit prefixes inside the repo:

- Duplicate information already captured elsewhere.
- Encourage `chore:` and `refactor:` over descriptive messages.
- Couple commit messages to a tooling pattern (Commitizen, semantic-release) that MSX does not use.

Direct, descriptive messages explain the change without duplicate type prefixes.

## When working with agents

The Builder writes commits as work proceeds. Each commit covers one logical change.
The Responder writes commits to address review feedback.
Use one commit per thread when practical so the history connects each fix to its feedback.

Never let an agent commit with a placeholder message.
If a commit cannot be described in one clear line, split the change.
