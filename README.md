# MSX Docs

The top-of-tree documentation for everything **MSX** builds on GitHub — the vision, principles, ways of working, and coding standards that every organization, repository, and agent in the ecosystem inherits.

Published with [Zensical](https://zensical.org) to GitHub Pages: **[msxorg.github.io/docs](https://msxorg.github.io/docs/)**.

## What's inside

- **Vision** — the *why*: the mission and the philosophy of easy, fast, and safe.
- **Initiatives** — the *what*: the products that make the vision real, from PSModule to reusable Actions and VS Code extensions.
- **Ways of Working** — the *how*: workflow, principles, issue/PR/commit conventions, review etiquette, and more.
- **Coding Standards** — language-agnostic standards for naming, layout, documentation, testing, and security.
- **Capabilities** — the reusable specs and designs for what the ecosystem builds.
- **Dictionary** — the shared vocabulary every reader and agent uses.
- **Agent Plugins** — installable entry points that route Copilot to the current canonical documentation.

The vision is written once, here, and referenced everywhere. Products change; the principles they express stay put.

## How to read it

The docs are built for recursive navigation. Every page declares a `title` and a one-line `description`, and every section has an `index.md` listing what sits below it. Start at [`src/docs/index.md`](src/docs/index.md) — or the [published root](https://msxorg.github.io/docs/) — read the descriptions, follow the link into a section, then into a page, until you reach the document that fits the task.

That structure is what lets a reader and an agent find the same page by the same route.

## Repository layout

```text
.github/
  plugin/marketplace.json # Copilot plugin marketplace
  workflows/Docs.yml   # lint, validate links, build, and publish to GitHub Pages
  scripts/             # documentation tooling (index generation, link validation)
  linters/             # shared linter configuration
.github/plugin/        # portable Agent Plugins that point into the documentation
src/
  zensical.toml        # site configuration
  docs/                # the documentation content
  includes/            # shared snippets (abbreviations, links)
  overrides/           # theme overrides
```
