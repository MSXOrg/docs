---
title: Naming
description: Names that reveal intent, consistently, in every language.
---

# Naming

Names identify the purpose of code. Clear names reduce the need for comments and prevent confusion during maintenance.

## Principles

- **Reveal intent.** A name should show what an element represents and why it exists, without a comment. Prefer `daysUntilExpiry` over `d`.
- **Pronounceable and searchable.** Rename a symbol if readers cannot pronounce it or find it reliably in a text search. Avoid single letters except for trivial loop indices.
- **No noise words.** `data`, `info`, `manager`, `helper`, `do`, `handle`, `process` carry no information. `userRecord` is not better than `user`; pick the one that is true.
- **Consistency over cleverness.** Use one word for one concept throughout the codebase. Do not mix `fetch`, `get`, `retrieve`, and `load` for the same operation.
- **Avoid abbreviations.** Spell it out. `configuration` over `cfg`, `repository` over `repo` — unless the abbreviation is more standard than the full form (`URL`, `ID`, `HTTP`).

## By kind

| Kind                 | Convention                                                                 |
| -------------------- | ------------------------------------------------------------------------- |
| **Functions / methods** | A verb or verb phrase that states the action. `validateInput`, `Get-User`. |
| **Variables / fields**  | A noun or noun phrase that identifies the value. `activeUsers`, `retryCount`. |
| **Booleans**            | A predicate that reads as true/false. `isReady`, `hasAccess`, `canRetry`.  |
| **Collections**         | Plural. `users`, not `userList`. The type already says it is a list.       |
| **Constants**           | Describe the value, not the magic number. `MAX_RETRIES`, not `FIVE`.       |
| **Types / classes**     | A noun. `HttpClient`, `RetryPolicy`.                                       |

## Casing

Follow the **language's conventions**, and apply them consistently within a codebase:

- Use the casing the language community expects — `PascalCase` for PowerShell functions and .NET types, `snake_case` for Python and Terraform, `camelCase` for JavaScript variables, `kebab-case` for CLI flags and filenames where idiomatic.
- Follow the language's conventions rather than personal preferences. Prefer names readers expect.
- Files and folders follow the repository's established pattern. For new layouts, prefer `kebab-case` to avoid case-sensitivity differences between Windows, macOS, and Linux.

## Solution settings files

Solution-owned settings MUST use `<name>.settings.yml` as their conventional filename, where `<name>` identifies the owning solution. One naming shape makes both the owner and the file's purpose discoverable.

Each solution documents its settings location. The filename convention does not impose a shared directory or change settings schemas, defaults, or precedence.

Tool-mandated manifests, lockfiles, workflow filenames, and YAML files that are not solution-owned settings follow their tool's contract, not this settings-filename convention.

A reader MAY expose a documented explicit path override. This convention does not remove that input or restrict otherwise supported custom paths.

A supported naming exception MUST be documented by the owning solution. Verify the reader before changing a released conventional filename, and keep exact migration actions in its [release record](../Capabilities/release-management/design.md#release-notes). Review verifies adoption against the reader contract.

## Scope and length

Name length should reflect scope. A loop index used for three lines can be `i`. A module-level export needs a full, descriptive name that readers understand without local context.

## Anti-patterns

- Encoding type into the name (`strName`, `arrUsers`) — the type system already knows.
- Numbered suffixes (`user1`, `user2`, `dataNew`) — they signal a missing concept.
- Negated booleans (`isNotReady`, `notReady`) require readers to interpret double negatives. For example, `notReady = false` means ready. Use the positive name (`isReady`) and negate at the point of use.
- Names that hide side effects. A `getUser` that also writes to a cache has a misleading name. Rename or split it.
