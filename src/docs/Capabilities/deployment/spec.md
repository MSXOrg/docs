---
title: Spec
description: Requirements for the deployment capability — a change to managed resources is approved together with its effect, and the approved effect is exactly what is deployed.
---

# Deployment — Spec

## Premise

Platform manages infrastructure through code. Approval covers both a code change
and its **effect** on managed resources. Before deployment, the process computes
and shows the effect on every environment in the promotion path. The team
approves the code change and all these effects as one decision. Deployment applies
exactly the approved effect to each environment.

Under **[Decision before change](../../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change)**,
review is the decision point for the source change and its resource effects.

## Problem {#problem-and-why-now}

A source diff alone does not show the effect on live resources. The same source
change can have different effects as resource state changes. A deployment that
computes a different effect after approval can make changes that no one approved.
Platform needs a deployment contract that binds approval to the deployed effect
across the full promotion path and records every action.

## Users and jobs

- **A contributor** proposes a change to managed resources. The contributor and
  reviewers need to see its exact effect before acceptance.
- **The reviewing team** decides whether the code change and its effect are
  acceptable for every environment in the promotion path.
- **An operator** needs predictable deployment, a complete action record, and a
  controlled emergency path.

## Outcomes and impact

- Deployment applies exactly the effect approved for each environment.
- The team reviews resource effects as well as code before deployment.
- Every deployment produces a complete, attributable record of its actions.

**Impact.** Approval of resource effects and complete action records support a
lower change-failure rate and shorter time to restore. Automated promotion of the
approved path supports low lead time. Domain signal: the share of deployments
whose deployed effect equals their approved effect (target 100%).

## Scope

- Changes to resources that Platform manages, expressed as code, from proposal
  through deployment across every environment in the promotion path (for
  example `dev` → `test` → `preprod` → `prod`).
- The review, approval, testing, and record-keeping around those changes.

Out of scope:

- The choice of CI/CD platform, service provider, and change engine — each
  combination is a **[design](index.md)**, not part of this contract.
- Application or runtime release — this capability governs managed resources.
- Provisioning of the state, identity, and trust the deployment relies on, which
  are prerequisites the designs assume.

## Non-goals

- A separate approval gate per environment. One approval of the code change and
  its effect on **every** environment covers the full promotion path. The
  capability adds no per-environment sign-offs to the approved change set.
- A custom deployment portal or user interface.
- Concurrent deployment of independent changes against the same resources.

## Requirements

