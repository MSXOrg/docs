---
title: Markdown
description: GitHub Flavored Markdown authoring rules enforced by the shared markdownlint configuration.
---

# Markdown

How Markdown is written across the ecosystem. All documentation is authored in [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/) and validated by a **single shared `markdownlint` configuration** that every repository consumes — no per-repo config drift.

This standard covers the **syntax and style rules** the linter enforces. For how documentation lives next to the thing it describes, see the [Documentation](Documentation.md) baseline standard and [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md).

## The shared configuration is the source of truth

The rules below are enforced by `.github/linters/.markdown-lint.yml` (markdownlint via super-linter), run at PR time and again on the assembled artifact. The **same** config runs in both places, so a file that passes locally passes in CI. The configuration file — not this page — is authoritative if the two ever diverge.

Check locally before opening a PR:

```bash
npx markdownlint-cli2 --config .github/linters/.markdown-lint.yml "src/docs/**/*.md"
```

## Enforced rules

These overrides and defaults are active, so author to them:

| Rule | Requirement |
|---|---|
| MD003 | Headings use **ATX** style (`# Heading`), never underline style. |
| MD007 | Nested list items indent by **2 spaces**. |
| MD025 | One H1 per document. A body `# Heading` is allowed **alongside** the YAML front-matter `title`. |
| MD026 | Headings do not end with trailing punctuation (`. , ; : !`). |
| MD046 | Code blocks are **fenced** (` ``` `), never indented. |
| MD048 | Code fences use **backticks**, not tildes. |

Beyond these the linter runs the default ruleset, so also honour its common defaults: headings tagged with a language on every code fence, no trailing whitespace, and a single trailing newline.

## Relaxed on purpose

These rules are disabled or widened so they do not flag valid documentation — do not work around them:

- **MD004** (unordered list marker style) — disabled; a file may use any consistent bullet.
- **MD013** (line length) — widened to 3000; prose and GFM tables wrap naturally.
- **MD029** (ordered list prefix) — disabled; ordered lists may renumber freely.
- **MD033** (inline HTML) — allowed, for Mermaid, `<details>`, and layout constructs.
- **MD036** (emphasis as heading) — allowed.
- **MD041** (first line must be a heading) — disabled, to allow YAML front matter at the top of a file.
- **MD060** (table column style) — disabled; compact and aligned GFM tables both pass.
- **Blank-line rules** — disabled, so spacing around headings, lists, and fences is a matter of style rather than a lint error.

## Style beyond the linter

- **Write one H1, then never skip heading levels** — an H3 only appears under an H2.
- **Use sentence-style headings.**
- **Surround headings, lists, and fenced blocks with a blank line** for readability, even though the linter no longer enforces it.
- **Prefer relative links** within a repository; use the canonical published URL for cross-repository references.
- **Tag every code fence with a language** (` ```bash `, ` ```yaml `) so it is highlighted and converts cleanly when published.
