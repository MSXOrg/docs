---
title: GitHub Actions
description: Workflow authoring — SHA pinning, least-privilege permissions, OIDC, secrets handling, a PowerShell-first scripting default, script extraction, and diagnostic logging.
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
- name: Check out the repository
  uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

- name: Set up Node
  uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0

# Avoid — mutable tag; the referenced code can change under us
- name: Check out the repository
  uses: actions/checkout@v6
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
```

```yaml
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
- name: Echo the PR title
  env:
    TITLE: ${{ github.event.pull_request.title }}
  run: echo "$TITLE"

# Avoid — attacker-controlled title is executed as shell
- name: Echo the PR title
  run: echo "${{ github.event.pull_request.title }}"
```

## Structure work into jobs and steps

A workflow is a set of **jobs**, and each job is a sequence of **steps**. The two
are not interchangeable: steps in a job share one runner — the same filesystem
and environment, running in order by default — while every job gets a **fresh
runner** and runs in parallel with its siblings unless told to wait. Reach for a
step by default; add a job only when a step cannot give you what you need.

- **Default to steps within one job.** Work that is sequential and shares state —
  check out, build, then test what you just built — belongs in a single job as
  ordered steps. They share the workspace, so each step sees the files the last
  one produced without copying anything, and the job reads top to bottom as one
  story.
- **Add a job to run independent work on its own runner.** Two pieces of
  work with no data dependency between them — a lint pass and a security scan —
  finish sooner as two jobs on two runners than as serial steps on one, each
  isolated with its own environment and permissions. Steps within a single job
  can now run concurrently too, but that is newer and shares one runner (see
  [Parallel steps are new and not yet a default](#parallel-steps-are-new-and-not-yet-a-default)).
  Add ordering with `needs:` only where a real dependency exists.
- **Add a job to draw a permission boundary.** The job is the unit that
  `permissions:` scopes (see
  [Grant least-privilege permissions](#grant-least-privilege-permissions)). When
  one slice of the work needs a wider scope — a step that comments on the pull
  request needs `pull-requests: write` — isolate it in its own job so the rest of
  the workflow stays read-only instead of raising the floor for everything.
- **Add a job for a different runner or a deployment environment.** A job pins
  its own `runs-on:` and can target an `environment:` with its own protection
  rules, approvals, and secrets. Work that must run on a different image, or
  behind a manual deploy gate, is a separate job.
- **Add a job when the result must gate merge.** Branch protection requires
  status checks by job name (see
  [Gate merges with a named status check](#gate-merges-with-a-named-status-check)),
  so a result that blocks a pull request is its own job.
- **Add a job to call a reusable workflow.** A reusable workflow is invoked as a
  job-level `uses:`, never as a step (see
  [Choose an action or a reusable workflow](#choose-an-action-or-a-reusable-workflow)).

Weigh these against what a job costs. A new job is a fresh runner: it checks out
again, warms its own caches, and shares no filesystem with its siblings — data
crosses a job boundary only through `outputs` or an uploaded artifact. So
splitting sequential, state-sharing work across jobs buys nothing and adds
handoff overhead; parallelism across separate runners, an isolated permission
scope, a distinct environment, and merge gating are what earn a new job.

```yaml
permissions: {}

jobs:
  build:
    name: Build and test
    runs-on: ubuntu-24.04
    permissions:
      contents: read
    steps:
      # Sequential, state-sharing work belongs in one job as ordered steps.
      - name: Check out the repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: Build
        shell: pwsh
        run: ./build.ps1     # writes artifacts into the workspace

      - name: Test
        shell: pwsh
        run: ./test.ps1      # reads them from the same workspace — no handoff

  report:
    name: Report
    needs: build             # runs only after build succeeds
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      pull-requests: write   # a wider scope, isolated to this one job
    steps:
      - name: Check out the repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: Publish the summary comment
        uses: ./.github/actions/publish-summary
