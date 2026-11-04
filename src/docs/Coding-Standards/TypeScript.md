---
title: TypeScript
description: ES modules, strict-mode typing, pinned dependencies, and the Prettier/ESLint/Vitest toolchain for Node tooling and VS Code extensions.
---

# TypeScript

TypeScript is the language for Node-based tooling, GitHub Actions written in JavaScript, and **VS Code extensions**. Target the **latest stable TypeScript** on **Node.js Active LTS**. Use **ES modules** and require the compiler's strict mode.

This standard builds on the [language-agnostic baseline](index.md). Where the two overlap, the baseline rules apply and this standard adds TypeScript-specific conventions.

## Project shape

- **ES modules** — set `"type": "module"` in `package.json` and use `import`/`export`, not CommonJS `require`.
- **Pin the Node.js version** with an `engines.node` field so the runtime is explicit.
- Source lives under `src/`; compiled output is generated, never committed.
- Author in **TypeScript, not plain JavaScript**, for anything beyond a trivial single-file script. Small build helpers may be `.mjs`.

## Dependencies are pinned

- **Pin dependencies to exact versions** in `package.json` — no `^` or `~` ranges. The lockfile plus exact versions makes every install reproducible.
- Keep runtime `dependencies` and `devDependencies` correctly separated.

## Compiler strictness

- Set **`"strict": true`** in `tsconfig.json` and keep it enabled for type safety.
- **Typecheck in CI** with `tsc --noEmit` as a dedicated step, separate from the build.
- Avoid `any`; use `unknown` and narrow the type, or define the type. Each `// @ts-expect-error` or `any` exception must have a comment that justifies it.
- Model absence explicitly (`T | null` / `T | undefined`) and handle it. Do not rely on implicit `undefined`.

## Naming and declarations

- **`camelCase`** for variables and functions, **`PascalCase`** for types and classes, **`UPPER_SNAKE_CASE`** for constants.
- Prefer `const`; use `let` only when the value is reassigned; never `var`.

## Style and tooling

The toolchain checks formatting and linting in CI.

- **[Prettier](https://prettier.io/)** owns formatting (`prettier --check` in CI); do not hand-format.
- **[ESLint](https://eslint.org/)** with the TypeScript plugin is the linter; code must pass `eslint` cleanly.

## Testing

- **[Vitest](https://vitest.dev/)** is the test runner; colocate or mirror tests and run them in CI (`vitest run`, with coverage on the CI path).
- Tests are the executable specification — see the [Testing baseline](Testing.md).

## VS Code extensions

A VS Code extension's `package.json` has two version fields that must stay consistent: `engines.vscode` and the `@types/vscode` dev dependency. An incorrect value can cause a build failure or unnecessarily raise the minimum supported VS Code version.

`engines.vscode` is the **minimum** VS Code version the extension supports: a compatibility floor, not a dependency pin. A user on an older VS Code cannot install the extension. Keep the floor **as low as the extension's APIs allow** to support the widest audience. Express it as a caret range on that floor (`^1.118.0`). This is the platform convention for engine fields, rather than the exact pin used for [dependencies](#dependencies-are-pinned).

**Raise `engines.vscode` only when the extension calls an API introduced in a newer release**. Do not raise it solely because a newer version exists. An unnecessary increase excludes users on older VS Code versions without a functional benefit.

**`@types/vscode` must never exceed `engines.vscode`.** The type definitions describe the API of one VS Code version. Newer definitions can permit calls to APIs that are absent at the declared compatibility floor. `@vscode/vsce` enforces this constraint during packaging and fails the build if it is violated:

```text
@types/vscode ^1.125.0 greater than engines.vscode ^1.118.0.
Either upgrade engines.vscode or use an older @types/vscode version
```

**Update the two together.** Pin `@types/vscode` to the same version as the `engines.vscode` floor. Change both in one commit, and only when a required API needs a higher floor.

**Do not let automated updates change `@types/vscode` independently.** An automated update of `@types/vscode` is neither a fix nor a feature. It requires a corresponding `engines.vscode` increase or the build fails. That increase also raises the minimum supported VS Code version.

Treat `@types/vscode` as pinned to the engine floor. Exclude it from automated updates (for example, ignore `@types/vscode` in `dependabot.yml`). Raise it deliberately alongside `engines.vscode` only when a required API needs a higher floor. This applies the [dependency locking](Dependencies.md) rule to a compatibility floor: change it only when the required functionality needs it.
