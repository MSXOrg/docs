---
title: YAML
description: One file extension, yamllint locally and in CI, narrowly scoped suppressions, and actionlint on top for workflow files.
---

# YAML

YAML carries most of the configuration in this ecosystem — workflows, linter configs,
dependency manifests, deployment descriptors. It is also unusually easy to write in a way
that parses but does not mean what it looks like, which is why it is linted rather than
reviewed by eye.

This standard builds on the [language-agnostic baseline](index.md); where the two
overlap, the baseline rule applies and the conventions below add the YAML specifics.

## Use `.yml` consistently

Every YAML file MUST use the `.yml` extension, including files whose tooling accepts
either form.

The two extensions are equivalent to every parser and not equivalent to a glob. A
repository mixing both needs `*.{yml,yaml}` in every lint path, every `paths:` filter, and
every editor association — and the day one of those is written as `*.yml` only, a file
stops being checked without anything failing.

One exception exists, and only because the tool allows no alternative:
`.pre-commit-config.yaml`. Where a tool hard-codes the long form, follow the tool and note
it; otherwise, `.yml`.

## Lint every file

`yamllint` MUST run against every YAML file in the repository — locally through
[pre-commit](Pre-Commit.md) and again in CI as a required check.

Running it in both places is the point. The local run is fast feedback; the CI run is what
a merge depends on, because a local hook can be skipped.

```bash
yamllint .
```

## Fix rather than suppress

A `yamllint` finding follows the standard [linter decision path](index.md#linter-decision-path):
fix the file, reconsider the shape, then suppress, then change the shared configuration.

Where a suppression is genuinely warranted, it MUST be scoped as narrowly as possible —
a single line, and a single named rule:

```yaml
# yamllint disable-line rule:line-length
some_key: a value that genuinely cannot be wrapped without changing its meaning
```

A file-wide `# yamllint disable` turns off checking for content nobody has looked at yet,
including whatever gets appended to the file next year. If a rule is wrong often enough to
warrant that, the rule is wrong and the shared configuration under `.github/linters` is
what changes — once, for every repository.

## Workflow files get more

A GitHub Actions workflow is a YAML file, so `yamllint` applies to it. It is also a
program with a security model, so it is additionally linted by `actionlint` for
correctness and `zizmor` for security.

`yamllint` cannot know that a workflow is missing `permissions` or interpolating untrusted
input; that is what the extra linters are for. See
[GitHub Actions → Toolchain](GitHub-Actions.md#toolchain) for what each one enforces and
how findings are triaged.

## Where this connects

- [Pre-Commit](Pre-Commit.md) — the hook that runs `yamllint` before a commit exists.
- [GitHub Actions](GitHub-Actions.md#toolchain) — the additional workflow linters and their severity policy.
- [Markdown](Markdown.md) — the sibling markup standard, and the front matter YAML every page carries.
- [Code Layout](Code-Layout.md) — the baseline formatting rules this inherits.
