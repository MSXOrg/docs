---
title: Automation Labels
description: Why every label that drives automation belongs to exactly one owning function, how namespacing keeps label dimensions disjoint, and why automation ignores labels it does not own.
---

# Automation Labels

A label is the cheapest control surface a repository has: anyone with write access
can apply one, it is visible on the issue or pull request that carries it, and it
survives in the audit trail. That makes labels the natural way for a human to tell
automation what to do — and it makes an unstructured label set a liability, because
the same word can mean different things to different automations reading the same
pull request.

Labels that drive automation are therefore **owned**, and ownership is made visible
in the label's own name.

## One owner per label set

Every label an automation reads MUST belong to exactly one owning function, and
that function MUST provision the labels it reads.

Ownership is what makes collisions structurally impossible rather than merely
unlikely. Two functions cannot disagree about what a word means if only one of them
is allowed to read it. The alternative — a shared flat vocabulary any automation may
interpret — requires every function to know about every other function's labels in
order to avoid them, and that knowledge is nowhere written down.

Because the owning function provisions its own labels, the valid set is derivable
from that function's configuration rather than from whatever a repository's label
list happens to contain.

## Namespacing

A label set MUST be namespaced as `namespace:value`, where the namespace names the
owning function and the value is the instruction to it.

```text
dependency:github-actions
dependency:containers
release:minor
```

Namespacing is not decoration. It is what lets two functions describe the *same kind
of thing* about one pull request without either one silently reading the other's
signal. Dependency scope and release impact are separate concerns, so they use
separate namespaces
([dependency updates](../Capabilities/dependency-updates/design.md#dependency-labels)).

## Every set is namespaced

There is no reserved unprefixed vocabulary. Every label set an automation reads is
namespaced, including the release bump set:

```text
release:major         release:none
release:minor
release:patch
```

`release:major`, `release:minor`, `release:patch`, and `release:none` are read by
[release management](../Capabilities/release-management/spec.md) and by nothing else.

Reserving bare words would be the weaker mechanism, because it depends on a documented
prohibition rather than on the label's own name — and for the release set specifically,
the prohibition is not the only thing at stake.

## Automation ignores what it does not own

Automation MUST NOT respond to a label outside the set it owns.

An ad-hoc label therefore does nothing. That is the safe failure: a label nobody
provisioned expresses an intent nobody defined, and acting on a guess about it is
worse than ignoring it. A contributor who applies an invented label and expects a
consequence gets none, and learns that from the absence of the consequence rather
than from an unexpected one.

The corollary is that an owned label MUST be honoured everywhere its function runs.
A label that acts in one repository and is decorative in another is worse than no
label, because it teaches a contributor a rule that does not hold.

## Why not paths, states, or free text

Labels are chosen over the alternatives because of what each one costs:

| Alternative | Cost |
| --- | --- |
| A file in the repository | Requires a commit to change, so it cannot express a decision about a pull request that is already open |
| A pull request comment | Free text; automation parsing prose is guessing |
| A project field | Not visible on the pull request, and not present in the repository's own audit trail |
| An unowned label | Ambiguous across functions, and indistinguishable from an ad-hoc one |

An owned label is applied without a commit, read without parsing, visible where the
decision applies, and unambiguous about who acts on it.

## Where this connects

- [Release Management](../Capabilities/release-management/spec.md) — the namespaced bump vocabulary and why exactly one of its values is required.
- [Dependency Updates](../Capabilities/dependency-updates/design.md#dependency-labels) — dependency-scope labels and the separate release decision.
- [Repository Governance](../Capabilities/repository-governance/design.md) — the controls that read repository state, of which labels are one.
- [Repository Standard](Repository-Standard.md) — the repository-level requirement that labels be provisioned rather than improvised.
