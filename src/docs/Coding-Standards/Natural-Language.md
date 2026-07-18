---
title: Natural Language
description: Plain-language writing rules for docs, issues, pull requests, comments, prompts, and agent-facing text — with US English as the project dialect.
---

# Natural Language

Natural language is source code for humans and agents. It drives issues, pull requests, documentation, prompts, comments, error messages, release notes, and memory. Write it with the same care as code: clear, testable, consistent, and easy to change.

This standard defines the writing style for English prose in the MSX ecosystem. The project dialect is **US English**.

## Use US English

Use US spelling and vocabulary in all new and changed prose.

| Use | Avoid |
| --- | --- |
| behavior | behaviour |
| color | colour |
| customize | customise |
| organization | organisation |
| organize | organise |
| license | licence |
| labeled | labelled |
| serializes | serialises |
| center | centre |
| analyze | analyse |
| optimize | optimise |
| artifact | artefact |

Do not churn unrelated existing text just to change spelling. Update nearby text when you are already editing it, and keep new pages internally consistent.

## Write for the next reader

Assume the reader has competence but no local context. The reader may be a human contributor, a maintainer reviewing a PR, or an agent resolving task context.

- Lead with the point.
- State one idea per paragraph.
- Prefer concrete nouns and active verbs.
- Use examples when they shorten the explanation.
- Link to canonical docs instead of restating them.
- Remove words that do not change meaning.

## Be direct and specific

Prefer specific, observable language over vague intent.

| Prefer | Avoid |
| --- | --- |
| `The workflow fails when the version label is missing.` | `There may be some issues with labels.` |
| `Add `NoRelease` to documentation-only PRs.` | `Make sure docs PRs are handled correctly.` |
| `The agent reads `AGENTS.md` before editing files.` | `The agent should probably look at the instructions.` |

Use **MUST**, **SHOULD**, and **MAY** only when a sentence is intentionally normative. If a rule is optional, say what trade-off decides it.

## Keep pages small

Natural-language pages follow the same rule as functions: one responsibility. If a page grows into several concepts, split it and add links from the nearest index.

A good page:

- has one primary concept;
- starts with the current rule or model;
- links outward instead of duplicating context;
- can be read in one sitting;
- gives agents enough context to act correctly.

## Write evergreen prose

Write the current truth, not the history of how it became true.

- Use present tense.
- Do not include changelog language in the body.
- Do not write "currently", "new", or "recently" unless time is the subject.
- Do not keep obsolete caveats as warnings after the caveat is gone.
- Let git history and pull requests carry the timeline.

Good:

> The docs repository owns organization-wide standards.

Avoid:

> We recently moved organization-wide standards into the docs repository.

## Make agent-facing text executable

Instructions for agents should be ordered, scoped, and verifiable. A good instruction tells the agent where to start, what to load, what not to do, and how to know it is done.

Prefer:

```markdown
Before editing:

1. Resolve the host, organization, repository, path, and task.
2. Read the organization docs index.
3. Read relevant organization memory.
4. Read the repository README and local instructions.
5. Apply path-specific instructions for files being changed.
```

Avoid:

```markdown
Understand the project and follow the right process.
```

## Use inclusive, impersonal language

Use language that keeps focus on the work.

- Prefer `the user`, `the contributor`, `the maintainer`, or `the agent` when a role matters.
- Use `you` in guides and instructions when it makes action clearer.
- Avoid blame language. Say what failed and what fixes it.
- Avoid idioms that are hard to translate or parse literally.

## Error messages and warnings

Error messages are documentation at the failure boundary. They should help the reader recover.

A good error message includes:

1. what failed;
2. why it failed, when known;
3. what to do next.

Prefer:

```text
Release label is missing. Add exactly one of Major, Minor, Patch, or NoRelease.
```

Avoid:

```text
Invalid labels.
```

## Pull requests and release notes

PR titles and descriptions are written for the user of the change first, then the reviewer. Describe the outcome, not the internal implementation.

| Prefer | Avoid |
| --- | --- |
| `📖 [Docs]: Agentic development framework documented` | `Update framework docs` |
| `Agents segment project context before loading standards.` | `Refactor AGENTS.md instructions.` |

Technical implementation details belong in a clearly named technical section at the bottom of the PR body.

## Prompts

Prompts are requests, not guesses. A good prompt names the desired outcome, the scope, and the constraints.

Prefer:

```text
Create a spec and design for org-scoped agent docs and memory in MSXOrg/docs. Follow the existing spec/design documentation model and use US English.
```

Avoid:

```text
Make something for agents.
```

## Memory notes

Memory notes should be short, factual, and reusable. They should not be a transcript of a session.

Include:

- the durable lesson;
- the affected project or repository;
- links to the issue, PR, file, or command that proves it;
- the date when the fact was learned, if timing matters.

Do not include secrets, private personal notes, or speculation.

## Where this connects

- [Documentation](Documentation.md) — where documentation lives and what it explains.
- [Markdown](Markdown.md) — Markdown syntax and linted formatting rules.
- [Agentic Development](../Ways-of-Working/Agentic-Development.md) — how agents consume the same docs as humans.
- [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md) — why the README is the repository front door.
