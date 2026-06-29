---
title: Security
description: Least privilege, secret hygiene, and the OWASP baseline.
---

# Security

Security is a property of how we build, not a phase at the end. The cheapest vulnerability to fix is the one caught in the editor; the most expensive is the one found in production. Shift it left.

## Least privilege, everywhere

Every identity — human, agent, or workflow — gets only the permissions it needs for its specific task, and nothing more.

- Workflow jobs declare `permissions` explicitly and as narrowly as possible. A job that only reads never has write access.
- Tokens and API scopes are minimal and scoped to the step or job that uses them — never passed wider.
- Agents are scoped to the actions they are authorized to take. An agent that reviews code cannot merge it.
- Expanding a scope is a deliberate, reviewed decision — never a default or a shortcut.

The goal is to limit blast radius: if any one identity is compromised, the damage is contained. See [Principles → Least-privilege](../Ways-of-Working/Principles.md#least-privilege).

## Secrets stay secret

- **Never commit secrets.** No tokens, keys, passwords, or connection strings in source — not even briefly, not even in history.
- **Secret scanning runs on every commit and PR.** A pre-commit hook and a CI gate catch leaks before they spread.
- **Secrets live in a vault** or the platform's secret store, injected at runtime, never baked into images or config.
- **Prefer short-lived, federated credentials.** Where a platform supports it, authenticate with OIDC or workload-identity federation instead of storing a long-lived secret. A token that lasts minutes and is scoped to one job beats a key that sits in a vault for a year.
- **Rotate on exposure.** A leaked secret is a compromised secret — revoke and rotate, don't hope.

## Validate at the boundaries

Validate and sanitize all input where it crosses a trust boundary — user input, API responses, file contents, environment variables, anything from outside the system. Inside a validated boundary, trust the data; at the edge, trust nothing.

Be especially deliberate where untrusted input meets a powerful sink: shell commands, SQL, templating, deserialization, and dynamic code. These are where the [OWASP Top 10](https://owasp.org/www-project-top-ten/) lives.

## The OWASP baseline

All code is written to be free of the vulnerabilities in the [OWASP Top 10](https://owasp.org/www-project-top-ten/) — injection, broken access control, insecure deserialization, and the rest. Treat them as a checklist for any code that touches a trust boundary, and fix insecure patterns the moment they are spotted rather than filing them for later.

## Supply chain

Our dependencies are part of our attack surface.

- **Pin dependencies** to a known-good version. Pin GitHub Actions to a full commit SHA, not a moving tag.
- **Automate updates** with a dependency bot, so patches land quickly and reviewably.
- **Make builds reproducible.** Lock or vendor dependencies so a build resolves the same inputs every time — and can run without network access where that matters.
- **Generate provenance.** Build artifacts carry a software bill of materials (SBOM) and build attestations, so what is inside a release is verifiable.
- **Minimize the surface.** Every dependency is a liability as well as a convenience — add them deliberately, remove them when unused.

## Secure by default

The secure choice should be the easy choice and the default choice. Design tools and templates so that doing the right thing requires no extra effort, and a deliberate override is required to do the risky thing — never the reverse. This is [Easy](../index.md) and [Safe](../index.md) applied to security.
