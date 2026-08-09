---
title: MCP Servers
description: How one logical set of tool servers is defined once and declared by every runtime in its own format, so a documented procedure does not depend on which client runs it.
---

# MCP Servers

An agent that can only read files is limited to what the repository already knows. Useful
work needs the platform itself: opening an issue, reading a pull request, querying a
tracker, fetching a reference. Those capabilities reach the agent through **tool servers**
declared by the runtime — the [Model Context Protocol](https://modelcontextprotocol.io/) is
the interface they present.

The design question is not which servers exist. It is whether they are the *same* servers
everywhere.

## One logical layer

The set of tool servers available to agents MUST be defined once, as a property of the
organization rather than of a runtime.

The alternative is what happens by default: each runtime accumulates the servers whoever
configured it happened to need. The result is a documented procedure that works in one
client and fails in another, and the failure is not legible — the agent does not report
"this client lacks that tool", it reports that it could not do the thing. A contributor then
concludes the procedure is wrong.

A shared layer makes capability a fixed premise. When documentation says an agent opens an
issue, that instruction holds for every agent, because the server that opens issues is part
of the layer rather than part of someone's local setup.

| Server kind | Why the layer includes it |
| --- | --- |
| **Source platform** | Issues, pull requests, reviews, and repository metadata are the artifacts the process is defined in terms of ([agent interaction](agent-interaction.md)) |
| **Issue tracker** | Where planning lives, when it lives outside the source platform |
| **Knowledge base** | Where reference material lives, when it is not in a `docs` repository |
| **Organization-specific services** | Whatever else the organization's procedures name |

The kinds are stable; the specific services are the organization's choice. What matters is
that the choice is made once.

## Same contract, different declaration syntax

Every runtime MUST declare the same logical set, in its own native configuration format.

Runtimes disagree about where server configuration lives, what the file is called, and how a
server's transport and credentials are expressed. None of that is worth fighting. What is
worth insisting on is that the *contract* — which servers, offering which capabilities — is
identical, so translation is mechanical:

```text
one logical server set
        │
        ├──> runtime A: its own configuration file, its own schema
        ├──> runtime B: its own configuration file, its own schema
        └──> runtime C: its own configuration file, its own schema
```

This is the same relationship the framework already uses for instructions, where
[client routes](design.md#client-behavior) differ in filename and are identical in content. A
declaration is a route to a capability, and a route holds nothing that can drift.

The consequence is a rule about additions: adding a server means adding it to the logical set
and then to every runtime's declaration. A server declared in one runtime only is a local
convenience, and MUST NOT be relied on by documentation.

## Credentials are not part of the layer

The layer defines *which* servers and *what* they offer. It MUST NOT carry credentials.

Authentication is per-operator and per-environment: a local agent authenticates as the
person running it, a hosted agent as the identity its environment grants. Both reach the
same servers with different permissions, and that difference is correct — it is
[least privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege)
working as intended. A server declaration that embedded a credential would either leak it or
force every agent to share one identity.

So a declaration names the server and how to reach it, and resolves its credential from the
environment. An agent that cannot authenticate to a server MUST fail visibly rather than
silently proceeding without the capability, because a procedure that assumed the capability
will otherwise produce a confusing partial result.

## Tools do not replace documentation

A tool server changes what an agent *can do*. It MUST NOT change what the agent is *supposed
to do*.

The distinction matters because tool descriptions are themselves instructions, and a
capable server is tempting to treat as guidance: it knows how to open an issue, so let it
decide what an issue should contain. That inverts the framework — the procedure for opening
an issue is documentation, and the server is how the documented result is achieved.

A server MUST NOT be the source of a process rule, for the same reason a
[skill or command MUST NOT define a workflow stage](spec.md#requirements): a rule that lives
in a tool is a rule nobody reviews, and it disagrees with the documentation the moment either
one changes.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that the tool layer is defined once and declared per runtime.
- [Design](design.md#client-behavior) — the same route-not-copy relationship applied to instruction files.
- [Plugin Distribution](plugin-distribution.md) — named intents, which use tools but do not define procedure either.
- [Agent Interaction](agent-interaction.md) — the platform artifacts the source-platform server exists to operate on.
- [Conformance](conformance.md) — how a repository's runtime declarations are checked against the shared set.
