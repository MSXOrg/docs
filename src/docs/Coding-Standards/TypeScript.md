---
title: TypeScript
description: ES modules, strict-mode typing, pinned dependencies, and the Prettier/ESLint/Vitest toolchain for Node tooling and VS Code extensions.
---

# TypeScript

How TypeScript is written across the ecosystem. TypeScript is the language for Node-based tooling, GitHub Actions written in JavaScript, and **VS Code extensions**. We target the **latest stable TypeScript** on the **Node.js Active LTS**, ship **ES modules**, and treat the compiler's strict mode as non-negotiable.

This standard builds on the [language-agnostic baseline](index.md); where the two overlap, the baseline rules apply and the conventions below add the TypeScript specifics.

## Project shape

- **ES modules** — set `"type": "module"` in `package.json` and use `import`/`export`, not CommonJS `require`.
- **Pin the Node.js version** with an `engines.node` field so the runtime is explicit.
- Source lives under `src/`; compiled output is generated, never committed.
- Author in **TypeScript, not plain JavaScript**, for anything beyond a trivial single-file script. Small build helpers may be `.mjs`.

## Dependencies are pinned

- **Pin dependencies to exact versions** in `package.json` — no `^` or `~` ranges. The lockfile plus exact versions makes every install reproducible.
- Keep runtime `dependencies` and `devDependencies` correctly separated.

## Compiler strictness

- **`"strict": true`** in `tsconfig.json`, and keep it on — strict mode is the main reason to use TypeScript at all.
- **Typecheck in CI** with `tsc --noEmit` as a dedicated step, separate from the build.
- Avoid `any`; reach for `unknown` and narrow, or define the type. An `// @ts-expect-error` or `any` escape hatch must carry a comment justifying it.
- Model absence explicitly (`T | null` / `T | undefined`) and handle it; do not lean on implicit `undefined`.

## Naming and declarations

- **`camelCase`** for variables and functions, **`PascalCase`** for types and classes, **`UPPER_SNAKE_CASE`** for constants.
- Prefer `const`; use `let` only when reassignment is real; never `var`.

## Style and tooling

The toolchain is the enforcement mechanism — formatting and linting are not matters of taste, and both run in CI.

- **[Prettier](https://prettier.io/)** owns formatting (`prettier --check` in CI); do not hand-format.
- **[ESLint](https://eslint.org/)** with the TypeScript plugin is the linter; code must pass `eslint` cleanly.

## Testing

- **[Vitest](https://vitest.dev/)** is the test runner; colocate or mirror tests and run them in CI (`vitest run`, with coverage on the CI path).
- Tests are the executable specification — see the [Testing baseline](Testing.md).

## VS Code extensions

A VS Code extension's `package.json` carries two version fields that must be kept in step — `engines.vscode` and the `@types/vscode` dev dependency. Getting them wrong is the most common way an extension build breaks or an extension quietly drops users.

`engines.vscode` is the **minimum** VS Code version the extension supports — a compatibility floor, not a dependency pin. A user on an older VS Code cannot install the extension, so keep the floor **as low as the extension's APIs allow**, to reach the widest audience. Express it as a caret range on that floor (`^1.118.0`) — the platform convention for engine fields, and the one place a range is correct rather than the exact pin used for [dependencies](#dependencies-are-pinned).

**Raise `engines.vscode` only when the extension actually calls an API introduced in a newer release** — bump for functionality you need, never because a newer version exists. Raising the floor for its own sake drops everyone on an older VS Code for no functional gain.

**`@types/vscode` must never exceed `engines.vscode`.** The type definitions describe the API surface of one VS Code version, so typing against a version newer than the declared floor lets the code call APIs that will not exist for some users. `@vscode/vsce` enforces this at package time and fails the build otherwise:

```text
@types/vscode ^1.125.0 greater than engines.vscode ^1.118.0.
Either upgrade engines.vscode or use an older @types/vscode version
```

So the two move **together**: pin `@types/vscode` to the same version as the `engines.vscode` floor, and change both in a single commit — and only when you adopt an API that requires it.

**Do not let automated updates float `@types/vscode`.** A bot bump of `@types/vscode` is neither a fix nor a feature: because the two are tied, it forces a matching `engines.vscode` bump (or the build breaks), silently raising the minimum supported VS Code. Treat `@types/vscode` as pinned to the engine floor — hold it back in the updater (for example, ignore `@types/vscode` in `dependabot.yml`) and raise it deliberately, alongside `engines.vscode`, when a needed API lands. This is the [dependency locking](Dependencies.md) rule applied to a compatibility floor: move it only when the functionality you need requires it.