Requirements use [BCP 14](https://www.rfc-editor.org/info/bcp14) keywords.

### FR1 — A change is expressed as code and proposed for review {#fr1}

Every change to managed resources MUST be expressed as code and proposed for
review before deployment. A change that reaches resources without review MUST
use the emergency path ([FR8](#fr8)).

### FR2 — The effect of a change is computed and shown for review {#fr2}

For each environment in the promotion path, the process MUST compute the change's
**effect on the managed resources** and show it during review. This effect
identifies what the change creates, updates, and destroys. The process MUST
compute each effect successfully before acceptance.

### FR3 — Approval covers the code change together with its effect {#fr3}

Acceptance MUST approve the code change **and** its computed effect on every
environment in the promotion path, as one decision. Approval of the code alone,
without its effect, MUST NOT satisfy this requirement.

### FR4 — The approved effect is exactly what is deployed {#fr4}

Deployment to each environment MUST carry out exactly the effect approved for
that environment. The process MUST NOT recompute the effect between approval and
deployment in a way that could change resources without approval.

### FR5 — Deployment fails closed when the approved effect is no longer valid {#fr5}

If the approved effect is invalid for an environment's current state at
deployment time, deployment MUST stop without applying a different effect. The
process MUST recompute the effect and obtain approval again, and never force the
invalid effect.

### FR6 — Changes against the same resources are serialized {#fr6}

The process MUST deploy at most one change against a given set of resources at a
time. It MUST prevent concurrent deployments against the same resources. It MUST NOT
interrupt a deployment in progress.

### FR7 — The process runs its automated tests {#fr7}

The process MUST run its defined automated tests as part of each change. A
failing required test MUST stop promotion before the next environment.

### FR8 — An audited emergency path exists {#fr8}

An emergency path MUST support deployment without the standard review. It MUST
require a recorded reason and an incident reference. It MUST restrict access to
authorized people. It MUST compute and show the effect before deployment. It MUST
open a follow-up that brings the change back through the standard path.

### FR9 — Every deployment documents the actions it took {#fr9}

Every deployment, standard or emergency, MUST record its actions in a retained,
immutable record with the following information:

- Who approved
- Who deployed
- When the deployment ran
- The target environment
- The effect applied
- The test outcomes

### FR10 — Drift is detected and surfaced {#fr10}

The process SHOULD detect divergence between real resources and recorded state
on an ongoing basis and report it for action.

### NFR1 — No standing secrets {#nfr1}

Access to managed resources MUST use short-lived, federated identity. The
repository and its automation contain no long-lived credentials or static
secrets.

### NFR2 — Least privilege separated by phase {#nfr2}

The process MUST use read-only access to compute an effect. It MUST use write
access scoped to the target environment to deploy it. The two forms of access
MUST be distinct.

### NFR3 — Per-environment identity boundary {#nfr3}

Each environment MUST have its own access identity, so an effect approved for one
environment cannot be deployed to another. Zero cross-environment deployments.

### NFR4 — Complete auditability {#nfr4}

100% of deployments, including emergency ones, MUST produce a retained,
attributable record ([FR9](#fr9)).

## Acceptance criteria

```gherkin
Feature: Deployment approves and applies the effect, not just the code

  Scenario: The whole promotion path is approved at once
    Given a change that will pass through dev, test, preprod, and prod
    When it is proposed for review
    Then the effect on the resources of each of those environments is shown for review
    And accepting the change approves the code together with all of those effects

  Scenario: The approved effect is what deploys
    Given an accepted change with an approved effect per environment
    When it is deployed to an environment
    Then the effect carried out equals the effect approved for that environment
    And the deployment records who approved, who deployed, and what changed

  Scenario: Resources moved after approval
    Given an approved effect for an environment
    And that environment's resources have changed since the effect was computed
    When the deployment runs
    Then it stops without changing resources
    And a fresh effect must be computed and approved before any deployment

  Scenario: A required test fails during promotion
    Given a change being promoted across environments
    When a required automated test fails in one environment
    Then the promotion stops before the next environment
    And the failure is recorded

  Scenario: Two changes race the same resources
    Given two accepted changes targeting the same resources
    When both attempt to deploy
    Then they deploy one after another, never concurrently
    And no deployment is interrupted partway

  Scenario: Emergency change during an incident
    Given an authorised person triggers the emergency path with a reason and an incident reference
    When the change is deployed
    Then its effect is computed and shown before it deploys
    And an attributable record is retained
    And a follow-up to reconcile the change is opened

  Scenario: No standing secrets
    Given the repository and its automation
    When they are inspected for credentials
    Then no long-lived secret is present
    And access is obtained through short-lived, per-environment identity
```

## Constraints, assumptions, and dependencies

- The change is expressed as **code**. Its effect can be computed and captured as
  an artifact before deployment.
- The **review and approval** mechanism records who approved a change and its
  effect.
- Each environment has a **record of state** that the process uses to compute an
  effect. A state change can invalidate an approved effect.
- A [design](index.md) supplies **how** the contract is delivered: the CI/CD
  platform, service provider, change engine, and identity mechanism.

## Where this connects

- [Designs](index.md) — how these requirements are delivered for a specific
  service provider and CI/CD platform.
- [Documentation Model](../../Ways-of-Working/Documentation-Model.md) — why this spec holds only the why and the what.
- [PR Format](../../Ways-of-Working/PR-Format.md) — the review that approves the change and its effect.
