---
title: Advisory Agents
description: The pattern for automation that analyses work and publishes its conclusion as advice, without deciding, relabelling, or committing.
---

# Advisory Agents

Some useful automation produces a **judgement** rather than a change: whether a pull request
looks ready, whether a specification covers its requirements, whether a change carries risk
its description does not mention. The judgement is worth having and cannot be expressed as a
passing or failing check, because it is not a fact — it is an opinion, and opinions can be
wrong.

The advisory pattern exists so that such automation can be useful without becoming
authoritative.

## Advice, not authority

An advisory agent MUST publish its conclusion as advice and MUST NOT be the thing that
decides.

Concretely, it MUST NOT:

- Commit to the branch it is advising on.
- Merge, close, or approve the artifact it is advising on.
- Overwrite a decision a human has recorded.
- Re-apply a decision a human has changed.

The last two are the ones that get violated by accident. An agent that sets a label on every
run will faithfully undo the maintainer who corrected it, and it will do so without malice
and without noticing. From the maintainer's side, the correction simply does not stick, and
the reasonable conclusion is that the automation is broken and should be turned off.

So the constraint is behavioural, not just permissive: it is not enough that a human *can*
override the agent. Overriding it MUST be final.

## Seed once, never relabel

Where an advisory agent expresses its conclusion as a label, it MUST apply that label only
when no label from the same set is present, and MUST leave the set alone thereafter.

This gives the agent exactly one turn to speak. It supplies an initial assessment when there
is none — which is the case where the automation adds most, because the alternative is
nothing — and from then on the field belongs to whoever curates it.

The rule is what makes the agent safe to run repeatedly. Combined with idempotence, it means a
re-run on an artifact a human has since touched changes nothing at all.

## Idempotent by construction

An advisory agent MUST be safe to run repeatedly on the same artifact.

It will be: events fire more than once, workflows are re-run, and an artifact under active
review is re-examined many times. An agent whose output accumulates turns a busy pull request
into an unreadable one, and the noise costs more than the advice is worth.

In practice that means an agent updates its previous conclusion in place rather than adding a
new one, and says nothing when it has nothing new to say. Silence at steady state is a
feature.

## Triggering late

An advisory agent SHOULD trigger when work is declared ready rather than on every change.

Advice on unfinished work is mostly advice about the unfinished parts, and a contributor
learns to ignore it — after which the one useful comment is ignored too. Waiting until the
author says the work is ready both makes the advice relevant and makes it clear what it is
about.

Where an agent must run earlier, it SHOULD scope its advice to what is stable, and MUST NOT
present provisional findings as conclusions.

## Advice is legible

An advisory agent's output MUST make clear what it is: which agent produced it, what it
examined, and that it is advice rather than a gate.

An unattributed conclusion is indistinguishable from a requirement, and a reviewer who cannot
tell the difference either treats optional advice as blocking or treats a real constraint as
optional. Naming the source also makes the agent's own failures diagnosable: advice that is
consistently wrong is a fixable bug in the agent, but only if it is traceable to the agent.

Where advice rests on a rule, it MUST cite the documentation that carries the rule, so the
reviewer can check the rule rather than trusting the agent's summary of it. An agent MUST NOT
introduce a requirement that no documentation states — if the rule is real it belongs in
documentation, and if it is not, the agent is inventing policy.

## Composition

Several advisory agents MAY examine the same artifact, and MUST NOT depend on each other's
output or on the order in which they run.

Independence is what keeps them cheap to add and remove. A chain of advisors is a pipeline
with failure modes, and a pipeline whose stages are opinions has failure modes nobody can
debug.

Where two advisors disagree, both conclusions stand and the human resolves them. That is not
a defect in the design; disagreement between two opinions is information, and suppressing it
would mean picking a winner arbitrarily.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that advice and authority are separate.
- [Agent Interaction](agent-interaction.md) — the artifacts an advisory agent publishes onto.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — label ownership, which is what makes seed-once enforceable.
- [Review Etiquette](../../Ways-of-Working/Review-Etiquette.md) — the human review the advice feeds into.
- [AI-First Development](../../Ways-of-Working/Principles/AI-First-Development.md#4-eyes-or-n-eyes-principle) — why an automated reviewer adds eyes rather than replacing them.
