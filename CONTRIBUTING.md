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
2. Edit the relevant page(s) under `src/docs/`.
3. If you added or renamed a page, run the index generator:

   ```pwsh
   pwsh .github/scripts/Update-DocumentationIndex.ps1
   ```

4. Validate links locally before opening a pull request:

   ```pwsh
   pwsh .github/scripts/Test-DocumentationLink.ps1
   ```

5. Preview the site if you want to see the rendered result:

   ```bash
   pip install -r requirements.txt
   cd src
   zensical serve
   ```

6. Open the pull request as a draft and follow the
   [Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/).

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

See the [README](README.md) for what this repository is and how it builds, and the
[Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) for the conventions
every pull request follows — issue format, PR format, branching, and review etiquette.
