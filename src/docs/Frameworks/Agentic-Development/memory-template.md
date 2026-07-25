---
title: Memory Repository Template
description: The concrete, copy-pasteable scaffold every organization's memory repository instantiates, and why it deliberately breaks from the Repository Standard.
---

# Memory Repository Template

[Spec](spec.md) and [Design](design.md) require every adopting organization to have a
`memory` repository, and the design's [organization anatomy](design.md#organization-anatomy)
already names `MSXOrg/memory` and `PSModule/memory` as canonical examples. Neither design
document defines an exact file layout — this page is that layout. It is the one scaffold
every adopting organization's `memory` repository instantiates. Content differs per
organization; structure does not.

## Scaffold

```text
memory/
├── README.md        # front door: what this repo is, that it's private, "commit straight to main, no PR"
├── CONTRIBUTING.md   # short: direct push to main, no PR/review gate, keep entries short/dated/factual
├── .gitattributes
├── .gitignore
├── index.md          # OKF root index (okf_version frontmatter), links to the sections below
├── gotchas/          # short, dated entries: pitfalls, conventions, verified commands
│   └── index.md
├── knowledge/        # durable facts about the ecosystem, tools, cross-repo relationships
│   ├── index.md
│   └── repos/        # one file per repo worth remembering repo-specific facts about (created lazily as needed)
└── agents/           # per-agent-role working knowledge; empty stub until agent roles are formally defined
    └── index.md
```

Create `knowledge/repos/<repo>.md` files lazily, only once a repository accumulates facts
worth remembering — the folder starts empty in a freshly scaffolded `memory` repository.

## How the scaffold maps to what memory owns

[Design](design.md#memory) already states what the `memory` repository owns. Each
top-level folder is one of those responsibilities made concrete:

| Folder | Owns (from [Design](design.md#memory)) |
| --- | --- |
| `gotchas/` | Recurring gotchas and lessons learned. |
| `knowledge/` | Active project context that should survive a single chat session, project-specific preferences that are factual rather than private user preference, and issue/PR/incident notes worth reusing. |
| `agents/` | Agent role working knowledge. |

`index.md` is the root map described in [Design's indexes section](design.md#indexes-as-the-mindmap):
it links to `gotchas/index.md`, `knowledge/index.md`, and `agents/index.md` so a human or
agent can start at the root and drill inward.

## A deliberate exception to the Repository Standard

[Repository Standard](../../Ways-of-Working/Repository-Standard.md) lists the files every
repository must carry: `LICENSE`, `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`,
`.github/dependabot.yml`, `.github/CODEOWNERS`, `.github/pull_request_template.md`, and
more. A `memory` repository intentionally omits all of these.
[Organization Standard](../../Ways-of-Working/Organization-Standard.md) allows an
initiative to define type-specific exceptions to the default file set — this is that
exception, made explicit rather than left as an oversight:

- **Private, not public.** There is no external audience to license, and no public
  vulnerability surface to run a `SECURITY.md` disclosure process against.
- **No PR workflow.** [Spec](spec.md#requirements) allows memory changes to be
  lighter-weight than `docs` changes, as long as they stay versioned in git. A
  `pull_request_template.md` and `CODEOWNERS` review routing make no sense for a repo
  where every change lands as a direct commit to `main`.
  See [Memory writing rules](design.md#memory-writing-rules) for what a good direct
  commit looks like.
- **No external dependencies.** Plain Markdown files have no supply chain, so
  `.github/dependabot.yml` has nothing to update.
- **Small, defined audience.** `SUPPORT.md` and `CODE_OF_CONDUCT.md` exist to set
  expectations for a broad or public contributor community; a `memory` repository's
  audience is the organization's own humans and agents.

A `memory` repository still carries `README.md`, `CONTRIBUTING.md`, `.gitattributes`, and
`.gitignore` — the minimum needed to explain itself and behave predictably in git.

## Visibility

`memory` repositories default to **private**. Working memory can capture internal
context, half-finished reasoning, and organization-specific detail that isn't meant for a
public audience, even when the adjoining `docs` repository is public.

## Where this connects

- [Spec](spec.md) — the requirement that every organization has a `memory` repository.
- [Design](design.md) — the organization anatomy, `memory` repository role, and OKF page
  model this scaffold implements.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md) — the default file
  set this page's scaffold deliberately departs from.
- [Organization Standard](../../Ways-of-Working/Organization-Standard.md) — how
  initiative-defined, type-specific exceptions to the default file set are allowed.
