---
title: PR Format
description: Audience-first pull request titles and descriptions with evidence-based, conditional release decisions.
---

# PR Format

Write the pull request title and description as a release note. Write for the
people and systems that use the products of the repository.

If the pull request has both consumer and internal changes, put the internal
changes at the end. If the pull request has only internal changes, give the
internal result first. Put review evidence at the end.

For a release-bound pull request, write the release note in that pull request.
Publication uses the frozen snapshot of the complete reviewed title and
description for the fixed source. This snapshot includes collapsed blocks.

Give consumers all release-specific changes and upgrade steps in the published
MSX notes. Diffs, links, issues, templates, and
[resource documentation](Documentation-Model.md#current-product-guidance-and-release-history)
can give context, usage information, or evidence. Do not put a necessary step
only in those sources.

Consumers read the applicable notes in release order. They start after their
actual baseline and include the note for the fixed target. They use these notes
to make an upgrade plan. They install or run an intermediate version only if a
note requires that operation.

The title and description use a shared format. The
[Contribution Workflow](Contribution-Workflow.md) owns draft, assignment,
review, and handoff mechanics; [Branching and Merging](Branching-and-Merging.md)
owns branches, commits, and integration.

## Analyze before writing

Write from evidence, not from the branch name, commit messages, or the existing
pull request text. Those surfaces are useful leads, but the complete change is
the source.

### Identify the readers

Start with the [audience in the README](Readme-Driven-Context.md#target-audience).
Read the linked product documentation, capability specifications, and the
configuration in effect. Identify what the repository supplies and how consumers
use it.

If consumers depend on a supported interface, treat it as consumer-facing.
The product can be a command, API, configuration, reusable workflow, Action,
template, or published guidance. If a workflow changes behavior that other
repositories use, treat the change as consumer-facing. A change to the
repository's own test setup is internal if it has no effect on supported uses.
Consumers can write scripts or maintain other products.

If a change updates only documentation, tell the reader what they can now
understand or do. Do not say that the change also updates the documented system.

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

Record these identities in the `Technical details` block once per applicable
product, publishing target, and channel. Identify which range supports each
result when the ranges differ:

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
`.github/release.settings.yml` file refines the route's settings; its absence alone
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

If a change has an effect on consumers, use the title for the most important
consumer result. Write the shareable summary for consumers. Use the classified
sections only for consumer results. Include all applicable changes and upgrade
steps. Put maintainer-only changes and review evidence
[at the end](#put-maintainer-content-last).

If the work has only internal changes, give the internal result in the title.
Give the reason for the change in the summary. Do not add a consumer result
or an upgrade step.

### Group related changes

Group consumer changes by result or affected interface, not by commit, file,
issue, or implementation step. One section may describe several files that
jointly deliver one result. Give distinct consumer results their own sections
and classify each once.

## Write in Simplified Technical English

Use **ASD-STE100 Issue 9** writing practices and American English (`en-US`).
This rule applies to the pull request title and all prose in the description.
It also applies to the published release note, including collapsed text.
Follow [Natural Language](../Coding-Standards/Natural-Language.md). Use the
[Technical Writing Guide](../Coding-Standards/Writing-Guide.md) to find the
official rules and dictionary.

Use short sentences in the active voice. Give instructions as direct commands.
Give one action per instruction. If the reader must know a condition first,
put it before the instruction. Use the same term for the same concept.
Keep exact interface names, commands, and values.

## Write the title

Use a short title for the most important consumer result. For a release-bound
record, use the complete publication-to-candidate range to select that result.
Do not use only the changes in the pull request diff.

```text
LLM Gateway reports usage for streaming requests
```

For internal-only work, give the internal result:

```text
Docs builds use a cache for Python packages
```

The title must not contain:

- an icon or type prefix;
- a Conventional Commit prefix such as `feat:` or `docs:`;
- an issue reference;
- a list of unrelated changes;
- AI or agent attribution;
- an implementation detail when a consumer result is available.

## Write the description

Give the reader all necessary information in the description. Do not make the
reader use the diff to find a required step.

### Summarize the result

Start with one or two short paragraphs. Do not add a `Summary` heading.
If a change breaks a supported use or requires action, put this information
first. If prose cannot show several different results clearly, use a short
unordered list.

For consumer results, use the terms of the supported interface. Tell the
reader what changes and why. Identify which supported uses the change applies
to. Tell the reader if those uses stay compatible. Give the required action.
If no action is necessary, give the reason. If a deadline or prerequisite
controls whether or when to upgrade, give it in the summary. Do not put
implementation details in the summary.

For internal-only work, give the internal result and the reason for the change.
Do not add a statement about consumer compatibility or adoption.

### End the shareable summary

End the summary with the exact HTML marker shown in the
[complete description example](#complete-description-example).

The marker appears exactly once, on its own line, outside a code fence, and
before the first detailed section. Text before it must remain useful when shared
without the rest of the description.

### Explain each reader-facing result

Use these classifiers for consumer results only. Keep this order and omit
empty groups. An internal-only pull request has no classified sections.

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

Use one result as the section heading. Do not use only the component name.
Start the section with one or two visible paragraphs. Tell the reader what
changes and why. Identify which supported uses the change applies to. Tell the
reader if those uses stay compatible. Give the required action. If the consumer
only has to select the release reference, give the reason. If a prerequisite
or deadline controls whether or when to upgrade, put it in the visible text.
Do not put it only in a collapsed block. For a documentation change, use the
classifier for the new result of the guidance.

### Show interfaces after the prose

After the opening prose, add a short interface example or compact table only
when it clarifies the result. Do not lead a section with a code block or table.
Put exact transition examples in `Migration details`.

Link optional usage documentation using an absolute default-branch URL or the
canonical published URL so the link survives when the pull request becomes a
release record. Never include secret values.

### Record migration details

If a result has technical steps for adoption, put them in one `<details>`
block. Use `Migration details` as the exact summary. If a compatible change
has adoption steps, use the block for those steps. If adoption is optional,
tell the reader in the visible text. If no migration applies, do not add the
block. Do not use an empty block or a placeholder for no action.

- Identify the versions or source baselines that apply. Identify the supported
  uses and prerequisites.
- Give exact old and new names, values, commands, or examples. For first-time
  adoption, give the exact setup. Do not add a previous state that did not exist.
- Put edits and operations in the order the consumer must do them. If an
  intermediate installation or run is necessary, give the version or source.
  Give the steps for that operation. Give the reason why it is necessary.
- Give the checks and their expected results. If a check must pass before the
  consumer continues, put the check before the next step.

If a release changes an earlier instruction, tell the reader which step to
remove or replace. Tell the reader which intermediate steps still apply.
Put all required steps in the notes. Do not put a required step only in a
diff, link, issue, template, or evergreen document.

### Put maintainer content last

After the last consumer result, add each applicable collapsed block one time.
Use the order below. These blocks apply to the complete pull request.

1. `Internal changes`: Give a short summary of each useful change for
   maintainers only. Give the reason for each change. If there is no useful
   internal result, do not add the block.
2. `Technical details`: Record implementation and validation evidence. Name
   the result or changed interface that each item supports.
3. `Related references`: Include closing and non-closing references. Name
   the relevant result or interface when the connection is not clear.

For internal-only work, put the applicable `Technical details` and `Related
references` blocks directly after the summary marker. Do not repeat the outcome
in an `Internal changes` block. Keep every consumer migration step with its
consumer result, not in the maintainer blocks.

Put the standards and framework alignment evidence required by
[Implement](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass)
in `Technical details`. Include the applicable consumer and immutable template
compatibility evidence required by [Release
Management](../Capabilities/release-management/spec.md#release-evidence).
Record the [publication baseline and candidate](#resolve-release-coverage-first),
comparison, and freshness once for each applicable range, not once per result.
Keep the scoped PR-base comparison separate; it supports implementation review,
not release-note coverage.

Record the closing delivery leaf's implementation-plan progress and the
[issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep)
search scope and outcome in that same block, including when no additional issue
converges.

Use fully qualified `owner/repository#number` references for every same-instance
GitHub issue or pull request, including references to the current repository.
Use closing keywords only for issues the complete change actually resolves.
Prefix non-closing relationships with terms such as `References`, `Depends on`,
or `Followed by`. Use absolute Markdown links for Jira, cross-instance GitHub,
and references that will render outside GitHub.

Do not include AI or agent attribution anywhere in the description.

### Record release decisions only when invoked

When the target route invokes Release Management, add one `Release decisions`
block at the end, after all other content. Apply the exact labels the block
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
has no `.github/release.settings.yml`.

### Assemble the body

Use this order:

1. Summary prose: consumer impact, or the operational outcome for internal-only work.
2. The shareable-summary marker.
3. Consumer sections in classifier order, each with its own `Migration details`
   block when applicable. Omit these sections for internal-only work.
4. Applicable end blocks in order: `Internal changes` (mixed work only),
   `Technical details`, and `Related references`.
5. `Release decisions` last, only when the target route invokes Release Management.

Do not add a `Summary` heading, empty sections or blocks, or parallel
release-note metadata.

### Complete description example

Follow the [ASD-STE100 writing rule](#write-in-simplified-technical-english)
when you use either example.

#### Mixed change

Use the most important consumer result as the title. Replace every placeholder
below and delete sections, examples, or blocks that do not apply. Repeat a
consumer section when several distinct results share the same classifier.
Keep classifier order and include `Migration details` only where there are
technical adoption steps, including compatible adoption where applicable.

Use the final block only for a route that invokes Release Management. Follow
[Record release decisions only when invoked](#record-release-decisions-only-when-invoked)
for release and no-release decisions. When the valid effective `DefaultBump`
supplies the correct level, no per-PR bump label is needed. Include configured
release-candidate routing in the mode evidence. Never turn invalid settings or
conflicting owned labels into a no-action result.

````markdown
{{ Write one or two short paragraphs for consumers. Tell the reader what
changes and why. Identify which supported uses the change applies to. Give
the required action. If no action is necessary, give the reason. Give any
deadline or prerequisite that controls whether or when to upgrade. }}

<!-- ANNOUNCEMENT STOP -->

## Breaking: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify which supported uses the
change applies to. Tell the reader if those uses stay compatible. Give the
required action. If no action is necessary, give the reason. Give any
prerequisite or deadline that controls whether or when to upgrade. }}

{{ Optional short interface example or table that clarifies the result. }}

<details>
<summary>Migration details</summary>

{{ Identify the applicable baselines, uses, and prerequisites. Give exact old
and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Tell the
reader which earlier steps to remove, replace, or keep. }}

</details>

## Removed: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify which supported uses the
change applies to. Tell the reader if those uses stay compatible. Give the
required action. If no action is necessary, give the reason. Give any
prerequisite or deadline that controls whether or when to upgrade. }}

{{ Optional short interface example or table that clarifies the result. }}

<details>
<summary>Migration details</summary>

{{ Identify the applicable baselines, uses, and prerequisites. Give exact old
and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Tell the
reader which earlier steps to remove, replace, or keep. }}

</details>

## New: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify which supported uses the
change applies to. Tell the reader if those uses stay compatible. Give the
required action. If no action is necessary, give the reason. Give any
prerequisite or deadline that controls whether or when to upgrade. }}

{{ Optional short interface example or table that clarifies the result. }}

<details>
<summary>Migration details</summary>

{{ Identify the applicable baselines, uses, and prerequisites. Give exact old
and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Tell the
reader which earlier steps to remove, replace, or keep. }}

</details>

## Changed: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify which supported uses the
change applies to. Tell the reader if those uses stay compatible. Give the
required action. If no action is necessary, give the reason. Give any
prerequisite or deadline that controls whether or when to upgrade. }}