```

### Parallel steps are new and not yet a default

Every step in a job historically ran in sequence — each starting only once the
last finished — and that sequential model is what the rest of this section
assumes. GitHub has since added **concurrent steps** within a single job, through
four workflow keywords:

- `background: true` starts a step asynchronously and continues straight to the
  next step.
- `wait` / `wait-all` block until one, several, or all prior background steps
  finish.
- `cancel` stops a background step once it is no longer needed — for instance a
  service started only for the steps that run alongside it.
- `parallel` runs a group of steps concurrently and then waits for them: the
  convenience form of "start these together, then carry on".

This covers patterns that used to force a second job or a shell backgrounding
hack (`&`): independent work run at once on one runner, a background service that
later steps use and then shut down, or non-blocking work — uploading telemetry
while packaging continues — overlapping the steps after it. Because the steps
share the runner, they also share its filesystem, which a separate job does not.

Adopt it deliberately:

- **Prefer a separate job for ordinary parallelism.** When independent work does
  not need a shared workspace, two jobs stay the clearer, better-isolated choice —
  separate runners, permissions, and logs. Reach for concurrent steps only when
  the work genuinely benefits from one shared runner.
- **Confirm the toolchain supports the keywords first.** The feature is recent,
  so the pinned [`actionlint` / `zizmor`](#toolchain) versions and the runner
  image in use may not yet validate or run `background` / `wait` / `parallel`;
  verify before relying on it. Expect interleaved concurrent steps to be harder
  to follow, so keep the [grouped-logging discipline](#build-in-logging-and-diagnostics).

Until it has settled in the ecosystem, treat concurrent steps as a tool for the
few cases that need a shared runner, and let a separate job remain the default
answer to "these should run in parallel". See the
[workflow syntax reference](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
for exact usage.

## Choose an action or a reusable workflow

Both an **action** and a **reusable workflow** package automation for reuse, but
at different granularities, and they plug in at different levels. Match the unit
to the thing being reused.

- **An action is a reusable unit of *steps*.** It plugs into a job as a step
  (`uses:` at step level), runs on the caller's runner inside the caller's job —
  sharing that job's filesystem and environment — and does **one well-defined
  thing** through an `inputs` / `outputs` interface. Several actions compose
  within a single job. This is the smaller unit and the common case;
  [Extract non-trivial `run:` scripts into an action](#extract-non-trivial-run-scripts-into-an-action)
  is entirely about authoring one.
- **A reusable workflow is a reusable unit of *jobs*.** It is called as a
  job-level `uses:` (`org/repo/.github/workflows/build.yml@<sha>`) and brings its
  own jobs, runners, `permissions`, and `secrets` contract — a whole pipeline,
  not a single task. Use it to standardize a **multi-job process** several callers
  should run the same way: a shared build-test-publish flow, a common release
  pipeline.

Reach for the smallest unit that fits:

- **Choose an action** to package a **step-level capability** — one task used
  inside a job (`link-check`, `publish-docs`, `start-cloud-agent`). It composes
  with the steps around it and hands results back as outputs.
- **Choose a reusable workflow** to package an **end-to-end, multi-job process** —
  its own job graph, `needs:` ordering, per-job permissions, and environment
  gates — that several repositories should run identically. When the thing worth
  sharing is the *whole pipeline* rather than one step of it, the workflow is the
  unit that carries the jobs with it.
- **Do not wrap a single task in a reusable workflow.** A workflow drags a job
  and a runner behind it; if the reused logic is one step's worth, an action is
  lighter, composes with the surrounding steps, and returns outputs to the
  calling step directly. Equally, do not force a multi-job pipeline into one
  action — an action cannot span jobs or set per-job permissions.

Both are consumed the same disciplined way: **pinned by full commit SHA** (see
[Pin every action to a full commit SHA](#pin-every-action-to-a-full-commit-sha)),
and both **start local and are promoted to a standalone repository only once a
second consumer appears** (see
[Start local; promote when it is reused](#start-local-promote-when-it-is-reused)).
A reusable workflow additionally takes its secrets **explicitly by name, never
`secrets: inherit`** (see
[Distinguish `vars` from `secrets`](#distinguish-vars-from-secrets)).

```yaml
permissions: {}

jobs:
  # An action — a step-level capability, composed inside a job.
  docs:
    name: Publish docs
    runs-on: ubuntu-24.04
    permissions:
      contents: read
    steps:
      - name: Check out the repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: Publish the docs
        uses: ./.github/actions/publish-docs     # one task; returns outputs
        with:
          space: ENG

  # A reusable workflow — a whole multi-job process, called as a job.
  ci:
    name: CI
    uses: org/reusable-workflows/.github/workflows/build.yml@<sha> # vX.Y.Z
    permissions:
      contents: read
      id-token: write
    secrets:
      PROPAGATION_TOKEN: ${{ secrets.PROPAGATION_TOKEN }}  # explicit, by name
