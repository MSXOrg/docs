---
title: Comparative Review Orchestration
description: A repeatable playbook for reviewing a target against reference sources — establishing the frame, building the evidence model before judging, and converting findings into small scoped issues.
---

# Comparative Review Orchestration

Some reviews are not "is this correct" but "is this consistent with what we already
decided". A repository against a standard. An implementation against a sibling that
solved the same problem first. A capability against the specification it claims to
satisfy.

Run casually, that kind of review produces a long list of differences, an intuition
about which of them matter, and an umbrella issue nobody picks up. This playbook exists
so the same review yields the same structure every time, whether a human or an agent
runs it.

The target, the references, and the domain are **inputs** to the process. They are not
part of it.

## Purpose and scope

This playbook standardizes how a comparative review is framed, executed, and closed
out. In scope:

- Making the review inputs explicit **before** investigation starts.
- Converting evidence-backed findings into small, independently fixable issues.
- Separating actionable gaps from observations, open questions, and deferred work.
- Filing issues only where the finding is actionable and the owner is known.

Explicitly out of scope:

- **Implementing fixes during the review.** A review that starts fixing stops reviewing.
- **Umbrella issues** that bundle unrelated improvements.
- **Treating every difference as a defect.** A difference is a candidate finding, not a
  verdict.
- **Filing issues where there is no confirmed owner** or no required change.

## Inputs and prerequisites

Before a review starts, all of the following MUST be established:

| Input | Requirement |
| --- | --- |
| Target | The thing being reviewed, named unambiguously |
| Reference sources | What it is being compared against, and why those are authoritative |
| Comparison dimensions | The axes the comparison runs along |
| Issue destination rules | Where issues may be filed, and where they MUST NOT be |
| Access | Repository, documentation, and issue-tracker access is in hand |
| Output shape | Findings, issues, deferred observations, open questions, and a suggested dependency order |

A review that begins without the destination rules will discover, halfway through, that
its most valuable finding belongs to somebody who has not agreed to receive it.

## Workflow stages

### Stage 1 — Establish the review frame

Define, in writing:

- The target.
- The reference sources used for comparison.
- The comparison dimensions relevant to this review.
- What counts as an **actionable gap**, an **observation**, a **deferred item**, and an
  **open question**.
- Where issues may and may not be filed.

Defining the classification vocabulary *before* looking at anything is what stops it
being defined retroactively to justify whatever was found.

**Exit criteria.** The review scope names the target, the reference sources, the
comparison dimensions, and the issue destination rules.

### Stage 2 — Build the evidence model

Inspect the reference sources **before** judging the target. This ordering is the whole
method: reading the target first produces expectations shaped by what the target already
does, and every subsequent comparison confirms them.

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

A gap observed in the target is not always the target's gap.

- Inspect adjacent systems, sibling implementations, shared libraries, and process
  dependencies where they affect who owns a finding.
- Determine whether each gap belongs to the target, a shared dependency, the
  documentation, an upstream or downstream system — or to no issue at all.
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
- Enough evidence that the issue is fixable **without repeating the review** — source
  references, the affected area, the expected behavior, and how to validate the fix.
- No mega-issues, no vague cleanup tickets, and no issue whose fix requires unrelated
  work first.

**Exit criteria.** Each issue is independently actionable by one focused pull request
and carries evidence, acceptance criteria, and validation notes.

### Stage 7 — Close out

- Summarize the filed issues, the deferred observations, the accepted differences, and
  the open questions.
- Group the filed issues by likely dependency order **without** merging their scopes.
- Record why reviewed discrepancies did *not* become issues. This is the part most often
  skipped and the part that stops the next review rediscovering the same non-problems.
- Link the closeout summary to the filed issues.

**Exit criteria.** The output is traceable from source evidence to the final issue list,
and deferred items and open questions are explicit.

## Quality gates

Every one of these MUST hold at closeout:

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
- [Spec-Driven Development Templates](Spec-Driven-Development-Templates.md) — the orchestration playbook skeleton this page is an instance of.
