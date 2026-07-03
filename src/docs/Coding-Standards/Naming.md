---
title: Naming
description: Names that reveal intent, consistently, in every language.
---

# Naming

Names are the primary interface to code. A good name removes the need for a comment; a bad name survives every refactor and misleads for years. Naming is the cheapest documentation we have — spend on it.

## Principles

- **Reveal intent.** A name should answer *what is this and why does it exist* without a comment. `daysUntilExpiry` beats `d`.
- **Pronounceable and searchable.** If you cannot say it in a conversation or grep for it reliably, rename it. Avoid single letters except for trivial loop indices.
- **No noise words.** `data`, `info`, `manager`, `helper`, `do`, `handle`, `process` carry no information. `userRecord` is not better than `user`; pick the one that is true.
- **Consistency over cleverness.** One concept, one word, everywhere. Don't mix `fetch`, `get`, `retrieve`, and `load` for the same operation.
- **Avoid abbreviations.** Spell it out. `configuration` over `cfg`, `repository` over `repo` — unless the abbreviation is more standard than the full form (`URL`, `ID`, `HTTP`).

## By kind

| Kind                 | Convention                                                                 |
| -------------------- | ------------------------------------------------------------------------- |
| **Functions / methods** | A verb or verb phrase — they *do* something. `validateInput`, `Get-User`. |
| **Variables / fields**  | A noun or noun phrase — they *hold* something. `activeUsers`, `retryCount`. |
| **Booleans**            | A predicate that reads as true/false. `isReady`, `hasAccess`, `canRetry`.  |
| **Collections**         | Plural. `users`, not `userList`. The type already says it is a list.       |
| **Constants**           | Describe the value, not the magic number. `MAX_RETRIES`, not `FIVE`.       |
| **Types / classes**     | A noun. `HttpClient`, `RetryPolicy`.                                       |

## Casing

Follow the **idiom of the language**, and be consistent within a codebase:

- Use the casing the language community expects — `PascalCase` for PowerShell functions and .NET types, `snake_case` for Python and Terraform, `camelCase` for JavaScript variables, `kebab-case` for CLI flags and filenames where idiomatic.
- Never fight the language's conventions to impose a personal preference. The least-surprising name is the right name.
- Files and folders follow the repository's established pattern. When starting fresh, prefer `kebab-case` for cross-platform safety (no case-sensitivity surprises between Windows, macOS, and Linux).

## Scope and length

Name length should track scope. A loop index living for three lines can be `i`. A module-level export read across the codebase earns a full, descriptive name. The wider the reach, the more the name has to carry on its own.

## Anti-patterns

- Encoding type into the name (`strName`, `arrUsers`) — the type system already knows.
- Numbered suffixes (`user1`, `user2`, `dataNew`) — they signal a missing concept.
- Negated booleans (`isNotReady`, `notReady`) — a negative name forces a double negative at every use, and a value turns it into a riddle: does `notReady = false` mean it *is* ready? Name the positive (`isReady`) and negate at the point of use.
- Names that lie — a `getUser` that also writes to a cache is a name that lies. Rename or split.
