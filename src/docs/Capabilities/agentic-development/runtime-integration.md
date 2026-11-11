---
title: Runtime Integration
description: Requirements for a runtime's entry file, context freshness, tool declaration, identity, and permissions.
---

# Runtime Integration

The framework supports different agent runtimes. A runtime supplies capabilities and
lifecycle points, not process rules. Each runtime follows the same documented procedure.

Every runtime MUST supply the four integration elements below. These elements keep
runtime-specific mechanics separate from shared process.

## What a runtime must supply

| Obligation | What it means | Where it is defined |
| --- | --- | --- |
| **Entry file** | The instruction file the runtime reads first, which routes to the canonical router rather than restating it | [Pointer files](design.md#pointer-files) |
| **Lifecycle point** | The moment before the first turn where the runtime verifies and synchronizes context | [Context freshness](design.md#context-freshness) |
| **Tool declaration** | The shared tool server set, expressed in the runtime's own configuration format | [MCP Servers](mcp-servers.md#same-contract-different-declaration-syntax) |
| **Identity** | The credential the runtime authenticates with, and the permissions that identity holds | [Permissions](#permissions-follow-the-identity-not-the-runtime) |

A runtime that supplies all four elements is supported. A human who knows the gap can use
a runtime with a missing element. Documentation MUST NOT rely on such a runtime, because
part of the procedure can fail without a visible error.

Integration covers entry files, lifecycle points, tool declarations, and identity.
Process remains in the canonical documentation.

## Runtime shapes, not runtime names

Integration depends on the runtime's **shape**, not its product name. A shape describes
where the runtime runs and when it can prepare context.

The framework distinguishes four runtime shapes:

| Shape | Where it runs | Distinguishing constraint |
| --- | --- | --- |
| **Local interactive** | On a contributor's machine, driven turn by turn | Has a durable local workspace, so context can go stale between sessions |
| **Hosted** | In a prepared environment, given a task and left to work | Workspace is created per run, so setup is the only chance to establish context |
| **Review-time** | Triggered by a platform event on a pull request | Reads instructions from the branch under review, not from a local clone |
| **Scheduled** | On a timer, with no human present | No earlier lifecycle point exists, and no one is watching a failure |

All four use the same Git synchronization contract, router, and tool contract.
Only the synchronization lifecycle point differs.

### Local interactive

A durable local workspace can contain context from an earlier session. The runtime can
therefore read a stale standard as if it were current.

Git synchronization MUST run at a session-start lifecycle point in the runtime's own
configuration. It MUST run before the first turn, not on first context use.

Where the runtime offers no session-start point, Git synchronization MUST be invoked explicitly
before context is read.

### Hosted

A hosted runtime receives a fresh workspace for each run. Setup provides the required
context before the agent starts.

The environment runs Git synchronization during setup. A setup failure MUST fail the run.
Without this failure signal, ungoverned work can appear complete at review.

### Review-time

A review-time runtime reads instructions from the head branch of the pull request under
review. An instruction change therefore applies to the pull request that proposes it.

A contributor can change agent behavior and observe the result in the same review.
Reviewers MUST assess instruction changes as carefully as code because those instructions
apply before merge.

### Scheduled

The job itself is a scheduled runtime's first lifecycle point, so Git synchronization is
the job's first step. No human is present to observe a failure. A scheduled run MUST report
a visible failure and MUST NOT proceed with partial context. Otherwise, the same partial
run can repeat on the schedule.

## Permissions follow the identity, not the runtime

Every runtime reaches the same tool servers. Its authenticated identity determines
what it is permitted to do.

A local runtime acts as the person operating it. A hosted or scheduled runtime acts as the
identity its environment grants. A review-time runtime acts with whatever the platform event
provides. These permission sets use the same tool contract. Their differences implement
[least privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege);
they are not runtime inconsistencies.

Two rules follow:

- A runtime MUST have only the permissions its documented tasks require. A runtime that
  only advises does not need write access. The
  [advisory automation](advisory-agents.md) pattern separates advice from authority.
- If a required permission is missing, the runtime MUST report a visible failure rather
  than skip the step. An agent that cannot open an issue cannot report that the issue
  was created.

Permissions are not part of the shared tool layer, for the same reason
[credentials are not](mcp-servers.md#credentials-are-not-part-of-the-layer): they are a
property of the operator and the environment, not of the capability.

## Adding a runtime

Adding a runtime is a documentation change plus four declarations, in this order:

1. Identify its **shape** from the table above; the shape determines the lifecycle point.
2. Add its **entry file** as a route to the canonical router, carrying no process content.
3. Attach Git synchronization to its lifecycle point, preserving the clean, default-branch,
   fast-forward-only contract.
4. Declare the **shared tool set** in the runtime's native configuration format.
5. Record the **identity** it authenticates as and the permissions that identity holds.

These steps add runtime declarations, not process. Do not copy another runtime's
instructions to complete them. Copies can diverge when either runtime changes its version
of the procedure.

If integration requires a process rule, define that rule in the canonical documentation.
The runtime configuration does not own process.

## Where this connects

- [Design](design.md#context-freshness) — the lifecycle table where each shape verifies context freshness.
- [Design](design.md#client-behavior) — why entry files differ in filename and are identical in content.
- [MCP Servers](mcp-servers.md) — the shared tool layer every runtime declares.
- [Plugin Distribution](plugin-distribution.md) — named intents, which are per-runtime packaging over the same documented procedures.
- [Session Interactions](../../Ways-of-Working/Session-Interactions.md) — the phrase vocabulary a runtime recognizes without defining.
- [Conformance](conformance.md#checking) — how a repository's runtime declarations are verified.
