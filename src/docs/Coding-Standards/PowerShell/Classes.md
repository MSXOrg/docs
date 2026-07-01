---
title: Classes
description: When to reach for a PowerShell class, and how to structure its members, constructors, and documentation.
---

# Classes

Prefer functions. Reach for a **class** only when you need a real type — structured data with behaviour, a custom enum, a DSC resource, or an argument-completer or validator class — not as a way to group operations. Grouping is what modules are for.

## When to use a class

- **Do** use a class for a strongly-typed data shape with methods, a custom validator or `[ArgumentCompleter]`, or an enum.
- **Don't** use a class to namespace a set of operations — export functions from a module instead.

## Section structure

Lay a class out in a consistent order so members are easy to find:

1. **Properties** — typed, `PascalCase`, with an inline comment where the intent is not obvious.
2. **Constructors** — the default first, then more specific overloads.
3. **Methods** — typed parameters and an explicit return type.

```powershell
class Repository {
    # The owner/name slug, e.g. 'MSXOrg/docs'.
    [string] $FullName

    [bool] $Archived

    Repository([string] $fullName) {
        $this.FullName = $fullName
        $this.Archived = $false
    }

    [string] ToString() {
        return $this.FullName
    }
}
```

## Documentation

- Document the class with a comment block above the `class` keyword, and each non-obvious property with an inline comment.
- Keep classes in their own file (or a dedicated area of a module) and load them before the functions that depend on them.
