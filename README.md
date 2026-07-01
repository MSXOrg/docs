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

The vision is written once, here, and referenced everywhere. Products change; the principles they express stay put.

## Documentation conventions

The docs are built for recursive navigation — a reader, or an agent, starts at the top index and drills down until it reaches the right page.

- **Every page carries front matter.** Each `.md` file declares a `title` (matching its H1) and a one-line `description`:

  ```yaml
  ---
  title: Error Handling
  description: Fail fast, never swallow, and write messages that help the next person.
  ---
  ```

- **Every section has an index.** Each `index.md` holds an auto-generated table of the documents at its level, between markers:

  ```markdown
  <!-- INDEX:START -->
  <!-- INDEX:END -->
  ```

- **The tables are generated from front matter.** `.github/scripts/generate-indexes.ps1` reads each page's `title` and `description`, orders them to match the navigation in `src/zensical.toml`, and fills every index in place. Run it after adding or renaming a page:

  ```pwsh
  pwsh .github/scripts/generate-indexes.ps1
  ```

  CI runs the same script with `-Check` and fails if an index is out of date.

The result is self-describing documentation: start at `src/docs/index.md`, read the descriptions, follow the link into a section, then into a page — repeating until you reach the document that fits the task.

## Repository layout

```text
.github/
  workflows/Docs.yml   # lint, build, and publish to GitHub Pages
  scripts/             # documentation tooling (index generation)
  linters/             # shared linter configuration
src/
  zensical.toml        # site configuration
  docs/                # the documentation content
  includes/            # shared snippets (abbreviations, links)
  overrides/           # theme overrides
```

## Build locally

The site is built with [Zensical](https://zensical.org), a Python static-site generator.

```bash
pip install zensical
cd src
zensical serve    # live preview at http://localhost:8000
zensical build    # output to src/site
```

## Contributing

Every change lands through a pull request — nothing goes directly to `main`. Branch, build, open a draft PR, and let CI validate it. See the [Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) for the full workflow.
