---
title: Documentation
description: Help that lives next to the code and explains the why.
---

# Documentation

Documentation is part of the work, not a later task. Missing documentation leaves contributors, users, and agents without the context they need.

## The hierarchy of documentation

Documentation and its subject are maintained together. Keep each kind of documentation as close to what it describes as possible:

| Documentation        | Lives                                          |
| -------------------- | ---------------------------------------------- |
| Why a line exists    | In a comment next to the line                  |
| How a function works | In comment-based help next to the function     |
| What a repo is       | In the README at the repository root           |
| How the work is done | In this org-level docs site                    |
| Why a decision held  | In the issue that produced it                  |

## Self-documenting code first

Use clear names and code structure before adding comments. Before you add a comment, consider whether a clearer name, smaller function, or extracted variable removes the need. Reserve comments for information that code *cannot* express.

## Comment the why, not the what

- **Bad:** `// increment i by one` — the code already says this.
- **Good:** `// the API is 1-indexed, so the first page is 1 not 0` — context the code cannot carry.

Comments explain intent, trade-offs, workarounds, and the reasons for non-obvious choices. They record why one approach is used instead of an alternative.

## Keep comments concise

A comment ends when it explains the reason. Use the shortest explanation that preserves the necessary context. Extra detail can hide important information and become inaccurate as code changes.

- **One line where one line works.** State the reason and stop. Put a longer explanation in the design, an ADR, or the issue, and link to it.
- **Do not restate the code.** Skip step-by-step commentary, banner headers, and comments that repeat the next statement.
- **Trust the reader.** Explain the non-obvious, not the ordinary — assume competence with the language and the codebase.

- **Too expressive:** a five-line block walking through each step of a retry loop.
- **Enough:** `// retry: the gateway 503s for a few seconds after a cold start`

## Public surfaces are documented

Document every public function, command, module, or API at its boundary. Use the language's native format (comment-based help, docstrings, doc comments) so tools can display it. Consumers do not need to read the implementation to learn how to call it.

Include, at minimum: what it does, its parameters, what it returns, and at least one example. Examples show how to use the documented interface.

Internal and private units, including helper functions and the scripts that call them, carry the same native-format documentation. Maintainers and agents can understand a helper's contract without reading its complete implementation.

## The README is the front door

Every repository has a README that is the single source of truth for what the repository is and does. It is **evergreen** — kept current in the same pull request that changes behavior, never as a separate task. Relevant README content follows the shared [documentation and design evidence](../Ways-of-Working/Definition-of-Ready-and-Done.md#documentation-and-design-evidence) gate, including verification when it already describes the delivered result correctly.

See [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md) for the full model.

## Write for someone with no context

Assume the reader, human or agent, has no prior context. Use clear, direct language. Prefer an example over an explanation. Link to related material rather than restating it, so one source of truth defines the information.

## Documentation is for agents too

Agents read documentation as context before they act. Outdated or missing documentation can mislead both humans and agents. Updating documentation before code supports [context-first development](../Ways-of-Working/Principles/AI-First-Development.md#context-first-development) across repositories.
