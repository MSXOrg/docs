---
title: PR Format
description: Audience-first pull request titles and descriptions with evidence-based, conditional release decisions.
---

# PR Format

A pull request title and description are release-note-ready artifacts. They
explain one complete change to the people who use what the repository delivers,
while carrying the evidence reviewers and maintainers need.

The release-bound title and complete description author the eventual release
note. Published release records are the consumer's sufficient upgrade history:
what changed, why, who is affected, compatibility, and exactly how to adopt each
release, including an explicit no-action result when applicable. PRs and diffs
provide optional depth, not required instructions missing from the notes.

Consumers read every applicable release after their actual consumed baseline
through the chosen target in release order and compose the necessary actions.
Reading those records does not require installing every intermediate version;
an intermediate installation or run is required only when a note explicitly
requires it. [Resource documentation](Documentation-Model.md#current-product-guidance-and-release-history)
describes supported target-state behavior and usage, not release-specific
transitions or history.

This page owns the title and description format. The
[Contribution Workflow](Contribution-Workflow.md) owns draft, assignment,
review, and handoff mechanics; [Branching and Merging](Branching-and-Merging.md)
owns branches, commits, and integration.

## Analyze before writing

Write from evidence, not from the branch name, commit messages, or the existing
pull request text. Those surfaces are useful leads, but the complete change is
the source.

### Identify the readers

Start with the repository [README audience
declaration](Readme-Driven-Context.md#target-audience), then inspect linked user
documentation, capability specifications, and effective configuration.

Treat every supported interface as reader-facing when someone depends on it.
Commands, APIs, configuration, reusable workflows, Actions, templates, and
published guidance can all be the product. Do not classify an integration as
internal merely because its readers write scripts or maintain another product.

For documentation-only work, the delivered result is guidance. State what a
reader can now understand or do; do not present documentation as product
behavior that the change did not implement.

### Resolve release coverage first

For a release-bound record, establish the artifact-to-candidate range before
inspecting a scoped PR diff or writing the title, classified results, adoption
actions, or compatibility decision. The
[actual publication route](../Capabilities/release-management/design.md#applicability)
determines the product, publishing target, and stable/prerelease channel.
Native producers participate even when they do not call a named shared workflow.
If a record serves several artifact targets or channels, resolve each
consumer-publication baseline independently and state each result's
applicability. A metadata-only mirror's completion does not replace the actual
artifact target's publication baseline.

1. **Find the actual publication baseline.** Inspect the target's authoritative
   publication inventory and successful-publication receipts for that same
   product, target, and channel. Establish which artifact was last successfully
   published from publication evidence, not an assumed highest version.
   GitHub's Latest hint and moving tags may aid discovery but are not proof;
   a failed run alone is not a published artifact.
2. **Verify its immutable source.** Read back the artifact identity and retained
   provenance linking it to the exact source tree. Pin the artifact version or
   digest, publication evidence, source repository, and full source identity.
   For module publication, PowerShell Gallery success counts even when later
   GitHub completion fails. Completing that older GitHub record does not make
   its already-published module changes new again.
3. **Pin the exact candidate.** Record the candidate PR source repository and
   full immutable source identity. Do not compare a moving branch name, tag,
   latest commit selected later, or a different build's source.
4. **Verify the comparison.** Check that the published and candidate sources
   belong to the intended publication lineage. Compare those two source trees,
   for example with `git diff <published-source> <candidate-source>`, and retain
   the comparison evidence. A scoped PR-base diff or substituted merge base
   does not define this boundary.
5. **Inventory the complete delivered range.** Inspect every consumer-facing
   change in that comparison, including earlier merged, skipped, or otherwise
   unshipped changes. Use this inventory for the title, ordered result groups,
   complete adoption actions, and compatibility decision. Do not classify a
   change as new merely because an older publication record finished later.

Record these identities in the applicable result's supporting evidence:

| Field | Evidence |
| --- | --- |
| Product scope | Product, publishing target, and channel whose consumers receive the artifact. |
| Published artifact | Actual latest successful artifact identity and publication receipt; explicitly no predecessor only for a verified initial publication. |
| Published source | Source repository, full immutable source identity, and verified artifact-to-source provenance. |
| Candidate source | Exact candidate source repository and full immutable identity reviewed for this record. |
| Scoped PR comparison | PR base and candidate source identities, retained separately for implementation and reviewer evidence. |

Missing or unverifiable publication/source evidence is an unresolved coverage
gap, not a no-action result or proof of patch compatibility. If no predecessor
exists, verify and record initial publication and review the whole candidate's
supported consumer surface and initial adoption instructions instead of
inventing a previous artifact or treating `0.0.0` as a consumed release. A
version-computation baseline does not establish consumer history.

Resolve diverged lineage or an ambiguous target/channel before making coverage
claims; do not silently choose another release, branch, or merge base. Re-read
the publication baseline and candidate before readiness and release-bound
snapshot capture. If either identity changes, refresh the comparison,
inventory, instructions, and compatibility evidence; the older analysis does
not validate the new pair.

#### Coverage counterexamples

| Evidence | Release-bound coverage | Scoped PR evidence |
| --- | --- | --- |
| Artifact source A is published; B merges a new input without publication; candidate C adds a fix. | A-to-C includes B's new input and C's fix, even if B was skipped. | B-to-C describes only the current PR's implementation. |
| Module source B is successfully published to Gallery, but its GitHub completion fails; candidate C follows. | B-to-C describes only changes not already published to module consumers. Later GitHub completion of B does not reintroduce A-to-B as new. | The current PR diff remains separate; GitHub's older Latest hint is not the module baseline. |

A, B, and C represent pinned immutable source identities, not moving refs.
These cases establish authoring scope, not a new publisher or version resolver.

### Read the whole change

For a release-bound record, inspect the complete
[resolved publication-to-candidate comparison](#resolve-release-coverage-first).
A promotion or bundled release retains every applicable consumer delta, not
just the latest commit or pull request.

Inspect the ordinary base-to-head PR diff separately to establish the scoped
implementation, validation, Task/Bug plan progress, and issue-convergence
evidence reviewers need. It does not replace the release-note coverage range
or make earlier work part of this PR's implementation. When no release-bound
artifact record applies, this scoped diff supplies the PR's change coverage;
do not manufacture a publication baseline or release metadata.

Check claims against the changed public interfaces, documentation,
configuration, tests, and generated output. Commit messages and an earlier pull
request description may be incomplete or stale and never replace this check.

### Keep claims accurate

State only outcomes the evidence supports:

- Describe a dependency update's behavior or security benefit only when upstream
  notes, tests, or product evidence establish that result.
- Describe documentation work as changed guidance unless the same change also
  changes the documented product.
- Distinguish a public contract change from the internal implementation that
  delivers it.
- Check affected supported uses for compatibility, prerequisites, and exact
  adoption actions, including required ordering or intermediate operations.
- State an explicit no-action result and its compatibility basis when adoption
  needs no consumer change beyond selecting the release reference.
- Treat missing applicability or migration instructions as an evidence gap to
  resolve in the note, not a reason to send consumers to PRs, diffs, or
  historical product docs.

### Resolve release decisions

Before adding release metadata or changing a `release:*` label, determine
whether the repository invokes [Release
Management](../Capabilities/release-management/spec.md) for the pull request's
target route. Inspect the effective pipeline and its inputs, including native
producer pipelines that publish versioned artifacts without calling a named
shared workflow. The [applicability contract](../Capabilities/release-management/design.md#applicability)
is about the route's release behavior, not one implementation. The optional
`.github/release.config.yml` file refines the route's settings; its absence alone
does not prove that release management is absent.

Verify the immutable producer revision's supported settings and owned-label
mapping before using the canonical signals below. A native producer participates
in the contract but does not gain support for those signals from this
documentation alone. If its released interface differs, require a verified
adapter or a producer/configuration migration with complete adoption actions in
that producer's PR/release record. Hold finalization until the effective mapping
and required decision check are verified; do not apply a label the pipeline
ignores, silently translate it, or classify an incompatible producer as unmanaged.

If the route does not invoke Release Management, omit the entire `Release
decisions` block and do not apply or report any `release:*` label, including
`release:skip`.

If the route does invoke Release Management, resolve these decisions from the
complete [delivered consumer range](#resolve-release-coverage-first) and the effective
[configuration](../Capabilities/release-management/design.md#configuration-surface):

1. **Release or skip.** Release when the change affects the versioned artifact
   or a supported consumer contract. Otherwise select `release:skip`.
2. **Version bump.** For a release, choose Patch, Minor, or Major from the
   compatibility impact. An explicit bump label overrides a valid
   effective `DefaultBump`; a matching default supplies the level without a
   per-PR bump label. Resolve the documented shared default, repository settings,
   and supported caller overrides under
   [settings and caller overrides](../Capabilities/release-management/design.md#settings-and-caller-overrides).
3. **Mode.** Record Stable or Prerelease from the target route and any valid
   `release:prerelease` override. Identify a configured release-candidate route
   in the mode evidence; release candidates are prereleases, not another bump.

Use only the labels owned by the
[`release:` namespace](Automation-Labels.md#every-set-is-namespaced). Missing,
invalid, or conflicting decisions are errors to resolve before review, not
reasons to invent a fallback. Inheriting the documented patch default is a valid
decision source, not an error recovery path.

### Select the news

Keep the summary and named sections focused on results that matter to the
identified readers without omitting a consumer delta or required action. Put
implementation facts, validation, and process evidence in supporting details.
Omit internal facts that neither explain a reader-facing result nor help review
it.

Internal-only work can still have a clear result, such as a shared automation
configuration. When it has no reader-facing classified section, summarize the
result and put necessary supporting blocks directly after the summary marker.

### Group related changes

Group changes by audience-facing result or affected interface, not by commit,
file, issue, or implementation step. One section may describe several files
that jointly deliver one result. Separate unrelated reader outcomes into their
own sections and classify each result once.

## Write the title

Use one short statement of the most important user-facing result. For a
release-bound record, choose it from the complete resolved delivered range,
not only the scoped PR implementation:

```text
LLM Gateway streaming requests report usage
```

For internal-only work, name the operational result:

```text
Release automation uses a shared configuration
```

The title must not contain:

- an icon or type prefix;
- a Conventional Commit prefix such as `feat:` or `docs:`;
- an issue reference;
- a list of unrelated changes;
- AI or agent attribution;
- an implementation detail when a reader-facing result is available.

## Write the description

The description stands on its own for a reader who has not inspected the diff.
Use the following structure.

### Summarize the result

Start with one or two short paragraphs and no `Summary` heading. Lead with
required action and breaking impact when either exists. A short unordered list
is acceptable only when the change has several distinct result groups that
cannot be stated clearly in prose.

Use the vocabulary of the supported interface. Describe what changes, who is
affected, and what they need to do. Keep implementation narration out of the
summary.

### End the shareable summary

End the summary with the exact HTML marker shown in the
[complete template](#copy-the-complete-template).

The marker appears exactly once, on its own line, outside a code fence, and
before the first detailed section. Text before it must remain useful when shared
without the rest of the description.

### Explain each reader-facing result

Use these classifiers in this order and omit empty groups:

1. `## Breaking: <result>`
2. `## Removed: <result>`
3. `## New: <result>`
4. `## Changed: <result>`
5. `## Fixed: <result>`

| Classifier | Use when |
| --- | --- |
| `Breaking` | A supported consumer must act or an existing supported use becomes incompatible. |
| `Removed` | A supported capability, interface, or documented path is no longer available. |
| `New` | Readers gain a capability, interface, or body of guidance. |
| `Changed` | Existing behavior, configuration, or guidance changes compatibly. |
| `Fixed` | An incorrect behavior or guidance now works as intended. |

Each section heading states one result, not a component name. Open the section
with one or two prose paragraphs that explain what changes, why, affected
supported uses, compatibility, and exact adoption actions or an explicit
no-action result. Include applicable prerequisites, verification, and ordering
constraints. A later release that supersedes an earlier action explains how
consumers compose the remaining actions through its target; preserve any
required intermediate installation or run. A documentation change uses the
classifier that describes what its guidance now provides.

### Show interfaces after the prose

After the opening prose, add an interface example or compact table only when it
makes the reader's action clearer. Do not lead a section with a code block or
table. Include necessary old-to-new examples, before-and-after comparisons, or
diagrams in the note itself when they explain an applicable transition. Keep
release-specific migration details here; evergreen resource docs show supported
usage without accumulating those transitions.

Link optional usage documentation using an absolute default-branch URL or the
canonical published URL so the link survives when the pull request becomes a
release record. Such links supplement the note; consumers must not need them to
discover required upgrade actions. Never include secret values.

### Close each section with supporting details

A named section may end with either or both of these optional blocks, in this
order:

```markdown
<details>
<summary>Technical details</summary>

Implementation and validation evidence for this result.

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- Depends on MSXOrg/other-repository#456

</details>
```

The blocks are section-scoped. Do not add global catch-all `Technical details`
or `Related references` blocks after several classified sections. If the pull
request is internal-only and has no classified section, place its supporting
blocks directly after the summary marker.

Put the standards and framework alignment evidence required by
[Implement](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass)
in the `Technical details` block for the result it supports. For a
release-managed result, include the applicable consumer, template, and baseline
evidence required by [Release
Management](../Capabilities/release-management/spec.md#release-evidence) in that
same scoped block. Keep the consumer's instructions in the result's prose and
examples; the supporting evidence verifies those instructions rather than
replacing them.

Include the [publication-baseline and candidate
identities](#resolve-release-coverage-first), comparison, and freshness evidence
for a release-bound result. Identify the scoped PR-base comparison separately;
it supports implementation review, not release-note coverage.

Record the closing delivery leaf's implementation-plan progress and the
[issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep)
search scope and outcome in that same block, including when no additional issue
converges. For internal-only work without classified sections, the block after
the summary marker carries this evidence and any applicable release evidence.

Use fully qualified `owner/repository#number` references for every same-instance
GitHub issue or pull request, including references to the current repository.
Use closing keywords only for issues the complete change actually resolves.
Prefix non-closing relationships with terms such as `References`, `Depends on`,
or `Followed by`. Use absolute Markdown links for Jira, cross-instance GitHub,
and references that will render outside GitHub.

Do not include AI or agent attribution anywhere in the description.

### Record release decisions only when invoked

When the target route invokes Release Management, add one `Release decisions`
block after the classified sections and apply the exact labels the block
reports:

```markdown
<details>
<summary>Release decisions</summary>

- **Release:** Yes - the delivered artifact and supported caller contract change.
- **Version bump:** Minor - callers gain a compatible optional input.
- **Mode:** Stable - the target route publishes stable releases.
- **Labels:** `release:minor`

</details>
```

For a no-release decision, include only the decision and its label:

```markdown
<details>
<summary>Release decisions</summary>

- **Release:** No - the change does not affect the artifact or its supported consumer contracts.
- **Labels:** `release:skip`

</details>
```

The evidence after each decision must identify the applicable route,
configuration, and audience impact. List the exact resulting labels, or `None`
when effective configuration supplies the release decision and no override
label applies. Do not predict the final version; Release Management resolves it
from the actual base.

When the target route does not invoke Release Management, omit this block and
all `release:*` labels. Do not add `release:skip` merely because the repository
has no `.github/release.config.yml`.

### Assemble the body

Use this order:

1. Summary prose.
2. The shareable-summary marker.
3. Classified sections in the required order, each with its own optional
   `Technical details` and `Related references` blocks.
4. Supporting blocks directly after the marker only when internal-only work has
   no classified section.
5. The conditional `Release decisions` block, only when the target route
   invokes Release Management.

Do not add a `Summary` heading, empty classified sections, global supporting
blocks, or parallel release-note metadata.

### Copy the complete template

Start from this complete body. Replace every placeholder and delete every
classifier section, supporting block, example, or release field that does not
apply. Repeat a complete classifier section when several distinct results share
the same classifier, and keep every remaining classifier group in the order
shown.

For internal-only work with no classified result, delete all five classifier
groups and place one applicable `Technical details` block and `Related
references` block directly after the marker. Delete the complete `Release
decisions` block when the target route does not invoke Release Management. On an
invoked route with a no-release decision, replace the release block with the
shorter no-release form shown in
[Record release decisions only when invoked](#record-release-decisions-only-when-invoked).

For a publishing decision, retain the resolved bump and mode with their input
sources. A valid effective `DefaultBump` needs no per-PR bump label: report
`Labels: None` when no owned override applies, or the exact mode label when it
does. Include configured release-candidate routing in the mode evidence. Never
turn invalid settings or conflicting owned labels into a no-action result.

````markdown
{{ One or two short summary paragraphs that state what changes, why, who is
affected, and required adoption actions or an explicit no-action result. }}

<!-- ANNOUNCEMENT STOP -->

## Breaking: {{ Reader-facing result }}

{{ Explain what changes, why, affected supported uses, compatibility, and exact
adoption actions or an explicit no-action result. Include applicable
prerequisites, verification, ordering, and any required intermediate installation
or run. }}

{{ Interface or old-to-new example, comparison, or diagram after the prose when
needed to make adoption unambiguous. Keep required transition details in this
note; link to evergreen usage docs only for optional depth. Delete when prose
is sufficient. }}

<details>
<summary>Technical details</summary>

{{ Implementation and validation evidence, closing delivery-leaf plan progress,
and issue-convergence search scope and outcome for this result, even when no
additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ Publication-baseline evidence: for a release-bound result, identify the
product/target/channel, latest successful artifact and immutable source, exact
candidate source, comparison, and freshness under Resolve release coverage
first. Retain the scoped PR-base comparison separately. Support the actions or
no-action result above. For an affected integration template, identify its
repository, verified compatible immutable commit, and compatibility evidence.
Publication resolves actual coordinates; do not predict a final version.
Delete inapplicable evidence. }}

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- References MSXOrg/repository#456
- Depends on MSXOrg/other-repository#789

</details>

## Removed: {{ Reader-facing result }}

{{ Explain what changes, why, affected supported uses, compatibility, and exact
adoption actions or an explicit no-action result. Include applicable
prerequisites, verification, ordering, and any required intermediate installation
or run. }}

{{ Interface or old-to-new example, comparison, or diagram after the prose when
needed to make adoption unambiguous. Keep required transition details in this
note; link to evergreen usage docs only for optional depth. Delete when prose
is sufficient. }}

<details>
<summary>Technical details</summary>

{{ Implementation and validation evidence, closing delivery-leaf plan progress,
and issue-convergence search scope and outcome for this result, even when no
additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ Publication-baseline evidence: for a release-bound result, identify the
product/target/channel, latest successful artifact and immutable source, exact
candidate source, comparison, and freshness under Resolve release coverage
first. Retain the scoped PR-base comparison separately. Support the actions or
no-action result above. For an affected integration template, identify its
repository, verified compatible immutable commit, and compatibility evidence.
Publication resolves actual coordinates; do not predict a final version.
Delete inapplicable evidence. }}

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- References MSXOrg/repository#456
- Depends on MSXOrg/other-repository#789

</details>

## New: {{ Reader-facing result }}

{{ Explain what changes, why, affected supported uses, compatibility, and exact
adoption actions or an explicit no-action result. Include applicable
prerequisites, verification, ordering, and any required intermediate installation
or run. }}

{{ Interface or old-to-new example, comparison, or diagram after the prose when
needed to make adoption unambiguous. Keep required transition details in this
note; link to evergreen usage docs only for optional depth. Delete when prose
is sufficient. }}

<details>
<summary>Technical details</summary>

{{ Implementation and validation evidence, closing delivery-leaf plan progress,
and issue-convergence search scope and outcome for this result, even when no
additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ Publication-baseline evidence: for a release-bound result, identify the
product/target/channel, latest successful artifact and immutable source, exact
candidate source, comparison, and freshness under Resolve release coverage
first. Retain the scoped PR-base comparison separately. Support the actions or
no-action result above. For an affected integration template, identify its
repository, verified compatible immutable commit, and compatibility evidence.
Publication resolves actual coordinates; do not predict a final version.
Delete inapplicable evidence. }}

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- References MSXOrg/repository#456
- Depends on MSXOrg/other-repository#789

</details>

## Changed: {{ Reader-facing result }}

{{ Explain what changes, why, affected supported uses, compatibility, and exact
adoption actions or an explicit no-action result. Include applicable
prerequisites, verification, ordering, and any required intermediate installation
or run. }}

{{ Interface or old-to-new example, comparison, or diagram after the prose when
needed to make adoption unambiguous. Keep required transition details in this
note; link to evergreen usage docs only for optional depth. Delete when prose
is sufficient. }}

<details>
<summary>Technical details</summary>

{{ Implementation and validation evidence, closing delivery-leaf plan progress,
and issue-convergence search scope and outcome for this result, even when no
additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ Publication-baseline evidence: for a release-bound result, identify the
product/target/channel, latest successful artifact and immutable source, exact
candidate source, comparison, and freshness under Resolve release coverage
first. Retain the scoped PR-base comparison separately. Support the actions or
no-action result above. For an affected integration template, identify its
repository, verified compatible immutable commit, and compatibility evidence.
Publication resolves actual coordinates; do not predict a final version.
Delete inapplicable evidence. }}

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- References MSXOrg/repository#456
- Depends on MSXOrg/other-repository#789

</details>

## Fixed: {{ Reader-facing result }}

{{ Explain what changes, why, affected supported uses, compatibility, and exact
adoption actions or an explicit no-action result. Include applicable
prerequisites, verification, ordering, and any required intermediate installation
or run. }}

{{ Interface or old-to-new example, comparison, or diagram after the prose when
needed to make adoption unambiguous. Keep required transition details in this
note; link to evergreen usage docs only for optional depth. Delete when prose
is sufficient. }}

<details>
<summary>Technical details</summary>

{{ Implementation and validation evidence, closing delivery-leaf plan progress,
and issue-convergence search scope and outcome for this result, even when no
additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ Publication-baseline evidence: for a release-bound result, identify the
product/target/channel, latest successful artifact and immutable source, exact
candidate source, comparison, and freshness under Resolve release coverage
first. Retain the scoped PR-base comparison separately. Support the actions or
no-action result above. For an affected integration template, identify its
repository, verified compatible immutable commit, and compatibility evidence.
Publication resolves actual coordinates; do not predict a final version.
Delete inapplicable evidence. }}

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123
- References MSXOrg/repository#456
- Depends on MSXOrg/other-repository#789

</details>

<details>
<summary>Release decisions</summary>

- **Release:** {{ Yes or No }} - {{ Evidence from the artifact, route, and
  supported consumer contract. }}
- **Version bump:** {{ Patch, Minor, or Major }} - {{ Compatibility evidence.
  Identify the explicit label, supported caller input, repository setting, or
  documented shared default that supplies it. Delete this field when Release
  is No. }}
- **Mode:** {{ Stable or Prerelease }} - {{ Target-route or override evidence.
  Identify configured release-candidate routing when applicable. Delete this
  field when Release is No. }}
- **Labels:** {{ Exact `release:*` labels, or `None` when effective configuration
  supplies the decision without an override label. }}

</details>
````

## Check readiness

Before marking the pull request ready, verify:

- the title states one result and contains none of the prohibited prefixes,
  references, lists, or attribution;
- the summary is accurate on its own and the marker appears exactly once in the
  required position;
- release-bound claims match the complete published-artifact-to-candidate
  range; implementation claims match the separate scoped PR diff;
- the product/target/channel, actual successful publication, immutable
  artifact/source provenance, and exact candidate identities are verified and
  current, including partial-publication evidence rather than a GitHub hint;
- the complete delivered range is covered, including earlier merged, skipped,
  unshipped, and bundled consumer deltas;
- missing or unverifiable baselines, diverged lineage, and changing comparison
  inputs are resolved; an initial publication has explicit reviewed initial
  coverage rather than a fabricated predecessor or no-action assumption;
- classified sections are non-empty, ordered, and grouped by reader-facing
  result;
- the notes explain what changed, why, affected supported uses, compatibility,
  and exact applicable actions or an explicit no-action result, without
  requiring PRs, diffs, or historical product docs to discover instructions;
- release-order composition preserves required intermediate operations without
  assuming every intermediate version must be installed;
- prose precedes optional examples and tables;
- supporting blocks are scoped to their section and ordered correctly;
- same-instance references are fully qualified and closing keywords are
  accurate;
- release metadata and `release:*` labels are absent when the route does not
  invoke Release Management;
- when Release Management applies, the decision block, labels, effective
  configuration, and complete-change evidence agree;
- the description contains no AI or agent attribution.

The pull request still follows the complete [Definition of Ready for
Review](Definition-of-Ready-and-Done.md#definition-of-ready-for-review).

## Where this connects

- [README-Driven Context](Readme-Driven-Context.md) — where the product audience
  and supported interfaces are declared.
- [Contribution Workflow](Contribution-Workflow.md) — how a draft pull request
  moves through automated and human review.
- [Definition of Ready and Done](Definition-of-Ready-and-Done.md) — the gate
  before review and completion.
- [Branching and Merging](Branching-and-Merging.md) — branch, integration, and
  merge rules.
- [Automation Labels](Automation-Labels.md) — ownership and meaning of
  `release:*` labels.
- [Release Management](../Capabilities/release-management/design.md) — release
  invocation, configuration, decision resolution, and publication.
