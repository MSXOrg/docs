---
title: Automation Labels
description: Ownership and namespace rules for labels that control repository automation.
---

# Automation Labels

Labels let contributors give instructions to repository automation. Anyone with
write access can apply a label. The issue or pull request displays it, and the
audit trail retains it. Without a defined label set, different automation
functions can interpret the same word differently.

Every label that controls automation has one **owner**. Its name identifies that
owner.

## One owner per label set

Every label an automation reads MUST belong to exactly one owning function, and
that function MUST provision the labels it reads.

Ownership prevents two functions from assigning different meanings to the same
label. Only the owning function can read it. A shared, unqualified vocabulary
requires every function to know and avoid every other function's labels. The
ownership rule removes that dependency.

The owning function provisions its labels, so its configuration defines the valid
set. A repository's label list does not define that set.

## Namespacing

A label set MUST be namespaced as `namespace:value`, where the namespace names the
owning function and the value is the instruction to it.

```text
release:minor
```

A namespace separates each function's labels. Two functions can describe the same
kind of decision on one pull request without reading each other's instructions.

## Every set is namespaced

There is no reserved unprefixed vocabulary. Every label set an automation reads is
namespaced, including the release set:

| Label | Instruction |
| --- | --- |
| `release:patch` | Publish a patch release. |
| `release:minor` | Publish a minor release. |
| `release:major` | Publish a major release. |
| `release:prerelease` | Publish a prerelease from the open pull request. |
| `release:skip` | Validate the change without publishing a release. |

This set applies only when the pull request's target route invokes Release
Management, including through a native producer pipeline. An unmanaged route
does not apply or report any
`release:*` label, including `release:skip`. The optional
`.github/release.settings.yml` file refines an invocation; its absence alone does
not determine whether the route invokes the capability.

These labels are read by
[release management](../Capabilities/release-management/spec.md) and by nothing else.
One owned bump label records an explicit level and overrides the valid effective
`DefaultBump`; without a bump label, documented defaults, repository settings,
and supported caller overrides supply it. `release:skip` records a no-release decision.
`release:prerelease` is a mode used with a resolved explicit or default bump,
never with `release:skip`. Release Management owns the
[resolver and required pre-merge validation](../Capabilities/release-management/design.md#version-computation);
an omitted setting inherits the documented patch default, while invalid settings
and conflicting owned labels fail rather than select a fallback. Settings, not
additional release labels, select configured release-candidate and announcement behavior.

Bare words depend on a separate ownership rule. A namespace identifies the owner
in the label itself.

## Automation ignores what it does not own

Automation MUST NOT respond to a label outside the set it owns.

An ad-hoc label has no defined instruction. Automation ignores it instead of
inferring an action. Applying an invented label therefore produces no automation
result.

The owning function MUST honor an owned label everywhere that function runs.
A label that controls automation in one repository but has no effect in another
gives contributors an inconsistent rule.

## Why not paths, states, or free text

Labels provide per-change overrides without the limits below. Repository defaults
remain version-controlled settings, not another label vocabulary:

| Alternative | Cost |
| --- | --- |
| A file in the repository | Requires a commit to change, so it cannot express a decision about a pull request that is already open |
| A pull request comment | Free text requires automation to infer an instruction from prose |
| A project field | Not visible on the pull request, and not present in the repository's own audit trail |
| An unowned label | Ambiguous across functions, and indistinguishable from an ad-hoc one |

An owned label is applied without a commit, read without parsing, visible where the
decision applies, and unambiguous about who acts on it.

## Where this connects

- [Release Management](../Capabilities/release-management/spec.md) — the namespaced bump vocabulary, optional repository default, and required decision validation.
- [Repository Governance](../Capabilities/repository-governance/design.md) — the controls that read repository state, of which labels are one.
- [Repository Standard](Repository-Standard.md) — the repository-level requirement that labels be provisioned rather than improvised.
