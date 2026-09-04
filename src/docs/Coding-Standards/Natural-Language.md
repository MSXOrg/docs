---
title: Natural Language
description: Which language each artifact is written in, and the plain-language writing rules for docs, issues, pull requests, comments, prompts, and agent-facing text — with American English as the project dialect.
---

# Natural Language

Natural language is source code for humans and agents. It drives issues, pull requests, documentation, prompts, comments, error messages, and release notes. Write it with the same care as code: clear, testable, consistent, and easy to change.

This standard defines which language each artifact is written in, and how English prose is written in the MSX ecosystem. The project dialect is **American English (`en-US`)**.

## Write artifacts in English

Repository artifacts are written in English. A repository artifact is anything read to build, review, operate, or maintain the repository:

- code and identifiers, including parameter and flag names;
- comments;
- commit messages and branch names;
- issue and pull request titles and bodies, and review comments;
- in-repository documentation such as `README.md`, `AGENTS.md`, specs, and designs;
- workflow, job, and step names;
- log and error output;
- agent-facing instructions.

Delivered content is written in the language of its audience. Content an organization publishes for readers outside the repository — member letters, meeting minutes, public notices — reaches people who are not maintaining the repository, so it is written in the language those people read.

Material reproduced verbatim is never translated. A codified external source keeps the publisher's language and wording, because the copy exists to be compared against the original. The tooling that fetches, converts, and verifies that source is English.

The split is per artifact, not per repository. A repository that serves a Norwegian audience still has English scripts, English workflows, and English pull requests next to its Norwegian source documents and published letters.

| Prefer | Avoid |
| --- | --- |
| `scripts/Test-Link.mjs` | `scripts/Test-Lenker.mjs` |
| `Update-Source.ps1 -Offline` | `Update-Source.ps1 -Frakoblet` |
| `Source not found: <path>` | `Kilden finnes ikke: <path>` |
| `🪲 [Fix]: Broken links no longer reach main` | `🪲 [Fix]: Brutte lenker stoppes` |

Repository artifacts are read by contributors, reviewers, and agents who do not share one first language, and by tooling built for English. Mixed-language automation splinters the vocabulary — `-Frakoblet` and `-Offline` are the same switch — and makes shared standards, linters, and scripts unreusable across repositories.

## Use American English

Use American spelling and vocabulary in all new and changed prose.

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
| The workflow fails when `release:patch` and `release:minor` are both present. | There may be some issues with labels. |
| Add `release:skip` to documentation-only PRs. | Make sure docs PRs are handled correctly. |
| The agent reads `AGENTS.md` before editing files. | The agent should probably look at the instructions. |

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
2. Read the designated organization documentation source entry index.
3. Read the repository README and local instructions.
4. Apply path-specific instructions for files being changed.
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

> Release labels conflict: `release:patch` and `release:minor` cannot be combined. Keep one owned bump label, or remove both to use `DefaultBump`.

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
Create a spec and design for org-scoped agent documentation in MSXOrg/docs. Follow the existing spec/design documentation model and use American English.
```

Avoid:

```text
Make something for agents.
```

## Where this connects

- [Documentation](Documentation.md) — where documentation lives and what it explains.
- [Markdown](Markdown.md) — Markdown syntax and linted formatting rules.
- [Agentic Development](../Capabilities/agentic-development/index.md) — how agents consume the same docs as humans.
- [README-Driven Context](../Ways-of-Working/Readme-Driven-Context.md) — why the README is the repository front door.
