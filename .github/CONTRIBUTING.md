# Contributing

Every change enters `main` through a pull request. See the
[Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/)
for the process: draft first, the Copilot review loop, then human review. Write the
title and description according to
[PR Format](https://msxorg.github.io/docs/Ways-of-Working/PR-Format/).

Fix a small problem when it is directly in scope.
Register a larger or unrelated problem as an issue in the repository that owns it.

## Making a change

1. Work in a dedicated [worktree](https://msxorg.github.io/docs/Ways-of-Working/Git-Worktrees/)
   per topic branch, named `<type>/<issue>-<slug>` as
   [Branching and Merging](https://msxorg.github.io/docs/Ways-of-Working/Branching-and-Merging/)
   defines.
2. Edit the relevant pages under `src/docs/`. Follow the authoring conventions below.
3. If you add or rename a page, regenerate the indexes:

   ```pwsh
   pwsh .github/scripts/Update-DocumentationIndex.ps1
   ```

4. Validate links before you open a pull request.
   The first script resolves relative links and anchors from the checkout.
   The second resolves links into other MSX repositories over the network:

   ```pwsh
   pwsh .github/scripts/Test-DocumentationLink.ps1
   pwsh .github/scripts/Test-CrossRepositoryLink.ps1
   ```

5. Run the Pester suites. CI runs the same suites:

   ```pwsh
   pwsh .github/scripts/Invoke-PesterSuite.ps1
   ```

   If the pinned Pester version is missing, the script installs it for the current user.
   It runs every `tests/*.Tests.ps1` suite and exits non-zero if any test fails.
   To run one suite during development, use Pester directly:

   ```pwsh
   Invoke-Pester -Path ./tests/Update-DocumentationIndex.Tests.ps1
   ```

6. If you need to inspect the rendered result, preview the site. See
   [Building and previewing locally](#building-and-previewing-locally).
7. Open the pull request as a draft and follow the
   [Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/).

## Pull request format

Write the title and complete description using [canonical PR
Format](https://msxorg.github.io/docs/Ways-of-Working/PR-Format/).
Use its [complete description example](https://msxorg.github.io/docs/Ways-of-Working/PR-Format/#complete-description-example)
to write the record. Verify any applicable release-range and source evidence against that guidance.

## Authoring conventions

Section indexes help readers and agents find the relevant page.
Follow these three authoring conventions.

- **Every page carries front matter.** Each `.md` file declares a `title` for navigation and generated indexes.
  It also declares a one-line `description`:

  ```yaml
  ---
  title: Error Handling
  description: Fail fast, never swallow, and write messages that help the next person.
  ---
  ```

- **Every section has an index.** Each `index.md` contains a generated table of the
  documents at its level, between markers:

  ```markdown
  <!-- INDEX:START -->
  <!-- INDEX:END -->
  ```

- **The tables are generated from front matter.** `.github/scripts/Update-DocumentationIndex.ps1`
  reads each page's `title` and `description`. It orders entries to match the navigation in
  `src/zensical.toml` and updates each index in place.
  CI regenerates the indexes before the site build. It does not reject differences in generated tables.

Choose a page's location by subject. Then choose the artifact that answers the reader's question.
The [Documentation Model](https://msxorg.github.io/docs/Ways-of-Working/Documentation-Model/#architecture-and-classification)
defines the artifact tiers and minimal OKF-style front matter.

`.github/scripts/Test-DocumentationLink.ps1` validates relative links and heading anchors in the documentation.
`.github/scripts/Test-CrossRepositoryLink.ps1` validates file and anchor links into other MSX repositories.
Both run in CI for each pull request and push to `main`.
The cross-repository check also runs weekly because target repositories can change independently.

Follow the [Markdown standard](https://msxorg.github.io/docs/Coding-Standards/Markdown/)
and the [Documentation Model](https://msxorg.github.io/docs/Ways-of-Working/Documentation-Model/).
The shared linter configuration under `.github/linters/` enforces Markdown formatting rules.
Review page purpose and structure against the Documentation Model.

## Building and previewing locally

The site uses [Zensical](https://zensical.org), a Python static-site generator.

```bash
pip install -r requirements.txt
cd src
zensical serve    # live preview at http://localhost:8000
zensical build    # output to src/site
```

## Commits and pushes

Use small, descriptive commits, with one logical change in each commit.
Do not use conventional-commit prefixes. See
[Commit Conventions](https://msxorg.github.io/docs/Ways-of-Working/Commit-Conventions/).

Push every commit so the remote branch, CI, and draft pull request use the same committed work.

See the [README](../README.md) for the repository's purpose and layout.
The [Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) define issue format,
PR format, branching, and review etiquette.
