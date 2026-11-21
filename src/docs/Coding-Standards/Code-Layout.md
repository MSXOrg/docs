---
title: Code Layout
description: Structure, formatting, and file organization.
---

# Code Layout

Code layout defines structure within and across files. Consistent layout helps readers and agents find related code before they read the implementation.

## Formatting is automated

The standard defines the formatting rules. Repository tooling applies these rules in the editor, before a commit, and in CI. A repository's formatter and linter configuration is **derived from these standards**, so the tools apply the documented rules rather than define them.

- **Do not argue about formatting in review.** The standard defines the required format. A formatter verifies only the rules its configuration implements.
- **Change a rule by changing the standard, not the config.** Adjust it here first, in its own PR; the derived tool config follows.
- **The config lives in the repository**, in version control and traceable to this standard, so humans and agents apply the same rules.
- Automation lets reviewers focus on correctness, design, and clarity.

See [Shift Left → pre-commit hooks](../Ways-of-Working/Principles/Engineering-Practices.md#pre-commit-hooks) for where these gates run, and [Pre-Commit](Pre-Commit.md) for the mechanism that runs them.

## Functions and units

- **One responsibility per unit.** A function does one thing. If you need "and" to describe it, split it.
- **Keep functions small.** A function that does not fit on a screen usually does too much. Use screen fit, not a fixed line limit.
- **Few parameters.** Many parameters signal a missing type or a function doing too much. Group related parameters into an object or split the function.
- **Return early.** Put guard clauses before the main path. Handle edge cases and exit conditions without deep nesting.
- **One level of abstraction per function.** Do not mix high-level orchestration with low-level byte operations in the same body.

## File and folder structure

- **Use predictable locations.** A new contributor should be able to find each element. Follow the language or framework's conventional layout rather than inventing one.
- **Group by feature, then by type** as a codebase grows. Keep code that changes together in one location rather than separate type-based folders.
- **One public thing per file** where the language encourages it (one exported function, class, or module per file). Easy to find, easy to diff, easy to move.
- **Keep the root clean.** Give configuration, source, tests, and docs their own locations. The repository root directs readers to them.

## Within a file

- **Order top-down.** Put public interfaces before private helpers so readers see the interface before its implementation details.
- **Imports and dependencies at the top**, grouped (standard library, third-party, local) and ordered consistently. Let the tooling sort them.
- **Group related declarations.** Things used together live together.
- **Separate related groups with whitespace.** Blank lines distinguish groups of code and make their boundaries visible.

## Comments and dead code

- Delete dead code. Version control keeps its history. Remove commented-out blocks that no longer serve a purpose.
- Comments explain reasons that code cannot express. Do not restate the code. See [Documentation](Documentation.md).
