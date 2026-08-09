---
title: Design
description: How repository governance is built — a multi-select type property, organization rulesets selected by type, and continuous drift detection with graded reconciliation.
---

# Repository Governance — Design

Three moving parts deliver the [spec](spec.md): a **property** that carries the
declaration, **organization rulesets** whose conditions read it, and
**reconciliation** that compares the live world against what the declaration
implies.

```mermaid
flowchart LR
    decl["Type property<br/>on the repository"] --> rs["Organization rulesets<br/>selected by type"]
    decl --> files["Required-file set<br/>per type"]
    rs --> live["Live repository<br/>configuration"]
    files --> live
    live --> rec["Reconciliation"]
    decl --> rec
    rec --> findings["Graded findings"]
```

The declaration is the only per-repository input. Everything downstream of it is
organization-level configuration, which is what makes the number of things that
can drift equal to the number of types rather than the number of repositories
([NFR1](spec.md#non-functional)).

## The declaration

The type is a **multi-select** organization custom property, required on every
repository, defaulting to the Standard value. Multi-select rather than
single-select because branch model and layering are separate concerns
([FR2](spec.md#classification), [repository types](design-types.md)).

The property mechanism — how conditions target it, why conditions are written as
exclusions, and how an existing condition is migrated onto it without dropping
coverage — is owned by [Repository Type
Property](../../Ways-of-Working/Repository-Type-Property.md). This design does not
restate it.

Moving an organization from a single-select property to a multi-select one is a
schema change the platform does not perform in place. The migration is therefore
the same shape as any condition migration: create the multi-select property
alongside the existing one, populate it from the current values, verify that every
ruleset's computed coverage is unchanged, repoint the conditions, and only then
retire the old property. Coverage is verified by asking the platform which rules
apply to each repository rather than by reasoning about condition JSON.

## Rulesets by type

One ruleset per governed concern, each selecting repositories by type. Rulesets
are organization-level: a repository-level branch protection would be a second
definition of the same control, and two definitions are two truths
([NFR1](spec.md#non-functional)).

| Ruleset | Selects | Branches | Enforces |
| --- | --- | --- | --- |
| **Baseline** | Every type except the exemption and memory types | Protected branches | Pull request required, no deletion, no force-push, required checks, auto-delete head branch |
| **Artifact history** | Type includes Artifact | Default branch | Squash-only merge, linear history required |
| **Promotion — integration** | Type includes Infrastructure | Integration branch | Squash-only merge |
| **Promotion — production** | Type includes Infrastructure | Production branch | Merge-commit only, promotion-source check required |
| **Documentation build** | Type includes Docs | Protected branches | Documentation-build check required |
| **Automated review** | Every type except the exemption type | Default branch | A review is requested on every pull request; advisory, not a gate |

Two properties of this table matter more than its contents:

- **Conditions are exclusions, not allow-lists.** Each ruleset matches every repository and then subtracts the types that must be exempt. A type value invented later is covered by default; only a type an administrator has explicitly named ever loses coverage ([NFR5](spec.md#non-functional), [filter by exclusion](../../Ways-of-Working/Repository-Type-Property.md#filter-by-exclusion-not-by-inclusion)).
- **Rulesets layer rather than override.** A repository matching three rulesets is subject to the union of all three. Nothing needs to know what else applies, which is why a layering type can be added without touching a branch-model ruleset.

Bypass is granted on each ruleset to a **named administrative group in
pull-request mode only** — never to individuals, and never as a blanket write
exception ([FR16](spec.md#bypass)).

### The promotion-source check

Branch protection can require a check; it cannot express "only from this branch".
So the constraint is implemented as a check that reads its own pull request's head
branch and fails unless it is the integration branch. Being a required check, it
inherits everything the merge gate already provides: it blocks the merge, it is
visible on the pull request, and it is bypassable only by the group the ruleset
names.

## Required files by type

The [Repository Standard](../../Ways-of-Working/Repository-Standard.md#required-files)
owns the file list and which type adds to it. This design owns only the
enforcement: presence is checked by reconciliation on the default branch, at
**Block** severity for the files that make a repository contributable and
**Report** severity for the rest.

## Drift detection and reconciliation

Rulesets prevent unwanted changes to branches. They do not prevent a repository
from being *configured* into a state its declaration does not describe — a
required check renamed, a merge method re-enabled, a required file deleted, a type
value that no longer validates. Reconciliation is the loop that closes that gap:
**compare the declared intent against the live world, continuously, and grade
every difference.**

The loop is generic. It is a scheduled comparison plus a graded response, and it
is implementable as a workflow in an administrative repository, as an application
holding the organization's configuration, or as a policy engine. What matters is
the contract below, not the implementation that satisfies it.

### What is compared

| Comparison | Question |
| --- | --- |
| Type is set | Does the repository carry a type value at all? |
| Type is valid | Is every value in the organization's allowed list? |
| Type composes | Is the combination valid ([validation rules](design-types.md#validation-rules))? |
| Exemption is justified | Does an exempted repository carry a recorded reason? |
| Rulesets apply | Do the rulesets the type implies actually evaluate against this repository? |
| Branch shape matches | Do the protected branches, merge methods, and required checks match what the type declares? |
| Required files present | Does the default branch carry the files the type requires? |

### Severity decides the response

| Severity | Meaning | Response |
| --- | --- | --- |
| **Block** | The declaration is unusable or the repository is not contributable | A failing check on the change that introduces it |
| **Warn** | Live configuration diverges from the declaration but the repository still functions | A comment on the affected pull request |
| **Report** | A standing condition that needs review rather than an immediate fix | A tracking issue, opened once and updated thereafter |

Grading is what keeps the loop usable. A single severity forces a choice between
blocking on things that do not warrant it and merely reporting things that do; the
result of either is that findings stop being read.

### When it runs

On repository creation, on a change to the type property, on a push to a default
branch (for the file comparisons), and on a schedule that catches configuration
changed out of band. The schedule is the one that matters most, because
out-of-band configuration change is the drift the event triggers cannot see.

### Idempotence

Reconciliation reports the same finding at most once. A finding is identified by
the repository, the comparison, and the specific difference; a run that
re-discovers an existing finding **updates** it rather than creating a second one,
and a finding whose condition has been resolved is closed
([FR20](spec.md#reconciliation)). Without this, the loop's output degrades into a
stream nobody can distinguish new findings in.

### A finding names its remedy

Every finding states what is wrong, what the declared type requires instead, and
where the rule is written down. A finding that reports only a mismatch transfers
the work of interpretation to the reader; a finding that names the remedy is
actionable by whoever receives it, human or agent
([FR21](spec.md#reconciliation)).

Reconciliation **reports** by default. Whether it also *applies* a remedy is a
separate decision per comparison, and one that MUST be made deliberately: an
automated fix to a protection is itself a change to a control, and it belongs
under the same review as any other ([decision before
change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change)).

## Configuration surface

| Setting | Where |
| --- | --- |
| Allowed type values | Organization custom-property schema |
| Which controls a type implies | Organization rulesets |
| Required approvals per type | Organization rulesets |
| Bypass group | Organization rulesets |
| Required-file set per type | [Repository Standard](../../Ways-of-Working/Repository-Standard.md#required-files) |
| Comparison severities | Reconciliation configuration |
| Reconciliation schedule | Reconciliation configuration |

## Where this connects

- [Spec](spec.md) — the requirements this design delivers.
- [Repository Types](design-types.md) — the catalogue the rulesets select on.
- [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) — the property mechanism and condition migration.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md) — the required-file sets reconciliation checks.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — the merge gate and who may approve.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — the namespaced labels reconciliation and the rulesets rely on.
