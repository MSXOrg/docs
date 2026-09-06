---
title: Consumer Upgrades
description: Upgrade a consumer from its actual upstream baseline through a fixed target using complete release evidence and a compatible immutable template.
---

# Consumer Upgrades

An upgrade composes the producer's incremental release records into one verified
consumer change. Establish the consumed source, fix the target, read the complete
applicable range, and reconcile the required actions before calling the upgrade
complete. A version bump alone proves none of those steps.

## Purpose and scope

Use this procedure for a dependency, framework, Action, reusable workflow, or
other versioned product consumed by a repository. Humans and agents follow the
same stages; installing a skill is not a prerequisite. Each delivery follows the
[Contribution Workflow](Contribution-Workflow.md), and each consumer in a
[fleet](Fleet-Orchestration.md) establishes its own baseline and applicability.

Producer-owned guidance identifies authoritative source repositories, registries,
version discovery, release lineages, and applicable template records. This
playbook supplies the shared method, not initiative-specific discovery or
version-specific migration instructions.

**Out of scope**

- Downgrades, which require a separate compatibility and recovery assessment.
- Release-authoring and version-resolution policy, owned by
  [PR Format](PR-Format.md) and [Release Management](../Capabilities/release-management/design.md).
- Historical evidence repair, producer implementation, and automatic template
  synchronization. Register those gaps with their owners rather than expanding
  the consumer change.

## Inputs and prerequisites

| Input | Required | Notes |
| --- | --- | --- |
| Consumer delivery leaf and checkout | Yes | One ready Task or Bug, its intended upstream dependency, local instructions, and existing validation. |
| Producer authority | Yes | Producer-owned source/version discovery and release evidence, including the template mapping when one applies. |
| Baseline provenance | Yes | Evidence identifying what the consumer actually resolves or runs, not just its declared constraint. |
| Requested target | No | Latest stable by default; an explicit stable or prerelease target must still be an upgrade. |
| Template compatibility evidence | When applicable | The target record's template repository, full immutable commit, and compatibility evidence; otherwise an explicit no-template reason. |

## Workflow stages

### Stage 1 - Establish the actual baseline

1. Inventory every consumed reference in scope and where it is used: manifests,
   lockfiles, caller workflows, deployment configuration, and resolved execution
   records. Keep separate baselines when references consume different sources.
2. Distinguish the **consumed upstream version** from the consumer's own package
   or release version. A consumer publishing its next version does not identify
   the framework, tool, or dependency that built it.
3. Resolve each baseline to the exact upstream version and the ecosystem's
   authoritative immutable identity: a full commit SHA for Git-distributed
   source, or an artifact digest or equally immutable producer-defined identity
   for an image or package. Retain available source/artifact mappings; do not
   invent a Git SHA for a producer that distributes only artifacts. Correlate
   identity-bound release metadata with lockfiles, retained run provenance, or
   deployment records. Reconcile differences between declared, resolved, and
   deployed state; record which state is being upgraded.
4. For a floating alias or version range, recover the source that actually ran
   or was resolved in that baseline. **The alias's present destination does not
   prove its past destination.** Do not infer an old baseline from today's tag,
   the consumer's version, a timestamp, or the nearest release number. If the
   consumed identity cannot be mapped authoritatively to a release baseline,
   stop.

**Exit criteria.** Every in-scope reference has a recorded consumer location,
exact upstream baseline, immutable identity, and supporting provenance.

### Stage 2 - Fix the target and release path

1. Resolve the requested target once through the producer's authoritative
   release source: latest stable by default, or the explicit stable/prerelease
   selection. The default uses the producer's version ordering and designated
   stable lineage, not the API's first result or the most recently published
   timestamp. Record its version, release link, and immutable identity using
   the same ecosystem rule as the baseline. Do not silently retarget when a
   newer release appears.
2. Confirm the target is above the baseline under the producer's semantic
   version and lineage rules. A non-latest target is valid only when it is still
   an upgrade. An identical version/source is already current, not a fabricated
   upgrade; a lower target belongs to a separate downgrade task. Record either
   outcome and stop that upgrade path rather than continuing with an invalid
   range.
