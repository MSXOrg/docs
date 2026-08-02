# Contributing

Every change lands through a pull request — nothing goes directly to `main`. See the
[Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/)
for the full process: draft first, the Copilot review loop, then human review.

Everything here is a work in progress and can be improved. Fix a small problem when it is
directly in scope; register a larger or unrelated one as an issue in the repository that
owns it.

## Making a change

1. Work in a dedicated [worktree](https://msxorg.github.io/docs/Ways-of-Working/Git-Worktrees/)
   per topic branch, named `<type>/<issue>-<slug>` as
   [Branching and Merging](https://msxorg.github.io/docs/Ways-of-Working/Branching-and-Merging/)
   defines.
2. Edit the relevant page(s) under `src/docs/`, following the authoring conventions below.
3. If you added or renamed a page, regenerate the indexes:

   ```pwsh
   pwsh .github/scripts/Update-DocumentationIndex.ps1
   ```

4. Validate links before opening a pull request:

   ```pwsh
   pwsh .github/scripts/Test-DocumentationLink.ps1
   ```

5. Preview the site if you want to see the rendered result.
6. Open the pull request as a draft and follow the
   [Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/).

## Authoring conventions

The docs are built for recursive navigation, so a reader or an agent can start at the top
index and drill down to the right page. Three conventions make that work.

- **Every page carries front matter.** Each `.md` file declares a `title` — the label used
  in navigation and the generated indexes — and a one-line `description`:

  ```yaml
  ---
  title: Error Handling
  description: Fail fast, never swallow, and write messages that help the next person.
  ---
  ```

- **Every section has an index.** Each `index.md` holds an auto-generated table of the
  documents at its level, between markers:

  ```markdown
  <!-- INDEX:START -->
  <!-- INDEX:END -->
  ```

- **The tables are generated from front matter.** `.github/scripts/Update-DocumentationIndex.ps1`
  reads each page's `title` and `description`, orders them to match the navigation in
  `src/zensical.toml`, and fills every index in place. CI runs the same script with `-Check`
  and fails if an index is out of date.

Links are validated the same way: `.github/scripts/Test-DocumentationLink.ps1` checks that
every relative link and heading anchor across the docs resolves, in CI on every pull request
and on every push to `main`.

Write to the [Markdown standard](https://msxorg.github.io/docs/Coding-Standards/Markdown/)
and the [Documentation Model](https://msxorg.github.io/docs/Ways-of-Working/Documentation-Model/);
both are enforced by the shared linter configuration under `.github/linters/`.

## Building and previewing locally

The site is built with [Zensical](https://zensical.org), a Python static-site generator.

```bash
pip install -r requirements.txt
cd src
zensical serve    # live preview at http://localhost:8000
zensical build    # output to src/site
```

## Commits and pushes

Keep work reviewable with small, descriptive commits — one logical change each, no
conventional-commit prefixes. See
[Commit Conventions](https://msxorg.github.io/docs/Ways-of-Working/Commit-Conventions/).

Push every commit, so the remote branch, CI, and the draft pull request always reflect the
current state of the work.

## Agent workspace

Agents working here read organization memory from `~/.msx/memory`, set up by the
[workspace bootstrap](bootstrap/README.md). That bootstrap is user-global: it is installed
once per machine, not per repository.

When a verified lesson is likely to matter again, record it in `~/.msx/memory` and push it
directly to `main`, following that repository's own contribution guide.

See the [README](README.md) for what this repository is and how it is laid out, and the
[Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) for the conventions every
pull request follows — issue format, PR format, branching, and review etiquette.
