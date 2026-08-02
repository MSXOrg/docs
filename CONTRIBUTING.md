# Contributing

Every change lands through a pull request — nothing goes directly to `main`. See the
[Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/)
for the full process: draft first, the Copilot review loop, then human review.

## Making a change

1. Branch, then edit the relevant page(s) under `src/docs/`.
2. If you added or renamed a page, run the index generator:

   ```pwsh
   pwsh .github/scripts/Update-DocumentationIndex.ps1
   ```

3. Validate links locally before opening a pull request:

   ```pwsh
   pwsh .github/scripts/Test-DocumentationLink.ps1
   ```

4. Run the Pester suites — the same job CI runs, so a failure shows up before the
   pull request is opened:

   ```pwsh
   pwsh .github/scripts/Invoke-PesterSuite.ps1
   ```

   The script installs the pinned Pester version for the current user if it is
   missing, runs every `tests/*.Tests.ps1` suite, and exits non-zero if any test
   fails. To run one suite while iterating, use Pester directly:

   ```pwsh
   Invoke-Pester -Path ./tests/Update-DocumentationIndex.Tests.ps1
   ```

5. Preview the site if you want to see the rendered result:

   ```bash
   pip install -r requirements.txt
   cd src
   zensical serve
   ```

6. Open the pull request as a draft and follow the
   [Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/).

See the [README](README.md) for what this repository is and how it builds, and the
[Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) for the conventions
every pull request follows — issue format, PR format, branching, and review etiquette.
