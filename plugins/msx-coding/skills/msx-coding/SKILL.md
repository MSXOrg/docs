---
name: msx-coding
description: Routes code creation, modification, review, testing, security, dependency, GitHub Actions, Markdown, PowerShell, Terraform, TypeScript, and YAML work to the current MSX coding standards. Use for any coding task in an MSX-managed project.
compatibility: Requires access to the current MSXOrg/docs repository or its published documentation.
metadata:
  author: MSXOrg
  version: "0.1.0"
---

# Apply MSX coding standards

This skill is an entry point. The linked documentation is the source of truth; do not
copy its rules into this skill or reconstruct them from memory.

## Resolve the canonical documentation

1. Read the current repository's `AGENTS.md`, when present, and follow its routes in
   order.
2. Resolve the current MSX coding standards index from the synchronized documentation
   checkout named by that route.
3. If no checkout is available, read
   `https://github.com/MSXOrg/docs/blob/main/src/docs/Coding-Standards/index.md` through
   an available GitHub or web tool. Use
   `https://msxorg.github.io/docs/Coding-Standards/` as a read-only fallback.
4. Stop and report the missing context if none of these routes can be read. Do not
   invent an organizational standard.

## Route the task

1. Read the coding standards index and use its descriptions to select the baseline
   pages relevant to the task.
2. Determine every language or tool affected from the file paths, manifests, and
   repository structure. Follow the matching per-language entries in the index.
3. When a selected entry is itself an index, recurse through it and select the page
   that matches the construct being changed.
4. Follow links from the selected pages when they govern an artifact or decision in
   the task.
5. Read the repository's own build, contribution, architecture, and local tool
   configuration before changing code. Local context may narrow the implementation,
   but it does not silently override an organization standard.

## Apply the result

- Treat the current canonical pages as requirements and the repository's linters,
  formatters, and tests as their enforcement mechanisms.
- Reuse existing repository patterns and tooling before introducing a new mechanism.
- Validate with the smallest existing checks that cover the changed behavior.
- If the documentation does not govern a necessary choice, follow established local
  conventions and identify the documentation gap rather than inventing MSX policy.
