---
title: MCP Servers
description: How one logical set of tool servers is defined once and declared by every runtime in its own format, so a documented procedure does not depend on which client runs it.
---

# MCP Servers

Agents use tool servers to work with platform data outside the repository. Examples include
issues, pull requests, trackers, and reference sources. Runtimes declare these **tool servers**,
which expose the [Model Context Protocol](https://modelcontextprotocol.io/) interface.

The framework defines a shared server set, not a catalog of specific services.

## One logical layer

The organization MUST define one set of tool servers for its agents, independent of the runtime.

Separate runtime configurations can expose different servers. A documented procedure can then
work in one client and fail in another. Without an explicit missing-tool error, a contributor
cannot distinguish a configuration gap from an incorrect procedure.

A shared layer fixes the available capabilities across runtimes. If a documented procedure
opens an issue, every runtime declares the server that provides that capability.

| Server kind | Why the layer includes it |
| --- | --- |
| **Source platform** | Issues, pull requests, reviews, and repository metadata are the artifacts the process is defined in terms of ([agent interaction](agent-interaction.md)) |
| **Issue tracker** | Planning data when it is outside the source platform |
| **Knowledge base** | Reference material outside a `docs` repository |
| **Organization-specific services** | Whatever else the organization's procedures name |

The organization chooses the specific services once for all runtimes.

## Same contract, different declaration syntax

Every runtime MUST declare the same logical set, in its own native configuration format.

Each runtime uses its native configuration syntax for the same server contract. File
locations, schemas, transports, and credential declarations can differ. The logical server
set and capabilities remain identical:

```text
one logical server set
        │
        ├──> runtime A: its own configuration file, its own schema
        ├──> runtime B: its own configuration file, its own schema
        └──> runtime C: its own configuration file, its own schema
```

This matches the framework's [client routes](design.md#client-behavior): filenames can differ
while each route points to the same instructions. A server declaration likewise connects a
runtime to the shared capabilities without copying process rules.

The consequence is a rule about additions: adding a server means adding it to the logical set
and then to every runtime's declaration. A server declared in one runtime only is a local
convenience, and MUST NOT be relied on by documentation.

## Credentials are not part of the layer

The layer defines *which* servers and *what* they offer. It MUST NOT carry credentials.

Authentication depends on the operator and environment. A local agent uses the operator's
identity; a hosted agent uses the identity its environment grants. Both reach the same
servers with different permissions under
[least privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).
An embedded credential can expose a secret or force agents to share one identity.

A declaration names the server and its connection settings. It resolves credentials from
the environment. If an agent cannot authenticate to a server, it MUST fail visibly rather
than continue without the capability. Otherwise, a documented procedure can produce a
partial result.

## Tools do not replace documentation

A tool server provides capabilities. It MUST NOT change the agent's documented procedure.

Tool descriptions are instructions about tool use. The documentation, not the server,
defines what an issue must contain. The server provides the operations that produce the
documented result.

A server MUST NOT be the source of a process rule, for the same reason a
[skill or command MUST NOT define a workflow stage](spec.md#requirements). A rule stored only
in tool instructions can diverge from reviewed documentation.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that the tool layer is defined once and declared per runtime.
- [Design](design.md#client-behavior) — the same route-not-copy relationship applied to instruction files.
- [Plugin Distribution](plugin-distribution.md) — named intents, which use tools but do not define procedure either.
- [Agent Interaction](agent-interaction.md) — the platform artifacts the source-platform server exists to operate on.
- [Conformance](conformance.md) — how a repository's runtime declarations are checked against the shared set.
