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
- **Prefer relative links** within a repository; use the canonical published URL for cross-repository references. Relative links, and cross-repository links on `github.com`, are checked in CI — see [Links are checked](#links-are-checked).
- **Give a repeated or long link a reference-style definition** (`[text][ref]`, with `[ref]: url` listed below) so the prose stays readable and one edit updates every use.
- **Tag every code fence with a language** (` ```bash `, ` ```yaml `) so it is highlighted and converts cleanly when published.
- **Wrap code, commands, filenames, and identifiers in backticks** rather than bold or italic, so they read as code and do not lean on the emphasis the linter now allows freely.
- **Give every image descriptive alt text** — `![what the image shows](diagram.png)` — so it serves screen readers and still says something when the image fails to load; use a relative path for images kept in the repository.

## Links are checked

A link the standard asks for is a link something verifies. Two checks run on every pull request and on every push to `main`, and each answers a different question.

**Inside a repository** — `Test-DocumentationLink.ps1` resolves every relative target and every heading anchor against the checkout. It needs no network, and it fails the moment a moved page is not accompanied by the links that pointed at it.

**Into another repository** — `Test-CrossRepositoryLink.ps1` resolves cross-repository links on `github.com` against the repository they point at. It runs as its own job, so a red check says the network check failed rather than the documentation being wrong, and again weekly, because a target repository moves content long after a pull request here has merged.

What it covers:

- **Links into the organizations MSX controls** — `MSXOrg`, `PSModule`, and `Storhaug-ting`, on `github.com` and `raw.githubusercontent.com`. Scope is ownership, not scheme: checking every URL on the internet is slow and hostage to other people's outages, while the repositories we govern are a bounded set and are where the breakage starts — the target moved because we moved it.
- **The file and the anchor.** A `#fragment` is never sent to the server, so a HEAD request answers 200 whether or not the heading exists. The content is fetched and its headings are slugged with **GitHub's** rules, which are not the rules the published site uses — `## Hello — world` is `#hello--world` on GitHub and `#hello-world` on the site, and a repeated heading is `-1` there and `_1` here. Write the anchor GitHub gives you, which is the one the browser scrolls to.
- **Repository roots, `blob`, `tree`, `raw`, and `?tab=readme-ov-file#anchor`.** A link naming a branch or tag is resolved at that reference, so a renamed branch fails too. Routes that name an API object rather than a path — `/issues/`, `/pull/`, `/discussions/`, `/releases/`, `/actions/`, `/wiki/`, `/compare/`, `/commit/` — are left alone. They do not move when a repository is restructured.

What it does **not** cover yet: a published-site URL such as `https://msxorg.github.io/docs/…`, which is the canonical form for a repository that publishes to GitHub Pages. Nothing verifies those today — see [MSXOrg/docs#150](https://github.com/MSXOrg/docs/issues/150). Inside a repository, prefer a relative link anyway; the check that already resolves those is the stricter of the two.

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

- **Label the fence `powershell`**, and put command output in a separate block labelled `Output`, so it is neither syntax-highlighted as a command nor mistaken for input.
- **Use full cmdlet and parameter names**, and avoid positional parameters, so a reader can copy the sample and run it.
- **Avoid backtick line-continuation.** Break a long call with splatting, or at PowerShell's natural points — after a pipe, an opening parenthesis, or a brace.
- **Leave out the prompt string** (`PS>`) unless the sample is specifically about interactive, prompt-changing behaviour.
