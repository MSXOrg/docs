---
title: Conformance
description: What a repository must provide to be conformant with the agentic development framework, what it may add, and the duplication checks that keep the router thin.
---

# Conformance

A framework that cannot be checked is a preference. This page states what conformance to
agentic development means for a single repository: the baseline it MUST provide, what it MAY
add, and the conditions that indicate it has drifted.

The checks are deliberately structural. Whether a repository's documentation is *good* is a
review question; whether its agent context resolves correctly is a property that can be
determined by looking.

## The mandatory baseline

A conformant repository MUST provide all of the following.

| Requirement | Conformant when |
| --- | --- |
| **A router agent file** | The repository root holds a single agent instruction file, and it routes rather than instructs ([design](design.md#pointer-files)) |
| **Reading order** | The router states the order in which context is read, from repository-local to organization-canonical |
| **Client routes** | Every supported runtime's expected instruction path exists and resolves to the router, carrying no content of its own ([client behavior](design.md#client-behavior)) |
| **Canonical coordinates** | The router names the organization's canonical documentation location, so context is reachable without prior knowledge |
| **Freshness** | Canonical context is synchronized at the start of every session, in every runtime ([context freshness](design.md#context-freshness)) |
| **Precedence** | The router states that local files never override a standard |

The baseline is small on purpose. Every item is something an agent needs before it can find
anything else; nothing on the list is a judgement about how the repository should be
documented.

## The router stays thin

The router MUST NOT restate a standard.

This is the check that decays fastest, because adding one useful line to the router is always
easier than finding where that line belongs. A router that has grown into a summary is the
worst of both outcomes: it is not authoritative, so it may be wrong, and it is convenient, so
it is what gets read.

A repository is non-conformant where any of these hold:

- The router contains a rule that also appears in organization documentation.
- The router contains a rule that appears nowhere else — meaning documentation is missing, and
  the router is standing in for it.
- A client route contains instructions rather than a pointer to the router.
- A path-scoped rule file restates something the router or a standard already says.
- A named intent carries a copy of the procedure it invokes
  ([plugin distribution](plugin-distribution.md)).

Each of these is the same fault: one fact in two places, which is
[one fact one place](../../Ways-of-Working/Documentation-Model.md) violated, and which
resolves in whichever direction the reader happens to look first.

The remedy is always the same, and it is not deletion of the content: move the content to the
layer that owns it, then reduce the local file to a pointer.

## What a repository may add

Beyond the baseline, a repository MAY add:

- **Path-scoped rules**, for a caveat that is genuinely local to a directory and cannot be
  stated as a standard.
- **Runtime adapters**, for a client the organization has not yet standardized on, provided the
  adapter is a route and adds no content.
- **Named intents**, for recurring workflows, provided they remain pointers.
- **Repository-specific documentation**, which is normal and expected — the constraint is on
  restating standards, not on documenting the repository.

An addition MUST NOT introduce a requirement. Where local practice differs from a standard,
the resolution is to change the standard or to record an
[exemption](../repository-governance/spec.md#exemption), not to encode the difference where
only agents will read it.

## Levels

Conformance is graded, so that a repository can be positioned honestly rather than being
either compliant or not.

| Level | Meaning |
| --- | --- |
| **Baseline** | Every mandatory item is present; an agent can resolve context correctly from a cold start |
| **Consistent** | Baseline, plus no duplication findings: no local file restates a standard |
| **Uniform** | Consistent, plus every supported runtime resolves identically, and the shared tool layer is declared in each ([MCP servers](mcp-servers.md)) |

Only **Baseline** is required. The higher levels describe a repository whose agent context
needs no per-runtime knowledge to work with, which is the state the framework is aiming at.

## Checking

Conformance MUST be checkable without running an agent.

The baseline is a set of file and content properties, and duplication is detectable by
comparing local text against the standards it might be restating. Both are amenable to the
same [drift detection](../repository-governance/design.md#drift-detection-and-reconciliation)
the organization already applies to repository structure, and a conformance finding MUST name
its remedy for the same reason every other finding does: a finding that only reports a problem
becomes a number people learn to ignore.

Determining conformance by asking an agent whether it understood the repository MUST NOT be
treated as a check. The answer is generated from the same context whose adequacy is in
question.

## Where this connects

- [Spec](spec.md) — the requirements this checklist measures against.
- [Design](design.md) — the mechanisms each baseline item refers to.
- [MCP Servers](mcp-servers.md) — the shared tool layer the **Uniform** level requires.
- [Plugin Distribution](plugin-distribution.md) — the pointer discipline the duplication checks apply to intents.
- [Repository Governance](../repository-governance/index.md) — the drift detection and exemption machinery conformance checking reuses.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — one fact one place, which the duplication checks enforce.
