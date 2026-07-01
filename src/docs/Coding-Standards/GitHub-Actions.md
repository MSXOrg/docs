---
title: GitHub Actions
description: Workflow authoring — SHA pinning, least-privilege permissions, OIDC, secrets handling, and script extraction.
---

# GitHub Actions

How GitHub Actions workflows are authored across the ecosystem. Workflows are
code that runs with access to credentials and the ability to publish — they are
held to the same bar as application code, plus the supply-chain and
least-privilege controls below.

This standard builds on the [language-agnostic baseline](index.md). For the
threat model behind action pinning and vendoring, see
[Security → Supply chain](Security.md#supply-chain); this standard is the
canonical "how to author" reference that the security control points to.

## Pin every action to a full commit SHA

A `uses:` reference accepts a tag, a branch, or a commit SHA. Tags and branches
are **mutable** — a maintainer (or an attacker who compromises one) can move
them to point at different code. A full commit SHA is **immutable**.

- **Pin every `uses:` to a full 40-character commit SHA.** Keep the human
  version as a trailing comment so reviewers know the intended release.
- This applies to **all** actions — third-party, first-party, and our own
  internal actions alike.

```yaml
# Correct — immutable SHA; comment carries the readable version
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
- uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0

# Avoid — mutable tag; the referenced code can change under us
- uses: actions/checkout@v6
```

Internal actions follow the same rule.

## Keep pinned actions current

A SHA pin is immutable — which also means it does not move when the action
publishes a fix. Pinning and updating are two halves of one practice: pin to a
SHA for safety, then let automation propose the newer SHA so pins never rot into
stale, unpatched code.

- **Enable automated updates for the `github-actions` ecosystem** in
  `.github/dependabot.yml`. The updater opens a pull request that rewrites the
  pin to the new commit SHA and refreshes the trailing version comment.
- **Apply a cooldown** before adopting a freshly published version, and
  **group** low-risk action bumps so routine updates arrive as one reviewable
  pull request rather than many.
- **Label the update PR** with `dependencies` + `github-actions`, plus the
  dependency's own level (`update:major` / `update:minor` / `update:patch`).
  These update-level labels are deliberately **distinct from the release-bump
  labels** (`Major` / `Minor` / `Patch`) — a bumped action is an
  artifact-affecting change that itself cuts a release, so the two must not
  share one label set.
- **Review `update:major` by hand** — a major action bump can change inputs,
  outputs, or behaviour. Lower levels may auto-merge once checks pass.

The full mechanism — schedule, grouping, labels, and auto-merge policy — is the
[Dependency Updates](../Capabilities/dependency-updates/design.md) capability;
this section is the Actions-specific view of it.

## Grant least-privilege permissions

- **Set `permissions:` explicitly.** Never rely on the default token scope.
- **Start from a default-deny floor.** In any workflow with more than one job,
  declare `permissions: {}` at the workflow (top) level so the baseline is *no*
  access, then grant each job only the scopes its steps need. A job that omits
  its own `permissions:` block — including one added later — then inherits
  nothing rather than the broad default token, so forgetting to scope a new job
  fails *closed*, not open. (A single-job workflow may scope at the workflow
  level, since the workflow and its one job are equivalent.)
- **Declare permissions per job**, not only at workflow level, and grant only
  the scopes that job needs. Most jobs need no more than `contents: read`.

```yaml
# Default-deny floor at the top; each job opts into exactly what it needs.
permissions: {}

jobs:
  build:
    runs-on: ubuntu-24.04
    permissions:
      contents: read       # checkout only

  deploy:
    runs-on: ubuntu-24.04
    permissions:
      id-token: write      # OIDC federation to the cloud provider
      contents: read       # checkout only
```

## Authenticate with OIDC, not long-lived secrets

- **Use OIDC federation** (`id-token: write`) to obtain short-lived cloud
  credentials — `azure/login` and the AWS role-assumption actions both support
  it. Do not store long-lived cloud keys as secrets.
- Scope the federated trust to the specific repository, ref, and environment.

## Distinguish `vars` from `secrets`

- **`secrets`** — anything whose disclosure is a security event (private keys,
  API tokens). Never echo a secret to logs; never put one in `vars`.
- **`vars`** — non-sensitive configuration (client IDs, account numbers,
  gateway URLs). Using `vars` for config keeps secrets to the minimum that
  truly needs protecting.
- When calling a reusable workflow, **always pass secrets explicitly by name**
  (`secrets: { TOKEN: ${{ secrets.TOKEN }} }`) so the dependency is visible at
  the call site. **Never use `secrets: inherit`** — it silently forwards every
  secret the caller holds and makes it impossible to tell from the call site
  which secrets a workflow actually needs, defeating traceability and least
  privilege. (Org variables are forwarded to reusable workflows automatically
  and cannot be named — this rule is about `secrets`, not `vars`.)

```yaml
# Correct — only the needed secret is forwarded; the dependency is auditable
jobs:
  call:
    uses: org/reusable-workflows/.github/workflows/build.yml@<sha> # vX.Y.Z
    secrets:
      PROPAGATION_TOKEN: ${{ secrets.PROPAGATION_TOKEN }}

# Avoid — forwards every secret; the call site no longer documents what's used
jobs:
  call:
    uses: org/reusable-workflows/.github/workflows/build.yml@<sha> # vX.Y.Z
    secrets: inherit
```

## Never expand untrusted input inline

Interpolating `${{ github.event.* }}` (PR titles, branch names, issue bodies)
directly into a `run:` script allows shell injection. **Pass untrusted values
through an `env:` variable** and reference the variable, which is not re-parsed
as script.

```yaml
# Correct — value arrives as an environment variable, not inlined into the shell
- env:
    TITLE: ${{ github.event.pull_request.title }}
  run: echo "$TITLE"

# Avoid — attacker-controlled title is executed as shell
- run: echo "${{ github.event.pull_request.title }}"
```

## Extract non-trivial `run:` scripts into an action

A short `run:` step — a handful of commands wiring tools together — belongs
inline. But once a step carries a **multi-line script embedded as a YAML
string** (a block of Bash, Python, or PowerShell), that script is invisible to
every linter, formatter, and editor: `shellcheck`, `ruff`, and the type
checkers all see an opaque string, not code. Pull it out.

- **A step whose logic is a non-trivial inline script must become its own
  action.** The workflow then `uses:` that action instead of carrying the
  script in its body. This keeps workflows declarative — what runs, in what
  order, with what permissions — and moves the *how* into linted, testable
  files.

Extracting a script out of a workflow string is an instance of the
[Code in code files](../Ways-of-Working/Principles/Engineering-Practices.md#code-in-code-files)
principle: code earns linters, security scanning, and IDE support only once it
lives in a file of its own language.

### Generalize the action; drive behaviour through inputs and outputs

An action that is lifted out of one workflow is tempting to write for exactly
that workflow — hard-coding the repository, the branch, the message it posts.
Resist this. An extracted action is a reusable unit, and it should be designed
like one. The [SOLID](https://en.wikipedia.org/wiki/SOLID) principles map
directly onto action design:

- **Generalize to the work the action does, not the caller that needs it.**
  Name and scope the action by its *capability* (`start-cloud-agent`,
  `publish-docs`), not by the one situation that prompted it
  (`bump-one-repo-pin`). The action does one well-defined job — a single
  responsibility — and does it for any caller. This is what makes it reusable
  rather than a copy of one workflow's internals.
- **Adjust behaviour through the input interface, never by editing the action.**
  Every value that varies between callers — the target repository, a model
  name, a prompt, a flag — is an `input`, with a sensible `default` where one
  exists. A new use case should be served by passing different inputs, not by
  forking the script or adding a caller-specific branch inside it. The action is
  *open for extension* (new inputs, new callers) but *closed for modification*
  (its logic does not change to accommodate each new consumer).
- **Keep defaults at the interface layer (`action.yml`) only.** Define optional
  input defaults under `inputs.<name>.default` in `action.yml`, and treat that
  as the single source of truth for caller-visible defaults. Do **not** duplicate
  those defaults in runtime code (`main.js`, shell, Python, PowerShell). This
  keeps the UI contract and auto-generated interface docs correct by construction,
  and makes default changes one-line updates without drift.
- **Keep the input interface focused.** Expose the inputs a caller genuinely
  needs and no more; a narrow, well-named interface is easier to use correctly
  than a broad one full of rarely-set knobs. Group related inputs rather than
  leaking internal implementation details as parameters.
- **Output anything a caller might reasonably act on.** Declare `outputs:` for
  the results the action produces — an identifier it created, a URL, a computed
  version, a pass/fail decision — so downstream steps consume a value instead of
  re-deriving it or scraping logs. An action that does meaningful work and
  returns nothing forces every caller to reconstruct what it already knew.

```yaml
# Correct — capability-named, behaviour driven by inputs, results surfaced
inputs:
  target-repository:
    description: Repository the agent should work in (owner/repo).
    required: true
  agent:
    description: Which cloud agent to start.
    required: false
    default: claude
  prompt:
    description: Full task description for the agent.
    required: true
outputs:
  task-url:
    description: URL of the created agent task, for callers to surface or poll.
    # `start` is a step id under the action's own `runs.steps`.
    value: ${{ steps.start.outputs.task-url }}

# Avoid — hard-codes one caller's situation; nothing comes back out
#   no inputs: repo, agent, and prompt are baked into the script
#   no outputs: callers must scrape the log to find the task URL
```

Designing the action this way is the difference between *reuse* and
*copy-paste*: a generalized action is consumed by SHA from many workflows; a
caller-specific one gets duplicated and diverges the moment a second consumer
appears.

### Start local; promote when it is reused

- **Default to a local action** under `.github/actions/<action-name>/`. That is
  the right home for logic used by one repository.
- **Promote to a standalone repository** only when the action is genuinely
  reused across repositories. At that point it gains its own versioning and is
  consumed by SHA like any other third-party action (see
  [Pin every action to a full commit SHA](#pin-every-action-to-a-full-commit-sha)).
  Do not reach for a separate repo preemptively — the cost of a shared release
  surface is only worth paying once there is a second consumer.

### Move the script into its own file

- **Lift the script out of `action.yml` into a separate file** so tooling can
  see it. The action's `run:` step then invokes that file rather than inlining
  its contents. A script file is subject to its language's coding standard and
  linter — for example the [PowerShell](PowerShell/index.md) standard — exactly as if
  it lived in application code.
- **One script file lives at the root of the action folder.** When the action
  grows to several source files, **collect them under a `src/` folder** so the
  action root stays readable.
- **Name the entry script `main.<ext>`** (`main.py`, `main.sh`, `main.ps1`).
  A consistent entry-point name makes the action's starting point unambiguous:
  `main.<ext>` sits at the action root for a single-file action, or under `src/`
  as the entry point alongside the other modules.

```text
# Single-file action — main.<ext> at the action root
.github/actions/link-check/
├── action.yml          # uses: composite; the run step calls main.py
├── main.py
└── README.md

# Multi-file action — sources under src/
.github/actions/publish-docs/
├── action.yml
├── README.md
└── src/
    ├── main.py
    ├── render.py
    └── client.py
```

### Keep a README with the action

- **Every action carries a `README.md`** describing what it does, its inputs and
  outputs, and an example `uses:` snippet. This is the starting point a reader
  hits first.
- As an action grows — especially once it earns its own repository — fuller
  reference material moves into a `docs/` folder there, and the README narrows
  to an overview and a pointer into those docs. The README is always present;
  it is the entry point, not the whole manual.

## Concurrency

Declare `concurrency` on workflows that must not race — anything that
publishes, deploys, or mutates shared state. Use a stable group key and choose
`cancel-in-progress` deliberately (`false` for publish/deploy so runs queue
rather than abort mid-write).

```yaml
concurrency:
  group: docs-publish
  cancel-in-progress: false
```

## Pin the runner and name everything

- **Pin `runs-on` to a specific runner image** (`ubuntu-24.04`) rather than
  `ubuntu-latest`, so a runner upgrade is a deliberate, reviewable change rather
  than a silent one.
- **Give every job and every non-trivial step a `name:`.** Named steps make the
  Actions UI and logs readable and make failures easy to locate.
