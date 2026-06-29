---
title: Code Layout
description: Structure, formatting, and file organization.
---

# Code Layout

How code is structured on the page and across files. Layout is not cosmetic — consistent structure lets readers (and agents) navigate by shape, before they read a single word.

## Formatting is automated

Formatting is a solved problem — hand it to a tool. Every repository runs a formatter and a linter, and they run in the editor, on commit, and in CI.

- **Do not argue about formatting in review.** If the formatter accepts it, it is correct. Disagreements are settled by changing the formatter config, in its own PR.
- **The formatter config lives in the repository**, in version control, so humans and agents apply the same rules.
- This frees review attention for what actually matters: correctness, design, and clarity.

See [Shift Left → pre-commit hooks](../Ways-of-Working/Principles.md#shift-left) for where these gates run.

## Functions and units

- **One responsibility per unit.** A function does one thing. If you need "and" to describe it, split it.
- **Small enough to hold in your head.** A function that does not fit on a screen is usually doing too much. There is no hard line limit — fit is the test.
- **Few parameters.** Many parameters signal a missing type or a function doing too much. Group related parameters into an object or split the function.
- **Return early.** Guard clauses at the top beat deep nesting. Handle the edge cases and exits first, then the main path reads straight down.
- **One level of abstraction per function.** Don't mix high-level orchestration with low-level byte-twiddling in the same body.

## File and folder structure

- **Predictable over clever.** A newcomer should guess where a thing lives. Mirror the language or framework's conventional layout rather than inventing one.
- **Group by feature, then by type** when a codebase grows — co-locating the things that change together beats scattering them across type-named folders.
- **One public thing per file** where the language encourages it (one exported function, class, or module per file). Easy to find, easy to diff, easy to move.
- **Keep the root clean.** Configuration, source, tests, and docs each have a home. The repository root is a table of contents, not a junk drawer.

## Within a file

- **Order top-down.** Public surface first, private helpers below — read like a newspaper, headline before details.
- **Imports and dependencies at the top**, grouped (standard library, third-party, local) and ordered consistently. Let the tooling sort them.
- **Group related declarations.** Things used together live together.
- **Whitespace is punctuation.** Blank lines separate ideas. A wall of code with no breaks is as hard to read as a paragraph with no sentences.

## Comments and dead code

- Delete dead code. Version control remembers it; the reader should not have to wonder whether the commented-out block matters.
- A comment that restates the code is noise. A comment that explains *why* is gold. See [Documentation](Documentation.md).
