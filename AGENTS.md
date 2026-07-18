# Agents

This repository is the central documentation for the MSX ecosystem. Everything an agent needs to work here — and the roles agents play across the ecosystem — is documentation, read the same way a new teammate would.

## Start here

1. Read this file, then the [README](README.md) for what this repository is and how it builds.
2. Resolve the project segment before loading standards: host, organization, repository, path, and task. This repository is `github.com/MSXOrg/docs`; use MSXOrg context unless the task explicitly asks for another organization.
3. Read the [Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) — how work flows from idea to delivery.
4. Load the [Coding Standards](https://msxorg.github.io/docs/Coding-Standards/) relevant to the change.

## Roles

Agent behavior is authored once, as documentation, in the [Agents](https://msxorg.github.io/docs/Agents/) section. Use the role that fits the task:

- [Define](https://msxorg.github.io/docs/Agents/define/) — capture, refine, and plan a change into an issue.
- [Implement](https://msxorg.github.io/docs/Agents/implement/) — deliver a planned issue as a review-ready pull request.
- [Reviewer](https://msxorg.github.io/docs/Agents/reviewer/) — review a pull request for delivery, taste, and security.
- [Security Reviewer](https://msxorg.github.io/docs/Agents/security-reviewer/) — a structured, defensive security pass.
- [Agent Author](https://msxorg.github.io/docs/Agents/agent-author/) — create and maintain these roles and pointers.

## How work happens here

- [Branching and Merging](https://msxorg.github.io/docs/Ways-of-Working/Branching-and-Merging/) and [Git Worktrees](https://msxorg.github.io/docs/Ways-of-Working/Git-Worktrees/) — the branch model and where to work.
- [Contribution Workflow](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/) — the draft-first, Copilot-review loop through to a ready pull request.
- [Definition of Ready and Done](https://msxorg.github.io/docs/Ways-of-Working/Definition-of-Ready-and-Done/) — when a change is ready for review and when it lands.
- This repository's build and checks — see the [README](README.md).

## Context segmentation

Before acting, segment the work by scope:

1. **Host** — `github.com` or `dnb.ghe.com`.
2. **Organization** — the project boundary, such as `MSXOrg`, `PSModule`, or `AI-Platform`.
3. **Repository** — the product, docs, or memory repository receiving the change.
4. **Path** — the file area and any path-specific standards that apply.
5. **Task** — the issue, prompt, branch, PR, diagnostics, and open files.

Load only the docs and memory for the resolved organization. Do not apply another organization's standards or memory unless the user explicitly asks for cross-organization work.

## The rule

This file points; it never defines. Process knowledge lives in the docs and is referenced by canonical URL — never copied here. See [Agentic Development](https://msxorg.github.io/docs/Ways-of-Working/Agentic-Development/).
