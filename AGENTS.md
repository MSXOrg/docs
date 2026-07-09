# Agents

This repository is the central documentation for the MSX ecosystem. Everything an agent needs to work here — and the roles agents play across the ecosystem — is documentation, read the same way a new teammate would.

## Start here

1. Read this file, then the [README](README.md) for what this repository is and how it builds.
2. Read the [Ways of Working](https://msxorg.github.io/docs/Ways-of-Working/) — how work flows from idea to delivery.
3. Load the [Coding Standards](https://msxorg.github.io/docs/Coding-Standards/) relevant to the change. Repo-local linter config wins where it disagrees.

## Roles

Agent behaviour is authored once, as documentation, in the [Agents](https://msxorg.github.io/docs/Agents/) section. Use the role that fits the task:

- [Define](https://msxorg.github.io/docs/Agents/define/) — capture, refine, and plan a change into an issue.
- [Implement](https://msxorg.github.io/docs/Agents/implement/) — deliver a planned issue as a review-ready pull request.
- [Reviewer](https://msxorg.github.io/docs/Agents/reviewer/) — review a pull request for delivery, taste, and security.
- [Security Reviewer](https://msxorg.github.io/docs/Agents/security-reviewer/) — a structured, defensive security pass.
- [Agent Author](https://msxorg.github.io/docs/Agents/agent-author/) — create and maintain these roles and pointers.

## How work happens here

- Work on a `<type>/<description>` branch in its own [worktree](https://msxorg.github.io/docs/Ways-of-Working/Git-Worktrees/); open a **draft** pull request early.
- Run the [Copilot review loop](https://msxorg.github.io/docs/Ways-of-Working/Contribution-Workflow/) until it is clean.
- Mark ready only when the change meets the [Definition of Ready for Review](https://msxorg.github.io/docs/Ways-of-Working/Definition-of-Ready-and-Done/), then enable auto-merge.
- Documentation is validated by lint, link, and index checks — see the [README](README.md).

## The rule

This file points; it never defines. Process knowledge lives in the docs and is referenced by canonical URL — never copied here. See [Agentic Development](https://msxorg.github.io/docs/Ways-of-Working/Agentic-Development/).