```

## Default to PowerShell as the glue language

Between the declarative steps, a workflow always has some glue to run — reading a
value, calling an API, shaping a result. That glue is written in **one language
by default**, so every action reads the same way and reaches for the same helpers
instead of each one inventing its own idiom. **PowerShell is that default.** It
runs cross-platform on every runner, it is held to the
[PowerShell](PowerShell/index.md) standard like any other code, and it carries the
ecosystem's Actions tooling — above all the PSModule `GitHub` module, whose
helpers speak the runner's own workflow-command protocol.

Reach for the options in this order, and drop to the next only when the one above
genuinely cannot serve:

- **First choice — PowerShell with the PSModule `GitHub` module.** Talk to the
  runner through the module's commands instead of hand-writing raw workflow
  strings: the `Write-GitHub*` family (`Write-GitHubNotice`, `Write-GitHubWarning`,
  `Write-GitHubError`) for annotations, `LogGroup` for grouped logging, and
  `Set-GitHubStepSummary` for the step summary. The helper escapes dynamic data
  for you, keeps the script declarative, and gives every action one vocabulary for
  the diagnostics the [logging section](#build-in-logging-and-diagnostics) calls
  for.
- **Fallback — plain PowerShell.** When the `GitHub` module is not available or
  not warranted — a script that does no runner communication, or one that must run
  before the module is installed — stay in PowerShell and write to the log
  directly.
- **Last resort — Bash, only when PowerShell cannot be supported.** A context with
  no `pwsh` — a minimal container, or a step that must run before PowerShell is on
  the image — falls back to Bash. Keep it small and hold it to the same rules,
  above all [never expand untrusted input inline](#never-expand-untrusted-input-inline).

```yaml
# Preferred — PowerShell glue; the GitHub module speaks to the runner.
- name: Publish
  shell: pwsh
  env:
    SPACE: ${{ inputs.space }}
    DRY_RUN: ${{ inputs.dry-run }}
  run: |
    LogGroup 'Resolve inputs' {
      Write-Host "space   = $env:SPACE"
      Write-Host "dry-run = $env:DRY_RUN"
    }
    Write-GitHubNotice -Message "publishing to $env:SPACE" -Title 'Publish'
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

## Toolchain

Two linters enforce this standard in CI, and their configuration is derived from
it — the rules above are the source of truth:

- **[actionlint](https://github.com/rhysd/actionlint)** checks workflow
  correctness: expression syntax, job and step wiring, runner labels, and the
  shell of every `run:` step through shellcheck.
- **[zizmor](https://docs.zizmor.sh/)** audits workflow security, flagging the
  failures this standard exists to prevent: unpinned actions, excessive
  `permissions`, template injection from untrusted input, `secrets: inherit`,
  and persisted credentials.

Both run through [super-linter](https://github.com/super-linter/super-linter) on
every push and pull request, so a workflow that breaks this standard fails the
build.

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

## Pin the runner, name everything, and space it out

- **Pin `runs-on` to a specific runner image** (`ubuntu-24.04`) rather than
  `ubuntu-latest`, so a runner upgrade is a deliberate, reviewable change rather
  than a silent one.
- **Give every job and every step a `name:`** — not only the non-trivial ones.
  Left unnamed, a step is labelled by whatever GitHub derives from its `run` or
  `uses`: the full pinned SHA for an action (`Run actions/checkout@de0fac…`), or
  the truncated first line of a script — both hard to read, and both changing
  whenever the command does. A written `name:` is the exact text shown in the
  Actions UI, the logs, and the Checks view, so a step **reads the same in the
  code as in the portal**, stays a **stable handle** for links and log searches
  when the command underneath it changes, and names a failure by intent rather
  than by a decoded command line. Under the
  [SHA-pinning rule](#pin-every-action-to-a-full-commit-sha) it matters all the
  more: an unnamed action step wears its 40-character SHA as its label.
- **Separate each job and each step with a single blank line.** One blank line
  between consecutive steps, and one between consecutive jobs, makes every unit a
  self-contained block that is easy to scan, reorder, and read in a diff. Use
  exactly one — with none, adjacent steps blur together; with several, the file
  turns gappy.

## Build in logging and diagnostics

An action is a black box until it fails. Make every run explain itself — what it
read, what it decided, and what it produced — *by default*, so a failure is
diagnosed from the log you already have rather than from a second run with extra
logging switched on. The craft is keeping all that detail present but out of the
way until someone wants it.

### Log the whole story by default, collapsed into groups

- **Log the resolved inputs, the decisions taken, each external call and its
  status, and the outputs produced — on every run.** These are the details a
  failure is diagnosed from, so the first run to fail carries enough to diagnose
  it. Log a secret's presence, never its value; secret inputs stay masked (see
  [Distinguish `vars` from `secrets`](#distinguish-vars-from-secrets)).
- **Force an untrusted value onto a single line before logging it.** The runner
  parses every line of stdout, so a value you do not control that carries a
  newline followed by `::...` can smuggle in a workflow command. Strip or encode
  `\r` / `\n` (or emit the value through a helper) so a logged input cannot break
  out into a command — the same untrusted-input rule as
  [Never expand untrusted input inline](#never-expand-untrusted-input-inline).
- **Wrap each phase in a `::group::` / `::endgroup::` block.** Grouping keeps the
  detail present but collapsed — there in plain sight, one expand away — so the
  top level reads as a short list of phases while the depth sits a click beneath
  each. Group by phase (`Resolve inputs`, `Publish 42 pages`), one group per
  phase, not one per line.
- **Wrap the group markers in a helper so the script stays declarative.**
  Emitting the raw `::group::` / `::endgroup::` lines by hand is noisy; a small
  wrapper that takes a title and a block keeps the intent visible. A PowerShell
  action gets this from the PSModule `GitHub` module — `LogGroup 'phase' { ... }`.

```yaml
- name: Publish
  shell: bash
  env:
    SPACE: ${{ inputs.space }}
    DRY_RUN: ${{ inputs.dry-run }}
  run: |
    echo "::group::Resolve inputs"
    echo "space   = ${SPACE}"
    echo "dry-run = ${DRY_RUN}"
    echo "::endgroup::"

    echo "::group::Publish"
    # ...every step of the actual work, logged here as it happens...
    echo "::endgroup::"
```

### Call out the result with an annotation

- **Use `::notice::`, `::warning::`, or `::error::` for the few lines a reader
  must not miss** — above all the final result: what was created, or the
  pass/fail verdict. Annotations render on the run summary and in the Checks
  view, above the collapsed log, so the headline is visible without expanding a
  single group.
- **Annotate the outcome, not the progress.** Step-by-step narration belongs in
  the grouped log; if every other line is a `::notice::`, the one callout that
  matters is lost. Aim to end a run on a single clear annotation.
- **Escape dynamic data in an annotation.** A workflow command is a single line,
  so a value carrying `%`, a carriage return, or a newline must be encoded
  (`%25`, `%0D`, `%0A`) or it corrupts the command — the same class of risk as
  [expanding untrusted input inline](#never-expand-untrusted-input-inline). A
  value placed in a command *property* (such as `title=`) needs `:` and `,`
  encoded too (`%3A`, `%2C`), since those characters delimit the property list. A
  helper that emits the command handles this for you (PowerShell:
  `Write-GitHubNotice` / `Write-GitHubError`).

```bash
# Integer counts are safe to interpolate. Escape free-form text (names, messages)
# with %25 / %0D / %0A first, or emit it through a helper such as Write-GitHubNotice.
echo "::notice title=Published::created ${CREATED}, updated ${UPDATED}"

# A blocking failure: annotate, then exit non-zero (see the status check below).
echo "::error title=Publish failed::${FAILED} page(s) rejected"
```

### Report the bigger picture in a step summary

- **When the result is more than a line — a table, per-item counts, a report —
  write it to `$GITHUB_STEP_SUMMARY` as GitHub-flavored Markdown.** The step
  summary renders on the run's summary page, so the outcome is legible without
  opening the log at all.
- **Keep the summary uncluttered by default.** Show the headline — the table or
  the verdict — in the open, and tuck long or secondary detail inside
  `<details><summary>...</summary>` blocks that stay closed until the reader
  opens them. A summary that spills everything inline is as hard to scan as an
  ungrouped log.
- **Compose the Markdown with a helper rather than building strings** where you
  can. A PowerShell action assembles the summary with the PSModule `Markdown`
  module — `Heading`, `Table`, `Details { ... }` — and writes it with the
  `GitHub` module's `Set-GitHubStepSummary`.
- **Surface the same facts as outputs.** A URL, a count, or a verdict worth
  putting in the summary is also worth an `output` (see
  [Generalize the action](#generalize-the-action-drive-behaviour-through-inputs-and-outputs)),
  so a calling workflow acts on a value instead of scraping the summary.

```bash
{
  echo "## ✅ Documentation publish"
  echo ""
  echo "| Result  | Count |"
  echo "| ------- | ----- |"
  echo "| Created | ${CREATED} |"
  echo "| Updated | ${UPDATED} |"
  echo "| Skipped | ${SKIPPED} |"
  echo ""
  echo "<details><summary>Pages created (${CREATED})</summary>"
  echo ""
  echo "${CREATED_LIST}"   # one entry per line — kept closed until opened
  echo ""
  echo "</details>"
} >> "$GITHUB_STEP_SUMMARY"
```

### Report back on the triggering PR or issue

The step summary is only seen by someone who opens the run. When the outcome
matters to a person mid-flow — a PR author, an issue reporter — surface the
result where they already are. **Which channel is right depends on the event
that triggered the run**, so make reporting conditional on the trigger rather
than assuming one exists.

- **`pull_request` → a pull request comment.** Post the summary to the PR so the
  author sees it in the timeline.
- **`issues` / `issue_comment` → an issue comment.** Reply on the issue that
  started the run.
- **`push` / `schedule` / `workflow_dispatch` → the step summary, plus a tracking
  issue for a finding worth chasing.** There is no PR or issue in context, so the
  step summary stands on its own; a scheduled job that detects a problem can open
  or update an issue.
- **Upsert one comment; never post a fresh one per run.** Write a hidden marker
  (an HTML comment such as `<!-- publish-summary -->`) into the body, find the
  existing comment by that marker, and edit it in place — so a PR pushed ten
  times carries one current comment, not ten stale ones.
- **Grant the write scope only on the job that comments.** A PR comment needs
  `pull-requests: write`, an issue comment needs `issues: write`; the rest of the
  workflow stays read-only. Keep untrusted input out of the comment body (see
  [Never expand untrusted input inline](#never-expand-untrusted-input-inline)),
  and treat `pull_request_target` with particular care — it runs with a writable
  token in the context of untrusted pull request code.

```yaml
jobs:
  report:
    name: Report
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-24.04
    # Only this job can write to the PR; every other job stays read-only.
    permissions:
      contents: read       # checkout
      pull-requests: write # comment on the PR
    steps:
      # A local action runs from the checked-out repo, so check out first.
      - name: Check out the repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: Publish the summary comment
        uses: ./.github/actions/publish-summary   # upserts one marked comment
```

### Gate merges with a named status check

- **If a run's result should block merge, it must surface as a named status
  check** that branch protection can require. A run that only writes to the log
  or a comment cannot hold a pull request; a required check can.
- **Keep the check name stable.** Branch protection matches checks by name, so
  renaming the job or workflow silently drops the gate. Pick a clear, permanent
  name and treat it as a contract — renaming it later removes the gate without a
  trace, so the rename and the branch-protection update must land together.
- **Fail the check for real problems; do not annotate and exit 0.** A gating
  action must exit non-zero when it finds a blocking issue — the annotations and
  the red summary are for humans, the exit code is what the merge gate reads.
  Reserve `::warning::` and `::notice::` for advisory findings that should *not*
  hold the pull request.

```yaml
jobs:
  publishable:
    name: Publishable          # the exact string branch protection requires
    runs-on: ubuntu-24.04
    permissions:
      contents: read
    steps:
      # A local action runs from the checked-out repo, so check out first.
      - name: Check out the repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: Validate that the docs are publishable
        uses: ./.github/actions/validate-publishable   # exits 1 on a blocker
```
