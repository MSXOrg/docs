---
title: Plugin Distribution
description: How recurring workflows are packaged as named intents that point to canonical documentation, and why a packaged shortcut never carries a copy of the procedure.
---

# Plugin Distribution

Some workflows recur often enough to earn a name. "Review this pull request", "open an issue
for this", "wrap up and hand off" — each is a procedure the organization has already
documented, invoked repeatedly, by everyone.

Runtimes offer somewhere to put such things: a command, a skill, a named agent, a plugin.
The name differs; the shape does not. This page calls them **named intents**, and states what
one may contain.

## An intent is a pointer

A named intent MUST resolve to the canonical documentation for its workflow and MUST contain
only the runtime mechanics needed to get there.

This is the same rule that governs [client routes](design.md#client-behavior), applied to
behaviour instead of instructions, and for the same reason. An intent that restates its
procedure is a second definition of that procedure — one that no reviewer of the
documentation knows exists, and that starts disagreeing with the documentation the moment
either changes. Whichever one an agent happens to load then determines what the organization
appears to require.

So the division is strict:

| An intent MAY contain | An intent MUST NOT contain |
| --- | --- |
| A pointer to the canonical procedure | The steps of the procedure |
| Which arguments it takes and how they map to the procedure's inputs | Standards, review criteria, or acceptance rules |
| Runtime mechanics: which tools to enable, how to gather the current artifacts | A workflow stage definition |
| Where to start reading | A copy of anything in `docs` |

The test is whether the intent would still be correct if the documentation changed. If it
would silently become wrong, it is carrying a copy.

## Why intents are worth having anyway

A pointer sounds like it adds nothing. What it adds is **reliable entry**.

Without a named intent, reaching a procedure depends on the prompt being phrased in a way
that leads the agent to the right document. That usually works and occasionally doesn't, and
when it doesn't the agent invents a plausible process instead of following the documented
one. An intent removes the guess: the name maps to exactly one starting point.

Named intents also make the set of recurring workflows **visible**. A runtime that lists its
available intents is showing the organization's procedures, which is a discovery path a
newcomer can use without knowing any file path.

## One model, many runtimes

The set of named intents MUST be one shared model, and each runtime MUST express that same
set in its own format.

An intent available in one client and absent in another produces the failure mode the
framework exists to avoid: the same request behaves differently depending on which client
receives it, and no one can tell whether the difference is intended. Because an intent is
only a pointer plus mechanics, translating one into another runtime's format is mechanical —
there is no logic to port.

## Distribution is by reference

An intent MUST NOT bundle a copy of the documentation it points to.

Bundling is tempting because it makes an intent self-contained and therefore easy to
distribute. It is also how the framework's central premise gets broken: a bundled procedure
is a snapshot, and a snapshot distributed to many places is drift with extra steps. The
canonical documentation is available to every agent through the
[freshness gate](design.md#refresh-hooks); the intent can rely on it being there and current.

The practical consequence is that updating a procedure needs no redistribution. The
documentation changes, and every intent pointing at it is immediately correct — which is the
whole reason the intent holds a pointer instead of a copy.

## Intents do not define process

A named intent MUST NOT define a workflow stage, and MUST NOT add a requirement of its own.

The prohibition matters most where an intent looks like the natural place for a rule: a
review intent that "also checks X". If X is genuinely required, it belongs in the review
procedure, where it applies to every review including the ones nobody invoked an intent for.
If it is not required, the intent is inventing policy that no one reviewed.

An intent whose contents grew past mechanics is a signal that the documentation is missing
something. The fix is to move the content into the documentation and shrink the intent back
to a pointer.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that named intents stay pointer-based and that no client convenience redefines a stage.
- [Design](design.md#pointer-files) — the pointer-file discipline this extends from instructions to behaviour.
- [MCP Servers](mcp-servers.md) — the tool layer an intent's mechanics may enable, which likewise defines no procedure.
- [Workflow](../../Ways-of-Working/Workflow.md) — the canonical stage procedures intents point at.
- [Conformance](conformance.md) — the anti-duplication checks that catch an intent carrying a copy.
