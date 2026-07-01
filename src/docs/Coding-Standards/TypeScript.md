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
