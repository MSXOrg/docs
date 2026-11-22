---
title: Classes
description: When to use a PowerShell class and how to structure its members, constructors, and documentation.
---

# Classes

Prefer functions. Use a **class** only when the code needs a type. Examples include structured data with behavior, a custom enum, a DSC resource, or an argument-completer or validator class. Use modules, not classes, to group operations.

## When to use a class

- **Do** use a class for a strongly typed data structure with methods, a custom validator or `[ArgumentCompleter]`, or an enum.
- **Do not** use a class to namespace a set of operations. Export functions from a module instead.

## Section structure

Order class members consistently so readers can find them:

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
- Keep classes in their own file or a dedicated area of a module. Load them before the functions that depend on them.
