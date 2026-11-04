# MSX Docs

This repository contains the shared **MSX** documentation for GitHub projects. The vision, principles, ways of working, and coding standards apply to each MSX organization, repository, and agent.

Contributors, maintainers, integrators, and their agents use the published docs and plugin entry points to build and adopt MSX projects.

[Zensical](https://zensical.org) publishes the documentation to GitHub Pages: **[msxorg.github.io/docs](https://msxorg.github.io/docs/)**.

## What's inside

- **Vision** — the mission and the principles of easy, fast, and safe.
- **Initiatives** — the products that apply the vision, such as PSModule, reusable Actions, and VS Code extensions.
- **Ways of Working** — shared workflow, principles, issue/PR/commit conventions, and review etiquette.
- **Coding Standards** — shared rules for naming, code layout, documentation, testing, and security.
- **Capabilities** — reusable specs and designs for what the ecosystem builds.
- **Dictionary** — shared vocabulary for readers and agents.
- **Agent Plugins** — installable entry points that route Copilot to the canonical documentation.

The vision and principles have one canonical source in this repository. Products reference these sources, and the documentation changes as the supported contract changes.

## How to read it

The documentation uses a hierarchy of section indexes and pages. Each page declares a `title` and a one-line `description`. Each section has an `index.md` that lists its contents.

Start at [`src/docs/index.md`](src/docs/index.md) or the [published root](https://msxorg.github.io/docs/). Read section descriptions, then follow links to the page for your task.

Readers and agents use the same structure to find the relevant document.

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
