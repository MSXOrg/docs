---
title: Documentation
description: Help that lives next to the code and explains the why.
---

# Documentation

Documentation is part of the work, not a follow-up to it. Code that is not documented is effectively invisible — to the next contributor, to the user, and to the agents that read docs as their primary context.

## The hierarchy of documentation

Distance between a thing and its documentation is the rate at which they drift apart. Keep each kind of documentation as close to what it describes as possible:

| Documentation        | Lives                                          |
| -------------------- | ---------------------------------------------- |
| Why a line exists    | In a comment next to the line                  |
| How a function works | In comment-based help next to the function     |
| What a repo is       | In the README at the repository root           |
| How we work          | In this org-level docs site                    |
| Why a decision held  | In the issue that produced it                  |

## Self-documenting code first

The best comment is the one you didn't need to write because the code said it already. Before adding a comment, ask whether a better name, a smaller function, or an extracted variable would remove the need. Reserve comments for what code *cannot* express.

## Comment the why, not the what

- **Bad:** `// increment i by one` — the code already says this.
- **Good:** `// the API is 1-indexed, so the first page is 1 not 0` — context the code cannot carry.

Comments explain intent, trade-offs, workarounds, and the reasons behind non-obvious choices. They are where you record *why this and not the obvious alternative*.

## Keep comments concise

Once a comment carries the why, it is done. A short phrase beats a paragraph, and a paragraph beats a screenful — over-explaining buries the one line that matters and rots as the code moves on.

- **One line where one line works.** State the reason and stop. If the explanation keeps growing, it belongs in the design, an ADR, or the issue — link to it instead of inlining an essay.
- **Don't narrate the code.** Skip step-by-step commentary, banner headers, and comments that just echo the next statement.
- **Trust the reader.** Explain the non-obvious, not the ordinary — assume competence with the language and the codebase.

- **Too expressive:** a five-line block walking through each step of a retry loop.
- **Enough:** `// retry: the gateway 503s for a few seconds after a cold start`

## Public surfaces are documented

Every public function, command, module, or API carries documentation at its boundary — in the language's native format (comment-based help, docstrings, doc comments) so tooling can surface it. A consumer should never have to read the implementation to learn how to call it.

Include, at minimum: what it does, its parameters, what it returns, and at least one example. Examples are worth a paragraph of prose each.

## The README is the front door

Every repository has a README that is the single source of truth for what the repository is and does. It is **evergreen** — updated in the same pull request that changes behavior, never as a separate task. A feature that ships without a README update is not done.

See [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md) for the full model.

## Write for someone with no context

Assume the reader — human or agent — is seeing this for the first time. Use clear, direct language. Prefer an example over an explanation. Link to related material rather than restating it, so there is one source of truth and no drift.

## Documentation is for agents too

Agents read documentation as context before they act. A stale or missing doc does not just confuse a human — it makes an agent build the wrong thing. Keeping documentation ahead of code is what makes [context-first development](../Ways-of-Working/Principles.md#context-first-development) work at scale.
