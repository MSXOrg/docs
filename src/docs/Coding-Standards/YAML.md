---
title: YAML
description: One file extension, yamllint locally and in CI, narrowly scoped suppressions, and actionlint for workflow files.
---

# YAML

YAML defines workflows, linter configurations, dependency manifests, and deployment
descriptors. Valid YAML syntax can still produce unintended values. Use linting rather
than visual review alone.

YAML-specific conventions extend the [language-agnostic baseline](index.md).
Where the rules overlap, the baseline rule applies.

## Use `.yml` consistently

Every YAML file MUST use the `.yml` extension, including files whose tooling accepts
either form.

Parsers accept both extensions, but file globs distinguish them. A repository that uses
both needs `*.{yml,yaml}` in every lint path, `paths:` filter, and editor association.
A filter that uses only `*.yml` silently omits long-extension files.

One exception exists, and only because the tool allows no alternative:
`.pre-commit-config.yaml`. Where a tool hard-codes the long form, follow the tool and note
it; otherwise, `.yml`.

Solution-owned settings filenames follow the [Naming standard](Naming.md#solution-settings-files).

## Lint every file

`yamllint` MUST run against every YAML file in the repository — locally through
[pre-commit](Pre-Commit.md) and again in CI as a required check.

The local run provides fast feedback. The CI run gates merge because contributors can
skip a local hook.

```bash
yamllint .
```

## Fix rather than suppress

A `yamllint` finding follows the standard [linter decision path](index.md#linter-decision-path):
fix the file, reconsider its structure, then suppress, then change the shared configuration.

If a suppression is necessary, it MUST apply to a single line and a single named rule:

```yaml
# yamllint disable-line rule:line-length
some_key: a value that genuinely cannot be wrapped without changing its meaning
```

A file-wide `# yamllint disable` disables checks for existing content and later additions.
If a rule repeatedly needs file-wide suppression, correct the shared configuration under
`.github/linters` for every repository.

## Workflow files get more

A GitHub Actions workflow is a YAML file, so `yamllint` applies to it. It is also a
program with a security model, so it is additionally linted by `actionlint` for
correctness and `zizmor` for security.

`yamllint` does not validate workflow `permissions` or the use of untrusted input.
The additional linters check these concerns. See
[GitHub Actions → Toolchain](GitHub-Actions.md#toolchain) for what each one enforces and
how findings are triaged.

## Where this connects

- [Pre-Commit](Pre-Commit.md) — the hook that runs `yamllint` before a commit exists.
- [GitHub Actions](GitHub-Actions.md#toolchain) — the additional workflow linters and their severity policy.
- [Markdown](Markdown.md) — the sibling markup standard, and the front matter YAML every page carries.
- [Code Layout](Code-Layout.md) — the baseline formatting rules this inherits.