{{ Optional short interface example or table that clarifies the result. }}

<details>
<summary>Migration details</summary>

{{ Identify the applicable baselines, uses, and prerequisites. Give exact old
and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Tell the
reader which earlier steps to remove, replace, or keep. }}

</details>

## Fixed: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify which supported uses the
change applies to. Tell the reader if those uses stay compatible. Give the
required action. If no action is necessary, give the reason. Give any
prerequisite or deadline that controls whether or when to upgrade. }}

{{ Optional short interface example or table that clarifies the result. }}

<details>
<summary>Migration details</summary>

{{ Identify the applicable baselines, uses, and prerequisites. Give exact old
and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Tell the
reader which earlier steps to remove, replace, or keep. }}

</details>

<details>
<summary>Internal changes</summary>

{{ Give each useful change for maintainers only. Give the reason for it. }}

</details>

<details>
<summary>Technical details</summary>

{{ Record implementation and validation evidence by result or changed
interface. Record closing delivery-leaf plan progress and the issue-convergence
search scope and outcome, even when no additional issue converges. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ For each applicable range, record the product, target, and channel, latest
successful artifact and immutable source, exact candidate source, comparison,
and freshness as specified under Resolve release coverage first. State which
results the range covers. Record the scoped PR-base comparison separately.
For an affected integration template, identify its repository, verified
compatible immutable commit, and compatibility evidence. Do not predict a
final version. Delete inapplicable evidence. }}

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

