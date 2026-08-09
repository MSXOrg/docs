---
title: Issue Format
description: Universal title, body, audit, and formatting rules for every issue.
---

# Issue Format

Every issue in the MSX ecosystem follows the same universal rules. The issue's native type determines the body detail; use the guidance for [Epic](../Types/Epic.md), [PBI](../Types/PBI.md), [Task](../Types/Task.md), or [Bug](../Types/Bug.md) rather than adding type-specific conventions here.

## Title

Write a clear, imperative statement of the outcome or work:

- Name the scope when it aids disambiguation.
- Describe the requested result, not a question, symptom, or status.
- Do not add type prefixes such as `[Bug]` or `[Feature]`; the native issue type carries that meaning.

## Body

The body is the current source of truth. It:

- Explains the issue's local purpose and desired outcome without requiring prior context.
- States observable acceptance criteria.
- Records the decisions and plan needed at the issue's [planning altitude](Planning.md).
- Links to durable specifications, designs, prior decisions, pull requests, or external references instead of duplicating them.
- Changes as understanding, readiness, and scope change through the [issue lifecycle](Lifecycle.md).

Keep information at its owning altitude. User-visible intent precedes technical detail, and implementation choices do not leak into outcome-level acceptance criteria. The type pages define which sections and evidence are required at each altitude.

## Native metadata and relationships

Assign the native issue type and maintain [native relationships](Relationships.md) in GitHub. Labels may classify release impact or repository-specific concerns, but they do not replace issue types, containment, dependencies, or readiness.

Do not duplicate metadata or relationships in the body. In particular, do not add manual `Parent:` or `Blocked by:` fields, copied child-link lists, or prose that treats list position as execution order.

## Audit trail

Edit the body whenever the current truth changes, then add a comment that briefly records:

- What changed.
- Why it changed.
- Any unresolved question or follow-up.

Comments preserve the audit trail; they do not become a second current specification or plan.

## Formatting

Use [GitHub Flavored Markdown](https://github.github.com/gfm/) to make the body easy to scan:

- Headings for distinct concerns.
- Task lists only where the type guidance calls for tracked work.
- Tables only when comparison is clearer than prose.
- Fenced code blocks with language identifiers.
- Backticks for identifiers and commands.
- Markdown links for external references rather than bare URLs.
- Refer to every issue or pull request as `Org/Repo#N`, including references in the current repository; do not use bare `#N` references.
- Horizontal rules when they clarify the transition between intent, decisions, and plan.

Write each paragraph as a single unbroken line. Prefer concise body content and link to the canonical source instead of restating it.
