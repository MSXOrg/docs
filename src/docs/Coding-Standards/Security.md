---
title: Security
description: Least privilege, secret hygiene, and the OWASP baseline.
---

# Security

Security is part of software development throughout delivery. Detect vulnerabilities in the editor rather than wait until production, when correction costs more.

## Least privilege, everywhere

Every identity — human, agent, or workflow — gets only the permissions it needs for its specific task, and nothing more.

- Workflow jobs declare `permissions` explicitly and as narrowly as possible. A job that only reads never has write access.
- Tokens and API scopes are minimal and scoped to the step or job that uses them — never passed wider.
- Agents are scoped to the actions they are authorized to take. An agent that reviews code cannot merge it.
- Expanding a scope is a deliberate, reviewed decision — never a default or a shortcut.

Least privilege limits the damage a compromised identity can cause. See [Principles → Least-privilege](../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).

## Secrets stay secret

- **Never commit secrets.** No tokens, keys, passwords, or connection strings in source — not even briefly, not even in history.
- **Secret scanning runs on every commit and PR.** A [pre-commit hook](Pre-Commit.md) and a CI gate detect secrets before merge.
- **Secrets live in a vault** or the platform's secret store. Supply secrets at runtime. Do not put them in images or configuration.
- **Prefer short-lived, federated credentials.** Where a platform supports it, authenticate with OIDC or workload-identity federation instead of storing a long-lived secret. A short-lived token scoped to one job reduces exposure compared with a long-lived key.
- **Rotate on exposure.** A leaked secret is a compromised secret. Revoke and rotate it.

## Validate at the boundaries

Validate and sanitize all input at trust boundaries. This includes user input, API responses, file contents, environment variables, and all other external sources. Trust data only inside a validated boundary.

Be especially careful when untrusted input reaches shell commands, SQL, templating, deserialization, and dynamic code. These operations can expose [OWASP Top 10](https://owasp.org/www-project-top-ten/) vulnerabilities.

## The OWASP baseline

All code is written to be free of the vulnerabilities in the [OWASP Top 10](https://owasp.org/www-project-top-ten/) — injection, broken access control, insecure deserialization, and the rest. Treat them as a checklist for any code that touches a trust boundary, and fix insecure patterns the moment they are spotted rather than filing them for later.

## Supply chain

Dependencies are part of the attack surface.

- **Pin external automation** to immutable identity. External GitHub Actions and reusable workflows use a full commit SHA, never a moving tag. Organization- or initiative-owned automation may use a floating major tag only when controlled release automation exclusively maintains it and keeps it within that compatible major line.
- **Automate updates** with a dependency bot, so patches arrive promptly as reviewable updates.
- **Make builds reproducible.** Lock or vendor dependencies so a build resolves the same inputs every time — and can run without network access where that matters.
- **Generate provenance.** Build artifacts carry a software bill of materials (SBOM) and build attestations, so what is inside a release is verifiable.
- **Minimize the surface.** Each dependency creates maintenance and security obligations. Add dependencies deliberately and remove unused ones.

### Identify a bot by the pull request author

Automation can treat a dependency bot's pull requests differently: auto-approving a patch bump, skipping a human-only gate, or applying a label. Base each condition on the pull request author:

```yaml
if: github.event.pull_request.user.login == 'dependabot[bot]'
```

Do not use `github.actor`. `github.actor` identifies who triggered the *current* run, not necessarily the pull request author. A maintainer who comments, re-runs a job, or pushes to the branch becomes the actor. A condition based on `github.actor` can therefore misidentify bot authorship. `github.event.pull_request.user.login` identifies the pull request author and does not change when others interact with the pull request.

Keep privileged bot detection out of the baseline. `pull_request_target` runs with the base repository's secrets and write token against a head reference the contributor controls. Bot detection does not make that privileged job safe. Use `pull_request`. Where write access is required, use a separate `workflow_run` job that consumes only trusted data.

This is the failure `zizmor`'s `bot-conditions` audit exists to catch, and it runs on every workflow — see [GitHub Actions → Toolchain](GitHub-Actions.md#toolchain).

## Secure by default

The secure choice should be the default and easy to use. Design tools and templates so secure behavior needs no extra effort and risky behavior requires a deliberate override. This is [Easy](../index.md) and [Safe](../index.md) applied to security.
