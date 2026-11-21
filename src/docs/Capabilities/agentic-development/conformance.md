---
title: Conformance
description: What a repository must provide to be conformant with the agentic development framework, what it may add, and the duplication checks that keep the router thin.
---

# Conformance

Conformance checks assess a repository's required files, context resolution, and
duplication limits. A conformant repository MUST meet the baseline and MAY add
the scoped extensions below.

These checks assess structure and content. Documentation quality requires review; file and
content inspection establishes whether agent context resolves correctly.

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

Each baseline item supports context discovery. The baseline does not assess the quality of
the repository's documentation.

## The router stays thin

The router MUST NOT restate a standard.

A router can accumulate copied rules when contributors add summaries instead of links.
Readers can then use a convenient summary that differs from its authoritative source.

A repository is non-conformant where any of these hold:

- The router contains a rule that also appears in organization documentation.
- The router contains a rule that appears nowhere else — meaning documentation is missing, and
  the router is standing in for it.
- A client route contains instructions rather than a pointer to the router.
- A path-scoped rule file restates something the router or a standard already says.
- A named intent carries a copy of the procedure it invokes
  ([plugin distribution](plugin-distribution.md)).

These cases either duplicate guidance or put guidance in a file that does not own it.
They violate [one fact one place](../../Ways-of-Working/Documentation-Model.md).
The order in which files are read can then affect the applied rule.

Move the affected content to the layer that owns it, then reduce the local file to a pointer.
Do not remove required information merely to shorten the router.

## What a repository may add

Beyond the baseline, a repository MAY add:

- **Path-scoped rules**, for a caveat that is genuinely local to a directory and cannot be
  stated as a standard.
- **Runtime adapters**, for a client outside the organization's standard set, provided the
  adapter is a route and adds no content.
- **Named intents**, for recurring workflows, provided they remain pointers.
- **Repository-specific documentation**, without copies of shared standards.

An addition MUST NOT introduce a requirement. Where local practice differs from a standard,
the resolution is to change the standard or to record an
[exemption](../repository-governance/spec.md#exemption), not to encode the difference where
only agents will read it.

## Levels

The levels distinguish required baseline checks from stricter consistency and runtime checks.

| Level | Meaning |
| --- | --- |
| **Baseline** | Every mandatory item is present; an agent can resolve context correctly from a cold start |
| **Consistent** | Baseline, plus no duplication findings: no local file restates a standard |
| **Uniform** | Consistent, plus every supported runtime resolves identically, and the shared tool layer is declared in each ([MCP servers](mcp-servers.md)) |

Only **Baseline** is required. The higher levels describe context that does not require
runtime-specific knowledge.

## Checking

Conformance MUST be checkable without running an agent.

The baseline uses file and content properties. Comparing local text with canonical standards
identifies duplication. Both kinds of finding fit the
[drift detection](../repository-governance/design.md#drift-detection-and-reconciliation)
model. A conformance finding MUST name its remedy so a maintainer can act on it.

An agent's report that it understood the repository MUST NOT count as a conformance check.
That answer depends on the same context being assessed.

## Where this connects

- [Spec](spec.md) — agentic-development conformance requirements.
- [Design](design.md) — the mechanisms each baseline item refers to.
- [MCP Servers](mcp-servers.md) — the shared tool layer the **Uniform** level requires.
- [Plugin Distribution](plugin-distribution.md) — the pointer discipline the duplication checks apply to intents.
- [Repository Governance](../repository-governance/index.md) — the drift detection and exemption machinery conformance checking reuses.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — one fact one place, which the duplication checks enforce.
