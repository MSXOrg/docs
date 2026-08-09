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

A label set that could be confused with another MUST be namespaced as
`namespace:value`, where the namespace names the owning function and the value is
the instruction to it.

```text
update:major          dependencies
update:minor          github-actions
update:patch          containers
```

Namespacing is not decoration. It is what lets two functions describe the *same kind
of thing* about one pull request without either one silently reading the other's
signal. A dependency update carries both an upstream version change and a version
decision for the repository consuming it; those are two version decisions on one
pull request, and only a namespace keeps them apart
([dependency updates](../Capabilities/dependency-updates/design.md#separation-from-release-versioning)).

## Reserved vocabularies

Where a function's label set is unprefixed, that set MUST be **reserved**: no other
function may read, provision, or reuse those words, and the reservation MUST be
documented on the owning capability's page.

The release bump vocabulary is the standing example. `Major`, `Minor`, `Patch`, and
`NoRelease` are read by [release management](../Capabilities/release-management/spec.md)
and by nothing else. Any other function that needs to express a version level MUST
namespace its own set instead of borrowing these, because a borrowed bump label does
not merely confuse a reader — it changes the version the repository publishes.

Reservation is the weaker of the two mechanisms, because it depends on a documented
prohibition rather than on the label's own name. New label sets are namespaced.

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

- [Release Management](../Capabilities/release-management/spec.md) — the reserved bump vocabulary and why exactly one of its values is required.
- [Dependency Updates](../Capabilities/dependency-updates/design.md#labels) — the namespaced dependency label sets and their separation from release versioning.
- [Repository Governance](../Capabilities/repository-governance/design.md) — the controls that read repository state, of which labels are one.
- [Repository Standard](Repository-Standard.md) — the repository-level requirement that labels be provisioned rather than improvised.
