---
title: Runtime Integration
description: How a runtime is wired into the framework — the entry file it reads, the lifecycle point where it verifies context freshness, the permissions it needs, and what a new runtime must supply to be supported.
---

# Runtime Integration

The framework is deliberately indifferent to which agent runtime a contributor uses. A
procedure documented once holds for every runtime, because a runtime supplies *capability
and lifecycle*, never process.

That indifference is not free. It holds only while each runtime is integrated the same way,
and a runtime integrated by improvisation becomes the one place where the documented process
is not what actually happens. So integration is itself a defined shape: four things a runtime
MUST supply, and nothing else.

## What a runtime must supply

| Obligation | What it means | Where it is defined |
| --- | --- | --- |
| **Entry file** | The instruction file the runtime reads first, which routes to the canonical router rather than restating it | [Pointer files](design.md#pointer-files) |
| **Lifecycle point** | The moment before the first turn where the runtime verifies that context is current | [Context freshness](design.md#context-freshness) |
| **Tool declaration** | The shared tool server set, expressed in the runtime's own configuration format | [MCP Servers](mcp-servers.md#same-contract-different-declaration-syntax) |
| **Identity** | The credential the runtime authenticates with, and the permissions that identity holds | [Permissions](#permissions-follow-the-identity-not-the-runtime) |

A runtime that supplies all four is supported. A runtime missing any of them is usable by a
human who knows what is missing, and MUST NOT be relied on by documentation — because the
documentation cannot say which part of the procedure will silently not happen.

Nothing on that list is process. That is the point: the list is short because integration
work is *plumbing*, and plumbing is where a new runtime's cost should be.

## Runtime shapes, not runtime names

Integration differs by the **shape** of the runtime, not by which product it is. Shapes are
stable; the products occupying them change, and a design pinned to a product name expires
with it.

Four shapes cover the field:

| Shape | Where it runs | Distinguishing constraint |
| --- | --- | --- |
| **Local interactive** | On a contributor's machine, driven turn by turn | Has a durable local workspace, so context can go stale between sessions |
| **Hosted** | In a prepared environment, given a task and left to work | Workspace is created per run, so setup is the only chance to establish context |
| **Review-time** | Triggered by a platform event on a pull request | Reads instructions from the branch under review, not from a local clone |
| **Scheduled** | On a timer, with no human present | No earlier lifecycle point exists, and no one is watching a failure |

The same freshness contract, router, and tool contract serve all four. What
changes is how the runtime reaches the named source and, when it uses a local
clone, where synchronization runs.

### Local interactive

The durable workspace is the hazard. A local runtime is the only shape whose context
survives between sessions, which means it is the only shape that can read a week-old standard
while believing it is canonical.

When the runtime uses local clones, Git synchronization MUST attach to a
session-start lifecycle point in the runtime's own configuration and run before
the first turn rather than on first use of context.

Where the runtime offers no session-start point, local clones MUST be
synchronized explicitly before context is read. A runtime MAY instead use a
current remote CLI, web, or published-documentation route.

### Hosted

A hosted runtime gets a fresh workspace per run, so staleness is not the risk — *absence*
is. The environment either establishes context during setup or the agent works without it.

Context preparation therefore belongs in the environment's setup steps, and
failure MUST fail the run. The environment may clone and synchronize the source
or provide current remote access. An agent that starts successfully against
missing context produces work that looks finished and was never governed.

### Review-time

A review-time runtime reads from the head branch of the pull request it is reviewing. This
inverts the usual freshness problem: context follows the branch under review, so a change to
the instructions is in effect for the very pull request that proposes it.

That is correct and worth stating, because it means a contributor can change agent behaviour
and see the result in the same review — and it means instruction changes MUST be reviewed as
carefully as code, since they are live before merge.

### Scheduled

A scheduled runtime has no lifecycle point earlier than the job itself, so
context preparation is the job's first step. It also has no human to notice a
problem, which raises the bar on failure handling: a scheduled run MUST fail
loudly and MUST NOT proceed with partial context.

## Permissions follow the identity, not the runtime

Every runtime reaches the same tool servers. What differs is the identity it authenticates
as, and therefore what it is permitted to do.

A local runtime acts as the person operating it. A hosted or scheduled runtime acts as the
identity its environment grants. A review-time runtime acts with whatever the platform event
provides. These are different permission sets reaching an identical tool contract, and the
difference is
[least privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege)
working as designed rather than an inconsistency to normalise.

Two rules follow:

- A runtime MUST be granted the narrowest permission set its documented tasks require. A
  runtime that only advises does not need write access, and
  [advisory automation](advisory-agents.md) that holds it will eventually be asked to use it.
- A permission a runtime lacks MUST surface as a visible failure, never as a quietly skipped
  step. An agent that cannot open an issue and continues anyway reports success for work that
  did not happen.

Permissions are not part of the shared tool layer, for the same reason
[credentials are not](mcp-servers.md#credentials-are-not-part-of-the-layer): they are a
property of the operator and the environment, not of the capability.

## Adding a runtime

Adding a runtime is a documentation change plus four declarations, in this order:

1. Identify its **shape** from the table above; the shape determines the lifecycle point.
2. Add its **entry file** as a route to the canonical router, carrying no process content.
3. Attach source freshness verification to its lifecycle point. For local
   clones, preserve the clean, default-branch, fast-forward-only contract.
4. Declare the **shared tool set** in the runtime's native configuration format.
5. Record the **identity** it authenticates as and the permissions that identity holds.

No step writes a procedure, and none of them may be satisfied by copying an existing runtime's
instructions. A copy is the failure mode this whole model exists to prevent: two runtimes with
their own copies of a procedure disagree the moment either is edited, and neither one is
obviously wrong.

If integrating a runtime appears to require new process rules, the rules belong in
documentation and the requirement is a signal that the documentation was incomplete — not
that this runtime is special.

## Where this connects

- [Design](design.md#context-freshness) — the lifecycle table where each shape verifies context freshness.
- [Design](design.md#client-behavior) — why entry files differ in filename and are identical in content.
- [MCP Servers](mcp-servers.md) — the shared tool layer every runtime declares.
- [Plugin Distribution](plugin-distribution.md) — named intents, which are per-runtime packaging over the same documented procedures.
- [Session Interactions](../../Ways-of-Working/Session-Interactions.md) — the phrase vocabulary a runtime recognises without defining.
- [Conformance](conformance.md#checking) — how a repository's runtime declarations are verified.