#### Internal-only change

Example title: `Docs builds use a cache for Python packages`

This route deploys the docs site. It does not publish a versioned artifact.
The example has no `Release decisions` block. If the actual route invokes
Release Management, put the `Release decisions` block at the end. Use the
same release criteria as for other changes. Do not select skip only because
the change is internal.

```markdown
The docs build job keeps Python packages in a cache. Later runs use the cache
and do not download the same packages again.

<!-- ANNOUNCEMENT STOP -->

<details>
<summary>Technical details</summary>

The docs build job uses the requirements file for its cache key. One test
starts with an empty cache. The other test uses the packages from the cache.
Both tests pass. Both give the same site output. The delivery plan is complete.
The search covered open docs CI issues. This change does not resolve another
issue in that set.

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| Docs build job | GitHub Actions, Testing | None (no framework-specific docs) | Aligned |

</details>

<details>
<summary>Related references</summary>

- Resolves MSXOrg/repository#123

</details>
```

## Check readiness

Before marking the pull request ready, verify:

- the title states one result and contains none of the prohibited prefixes,
  references, lists, or attribution;
- the title and all prose in the description follow the
  [ASD-STE100 writing rule](#write-in-simplified-technical-english);
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
- when any result affects consumers, only consumer results appear in the
  title, shareable summary, and classified sections. Classifier groups are
  non-empty and ordered;
- consumer-facing prose explains what changed and why, affected supported uses,
  compatibility, and the required action or compatible no-action outcome. It
  shows deadlines and prerequisites that affect whether or when to upgrade;
- each result with technical adoption steps has a `Migration details` block
  with applicability, exact edits, ordered operations, and verification.
  Results with no migration have no block;
- for a release-bound PR, the complete reviewed title and description,
  including collapsed blocks, are ready to freeze for the fixed source. No
  required step lives only in a diff, link, issue, template, or evergreen document;
- release-order composition preserves required intermediate operations without
  assuming every intermediate version must be installed;
- prose precedes optional examples and tables;
- in mixed work, useful maintainer-only outcomes appear in one optional
  `Internal changes` block after all consumer results. Review-only `Technical
  details` and `Related references` follow there, with evidence mapped to the
  result or interface it supports and common source evidence recorded once;
- for internal-only work, the title names the internal outcome and the summary
  explains why it matters. No classified section, migration block, or `Internal
  changes` block appears. Any review evidence follows the marker;
- same-instance references are fully qualified and closing keywords are
  accurate;
- release metadata and `release:*` labels are absent when the route does not
  invoke Release Management;
- when Release Management applies, `Release decisions` is the final block and
  agrees with the labels, effective configuration, and complete-change evidence;
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
