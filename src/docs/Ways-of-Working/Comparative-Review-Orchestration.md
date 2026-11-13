---
title: Comparative Review Orchestration
description: Comparative reviews use source evidence to separate required changes from accepted differences and file focused issues.
---

# Comparative Review Orchestration

A comparative review compares a target with authoritative reference sources.
Examples include a repository against a standard, an implementation against a
sibling implementation, or a capability against its specification.

Humans and agents use the same evidence process to produce small, independently
actionable issues. Source evidence distinguishes required changes from accepted
differences.

The target, references, and domain are **inputs**. The process does not depend
on a particular target or domain.

## Purpose and scope

A comparative review includes:

- Explicit review inputs **before** investigation starts.
- Small, independently fixable issues based on evidence.
- A distinction between actionable gaps, observations, open questions, and deferred work.
- Issues filed only where the finding is actionable and the owner is known.

Explicitly out of scope:

- **Implementing fixes during the review.** Implementation is separate from review.
- **Umbrella issues** that bundle unrelated improvements.
- **Treating every difference as a defect.** A difference is a candidate finding, not a
  verdict.
- **Filing issues where there is no confirmed owner** or no required change.

## Inputs and prerequisites

Before a review starts, the reviewer MUST establish each input:

| Input | Requirement |
| --- | --- |
| Target | The exact subject of the review |
| Reference sources | What it is being compared against, and why those are authoritative |
| Comparison dimensions | The aspects being compared |
| Issue destination rules | Where issues may be filed, and where they MUST NOT be |
| Access | Repository, documentation, and issue-tracker access is available |
| Output shape | Findings, issues, deferred observations, open questions, and a suggested dependency order |

Destination rules establish owners before investigation. Without them, a review
can produce findings for an owner who has not agreed to receive them.

## Workflow stages

### Stage 1 — Establish the review frame

Define, in writing:

- The target.
- The reference sources used for comparison.
- The comparison dimensions relevant to this review.
- What counts as an **actionable gap**, an **observation**, a **deferred item**, and an
  **open question**.
- Where issues may and may not be filed.

Define the classification vocabulary **before** investigation. This prevents
changes to the categories just to justify the findings.

**Exit criteria.** The review scope names the target, the reference sources, the
comparison dimensions, and the issue destination rules.

### Stage 2 — Build the evidence model

Inspect the reference sources **before** judging the target. This keeps source
expectations independent of the target's existing behavior.

- Extract expectations, patterns, constraints, and invariants from the authoritative
  sources.
- Record a source reference for **every** expectation.
- Exclude any expectation that cannot be tied to source evidence or an accepted
  practice. An expectation without a source is a preference.

**Exit criteria.** Evidence-backed expectations are written down, each with its source
reference.

### Stage 3 — Review the target

- Compare the target against the evidence-backed expectations.
- Record gaps, matching behavior, uncertainties, and relevant context.
- Classify each candidate finding by impact, owner, implementation boundary, and likely
  fix size.
- Discard findings that are speculative, cosmetic, or outside the frame.

**Exit criteria.** Candidate findings are evidence-backed and either scoped to an owner
or explicitly marked unresolved.

### Stage 4 — Check adjacent systems and shared dependencies

The component where a gap is observed does not necessarily own the gap.

- Inspect adjacent systems, sibling implementations, shared libraries, and process
  dependencies where they affect who owns a finding.
- Determine whether each gap belongs to the target, a shared dependency,
  documentation, or an upstream or downstream system.
  Record when no issue is required.
- Keep contextual observations out of the issue text unless they directly explain the
  required change.

**Exit criteria.** Each candidate finding is assigned to the smallest valid
implementation or documentation boundary.

### Stage 5 — Reconcile

- Compare the target's assumptions against the reference expectations and the adjacent
  constraints.
- Mark each discrepancy as an actionable gap, a documentation gap, an implementation
  gap, an accepted difference, a deferred observation, or an open question.
- Resolve ownership before filing anything outside the target.

**Exit criteria.** Every discrepancy carries a classification and either an owner, a
deferral reason, or an open question.

### Stage 6 — File surgical issues

- One issue per independent improvement.
- Solution-agnostic acceptance criteria, per [Issue Format](Issues/Process/Format.md).
- Include source references, the affected area, expected behavior, and a validation method.
  The issue is fixable **without repeating the review**.
- Do not combine unrelated work in one issue.
  Do not file vague cleanup tickets or issues whose fixes require unrelated work first.

**Exit criteria.** Each issue is independently actionable by one focused pull request
and carries evidence, acceptance criteria, and validation notes.

### Stage 7 — Close out

- Summarize the filed issues, the deferred observations, the accepted differences, and
  the open questions.
- Group the filed issues by likely dependency order **without** merging their scopes.
- Record why reviewed discrepancies did *not* become issues. This prevents repeated
  review of the same accepted differences.
- Link the closeout summary to the filed issues.

**Exit criteria.** The output is traceable from source evidence to the final issue list,
and deferred items and open questions are explicit.

## Quality gates

Each of these MUST hold at closeout:

- No finding is actionable without source evidence or observed target behavior.
- No issue bundles unrelated improvements.
- No issue is filed outside an owning repository unless ownership is confirmed.
- No recommendation relies on an unverified API, field, method, or contract.
- The closeout summary distinguishes filed work, accepted differences, deferred
  observations, and open questions.

## Outputs and evidence

- A review scope statement — target, reference sources, comparison dimensions, issue
  destination rules.
- An evidence table linking each expectation to its source.
- Filed issues, one per surgical improvement.
- A deferred-observation list, with reasons.
- An accepted-difference list, with rationale.
- An open-question list, with a suggested owner or next step.
- A suggested dependency order for the follow-up pull requests.

## Where this connects

- [Issue Format](Issues/Process/Format.md) — the shape every filed issue takes.
- [Issue Planning](Issues/Process/Planning.md) — how the filed issues are sized and ordered afterwards.
- [Definition of Ready and Done](Definition-of-Ready-and-Done.md) — the readiness bar a filed issue must clear.
- [Review Etiquette](Review-Etiquette.md) — the tone and severity conventions the findings are written in.
- [Spec-Driven Development Templates](Spec-Driven-Development-Templates.md) — the canonical orchestration playbook structure.
