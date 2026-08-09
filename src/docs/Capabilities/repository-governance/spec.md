---
title: Spec
description: Requirements for repository governance — classification-driven protection, a common baseline for every governed repository, explicit exemption, and continuous reconciliation.
---

# Repository Governance — Spec

## Premise

An organization's repositories are not uniform. A published package needs a
bisectable history; an infrastructure stack needs changes to reach a lower
environment before production; a documentation site needs its build to pass
before it lands. Configuring each repository to match its own shape produces as
many configurations as there are repositories, all of them drifting, none of them
reviewable together.

Governance MUST therefore be inverted: a repository **declares its kind**, and
the organization holds one configuration per kind. The declaration is the only
per-repository decision, and it is a value, not a configuration. Every control
follows from it, so the number of things that can drift is the number of kinds,
not the number of repositories.

### Principles

This capability rests on the [Principles](../../Ways-of-Working/Principles/index.md):

- **[Everything as Code](../../Ways-of-Working/Principles/Engineering-Practices.md#everything-as-code).** Types, rulesets, and required files are version-controlled configuration, reviewable as a diff.
- **[Smart defaults, local overrides](../../Ways-of-Working/Principles/Software-Design.md#smart-defaults-local-overrides).** A repository is governed because it exists, not because someone remembered to configure it. Opting out is an explicit, recorded act.
- **[Least-privilege](../../Ways-of-Working/Principles/Purpose-and-Direction.md#least-privilege).** Bypass is granted to a named administrative group, never to individuals and never permanently.
- **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).** Every write to a protected branch passes through a pull request that can be read, checked, and approved.
- **[Extensible by default](../../Ways-of-Working/Principles/Software-Design.md#extensible-by-default).** A new repository shape is a new type value and one ruleset, not a change to the ones that exist.

## Scope

**In scope.** How a repository is classified; which branch model, required
checks, review gate, merge methods, and required files each classification
implies; how classifications combine; how a repository is exempted; and how live
configuration is continuously compared against the declaration.

**Out of scope.** What a change must contain to be accepted — that is
[Contribution Workflow](../../Ways-of-Working/Contribution-Workflow.md), [PR
Format](../../Ways-of-Working/PR-Format.md), and the coding standards. Also out of
scope: the platform's own security baseline, which layers underneath this
framework and is owned by whoever operates the platform. This framework MUST NOT
weaken that baseline and MUST NOT restate it.

## Requirements

### Classification

- **FR1 — Every repository carries a type.** A repository MUST declare its kind through a repository-level property the organization defines. An undeclared repository MUST be treated as the default type rather than as ungoverned.
- **FR2 — The type is multi-valued.** The property MUST accept more than one value, because a repository's branch model and its build obligations are separate concerns. See [Repository Types](design-types.md).
- **FR3 — Only declared values are accepted.** A value outside the organization's allowed list MUST be rejected as a misconfiguration, not silently ignored.
- **FR4 — Combinations are validated.** Some combinations are contradictory. Validation rules MUST be stated once and enforced, not left to the reader ([composition rules](design-types.md#composition-and-precedence)).

### The common baseline

Every governed repository — every repository not explicitly exempted — MUST be
subject to the same baseline, regardless of type:

- **FR5 — Writes go through pull requests.** A protected branch MUST NOT accept a direct push.
- **FR6 — Protected branches cannot be deleted or force-pushed.** History on a protected branch is append-only.
- **FR7 — Required checks gate the merge.** A pull request MUST NOT be mergeable until the checks its type declares have passed.
- **FR8 — A review is requested automatically.** Every pull request MUST have a review requested without the author asking. Whether that review *gates* the merge is a separate rule ([the review gate](#the-review-gate)).
- **FR9 — Merged branches are deleted.** The repository-level `delete_branch_on_merge` setting MUST delete the head branch of a merged pull request automatically. A protected branch MUST NOT be deleted by this setting.
- **FR10 — Contribution rules are present.** Every governed repository MUST carry the [required files](../../Ways-of-Working/Repository-Standard.md#required-files) its type declares, so a contributor arriving at the repository can act without leaving it.

### The review gate

- **FR11 — Approval comes from a different identity than the author.** Where an approving review is required, it MUST NOT be satisfiable by the identity that authored the change, nor by the workflow identity that ran its checks. See [who approves](../../Ways-of-Working/Branching-and-Merging.md#who-approves).
- **FR12 — The number of required approvals is an organization decision.** The gate's strength is set per organization and per type, and MAY be zero where the checks and the automated review are judged sufficient. It MUST be stated in configuration rather than assumed.

### Exemption

- **FR13 — Exemption is a declared type, not an absence.** A repository that cannot meet the baseline MUST declare that explicitly. Being unclassified MUST NOT be a way to escape governance.
- **FR14 — An exemption records its reason.** An exempted repository MUST carry a machine-readable reason for the exemption, so the set of exemptions can be reviewed as a list rather than rediscovered.
- **FR15 — Exemption is narrow.** An exempted repository MUST still be discoverable: it carries the repository files that let a reader and an agent understand it, even where the pull-request requirement does not apply.

### Bypass

- **FR16 — Bypass is granted to a group, never a person.** Only a named administrative group MAY bypass a protection, and the grant MUST be recorded in the same configuration as the protection itself.
- **FR17 — Bypass is attributable.** Every use of a bypass MUST be visible in the organization's audit trail, so the exception can be found after the fact.

### Reconciliation

- **FR18 — Declared and live configuration are compared continuously.** Automation MUST periodically compare each repository's live configuration against what its declared type requires, and report every difference. See [reconciliation](design.md#drift-detection-and-reconciliation).
- **FR19 — Findings are graded, not uniform.** Each difference MUST carry a severity that determines the response: refuse the change, warn on it, or record it for review.
- **FR20 — Reconciliation is idempotent.** Running it twice MUST produce the same result and MUST NOT create a second report for the same finding.
- **FR21 — A finding names its remedy.** A reported difference MUST state what is wrong, what the declared type requires, and where the rule is documented. A finding a reader cannot act on is noise.

### Non-functional

- **NFR1 — One definition per control.** A control MUST be defined once, at the organization, and MUST NOT be duplicated into repository-level configuration. Two definitions are two truths.
- **NFR2 — Self-service classification.** Changing a repository's type MUST be within the repository owner's authority and MUST take effect without an administrator editing a control.
- **NFR3 — Derivable inventory.** The set of governed repositories, their types, and their exemptions MUST be derivable from configuration and the platform API, without a maintained-by-hand list.
- **NFR4 — Auditable by diff.** Any change to which controls apply MUST be visible as a change to version-controlled configuration.
- **NFR5 — Extending is additive.** Introducing a type MUST NOT require editing the conditions of existing controls ([filter by exclusion](../../Ways-of-Working/Repository-Type-Property.md#filter-by-exclusion-not-by-inclusion)).

## Success criteria

- A newly created repository is governed by the baseline before anyone configures it.
- A repository's protections can be predicted from its type alone, without opening its settings.
- A contradictory type combination is rejected at declaration rather than producing undefined protection.
- The complete list of exempted repositories, each with its reason, is produced by a query.
- A repository whose live configuration no longer matches its declared type is reported without anyone noticing it first.
- Introducing a new repository shape adds one type value and one control, and changes no existing control's condition.

## Where this connects

- [Design](design.md) — how classification, controls, and reconciliation are built.
- [Repository Types](design-types.md) — the type catalogue, what each implies, and how types compose.
- [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) — the property mechanism and safe migration of its conditions.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md) — the files a governed repository carries.
- [Organization Standard](../../Ways-of-Working/Organization-Standard.md) — what an organization must define centrally for this to be enforceable.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — the merge models the types select between.
- [Repository Segmentation](../../Ways-of-Working/Repository-Segmentation.md) — why a repository has one shape to declare in the first place.
