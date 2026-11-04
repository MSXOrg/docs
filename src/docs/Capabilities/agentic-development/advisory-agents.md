---
title: Advisory Agents
description: The pattern for automation that analyzes work and publishes its conclusion as advice, without deciding, relabeling, or committing.
---

# Advisory Agents

An advisory agent assesses work and publishes a **judgment**, not a change. It can assess
pull-request readiness, requirement coverage, or risks that a description omits. These
assessments are opinions that can be wrong. They do not establish a passing or failing
factual check.

The advisory pattern keeps these assessments useful without giving them decision authority.

## Advice, not authority

An advisory agent MUST publish its conclusion as advice and MUST NOT decide the artifact's
outcome.

Concretely, it MUST NOT:

- Commit to the branch it is advising on.
- Merge, close, or approve the artifact it is advising on.
- Overwrite a decision a human has recorded.
- Re-apply a decision a human has changed.

A repeated label update can overwrite a maintainer's correction. The agent can repeat this
action without recognizing that a human changed the decision. The maintainer then loses
control of the recorded decision.

The constraint is behavioral, not only a permission setting: a human override MUST be final.

## Seed once, never relabel

For label-based advice, the agent MUST apply its label only when no label from the same set
is present. It MUST leave the set unchanged thereafter.

The agent supplies an initial assessment only when no label from the set exists.
Later updates remain outside that assessment.

On repeated runs, the agent leaves an existing label unchanged, including a label corrected
by a human.

## Idempotent by construction

An advisory agent MUST be safe to run repeatedly on the same artifact.

Events can occur more than once. Contributors can rerun workflows or request another review
of the same artifact. Duplicate advice makes the review harder to read.

The agent updates its previous conclusion in place instead of adding duplicate advice.
If the conclusion has not changed, it publishes no update.

## Triggering late

An advisory agent SHOULD trigger when work is declared ready rather than on every change.

Feedback on unfinished parts can become irrelevant before review. Contributors can then
ignore later advice, including useful findings. A readiness signal identifies the work the
author considers complete.

If an agent must run before readiness, it SHOULD limit advice to stable work. It MUST NOT
present provisional findings as conclusions.

## Advice is legible

An advisory agent's output MUST identify which agent produced it, what it examined, and its
status as advice rather than a gate.

Without attribution, reviewers can confuse advice with a requirement. Attribution also lets
maintainers trace incorrect advice to its source and correct the agent.

When advice depends on a rule, it MUST cite the documentation that states that rule.
The reviewer can then verify the source instead of relying on the agent's summary.
An agent MUST NOT introduce a requirement that no documentation states. A required rule
belongs in the documentation.

## Composition

Several advisory agents MAY examine the same artifact. They MUST NOT depend on each other's
output or execution order.

Maintainers can add or remove independent agents without changing other agents. If one opinion
depends on another, failures can become difficult to isolate.

If advisors disagree, both conclusions remain available and a human resolves the disagreement.
Suppressing one opinion would hide evidence from that review.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that advice and authority are separate.
- [Agent Interaction](agent-interaction.md) — the artifacts an advisory agent publishes onto.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — label ownership, which is what makes seed-once enforceable.
- [Review Etiquette](../../Ways-of-Working/Review-Etiquette.md) — the human review the advice feeds into.
- [AI-First Development](../../Ways-of-Working/Principles/AI-First-Development.md#4-eyes-or-n-eyes-principle) — why an automated reviewer adds eyes rather than replacing them.
