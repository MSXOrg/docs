---
title: Markdown
description: GitHub Flavored Markdown authoring rules enforced by the shared markdownlint configuration.
---

# Markdown

Documentation across the ecosystem uses [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/) and a **single shared `markdownlint` configuration**. Repositories consume this configuration rather than define separate formatting rules.

This standard covers the **syntax and style rules** the linter enforces. For how documentation lives next to the thing it describes, see the [Documentation](Documentation.md) baseline standard and [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md).

## The shared configuration is the source of truth

The rules below come from `.github/linters/.markdown-lint.yml`. Markdownlint uses this configuration through super-linter at PR time and on the assembled artifact. Both runs use the **same** configuration. A successful local run covers only the examined content and enabled rules. The configuration file, not this page, is authoritative if they differ.

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
| MD051 | Link fragments resolve — a `#anchor` must match a real heading. A heading's custom anchor is written `{#id}`, with no spaces inside the braces. |

The linter also applies its default ruleset. Every code fence has a language tag. Files have no trailing whitespace and end with one newline.

MD051 validates **same-file** fragments only. The linter does not examine cross-file fragments such as `spec.md#fr1`. A successful lint run does not prove that cross-file anchors resolve. Repositories that use them also need a link checker. This repository uses `.github/scripts/Test-DocumentationLink.ps1`.

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
- **Surround headings, lists, and fenced blocks with a blank line** for readability, although the linter does not enforce it.
- **Prefer relative links** within a repository; use the canonical published URL for cross-repository references. Relative links, and cross-repository links on `github.com`, are checked in CI — see [Links are checked](#links-are-checked).
- **Give a repeated or long link a reference-style definition** (`[text][ref]`, with `[ref]: url` listed below) so the prose stays readable and one edit updates every use.
- **Write a heading's custom anchor as `{#id}`** when it needs a stable identifier. Markdown heading attributes are not part of [the original syntax](https://daringfireball.net/projects/markdown/syntax), [CommonMark](https://spec.commonmark.org/), or [GFM](https://github.github.com/gfm/). The site enables the [`attr_list`](https://python-markdown.github.io/extensions/attr_list/) extension; GitHub does not. The published page converts the braces to an `id`, while the repository file view shows literal text. `attr_list` also accepts `{ #id }` and `{: #id }`. Markdownlint reads only the unspaced form. With the other forms, the linter uses the heading's slugified anchor. Same-page references to the custom identifier fail lint, while cross-file references can break without a lint error. [Spec-Driven Development](../Ways-of-Working/Spec-Driven-Development.md#requirements) owns the FR/NFR identifiers. This syntax applies to any page.
- **Tag every code fence with a language** (` ```bash `, ` ```yaml `) so it is highlighted and converts cleanly when published.
- **Wrap code, commands, filenames, and identifiers in backticks** rather than bold or italic, so readers recognize them as literal code.
- **Give every image descriptive alt text** — `![what the image shows](diagram.png)` — for screen readers and for use when the image does not load. Use a relative path for images kept in the repository.

## Links are checked

Repositories validate the links this standard requires. This repository runs two checks on every pull request and on every push to `main`. Each check covers a different link scope.

**Inside a repository** — `Test-DocumentationLink.ps1` resolves every relative target and every heading anchor against the checkout. It needs no network. It fails when a target or anchor does not resolve.

**Into another repository** — `Test-CrossRepositoryLink.ps1` resolves cross-repository links on `github.com` against their target repository. Its separate job distinguishes cross-repository failures from local-link failures. It also runs weekly because a target repository can change after a pull request here merges.

What it covers:

- **Links into the organizations MSX controls** — `MSXOrg`, `PSModule`, and `Storhaug-ting`, on `github.com` and `raw.githubusercontent.com`. Ownership defines the scope. Checking every internet URL would add unrelated requests and exposure to external outages. The check covers a defined set of repositories whose content MSX controls.
- **The file and the anchor.** A request does not send its `#fragment` to the server. A HEAD response of 200 therefore does not prove that the heading exists. The check fetches the content and derives heading anchors with **GitHub's** rules. These differ from the published site's rules: `## Hello — world` is `#hello--world` on GitHub and `#hello-world` on the site. A repeated heading has the suffix `-1` on GitHub and `_1` on the site. Use the anchor GitHub assigns.
- **Repository roots, `blob`, `tree`, `raw`, and `?tab=readme-ov-file#anchor`.** The check resolves a branch or tag at that reference, so a renamed branch also fails. It excludes routes that name API objects rather than file paths: `/issues/`, `/pull/`, `/discussions/`, `/releases/`, `/actions/`, `/wiki/`, `/compare/`, `/commit/`. These routes do not change when a repository is restructured.

Published-site URLs such as `https://msxorg.github.io/docs/…` are outside these checks. This is the canonical URL form for a repository that publishes to GitHub Pages. See [MSXOrg/docs#150](https://github.com/MSXOrg/docs/issues/150) for the validation gap. Inside a repository, prefer relative links so the local check resolves both the file and its anchor.

Two things follow for authors:

- **Do not link a public page into a repository a reader cannot open.** The check reads targets as an anonymous reader does, so a private target is reported — not as a broken link, but as one nobody outside can follow. If the link has to stay, say in the prose that the target is private.
- **A run that resolved no cross-repository link fails.** *Every link resolves* is trivially true when none were found, so an empty result is reported as a failure rather than a pass. See [Nothing checked is not a pass](Testing.md#nothing-checked-is-not-a-pass).

Run both before opening a pull request:

```powershell
./.github/scripts/Test-DocumentationLink.ps1
./.github/scripts/Test-CrossRepositoryLink.ps1
```

## PowerShell code samples

Documentation is full of PowerShell, so present it the way the [PowerShell standard](PowerShell/index.md) writes it:

- **Label the fence `powershell`**. Put command output in a separate block labeled `Output`, so readers do not mistake it for a command.
- **Use full cmdlet and parameter names**, and avoid positional parameters, so a reader can copy the sample and run it.
- **Avoid backtick line-continuation.** Break a long call with splatting, or at PowerShell's natural points — after a pipe, an opening parenthesis, or a brace.
- **Leave out the prompt string** (`PS>`) unless the sample is specifically about interactive, prompt-changing behavior.
