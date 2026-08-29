---
title: Memory Repository Template
description: The concrete, copy-pasteable scaffold every organization's memory repository instantiates, and why it deliberately breaks from the Repository Standard.
---

# Memory Repository Template

[Spec](spec.md) and [Design](design.md) require every adopting organization to identify a
`memory` source repository, and the design's [organization anatomy](design.md#organization-anatomy)
already names `MSXOrg/memory` and `PSModule/memory` as canonical examples. Neither design
document defines an exact file layout — this page is that layout. It is the one scaffold
every adopting organization's `memory` repository instantiates. Content differs per
organization; structure does not.

## Memory has three horizons

Not every remembered thing has the same lifetime, and treating them alike is what makes a
memory repository degrade. A convention that holds everywhere, a fact true of one
repository, and a note that matters only until the current task finishes are three
different kinds of knowledge, and mixing them means the durable content is buried in the
ephemeral.

The scaffold therefore separates memory by **horizon** — how long the entry stays true and
how widely it applies:

| Horizon | Scope | Lifetime | Shared |
| --- | --- | --- | --- |
| **User** | Applies across every repository in the organization | Until the practice itself changes | Yes — committed and pushed |
| **Repository** | Applies to one repository | As long as that repository keeps the shape the entry describes | Yes — committed and pushed |
| **Session** | Applies to work in progress right now | Until the task finishes | No — local only, never pushed |

Horizon is a property of the entry, not of its subject. A workaround for one repository's
build quirk is repository-scoped even though it is about a build; a decision to always
verify a command before recording it is user-scoped even though it was learned in one
repository.

## Scaffold

```text
memory/
├── README.md         # front door: what this repo is, that it's private, "commit straight to main, no PR"
├── CONTRIBUTING.md   # short: direct push to main, no PR/review gate, keep entries short and factual
├── AGENTS.md         # cross-client agent entry point: orients an agent landing here cold, points at index.md and the memory-writing rules
├── .gitattributes
├── .gitignore        # ignores session/ so ephemeral notes are never pushed
├── index.md          # OKF root index (okf_version frontmatter), links to the scopes below
├── user/             # organization-wide, durable: conventions, verified commands, recurring gotchas, ecosystem facts
│   └── index.md
├── repo/             # per-repository, durable: one folder per repository worth remembering facts about
│   └── index.md      # created lazily: repo/<repo>/index.md once a repository accumulates facts
└── session/          # ephemeral working notes for the task in hand — git-ignored, never pushed
    └── .gitkeep
```

`repo/<repo>/` folders are created lazily, only once a repository accumulates facts worth
remembering — `repo/` starts with nothing but its index in a freshly scaffolded repository.

## Why `session/` is git-ignored

A session note is a scratchpad: what has been tried, what the current hypothesis is, which
file is half-edited. It is genuinely useful while the task runs and actively harmful
afterwards, because a later agent reading it cannot tell a live hypothesis from a settled
fact.

So `session/` is ignored rather than merely short-lived. Ignoring it, instead of relying on
discipline to delete it, means the ephemeral content cannot leak into shared memory at all:

- An agent MAY write freely to `session/` without weighing whether the note is worth
  keeping, which is the only way a scratchpad is useful.
- Nothing in `session/` reaches another person or another machine, so no one inherits
  someone else's half-finished reasoning as though it were knowledge.
- Promoting a session note to durable memory is a **deliberate move** into `user/` or
  `repo/<repo>/`, rewritten as a statement of fact. Promotion is the moment the entry gets
  reviewed for whether it is actually true, and an ignored folder is what forces that moment
  to exist.

An agent that wants a note to survive the session MUST move it, not leave it and hope.

## How the scopes map to what memory owns

