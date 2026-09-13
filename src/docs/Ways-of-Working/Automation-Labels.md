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
release:minor
```

Namespacing is not decoration. It is what lets two functions describe the *same kind
of thing* about one pull request without either one silently reading the other's
signal.

## Every set is namespaced

There is no reserved unprefixed vocabulary. Every label set an automation reads is
namespaced, including the release set:

| Label | Instruction |
| --- | --- |
| `release:patch` | Publish a patch release. |
| `release:minor` | Publish a minor release. |
| `release:major` | Publish a major release. |
| `release:pre-release` | Publish a prerelease from the open pull request. |
| `release:rc` | Publish the next release candidate for the resolved stable version. |
| `release:announce` | Deliver configured announcements after the release completes. |
| `release:skip` | Validate the change without publishing a release. |

These labels are read by
[release management](../Capabilities/release-management/spec.md) and by nothing else.
One owned bump label records an explicit level and overrides the optional
repository `DefaultBump`; for publishing decisions without a bump label, a valid
configured default supplies it. `release:skip` records a no-release decision.
`release:pre-release` is a mode used with a resolved explicit or configured bump,
never with `release:skip`. `release:rc` is the dedicated release-candidate mode:
it uses the constant `rc` identifier with an increasing numeric counter and
conflicts with both `release:pre-release` and `release:skip`.
`release:announce` can accompany a stable or prerelease publication; it selects
configured post-completion delivery and does not authorize a version, build, or
publication by itself.

Release Management owns the
[resolver and required pre-merge validation](../Capabilities/release-management/design.md#version-computation);
an absent label and absent default are not an implicit patch decision. The
[implementation crosswalk](../Capabilities/release-management/design.md#intended-and-implemented-behavior)
identifies which labels the current shared baseline executes. An owned label
reserved by this contract but unsupported by the invoked workflow MUST fail
validation rather than be ignored or approximated.

Reserving bare words would be weaker because it depends on a documented
prohibition rather than making ownership visible in the label itself.

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

For per-change overrides, labels are chosen over the alternatives because of what
each one costs. Repository defaults remain version-controlled settings, not
another label vocabulary:

| Alternative | Cost |
| --- | --- |
| A file in the repository | Requires a commit to change, so it cannot express a decision about a pull request that is already open |
| A pull request comment | Free text; automation parsing prose is guessing |
| A project field | Not visible on the pull request, and not present in the repository's own audit trail |
| An unowned label | Ambiguous across functions, and indistinguishable from an ad-hoc one |

An owned label is applied without a commit, read without parsing, visible where the
decision applies, and unambiguous about who acts on it.

## Where this connects

- [Release Management](../Capabilities/release-management/spec.md) — the namespaced bump vocabulary, optional repository default, and required decision validation.
- [Repository Governance](../Capabilities/repository-governance/design.md) — the controls that read repository state, of which labels are one.
- [Repository Standard](Repository-Standard.md) — the repository-level requirement that labels be provisioned rather than improvised.
