---
title: GitHub Actions
description: Workflow authoring — SHA pinning, least-privilege permissions, OIDC, secrets handling, a PowerShell-first scripting default, script extraction, and diagnostic logging.
---

# GitHub Actions

GitHub Actions workflows can access credentials and publish artifacts.
Workflow authors across the ecosystem apply the application-code standards and
the supply-chain and least-privilege controls below.

Workflow-authoring rules extend the [language-agnostic baseline](index.md). For the
threat model behind action pinning and vendoring, see
[Security → Supply chain](Security.md#supply-chain).
The workflow-specific requirements below apply that supply-chain control.

## Pin actions according to ownership

An external `uses:` dependency uses a SHA pin, as the
[Dependencies](Dependencies.md) standard requires.
This **identity pin** identifies immutable bytes. Automation keeps the pin current
as described below.

A `uses:` reference accepts a tag, a branch, or a commit SHA. Tags and branches
are **mutable**. A maintainer, or an attacker who compromises the maintainer, can
move either reference to different code. A full commit SHA is **immutable**. The only controlled
exception is a floating major tag on automation whose release path MSX controls:

- **External actions and reusable workflows MUST use a full 40-character commit
  SHA.** Keep the human version as a trailing comment so reviewers know the
  intended release. GitHub-owned and marketplace actions are external because
  the organization or initiative does not control their release automation.
- **Organization- or initiative-owned actions and reusable workflows MAY use a
  floating major tag** such as `@v8`. Only controlled release automation may
  create or move that tag, and it may advance only to compatible stable releases
  within the same major line.
- **Humans and ad hoc workflows MUST NOT move a floating major tag.** A breaking
  release creates the next major tag; it never repoints the existing major tag
  across the compatibility boundary.

If a local clone consumes an allowed owned major tag, explicitly accept
producer-controlled tag movement. Follow
[Accept moved release tags](../Capabilities/release-management/accept-moved-release-tags.md)
to repair a stale tag and configure trusted fetches. This does not relax the
immutable-SHA requirement for external actions.

```yaml
# External — immutable SHA; comment carries the readable version
- name: Check out the repository
  uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

# Owned — controlled major tag rolls compatible releases out centrally
jobs:
  process:
    uses: PSModule/Process-PSModule/.github/workflows/Process-PSModule.yml@v8

# Avoid — the organization does not control this external tag
- name: Check out the repository
  uses: actions/checkout@v6
```

## Keep pinned actions current

The update path follows ownership. An external SHA pin is immutable, so the
consumer's dependency automation proposes each newer SHA.
The producer's controlled release automation advances an owned floating major
tag once. Compatible patch and minor releases then reach every consumer on that
major without individual pin-update pull requests.

- **Enable automated updates for the `github-actions` ecosystem** in
  `.github/dependabot.yml`. For external dependencies, the updater opens a pull
  request that rewrites the pin to the new commit SHA and refreshes the trailing
  version comment.
- **Apply the updater's default three-day cooldown** before adopting a published
  version. Omit an explicit `cooldown` mapping unless the repository deliberately
  adopts a non-default duration.
- **Make the release decision separately** after dependency changes are
  collected when the target route invokes [Release
  Management](../Capabilities/release-management/design.md).
- **Publish owned floating major tags only through controlled release
  automation.** The release gate validates compatibility, publishes the immutable
  version tag first, and then advances the major tag to that stable release.
- **Move consumers to a new owned major through a deliberate
  [fleet campaign](../Ways-of-Working/Fleet-Orchestration.md#breaking-major-migrations).**
  A breaking release publishes the next major tag, but consumers remain on their
  current line until that campaign changes their `uses:` references.

The [Dependency Updates](../Capabilities/dependency-updates/design.md) capability
defines the schedule, cooldown, and merge policy.

### Audit and synchronize pins manually

Use the repository's automated dependency-update path for the `github-actions`
ecosystem. When an action update pull request arrives, verify the new SHA and
version comment. Run the required checks. Merge it through the normal gate.

Use the reusable [`Update-GitHubActionPin.ps1`](https://github.com/MSXOrg/docs/blob/main/.github/scripts/Update-GitHubActionPin.ps1)
utility to audit or deliberately synchronize external SHA pins.
Use it for these tasks:

- Add an existing repository to the update process.
- Reconcile pins after an update-service outage.
- Verify proposed changes before an update pull request opens.

The utility does not move owned floating major tags.

The utility needs PowerShell 7, network access to the GitHub REST API, and a
target repository with a `.github` directory. It can resolve public actions
anonymously.
Set `GITHUB_TOKEN` or `GH_TOKEN` to raise the API rate limit or resolve actions
that require authentication.
The utility sends the token only in an API request header.

From this checkout, preview a target repository without changing it:

```powershell
pwsh .github/scripts/Update-GitHubActionPin.ps1 -RepositoryPath ../service -WhatIf
```

Run the same command without `-WhatIf` to write the synchronized pins:

```powershell
pwsh .github/scripts/Update-GitHubActionPin.ps1 -RepositoryPath ../service
```

When the current directory is the target repository, the path is optional:

```powershell
pwsh ../docs/.github/scripts/Update-GitHubActionPin.ps1 -WhatIf
```

The utility recursively scans `.github` YAML files.
It updates only `uses:` references in the form
`owner/repository[/subpath]@<40-character-SHA>`.
It resolves the latest stable release to its commit SHA, including annotated
tags. It replaces the trailing release-tag comment, or adds the comment if it is
absent. It preserves UTF-8 BOM state and existing line endings.

The utility does not change these references or files:

- Local (`./...`) and Docker (`docker://...`) references.
- Mutable tags or branches.
- Non-YAML files.
- Expressions outside this shape.

If an action has no resolvable stable release or tag-to-commit mapping, the utility
stops the run with an explicit error. A partial audit must not appear successful.

## Grant least-privilege permissions

- **Set `permissions:` explicitly.** Never rely on the default token scope.
- **Start with no default permissions.** In a workflow with more than one job,
  declare `permissions: {}` at the workflow (top) level.
  Grant each job only the scopes its steps need.
  A job without its own `permissions:` block inherits no access, including a job
  added later. A missing scope then denies access instead of granting broad
  default access.
  A single-job workflow may declare its scope at the workflow level because it
  has only one job.
- **Declare permissions per job**, not only at workflow level, and grant only
  the scopes that job needs. Most jobs need no more than `contents: read`.
- **Disable checkout's persisted credentials unless the job intentionally pushes.**
  `actions/checkout` writes the token into the local Git configuration by default.
  For read-only jobs, set `persist-credentials: false` so later steps cannot
  accidentally push with it.
  If a job must push, isolate that work in the smallest possible job.
  Grant the write scope there. Make the persisted credential an explicit review
  point.

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

## Use GitHub App installation tokens as the default write identity

When a workflow needs write access, default to a **GitHub App installation token**.
This includes commits, releases, comments, statuses, and pull requests.
Do not default to a PAT or `github.token` unless a documented exception requires
it.

Use the right token type for the job:

| Token | Source | Tied to user | Cross-repo | Caller-scoped |
| --- | --- | --- | --- | --- |
| `github.token` (`GITHUB_TOKEN`) | Automatically injected | No (GitHub Actions bot) | No | Yes — workflow `permissions:` block |
| PAT (classic or fine-grained) | Stored in repo/org secret | Yes | Yes (if scoped) | No — fixed at creation |
| GitHub App installation token | Minted per run (`actions/create-github-app-token`) | No (app bot identity) | Yes (if installed multi-repo) | Yes — `repositories:` + `permission-*` inputs |

Prefer a GitHub App token when:

- commits and releases must be attributed to a bot identity rather than a person;
- a reusable workflow needs write access, including calls that originate from
  fork-driven pull request flows;
- per-job permission scoping must be controlled by the called workflow itself.

### `permissions:` scopes `github.token` only

The workflow or job `permissions:` block controls only the default
`github.token`/`GITHUB_TOKEN`. It does **not** constrain a GitHub App
installation token minted by `actions/create-github-app-token`.

Treat these as separate controls:

- `permissions:` limits what the default workflow token can do.
- `repositories:` + `permission-*` inputs limit what the minted app token can do.

If a minted app token omits `repositories:` and `permission-*`, it inherits the
full installation scope. This includes every installed repository and every
granted permission. Do not mint a token with that scope.

### Mint app tokens with minimum scope every time

Every token mint must declare both repository and permission scope explicitly.

```yaml
- name: Mint a minimally scoped app token
  id: app-token
  uses: actions/create-github-app-token@fee1f7d63c2ff003460e3d139729b119787bc349 # v2
  with:
    app-id: ${{ secrets.GitHubAppClientId }}
    private-key: ${{ secrets.GitHubAppPrivateKey }}
    repositories: ${{ github.event.repository.name }}
    permission-contents: read
    permission-pull-requests: write
```

Rules:

- **Always set `repositories:`.** Default to the current repository
  (`${{ github.event.repository.name }}`); widen only when cross-repository access
  is an explicit requirement.
- **Always set `permission-*` inputs.** Request only the scopes the job uses.
- **Never mint an unscoped token.** A token with no repository or permission
  narrowing violates least privilege.

### Inject app tokens at step scope, not job scope

A token should exist only in the step that consumes it.

- **Prefer step-level `env:`** so one step sees the token.
- **Avoid job-level `env:`** for tokens; it exposes the token to every step in
  the job, including third-party actions.

```yaml
# Correct — token visible only to this step.
- name: Update labels
  env:
    GH_TOKEN: ${{ steps.app-token.outputs.token }}
  shell: pwsh
  run: gh issue edit 123 --add-label ready
```

```yaml
# Avoid — token is injected into every step in the job.
jobs:
  update:
    env:
      GH_TOKEN: ${{ steps.app-token.outputs.token }}
```

Use `GH_TOKEN` for the GitHub CLI. `gh` reads `GH_TOKEN` before `GITHUB_TOKEN`.
Setting `GH_TOKEN` avoids accidentally replacing the default token that other
actions may need.

### Prefer environment-based token passing for actions and composite actions

If an action supports both a named token input (for example `with: token:`) and
environment-based authentication, prefer the environment variable (`GH_TOKEN`).

```yaml
# Preferred — token passed through environment.
- name: Run publish action
  uses: org/publish-action@<sha> # vX.Y.Z
  env:
    GH_TOKEN: ${{ steps.app-token.outputs.token }}
```

```yaml
# Avoid when an env-based option exists — named token input can appear in debug logs.
- name: Run publish action
  uses: org/publish-action@<sha> # vX.Y.Z
  with:
    token: ${{ steps.app-token.outputs.token }}
```

With `ACTIONS_STEP_DEBUG=true`, named input values can appear in debug output.
Runner masking protects the raw secret string, but not every transformed form. If
an action requires a named token input, verify the action masks it at startup
(`core.setSecret(inputs.token)`) before it logs any input.

## Authenticate with OIDC, not long-lived secrets

- **Use OIDC federation** (`id-token: write`) to obtain short-lived cloud
  credentials — `azure/login` and the AWS role-assumption actions both support
  it. Do not store long-lived cloud keys as secrets.
- Scope the federated trust to the specific repository, ref, and environment.

## Distinguish `vars` from `secrets`

- **`secrets`** — anything whose disclosure is a security event (private keys,
  API tokens). Never echo a secret to logs; never put one in `vars`.
- **`vars`** — non-sensitive configuration (client IDs, account numbers,
  gateway URLs). Use `vars` for this configuration.
  Reserve secrets for values that need protection.
- When calling a reusable workflow, **always pass secrets explicitly by name**
  (`secrets: { TOKEN: ${{ secrets.TOKEN }} }`) to show the dependency at the call
  site. **Never use `secrets: inherit`**.
  It forwards every secret the caller holds without listing them.
  The call site then does not show which secrets the workflow needs.
  This defeats traceability and least privilege.

  Organization variables reach reusable workflows automatically and cannot be
  named at the call site. This rule controls `secrets`, not `vars`.

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

Expanding `${{ github.event.* }}` (PR titles, branch names, issue bodies) directly
in a `run:` script allows shell injection.
**Pass untrusted values through an `env:` variable** and reference that variable.
The shell does not parse the variable's contents as script.

Avoid `pull_request_target` and `workflow_run` unless the workflow
needs the elevated context. Both can connect untrusted contributions to tokens,
secrets, or artifacts from a more privileged run.
If either is required, use separate workflows:

- Validate or build the contributor's code in the unprivileged workflow.
- Consume only trusted, explicitly produced artifacts or metadata in the
  privileged workflow.

Never execute untrusted code with a writable token.

```yaml
# Correct — value arrives as an environment variable, not inlined into the shell
- name: Print the PR title
  shell: pwsh
  env:
    TITLE: ${{ github.event.pull_request.title }}
  run: Write-Host $env:TITLE

# Avoid — attacker-controlled title is spliced into the script and executed
- name: Print the PR title
  shell: pwsh
  run: Write-Host "${{ github.event.pull_request.title }}"
```

## Structure work into jobs and steps

A workflow contains **jobs**. Each job contains **steps**.
Steps in a job share one runner, filesystem, and environment.
They run in sequence by default.
Each job gets a **fresh runner** and runs in parallel with other jobs unless a
dependency requires it to wait.
Use a step by default. Add a job only when a step cannot meet the requirement.

- **Default to steps within one job.** Work that is sequential and shares state —
  check out, build, then test the build — belongs in a single job as ordered
  steps. They share the workspace.
  Each step can use the files from the preceding step without copying them.
- **Add a job to run independent work on its own runner.** Two pieces of
  work with no data dependency between them — a lint pass and a security scan —
  can finish sooner on separate runners than as sequential steps on one.
  Each job has its own environment and permissions.
  Steps within a single job can also run concurrently, but they share one runner
  (see
  [Parallel steps are new and not yet a default](#parallel-steps-are-new-and-not-yet-a-default)).
  Add ordering with `needs:` only where a real dependency exists.
- **Add a job to isolate permissions.** The job is the unit that
  `permissions:` scopes (see
  [Grant least-privilege permissions](#grant-least-privilege-permissions)).
  If part of the work needs a wider scope, isolate it in its own job.
  For example, a step that comments on a pull request needs
  `pull-requests: write`. A separate job keeps the rest of the workflow read-only.
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

Consider the cost of each job. Each new job gets a fresh runner, repeats
checkout, and prepares its own caches.
Jobs do not share a filesystem.
Data crosses a job boundary only through `outputs` or an uploaded artifact.
Splitting sequential, state-sharing work across jobs adds data-transfer overhead
without a benefit.
Separate runners, isolated permissions, distinct environments, and merge checks
justify a separate job.

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
        with:
          persist-credentials: false

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

### A skipped job in `needs:` skips everything downstream

A job whose `needs:` list contains a **skipped** job is skipped too.
GitHub implicitly wraps a job's `if:` in `success()`.
`success()` is false when a dependency was *skipped* or failed.
Adding `needs:` to a job that may not run also makes every dependent job
conditional on it.

A skipped job is not a failed job, so the run still concludes **success**.
The commit and pull request show successful checks, and branch protection
accepts the result.
Only the skipped job shows that the work did not run.

This occurs when a conditional job is *upstream* of an unconditional job.
In the `build` / `report` pairing above, the condition is on the dependent job
instead. The dependency always runs.

```yaml
# Avoid — the two conditions are mutually exclusive, so publish never runs
jobs:
  lint:
    if: github.event_name == 'pull_request'    # runs only on pull requests

  publish:
    needs: [build, lint]
    if: github.event_name != 'pull_request'    # runs only when NOT a pull request
    # On push, lint is skipped, so publish is skipped — and the run still
    # reports success. A real occurrence froze a documentation site for two
    # weeks while every run was green.
```

Choose the correction according to whether the dependency is real.

**When a dependency can never provide a result, remove it.** Above, `lint` runs only
on a pull request and `publish` runs only when the event is not a pull request:
the two jobs cannot run on the same event.
No result can pass between them.
A status function leaves a `needs:` list that appears to require lint but does
not.
Remove the dependency. Explain its absence in a comment so a later edit does
not restore it.

```yaml
# Correct — the dead edge is gone; the implicit success() over build still gates
publish:
  # lint is deliberately not a dependency: it only runs on pull_request, which
  # is exactly when publish must not run, so the edge can never carry a signal.
  needs: [build]
  if: github.event_name != 'pull_request'
```

**When the dependency is real but optional, use a status function and test
failure results explicitly.**
If a job should wait for a dependency that sometimes does not run, its `if:`
must override the implicit `success()`.
`always()` runs the job even when a dependency failed or the run was canceled.
`!cancelled()` still runs the job when a dependency failed.
Neither is safe on its own. Pair the function with an explicit result check.

```yaml
# Correct — tolerates a skipped optional dependency, still refuses a failed one
deploy:
  needs: [build, integration-tests]
  # build must have succeeded; integration-tests may be skipped, but not failed
  if: ${{ !cancelled() && needs.build.result == 'success' && needs.integration-tests.result != 'failure' }}
```

Prefer `!cancelled()` over `always()`: a canceled run should stop, not deploy.
Check the result of every dependency whose failure should block, not just the
first. After the override removes implicit `success()`, an unchecked dependency
in `needs:` no longer blocks the job.

No linter in the [toolchain](#toolchain) detects this error.
A complete workflow built around the avoid example passes `actionlint` with no
findings.
`zizmor` audits supply-chain and privilege problems rather than reachability.
Both report no findings on the diff that introduces the error.

Detection requires analysis of whether two `if:` expressions can ever be true
together. Neither tool does this analysis.
Read `needs:` and `if:` together during review.

### Parallel steps are new and not yet a default

Steps in a job run in sequence by default.
Each step starts after the preceding step finishes.
**Concurrent steps** run within a single job through these workflow keywords:

- `background: true` starts a step asynchronously and continues to the
  next step.
- `wait` / `wait-all` block until one, several, or all prior background steps
  finish.
- `cancel` stops a background step once it is no longer needed — for instance a
  service started only for the steps that run alongside it.
- `parallel` runs a group of steps concurrently and waits for them to finish.

Concurrent steps support independent work on one runner, temporary background
services, and tasks that overlap later steps.
For example, telemetry upload can continue while packaging runs.
These patterns avoid a second job or shell-level background execution (`&`).
The steps share the runner and its filesystem, unlike separate jobs.

Adopt it deliberately:

- **Prefer a separate job for ordinary parallelism.** When independent work
  does not need a shared workspace, two jobs provide separate runners,
  permissions, and logs.
  Use concurrent steps only when the work benefits from one shared runner.
- **Confirm the toolchain supports the keywords first.** Verify that the pinned
  [`actionlint` / `zizmor`](#toolchain) versions and runner image can validate and
  run the keywords before use.
  Concurrent-step logs can interleave and become harder to follow.
  Keep the [grouped-logging discipline](#build-in-logging-and-diagnostics).

Use concurrent steps for work that needs a shared runner.
Use separate jobs by default for parallel work.
See the
[workflow syntax reference](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
for exact usage.

## Choose an action or a reusable workflow

An **action** and a **reusable workflow** both package automation for reuse.
They use different units and run at different levels.
Choose the unit according to the work that callers reuse.

- **An action is a reusable unit of *steps*.** A step calls it through `uses:` at
  step level. It runs on the caller's runner inside the caller's job.
  It shares that job's filesystem and environment.
  It does **one well-defined task** through an `inputs` / `outputs` interface.
  Several actions compose within a single job.

  This is the smaller unit and the common case.
  [Extract non-trivial `run:` scripts into an action](#extract-non-trivial-run-scripts-into-an-action)
  describes how to author an action.
- **A reusable workflow is a reusable unit of *jobs*.** A job calls it through
  job-level `uses:` (`org/repo/.github/workflows/build.yml@<sha>`).
  It defines its own jobs, runners, `permissions`, and `secrets` contract.
  It represents a whole pipeline, not a single task.
  Use it to standardize a **multi-job process** across callers, such as a shared
  build-test-publish flow or release pipeline.

Choose the smallest unit that meets the requirement:

- **Choose an action** to package a **step-level capability** — one task used
  inside a job (`link-check`, `publish-docs`, `start-cloud-agent`). It composes
  with the surrounding steps and returns results as outputs.
- **Choose a reusable workflow** for an **end-to-end, multi-job process** that
  several repositories should run the same way.
  Its contract includes the job graph, `needs:` ordering, per-job permissions,
  and environment gates.
  Use it when callers share the *whole pipeline* rather than one step.
- **Do not wrap a single task in a reusable workflow.** A workflow requires a job
  and a runner. If the reused logic is one step, use an action.
  It composes with the surrounding steps and returns outputs to the calling
  step directly.
  Do not force a multi-job pipeline into one action.
  An action cannot span jobs or set per-job permissions.

Both follow the same lifecycle.
**Start as a local action or workflow**, referenced by path (`./.github/...`).
This runs the automation at the checked-out commit.
**Promote it to a standalone repository only once a second consumer appears**
(see [Start local; promote when it is reused](#start-local-promote-when-it-is-reused)).
Once standalone, it is consumed by a controlled major tag while its release path
remains organization- or initiative-owned, or by full commit SHA when external
(see [Pin actions according to ownership](#pin-actions-according-to-ownership)).
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

## Separate a reusable workflow from the actions it consumes

Choosing a reusable workflow affects how it references actions.
The workflow is a **process** that defines the job order.
The actions are the **building blocks** it calls.
Sharing the workflow across repositories requires separate action references
because GitHub resolves paths against the checkout.
This separation supports independent versioning and reuse.

### A shared reusable workflow ships only workflow files

When one repository calls another's reusable workflow
by full path, GitHub loads that workflow file into the caller's run:

```yaml
jobs:
  call-shared-process:
    uses: OWNER/REPO/.github/workflows/name.yml@<sha>
```

If that workflow calls another reusable workflow, GitHub also loads the nested
workflow file.
GitHub does **not** check out the reusable workflow's repository.
A local action reference inside the workflow resolves against the **caller's**
checkout, not the workflow's own repository.
It finds the wrong action or no action:

```yaml
steps:
  - name: Run a local action
    uses: ./.github/actions/some-action
```

A same-repository caller may still name the workflow itself by a local path.
The constraint applies to the actions that the workflow calls.

- **Reference every action from a shared reusable workflow by full path** —
  `OWNER/REPO/path@<ref>`, which resolves the same way regardless of which
  repository is checked out. Use a full SHA for an external action or a
  controlled major tag for owned automation (see
  [Pin actions according to ownership](#pin-actions-according-to-ownership)).
- **A composite action may still call a sibling with `./`.** Inside a composite
  action, `./` resolves within *that action's own repository at the same ref*.
  Colocated actions call each other with `./` and no pin.
  This differs from workflow path resolution and lets a set of actions release
  together.
- **Self-checkout is the only alternative, and a last resort.** A reusable
  workflow *can* check out its own repository at runtime without caller input.
  It uses the `job.workflow_repository` / `job.workflow_ref` / `job.workflow_sha`
  contexts (`actions/checkout` with `repository: ${{ job.workflow_repository }}`,
  `ref: ${{ job.workflow_sha }}`).

  Those contexts are **not available on GitHub Enterprise Server**.
  The checkout must not overwrite the caller's workspace.
  It ties the actions to the workflow's own commit, so an independently consumed
  action has no version line of its own.
  Do not use self-checkout as the standard pattern.

### Why the actions need their own versioned repository

Two lifecycle requirements favor a **separately versioned** action repository
instead of colocated local actions:

- **Development must test the branch, not the last release.** During workflow
  development, run the action versions *on the development branch*.
  A `./` local action does not resolve in a shared reusable workflow.
  Pinning `OWNER/REPO/action@<released-sha>` runs released code instead of branch
  code. Give the actions their own repository.
  Point the workflow's pin at that repository's **branch or commit** to test both
  development versions.
- **A release cannot pin its actions to itself.** The action versions a released
  workflow runs must be exactly those of that release.
  The workflow's tag is created *after* the merge to its default branch.
  Its release commit does not exist when the author writes the workflow file.
  Thus, the file cannot pin a colocated action to its own release commit.

  An independently versioned repository has its own commit.
  The workflow pins that SHA to fix the exact set of actions for the release.

### Give the actions a home that matches their reuse

Use the smallest home that matches the reuse boundary and lifecycle:

- **Use a local action** when the logic is used by one repository. Keep it under
  `.github/actions/<action-name>/` and call it by `./` so the workflow tests the
  action at the checked-out commit.
- **Use a standalone action repository** when one action is consumed **on its
  own** by other repositories.
  The action has its own responsibility and version line.
  This is the promotion path in [Start local; promote when it is
  reused](#start-local-promote-when-it-is-reused).
- **Use an action-library repository** when several actions are built, tested,
  and released together as one package.
  Their lifecycle is shared: a change to one action releases the set again.
  Thus,
  [they belong in one repository](../Ways-of-Working/Repository-Segmentation.md#share-a-repository-only-when-the-development-lifecycle-is-shared),
  not one repository per action.
  The repository contains several top-level composite actions, one test suite,
  one release, and one SHA to pin.
- **Use a reusable-workflow repository** when several repositories reuse the
  *process*: a job graph, permissions contract, environment gates, and ordering.

A shared reusable workflow cannot use a local action.
When that workflow needs non-trivial actions, keep the workflow and the action
library in **separate repositories**.
The workflow repository defines the *process* and pins the action-library
repository's *building blocks* by SHA.
Upgrade each layer through a reviewed pull request with an explicit dependency
update.

## Default to PowerShell as the glue language

Workflow scripts read values, call APIs, and prepare results between declarative
steps. **PowerShell is the default language.**
One default language gives actions consistent code and shared helpers.
PowerShell runs cross-platform on every runner and follows the
[PowerShell](PowerShell/index.md) standard.
The ecosystem's Actions tooling includes the PSModule `GitHub` module.
Its helpers implement the runner's workflow-command protocol.

Use these options in order.
Use the next option only if the preceding option cannot meet the requirement:

- **First choice — PowerShell with the PSModule `GitHub` module.** Use the
  module's commands instead of writing raw workflow-command strings.
  Use the `Write-GitHub*` family (`Write-GitHubNotice`, `Write-GitHubWarning`,
  `Write-GitHubError`) for annotations, `LogGroup` for grouped logging, and
  `Set-GitHubStepSummary` for the step summary.
  The helpers escape dynamic data, keep the script declarative, and standardize
  the diagnostics in the [logging section](#build-in-logging-and-diagnostics).
- **Fallback — plain PowerShell.** If the `GitHub` module is unavailable or not
  needed, use plain PowerShell.
  This includes scripts with no runner communication and scripts that run before
  module installation.
  Write directly to the log.
- **Last resort — Bash, only when PowerShell cannot be supported.** If a context
  has no `pwsh`, use Bash.
  Examples include minimal containers and steps that run before PowerShell is
  installed on the image.
  Keep the script small and apply the same rules, especially
  [never expand untrusted input inline](#never-expand-untrusted-input-inline).

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

A short `run:` step with a few commands that connect tools belongs inline.
If a step contains a **multi-line script embedded as a YAML string** (Bash,
Python, or PowerShell), extract the script.
actionlint can send inline Bash and sh scripts to `shellcheck` when the integration
is enabled and the executable is available.
Its ShellCheck integration does not lint PowerShell or Python.

- **A step whose logic is a non-trivial inline script must become its own
  action.** The workflow then `uses:` that action instead of containing the
  script. The workflow states what runs, in what order, and with what
  permissions. Separate files contain the logic and support linting and tests.

Moving a script out of a workflow string applies the
[Code in code files](../Ways-of-Working/Principles/Engineering-Practices.md#code-in-code-files)
principle.
Standalone source files give tools the script's native language and file context.
They support language-specific linters, such as `ruff`, formatters, type checkers,
security scanners, and IDE features.

### Generalize the action; drive behaviour through inputs and outputs

When extracting an action from one workflow, do not hard-code that workflow's
repository, branch, or posted message.
An extracted action is a reusable unit and should be designed for reuse.
The [SOLID](https://en.wikipedia.org/wiki/SOLID) principles apply to action design:

- **Generalize to the work the action does, not the caller that needs it.**
  Name and scope the action by its *capability* (`start-cloud-agent`,
  `publish-docs`), not by the one situation that prompted it
  (`bump-one-repo-pin`). The action has one well-defined responsibility and
  performs it for any caller.
  It is reusable rather than a copy of one workflow's implementation.
- **Adjust behavior through the input interface, never by editing the action.**
  Every value that varies between callers — the target repository, a model
  name, a prompt, a flag — is an `input`, with a suitable `default` where one
  exists. Serve a new use case through different inputs.
  Do not fork the script or add a caller-specific branch.
  The action is *open for extension* (new inputs, new callers) but *closed for
  modification* (its logic does not change for each consumer).
- **Keep defaults at the interface layer (`action.yml`) only.** Define optional
  input defaults under `inputs.<name>.default` in `action.yml`, and treat that
  as the single source of truth for caller-visible defaults. Do **not** duplicate
  those defaults in runtime code (`main.js`, shell, Python, PowerShell).
  This keeps the UI contract and generated interface docs consistent.
  A default change then requires one interface update instead of synchronized
  copies.
- **Keep the input interface focused.** Expose only the inputs a caller needs.
  A small, well-named interface is easier to use correctly than a broad one with
  rarely used options.
  Group related inputs. Do not expose internal implementation details as
  parameters.
- **Output anything a caller might reasonably act on.** Declare `outputs:` for
  the results the action produces — an identifier it created, a URL, a computed
  version, a pass/fail decision.
  Downstream steps then consume an output instead of calculating it again or
  parsing logs.
  An action that produces results but returns none forces every caller to
  reconstruct those results.

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

Many workflows consume a generalized action by SHA.
A caller-specific action requires copies for other consumers.
Those copies can diverge.

### Start local; promote when it is reused

- **Default to a local action** under `.github/actions/<action-name>/`. That is
  the right home for logic used by one repository.
- **Promote to a standalone repository** only when the action is genuinely
  reused across repositories. At that point it gains its own versioning and is
  consumed according to ownership: a controlled major tag while its release path
  remains organization- or initiative-owned, or a full SHA when external (see
  [Pin actions according to ownership](#pin-actions-according-to-ownership)).
  Do not create a separate repository before a second consumer needs it.
  A shared release interface adds maintenance cost.
- **A reusable workflow's actions are the exception** — a shared reusable
  workflow cannot use a local action.
  Keep a cohesive set in one action library rather than one repository per action.
  See [Separate a reusable workflow from
  the actions it consumes](#separate-a-reusable-workflow-from-the-actions-it-consumes).

### Move the script into its own file

- **Move the script out of `action.yml` into a separate file** so tooling can
  process it. The action's `run:` step then invokes that file instead of
  containing the script.
  Apply its language's coding standard and linter, such as the
  [PowerShell](PowerShell/index.md) standard, just as for application code.
- **One script file lives at the root of the action folder.** When the action
  grows to several source files, **collect them under a `src/` folder** so the
  action root stays readable.
- **Name the entry script `main.<ext>`** (`main.py`, `main.sh`, `main.ps1`).
  A consistent entry-point name makes the action's starting point unambiguous:
  `main.<ext>` sits at the action root for a single-file action, or under `src/`
  as the entry point alongside the other modules.

### Name helper modules after the action

- **A helper module bundled inside an action is named after the action**, not
  given a generic name. For a `publish-docs` action the module is
  `publish-docs.Helpers` in `publish-docs.Helpers.psm1`, imported by path from
  the entry script.
- **Why it matters:** modules imported during a job share one session on the
  runner.
  A generic name — `Helpers`, `Utils`, `Common` — collides with a shared module of
  the same name or another action's helper in that job.
  For example, an ecosystem can install a shared helper module that actions
  import by name.
  If two loaded modules share a name, module resolution is ambiguous.
  Unit tests that target a module by name, such as tests that mock an internal
  command, fail because the framework cannot select a copy.
- **An action-scoped name is unambiguous, mockable, and traceable.** It does not
  clash with other module names.
  Tests can address it by name.
  It identifies the owning action in loaded-module listings, errors, and stack
  traces.
- **The exception is a module published for sharing.** A helper whose whole
  purpose is to be installed and imported by many actions keeps its shared,
  stable name; only an action's *private* helper module is action-scoped.

## Toolchain

Two linters check workflow correctness and security in CI.
Their configuration derives from the rules above, which are the source of truth:

- **[actionlint](https://github.com/rhysd/actionlint)** checks workflow
  correctness: expression syntax, job and step connections, and runner labels.
  Its [ShellCheck integration](https://github.com/rhysd/actionlint/blob/main/docs/checks.md#check-shellcheck-integ)
  checks inline Bash and sh `run:` scripts when enabled and ShellCheck is available.
  It does not check PowerShell or Python through ShellCheck.
- **[zizmor](https://docs.zizmor.sh/)** audits workflow security, flagging
  unpinned actions, excessive `permissions`, template injection from untrusted
  input, `secrets: inherit`,
  and persisted credentials.

Both run through [super-linter](https://github.com/super-linter/super-linter) on
every push and pull request.

The linters do not detect every workflow-authoring violation.
Review the authoring rules as well as the lint results.
For conditional dependencies, follow the
[skipped-job guidance](#a-skipped-job-in-needs-skips-everything-downstream).

Treat `actionlint` errors and high-severity `zizmor` findings as blockers.
Fix medium-severity `zizmor` findings unless the workflow documents why the risk
is accepted.
Fix low-severity findings when a simpler, safer form is available.
Start an audit with these checks:

- Unpinned actions.
- Broad or inherited secrets.
- Missing `permissions`.
- Persisted checkout credentials.
- Untrusted context expansion.
- Elevated triggers such as `pull_request_target` or `workflow_run`.

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
  outputs, and an example `uses:` snippet.
  This is the reader's starting point.
- As an action grows, especially into its own repository, move fuller reference
  material into a `docs/` folder there.
  Keep an overview and a link to those docs in the README.
  The README is always present as the entry point, not the whole manual.

## Reusable workflows with colocated composite actions

When a reusable workflow (`on: workflow_call`) has its own composite actions,
they are local to that workflow.
They are stored alongside it in `.github/actions/`.
If the reusable workflow is an action's only caller, the action should stay
colocated and not be promoted to a standalone repository.

**The problem:** a reusable workflow runs in the *caller's* checked-out
workspace, not in its own repository.
A relative action path in `uses:` (e.g., `./.github/actions/my-action/`) resolves
to the *caller's* repository.
The workflow then fails or runs the wrong action version.

**The solution:** the reusable workflow must check itself out first.
Use the `job.workflow_repository` and `job.workflow_sha` contexts from GitHub
Actions.
These contexts identify the reusable workflow's exact repository and commit SHA,
not the caller's.

- **Check out the reusable workflow's own repository** at the start of the job,
  using `job.workflow_repository` and `job.workflow_sha`, before calling any
  local composite actions. This ensures the actions resolve in the reusable
  workflow's own workspace.
- **Use a `path:` argument** in the checkout step to place the reusable workflow
  in a separate subdirectory.
  This distinguishes it from the caller's checkout and gives its actions a
  separate path.
- The same reusable workflow works at a tagged release (e.g., `v1.2.3`) or on a
  development branch.
  The caller automatically gets matching versions of the workflow and its
  actions.

```yaml
jobs:
  # Reusable workflow with colocated composite actions
  my-task:
    runs-on: ubuntu-24.04
    permissions:
      contents: read
    steps:
      # Check out the reusable workflow's own repository
      # (not the caller's — that's assumed to be the default checkout)
      - name: Check out the reusable workflow
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          repository: ${{ job.workflow_repository }}
          ref: ${{ job.workflow_sha }}
          path: workflow

      # Now call the colocated action from the workflow's path
      - name: Run the workflow's action
        uses: ./workflow/.github/actions/my-action
        with:
          input-value: example
```

**Availability:** `job.workflow_repository` and `job.workflow_sha` are available
on GitHub.com and GitHub Enterprise Cloud (GHEC).
They are **not** available on GitHub Enterprise Server (GHES).

## Concurrency

Declare `concurrency` on workflows that publish, deploy, or change shared state.
Use a stable group key. Choose `cancel-in-progress` deliberately.
For publishing and deployment, use `false` so runs queue instead of stopping
during a write.

```yaml
concurrency:
  group: docs-publish
  cancel-in-progress: false
```

## Pin the runner, name everything, and space it out

- **Pin `runs-on` to a specific runner image** (`ubuntu-24.04`) rather than
  `ubuntu-latest`.
  This makes a runner upgrade a deliberate, reviewable change instead of a
  silent one.
- **Give every job and every step a `name:`** — not only the non-trivial ones.
  Without a name, GitHub derives a step's label from its `run` or `uses`.
  For an action, the label contains the full pinned SHA
  (`Run actions/checkout@de0fac…`).
  For a script, it contains the truncated first line.
  Both labels can be hard to read and change with the command.

  A written `name:` appears as the same text in the Actions UI, logs, and Checks
  view. It gives links and log searches a stable label when the command changes.
  It describes the intent of failed work instead of the command line.
  This matters under the [external SHA-pinning rule](#pin-actions-according-to-ownership)
  because an unnamed external action step uses its 40-character SHA as its label.
- **Separate each job and each step with a single blank line.** One blank line
  between consecutive steps and consecutive jobs makes each unit easy to scan,
  reorder, and read in a diff.
  Use exactly one. Without it, adjacent steps are harder to distinguish.
  Several blank lines add unnecessary space.

## Build in logging and diagnostics

An action reports what it reads, decides, and produces on every run.
A failure should be diagnosable from the existing log without a second run with
extra logging.
Keep the details available in collapsed groups.

### Log the whole story by default, collapsed into groups

- **Log the resolved inputs, the decisions taken, each external call and its
  status, and the outputs produced — on every run.**
  The first failed run then contains enough diagnostic detail.
  Log a secret's presence, never its value.
  Keep secret inputs masked (see
  [Distinguish `vars` from `secrets`](#distinguish-vars-from-secrets)).
- **Force an untrusted value onto a single line before logging it.** The runner
  parses every line of stdout.
  An untrusted value with a newline followed by `::...` can become a workflow
  command.
  Strip or encode `\r` / `\n`, or emit the value through a helper.
  This prevents a logged input from becoming a command, as required by
  [Never expand untrusted input inline](#never-expand-untrusted-input-inline).
- **Wrap each phase in a `::group::` / `::endgroup::` block.**
  Details remain available but collapsed.
  The top level shows a short list of phases.
  Expand a phase to read its details.
  Group by phase (`Resolve inputs`, `Publish 42 pages`), with one group per
  phase, not one per line.
- **Wrap the group markers in a helper so the script stays declarative.**
  A helper emits matching `::group::` / `::endgroup::` markers.
  A wrapper that accepts a title and a script block keeps the phase's intent
  visible.
  A PowerShell action uses the PSModule `GitHub` module:
  `LogGroup 'phase' { ... }`.

```yaml
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

    LogGroup 'Publish 42 pages' {
      # ...each page logged here as it is published...
    }
```

### Call out the result with an annotation

- **Use `::notice::`, `::warning::`, or `::error::` for the few lines a reader
  must not miss**, especially the final result: what was created or the
  pass/fail verdict.
  Annotations appear on the run summary and in the Checks view, above the
  collapsed log.
  The reader can see the result without expanding a group.
- **Annotate the outcome, not the progress.** Step-by-step narration belongs in
  the grouped log.
  Too many `::notice::` annotations make the result harder to find.
  Aim to end a run with one clear annotation.
- **Escape dynamic data in an annotation.** A workflow command is a single line,
  so a value with `%`, a carriage return, or a newline must be encoded
  (`%25`, `%0D`, `%0A`).
  Otherwise, the value corrupts the command, as with
  [expanding untrusted input inline](#never-expand-untrusted-input-inline).
  If a value is a command *property* (such as `title=`), also encode `:` and `,`
  (`%3A`, `%2C`).
  Those characters delimit the property list.
  A helper encodes the value when it emits the command (PowerShell:
  `Write-GitHubNotice` / `Write-GitHubError`).

```powershell
# The GitHub module escapes dynamic data for you — no manual %25 / %0D / %0A.
Write-GitHubNotice -Title 'Published' -Message "created $($created.Count), updated $($updated.Count)"

# A blocking failure: annotate, then throw so the step exits non-zero (see the status check below).
Write-GitHubError -Title 'Publish failed' -Message "$($rejected.Count) page(s) rejected"
throw "$($rejected.Count) page(s) rejected"
```

### Report the bigger picture in a step summary

- **When the result is more than a line — a table, per-item counts, a report —
  write it to `$GITHUB_STEP_SUMMARY` as GitHub-flavored Markdown.** The step
  summary appears on the run's summary page.
  The reader can see the outcome without opening the log.
- **Keep the summary uncluttered by default.** Show the main table or verdict.
  Put long or secondary details inside `<details><summary>...</summary>` blocks.
  These blocks stay closed until the reader opens them.
  A fully expanded report is as hard to scan as an ungrouped log.
- **Compose the Markdown with a helper rather than building strings** where
  possible.
  A PowerShell action uses the PSModule `Markdown` module:
  `Heading`, `Table`, and `Details { ... }`.
  Write the summary with the `GitHub` module's `Set-GitHubStepSummary`.
- **Return the same facts as outputs.** A URL, count, or verdict in the summary
  also belongs in an `output` (see
  [Generalize the action](#generalize-the-action-drive-behaviour-through-inputs-and-outputs)).
  A calling workflow then uses a value instead of parsing the summary.

```powershell
Set-GitHubStepSummary -Summary (
  Heading 2 '✅ Documentation publish' {
    Table {
      [pscustomobject]@{ Result = 'Created'; Count = $created.Count }
      [pscustomobject]@{ Result = 'Updated'; Count = $updated.Count }
      [pscustomobject]@{ Result = 'Skipped'; Count = $skipped.Count }
    }

    Details "Pages created ($($created.Count))" {
      $created -join "`n"   # one title per line — kept closed until opened
    }
  }
)
```

### Report back on the triggering PR or issue

Readers see the step summary only if they open the run.
If an outcome matters to a PR author or issue reporter, report it on that PR or
issue.
**Choose the reporting channel according to the event that triggered the run.**
Make reporting conditional on the trigger instead of assuming a PR or issue
exists.

- **`pull_request` → a pull request comment.** Post the summary to the PR so the
  author sees it in the timeline.
- **`issues` / `issue_comment` → an issue comment.** Reply on the issue that
  started the run.
- **`push` / `schedule` / `workflow_dispatch` → the step summary, plus a tracking
  issue for a finding that needs follow-up.**
  There is no PR or issue in context, so the step summary stands on its own.
  A scheduled job that detects a problem can open or update an issue.
- **Upsert one comment; never post a new one per run.** Write a hidden marker
  (an HTML comment such as `<!-- publish-summary -->`) into the body.
  Find the existing comment by that marker. Edit it in place.
  A PR pushed ten times then has one current comment, not ten stale copies.
- **Grant the write scope only on the job that comments.** A PR comment needs
  `pull-requests: write`, and an issue comment needs `issues: write`.
  Keep the rest of the workflow read-only.
  Keep untrusted input out of the comment body (see
  [Never expand untrusted input inline](#never-expand-untrusted-input-inline)).
  Use particular care with `pull_request_target`.
  It runs with a writable token in the context of untrusted pull request code.

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
  check** that branch protection can require.
  A run that only writes to a log or comment cannot block merge.
  A required check can.
- **Keep the check name stable.** Branch protection matches checks by name, so
  renaming the job or workflow removes the gate.
  Choose a clear, permanent name and treat it as a contract.
  The rename and the branch-protection update must land together.
- **Fail the check for real problems. Do not annotate and exit 0.** A gating
  action must exit non-zero when it finds a blocking issue.
  Annotations and the failed summary explain the problem to readers.
  The merge gate reads the exit code.
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

**Two mechanisms that a ruleset can require by name.**
A pull request receives a named check in one of two forms.
A ruleset can require either form:

- **A check run — the job itself.** Every Actions job automatically becomes a
  check run named after the job.
  The `Publishable` job above *is* the check and needs no extra permission.
  Prefer this form when the signal is one of the workflow's own jobs.
- **A commit status — the Status API.** A step or an external system posts a
  status against the head commit under its own **context** name via the
  [Commit Status API](https://docs.github.com/rest/commits/statuses), for a
  signal that is not a whole job.
  The linter in this repository's `Docs` workflow reports per-language statuses
  this way.
  Posting a status needs **`statuses: write`**.
  A check run does not.

```yaml
jobs:
  lint:
    name: Lint
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      statuses: write        # post commit statuses via the Status API
```

**A check blocks nothing until a ruleset requires it.**
A repository ruleset (or branch protection) must list the check as **required**
by its exact name or context.
Otherwise, the check is advisory: visible on the pull request but unable to block
merge.
A required check provides a machine-readable pass or fail signal.
Automation can then approve or merge a successful pull request and hold a failed
one.

The [Merge Automation](../Capabilities/merge-automation/index.md) capability
defines that end-to-end pattern.