[Design](design.md#memory) already states what the `memory` repository owns. Each scope is
one horizon of those responsibilities:

| Scope | Owns (from [Design](design.md#memory)) |
| --- | --- |
| `user/` | Recurring gotchas and lessons learned, durable facts about the ecosystem and its tools, and project-specific preferences that are factual rather than private user preference. |
| `repo/<repo>/` | Facts true of one repository: its shape, its quirks, its cross-repository relationships, and issue, pull request, or incident notes worth reusing. |
| `session/` | Active context for the task in hand, which should survive a single chat session but MUST NOT outlive the task. |

`index.md` is the root map described in [Design's indexes section](design.md#indexes-as-the-mindmap):
it links to `user/index.md` and `repo/index.md` so a human or agent can start at the root and
drill inward. It does not link into `session/`, which has no shared content to index.

`AGENTS.md` doesn't map to a `memory` ownership bullet — it isn't content memory owns, it's the
framework's [client behavior table](design.md#client-behavior) entry point: "Cross-client agents |
`AGENTS.md` | Read the shared project pointer and local nuance." Every repository in the
framework carries one so an agent landing cold knows where to start; a `memory` repository is no
exception. Its job is narrower than `README.md`'s and different from `CONTRIBUTING.md`'s — it
orients an *agent* specifically, pointing straight at `index.md` and the
[memory writing rules](design.md#memory-writing-rules), while `CONTRIBUTING.md` stays
contribution-process-flavored (direct push, no PR) even though this repository's real audience is
agents, not human contributors.

## Commit after every discrete action

Durable memory MUST be committed and pushed as soon as it is written, one commit per
discrete thing learned.

Batching memory writes until the end of a session is how memory gets lost. An agent session
can end at any point — the task completes, the context window fills, the process is
interrupted — and anything still uncommitted at that moment is gone. A lesson learned in
the first minute and pushed in the first minute survives all three endings.

Micro-commits also make memory legible in the way documentation is: one commit is one
lesson, so the history reads as a list of things learned rather than a periodic dump. A
memory entry whose commit bundles nine unrelated observations cannot be reverted, cited, or
blamed independently.

Because memory changes land directly on the default branch
([spec](spec.md#requirements)), there is no batching pressure from a review gate. The only
reason to hold a memory write is that it is not yet true, and an entry that is not yet true
belongs in `session/`.

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
  commit looks like. This only works in practice once the organization's ruleset stops
  requiring pull requests for `memory` repositories — see
  [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) for how
  that exclusion is implemented via a `Type: Memory` custom property value.
- **No external dependencies.** Plain Markdown files have no supply chain, so
  `.github/dependabot.yml` has nothing to update.
- **Small, defined audience.** `SUPPORT.md` and `CODE_OF_CONDUCT.md` exist to set
  expectations for a broad or public contributor community; a `memory` repository's
  audience is the organization's own humans and agents.

A `memory` repository still carries `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `.gitattributes`,
and `.gitignore` — the minimum needed to explain itself and behave predictably in git. The
`.gitignore` is load-bearing rather than conventional here: it is what keeps `session/` out
of the shared history.

## Visibility

`memory` repositories default to **private**. Working memory can capture internal
context, half-finished reasoning, and organization-specific detail that isn't meant for a
public audience, even when the adjoining documentation source is public.

Privacy and the `session/` ignore rule solve different problems and neither substitutes for
the other. Privacy decides *who* may read durable memory; the ignore rule decides *what*
becomes durable at all. A private repository full of stale hypotheses is still a repository
an agent will read and believe.

## Where this connects

- [Spec](spec.md) — the requirement that every organization has a `memory` repository.
- [Design](design.md) — the organization anatomy, `memory` repository role, and OKF page
  model this scaffold implements.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md) — the default file
  set this page's scaffold deliberately departs from.
- [Organization Standard](../../Ways-of-Working/Organization-Standard.md) — how
  initiative-defined, type-specific exceptions to the default file set are allowed.
- [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) — how a
  `Type: Memory` custom property value excludes memory repositories from the org-wide
  pull-request-required ruleset so the direct-commit workflow above actually works.