3. Enumerate the release history with **full pagination**, following every page
   to exhaustion. Establish the applicable path from each baseline to the fixed
   target using the records' consumer-change/source baselines. The
   version-computation base is not a substitute for that path.
4. Order the applicable releases semantically within that lineage, never by API
   order, publication timestamp, or string sorting. Inspect every release in
   **(baseline, target]**: baseline-exclusive and target-inclusive. Include
   explicit no-action releases; exclude unrelated backports and prerelease
   streams rather than merging them into a chronological list.
5. For prerelease baselines, prerelease targets, and promotion to stable, use
   records bound to those actual sources. Establish which prerelease increments
   belong to the selected path and how any stable roll-up covers them. Do not
   apply a delta twice or substitute the later final PR body for a prerelease
   snapshot.

For an older target, read immutable target-era source and documentation together
with its source-bound release records. Today's documentation, template, or
`latest` alias cannot establish what that target supports.

**Exit criteria.** The target is fixed, and the complete ordered release set and
its lineage are evidenced. An unexplained gap, missing page, unavailable required
source or artifact evidence, or ambiguous release relationship blocks traversal.

### Stage 3 - Compose the action ledger

Read each applicable record in full, including adoption instructions,
consumer-change evidence, prerequisites, no-action outcomes, and template
compatibility. [PR Format](PR-Format.md#consumer-change-record) owns the MSX
authoring structure; this ledger consumes it rather than defining another
release schema.

1. Associate each release/change identifier with the consumer surfaces it
   affects. Record applicability against the actual baseline and intended use,
   the required action or final state, prerequisite ordering, and the existing
   validation that can demonstrate the result.
2. Compose changes across the range. Follow rename chains to the target name;
   reconcile superseded or reversed changes against the target contract. Keep
   the earlier entries and links explaining their disposition instead of
   deleting evidence.
3. Retain genuinely required intermediate operations, such as a data conversion
   or a tool that only accepts the preceding format. A later rename or reversal
   does not cancel a required intermediate step. Skip a transient edit only when
   the evidence establishes that direct adoption reaches the supported target
   state without it.
4. Give every inspected release and affected action an explicit disposition:
   completed with evidence, not applicable with a reason, no action required,
   or blocked with the missing decision/evidence and owning issue. A no-action
   release still has a ledger entry; silence is not a no-action declaration.

An external producer may supply equivalent authoritative release notes,
changelogs, migration documentation, or maintainer evidence without MSX
headings or tables. Accept the evidence when it establishes the same source
range, applicability, actions, and applicable template compatibility. Source
diffs corroborate those facts; they do not justify inventing missing migration
instructions.

**Exit criteria.** Every crossed release is accounted for, actions compose to
the target contract, and no required action or prerequisite remains ambiguous.

### Stage 4 - Reconcile the template and apply the change

1. Resolve the template from the **target's recorded compatible baseline**, not
   the template's default branch or latest commit. Read that immutable commit
   and its evidence against the selected producer identity. A reused earlier
   template commit is valid when that compatibility is evidenced.
2. Compare the consumer with that template, separating **required integration
   surfaces**, **optional scaffolding**, and **intentional local differences**.
   Relate required differences to the ledger: caller inputs, configuration,
   permissions, secret names, runtime/tool requirements, or other supported
   interfaces. An unexplained incompatibility is a blocker, not permission to
   replace a file.
3. Where no template applies, record that fact and why. An absent or unverified
   template for a product that does have one is missing evidence, not a
   no-template result.
4. Apply the composed actions and select the target using existing ecosystem
   tooling and the applicable reference policy. Preserve consumer-owned code,
   tests, configuration intent, secrets, documentation, and assets. Make only
   the necessary integration edits; **never copy a template wholesale**.
   Record secret names and provisioning obligations, never secret values.

**Exit criteria.** The consumer selects the fixed target, every required edit
and intermediate operation is applied, and the template comparison explains
what changed, what stayed local, and what does not apply.

### Stage 5 - Validate and reconcile

1. Run the consumer's existing relevant tests, builds, linting, and integration
   checks for the affected surfaces. Verify the upstream immutable identity
   those runs actually used; a floating reference must not validate a different
   source or artifact from the recorded target.
2. Reconcile every ledger entry with the final consumer diff and observable
   results. Confirm rename endpoints, required intermediate operations, and
   preserved local behavior, not just the dependency version.
3. Validate no-action ranges too. When reference selection is the only edit,
   record that outcome and the relevant checks; neither a patch label nor an
   unchanged configuration proves compatibility.
4. Separate introduced failures from pre-existing failures with evidence and
   register the owning gaps. Do not suppress a failing relevant check or claim
   an unrun check passed. Unresolved required validation blocks readiness.

**Exit criteria.** Existing relevant validation demonstrates the target state,
every ledger disposition is supported, and no required action or validation
remains blocked.

### Stage 6 - Hand off and complete

Carry the [outputs and evidence](#outputs-and-evidence) into the upgrade PR,
using the existing [PR Format](PR-Format.md#description-structure). Keep the
consumer's own release decision separate from the upstream target selection;
classify its supported audience impact through that standard.

Follow the ordinary review loop and
[Definition of Ready and Done](Definition-of-Ready-and-Done.md). Review
readiness, merge, publication, and applicable template delivery are separate
milestones. A merged reference bump is not proof of the other milestones.

**Exit criteria.** The reviewed consumer change is merged, required publication
or deployment is evidenced where applicable, and the completion gate holds.
Before then, the issue and PR report the actual milestone and any blocker.

## Quality gates

| Condition | Required response |
| --- | --- |
| Baseline provenance, release lineage, complete evidence, or a required action cannot be established | Stop the affected upgrade and register the gap with its producer or evidence owner; link it from the consumer issue and PR. |
| An applicable template identity or compatibility result is missing | Block affected work until immutable compatible evidence exists; do not substitute today's template. |
| Baseline, chosen target, consumer intent, or source-bound evidence changes | Return to the affected stage and reconcile downstream evidence again; do not silently reuse the old ledger or validation. |
| Required work belongs elsewhere | Link the owning delivery issue and keep the consumer blocked when it needs that outcome. A follow-up does not make a necessary action optional. |
| Another consumer can proceed independently | Continue its separate delivery; do not infer its baseline or applicability from the blocked consumer. |

## Outputs and evidence

Keep progress and decisions in the delivery issue and upgrade PR, not a migration
history file in product documentation. The PR retains:

- Exact baseline-to-target ranges for all in-scope references, authoritative
  immutable identities and available source/artifact mappings, baseline
  provenance, and the fixed target selection.
- The complete ordered release links and source-bound records inspected,
  including no-action releases and evidence for lineage exclusions or roll-ups.
- The reconciled ledger: completed and not-applicable actions with reasons,
  required intermediate steps, explicit no-action results, and unresolved
  blockers with owning issues.
- The target-template identity and compatibility evidence, required versus
  optional differences, preserved local choices, and linked template work;
  alternatively, the justified no-template result.
- Existing validation commands/runs and outcomes bound to the tested sources,
  plus the actual review, merge, publication, and completion state.

## Canonical references

- [PR Format](PR-Format.md) - audience-based classification and incremental consumer evidence.
- [Release Management](../Capabilities/release-management/design.md#release-notes) - source-bound publication records and immutable identities.
- [Definition of Ready and Done](Definition-of-Ready-and-Done.md) - consumer-evidence readiness and producer/template completion.
- [Documentation Model](Documentation-Model.md) - current product guidance versus delivery and release history.
- [Fleet Orchestration](Fleet-Orchestration.md) - independent consumer deliveries coordinated across repositories.
- [Plugin Marketplaces](../Capabilities/agentic-development/design-plugin-marketplaces.md) - shared procedure pointers and producer-owned discovery.
