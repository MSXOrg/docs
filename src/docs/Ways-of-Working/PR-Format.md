---
title: PR Format
description: Write pull requests for consumers and maintainers. Give upgrade steps and release decisions when they apply.
---

# PR Format

Write the pull request title and description for consumers first. Consumers
are the people and systems that use the repository's products. If the pull
request has both consumer and internal changes, put the internal changes last.
If it has only internal changes, give the internal result first. Keep review
evidence with the result it supports.

Write the release note only in the release-bound pull request. Release
Management freezes the full title and description that reviewers approve
for the fixed source. The snapshot includes all collapsed blocks. The
publisher copies the snapshot to the release record without changes.

Put all release-specific changes and upgrade steps in the MSX release notes.
Diffs, links, issues, templates, and
[resource documentation](Documentation-Model.md#current-product-guidance-and-release-history)
can give context, usage information, or evidence. Do not put a necessary step
only in those sources.

Consumers read every applicable note in release order. They start after
their actual baseline and read through the note for the fixed target. They
use the notes to make an upgrade plan. They install or run an intermediate
version only if the notes show that the operation is necessary.

The [Contribution Workflow](Contribution-Workflow.md) gives the rules for
drafts, assignment, review, and handoff. [Branching and Merging](Branching-and-Merging.md)
gives the rules for branches, commits, and integration.

<a id="analyze-before-writing"></a>

## Examine the change before you write

Use evidence from the full change. Branch names, commit messages, and
earlier pull request text can help you find evidence. Do not use them as proof.

### Identify the readers

Start with the [audience in the README](Readme-Driven-Context.md#target-audience).
Read the linked product documentation and capability specifications. Read the
configuration in effect. Identify what the repository supplies. Identify how
consumers use those products.

If consumers use a supported interface, include it in the consumer scope.
The product can be a command, API, configuration, reusable workflow, Action,
template, or published guidance. If a workflow changes behavior that other
repositories use, include that change in the consumer results. If a change
to the test setup has no effect on supported uses, it is internal. Consumers
can write scripts or maintain other products.

If a change is only to documentation, tell the reader what they can now
understand or do. Do not say that the change also changes the system.

### Resolve release coverage first

For a release-bound record, find the artifact-to-candidate range first. Do this
before you examine the scoped PR diff. Use the range for the title, result
sections, adoption steps, and compatibility decision.

Use the [actual publication route](../Capabilities/release-management/design.md#applicability)
to identify the product, publishing target, and stable or prerelease channel.
Use this procedure for native producers, even if they do not call a shared
workflow. Find the publication baseline separately for each product, target,
and channel. Identify which results apply to each range. Completion of a
metadata-only mirror does not replace the publication baseline for the artifact.

1. **Find the actual publication baseline.** Read the target's authoritative
   publication inventory and success receipts for that product, target, and
   channel. Use this evidence to find the last artifact that the producer
   published successfully. Do not assume that the highest version is the
   baseline. Use GitHub's Latest hint and moving tags only to find candidates.
   A failed run alone does not show successful publication.
2. **Identify the artifact's exact source.** Use the artifact's provenance to
   identify the source tree of the artifact. Record the artifact version or
   digest, publication evidence, source repository, and full source identity.
   If publication to PowerShell Gallery succeeds, use that module artifact
   as the baseline even if GitHub completion fails. If the producer completes
   the older GitHub record later, do not list the published module changes
   as new.
3. **Record the fixed candidate.** Record the candidate PR source repository
   and full immutable source identity. Do not use a moving branch name, a moving
   tag, a later commit, or the source of a different build.
4. **Compare the source trees.** Make sure that the source trees are in the
   same intended publication lineage. Compare the published and candidate
   source trees with a command such as
   `git diff <published-source> <candidate-source>`. Keep the comparison evidence.
   Do not use the scoped PR-base diff or a substitute merge base for this range.
5. **List the consumer changes.** Examine the full comparison for consumer
   changes. Include changes from earlier merges, direct commits, skip
   decisions, or other unpublished work. Use the list for the title, result
   sections, adoption steps, and compatibility decision.

Put this evidence in a `Technical details` block for a result that it supports.
Record it once for each product, publishing target, and channel that applies.
If the ranges differ, identify the range for each result.

| Field | Evidence |
| --- | --- |
| Product scope | Product, publishing target, and channel whose consumers receive the artifact. |
| Published artifact | Artifact identity and receipt for the last successful publication. For a first publication, give evidence that no earlier artifact exists. |
| Published source | Source repository, full immutable source identity, and evidence that connects the artifact to that source. |
| Candidate source | Exact candidate source repository and full immutable identity that reviewers examined. |
| Scoped PR comparison | PR base and candidate source identities. Keep this evidence separate for the implementation review. |

If you do not have reliable publication or source evidence, stop. Do not
use missing evidence as a no-action result or proof of patch compatibility.

If there is no earlier artifact, make sure that this is the first publication.
Record the evidence for that result. Do not invent an earlier artifact.
Do not use `0.0.0` as a consumed release. The version-computation baseline
does not show consumer history.

For a first publication, examine all supported uses of the candidate. Give
all necessary instructions for first use.

If the sources diverge or the target or channel is not clear, stop. Find the
correct range before you write the note. Do not substitute another release,
branch, or merge base.

Before you mark the PR ready, read the publication baseline and candidate
again. Before you freeze the record, repeat this check.
If either identity changes, do the comparison again. Use the new evidence
for the list of changes, the instructions, and the compatibility decision.
The old comparison does not support the new range.

#### Coverage counterexamples

| Evidence | Release-bound coverage | Scoped PR evidence |
| --- | --- | --- |
| The producer publishes an artifact from A. B adds an input, but the producer does not publish it. Candidate C removes an error. | A to C includes the input from B and the fix from C, even if the producer skipped B. | B to C shows only the current PR's implementation. |
| The producer publishes the module from B to Gallery. GitHub completion fails. Candidate C follows. | B to C shows only changes that the producer did not publish to module consumers. Later completion of B does not make A to B new. | The current PR diff is separate. GitHub's older Latest hint is not the module baseline. |

A, B, and C are immutable source identities, not moving refs. These cases
show what to include in the note. They do not change publication or version
selection.

### Read the whole change

For a release-bound record, examine the full
[publication-to-candidate comparison](#resolve-release-coverage-first).
For a promotion or bundled release, include every consumer change in the range.
Do not use only the latest commit or pull request.

Examine the ordinary base-to-head PR diff separately. Use it as evidence for
this PR's implementation, validation, Task or Bug plan, and issue convergence.
The scoped diff does not replace the release-note range. It does not make
earlier work part of this PR's implementation. If no release-bound artifact
record applies, use the scoped diff for the PR's change coverage. Do not invent
a publication baseline or release metadata.

Make sure that changed interfaces, documentation, configuration, tests, and
outputs support your claims. Do not use commit messages or older PR text
instead of this evidence.

### Keep claims accurate

State only outcomes the evidence supports:

- Use upstream notes, tests, or product evidence before you make claims
  about a dependency update. Do not claim a behavior change or security
  benefit without this evidence.
- If the change is only to documentation, tell the reader how the guidance
  changes.
- Keep public contract changes separate from the internal work that delivers
  them.
- For each supported use in scope, examine compatibility, prerequisites, and
  the steps to adopt the change. Put the steps in order. Include any necessary
  intermediate operations.
- If consumers must change only the release reference, tell them that no
  other edits are necessary. Give the compatibility evidence.
- If you do not know which uses or migration steps apply, get the missing
  evidence. Put the result in the note. Do not send consumers to PRs, diffs,
  or older product docs for required steps.

### Resolve release decisions

Before you add release metadata or change a `release:*` label, examine the
pipeline. Read the settings and inputs it uses. Use the
[route's release behavior](../Capabilities/release-management/design.md#applicability)
to see if [Release Management](../Capabilities/release-management/spec.md)
applies. Include native pipelines that publish versioned artifacts without
a shared workflow. A Pages deployment alone does not invoke Release Management.

The optional `.github/release.settings.yml` file gives settings for the route.
A route can invoke Release Management without that file.

Before you use the canonical settings and labels, examine the immutable
producer revision. Make sure that the revision supports the settings and the
owned-label mapping. Do not assume that a native producer supports a signal
in this document. If the released interface is different, use one of these
options:

- Use an adapter. Get evidence that it works with the immutable producer revision.
- Migrate the producer or its configuration.

Put all adoption steps in the producer's release note.

Before you mark the PR ready, make sure that the effective label mapping
works. Make sure that the required release-decision check passes. If you
cannot show both, stop. Do not apply a label that the pipeline ignores. If a
producer or adapter translates a label, record the supported mapping. An
incompatible producer is not an unmanaged producer.

If the route does not invoke Release Management, do not add the `Release details`
block. Do not apply or list any `release:*` label. This includes `release:skip`.

If the route invokes Release Management, use the full
[delivered consumer range](#resolve-release-coverage-first) and the effective
[configuration](../Capabilities/release-management/design.md#configuration-surface).
Record these decisions:

1. **Release or skip.** Apply the
   [release scope rules](../Capabilities/release-management/design.md#release-scope)
   to the full range. If the range has an effect on the delivered artifact
   or a supported consumer contract, release it. If it has no such effect, select
   `release:skip`. This decision has no version bump or completion announcement.
   Validation still runs. An internal-only PR diff does not show that the
   full range is internal. If the range has earlier unpublished product
   changes, include them in the decision and the consumer summary.
2. **Version bump.** For a release, select Patch, Minor, or Major from the
   effect on compatibility. Do not use changes outside the release scope
   to select the bump.
   An explicit bump label overrides a valid effective `DefaultBump`. A
   matching default supplies the bump without a per-PR bump label. Use the
   [settings and caller override rules](../Capabilities/release-management/design.md#settings-and-caller-overrides)
   to find the effective default.
3. **Mode.** For a release, record Stable or Prerelease from the target route
   and any valid `release:prerelease` override. If the route uses release
   candidates, say so in the mode evidence. A release candidate is a
   prerelease, not a bump.

Use only the labels owned by the
[`release:` namespace](Automation-Labels.md#every-set-is-namespaced). Before
review, make sure that the decisions are present, valid, and consistent.
Do not use a fallback for errors. The documented patch default is a valid
source of a bump. It is not a fallback for an error.

<a id="select-the-news"></a>

### Select the main result

If a change has an effect on consumers, use the title for the most important
consumer result. Write the summary for consumers. Include all consumer changes
and upgrade steps that apply. Put
[maintainer-only sections](#put-maintainer-content-last) after all consumer
sections. Keep supporting details with the result they support.

If the work has only internal changes, give the internal result in the title.
Give the reason for the change in the summary. Do not add a consumer result
or a consumer upgrade step.

<a id="group-related-changes"></a>

### Put related changes together

Put changes to the same result or interface together. Do not divide them by
commit, file, issue, or implementation step. One result can come from several
files. Give each different result its own section.

## Write in Simplified Technical English

Use **ASD-STE100 Issue 9** writing practices. Use American English (`en-US`).
These rules apply to the title and all prose in the description. They also
apply to the published release note and to text in collapsed blocks.
Follow [Natural Language](../Coding-Standards/Natural-Language.md). Use the
[Technical Writing Guide](../Coding-Standards/Writing-Guide.md) to find the
official rules and dictionary.

- Use approved words in their approved meanings and parts of speech. Use
  technical nouns and verbs as Issue 9 permits.
- Use the active voice. Write instructions as commands. Give one instruction
  in each sentence. If the reader must know a condition first, put it
  before the command.
- Use the `-ing` form of a verb only as a technical noun or as part of one.
- Use no more than 20 words in an instruction sentence. Use no more than
  25 words in a descriptive sentence.
- Use the same term for the same concept. Keep exact interface names,
  commands, labels, and values.

## Write the title

Use a short title for the most important consumer result. For a release-bound
record, use the full publication-to-candidate range to select that result.
Do not use only the changes in the pull request diff.

```text
LLM Gateway shows usage for streaming requests
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

<a id="summarize-the-result"></a>

### Write the summary

Start with one or two short paragraphs. Do not add a `Summary` heading.
If a change breaks a supported use or makes an action necessary, put that
information first. If a list makes different results easier to read, use a
short unordered list.

For consumer results, use the terms of the supported interface. Tell the
reader what changes and why. Identify which supported uses the change applies
to. Tell the reader if those uses stay compatible. Give the required action.
If no action is necessary, give the reason.

If a deadline or prerequisite controls whether or when to upgrade, give it
in the summary. Do not put implementation details in the summary.

For internal-only work, give the internal result and the reason for the change.
Do not add a statement about consumer compatibility or adoption.

<a id="end-the-shareable-summary"></a>

### Add the summary marker

After the summary, put the exact HTML marker in the
[complete description example](#complete-description-example).

Put the marker exactly once on its own line. Put it outside code fences and
before the first detailed section. If the route sends a release announcement,
it uses the consumer summary above the marker. Write that summary so it is
useful on its own.

For internal-only work with no release, the summary is for
reviewers, not an announcement. The marker does not trigger an announcement.

<a id="describe-each-result"></a>

### Write each result

Start each result section with an H2 heading: `## <qualifier>: <result>`.
Give the description below the heading. Use these qualifiers in order for
consumer results. Do not add empty sections.

1. `## Breaking: <result>`
2. `## Removed: <result>`
3. `## New: <result>`
4. `## Changed: <result>`
5. `## Fixed: <result>`

| Qualifier | Use when |
| --- | --- |
| `Breaking` | A supported consumer must act or an existing supported use becomes incompatible. |
| `Removed` | A supported capability, interface, or documented path is no longer available. |
| `New` | Readers get a new capability, interface, or body of guidance. |
| `Changed` | Behavior, configuration, or guidance changes. Supported uses stay compatible. |
| `Fixed` | Behavior or guidance now gives the correct result. |

Give the result in the heading, not only the component name. Start the
description with one or two visible paragraphs.

For a consumer result, tell the reader what changes and why. Identify which
supported uses the change applies to. Tell the reader if those uses stay
compatible. Give the required action. If the consumer only has to select the
release reference, give the reason. If a prerequisite or deadline controls
whether or when to upgrade, put it in the visible text. Do not put it only
in a collapsed block.

For a documentation change, select the qualifier for what readers can now
understand or do.

### Show interfaces after the prose

If an example or table helps explain the result, put it after the first
paragraphs. Keep it short. Do not start a section with a code block or table.
Put examples of the exact adoption steps in the `Migration guide`.

Never include secret values.

### Write the migration guide

If a result has technical steps for adoption, put them in one `<details>`
block. Use `Migration guide` as the exact summary. Give the steps even if the
change is compatible. If adoption is optional, say so in the visible text.
If the result has no technical adoption steps, do not add the block. Do not
add an empty block or a placeholder.

- Identify the versions or source baselines that apply. Identify the supported
  uses and prerequisites.
- Give exact old and new names, values, commands, or examples. For first use,
  give the exact setup. Do not give a previous state that did not exist.
- Put edits and operations in the order the reader must do them. If an
  intermediate installation or run is necessary, give the version or source.
  Give the steps for that operation. Give the reason for it.
- Give the checks and their expected results. If a check must pass before the
  reader continues, put the check before the next step.

If a later release changes an earlier instruction, identify the step to
remove or replace. Identify the intermediate steps that still apply.
Put all required steps in the notes. Do not put a required step only in a
diff, link, issue, template, or evergreen document.

### Put maintainer content last

Use `## Internal: <what changes internally>` for a result that applies only to
maintainers. Give the result and the reason below the heading. Use the same
block order as for a consumer result. If maintainers must act, give the action
in the visible text. Put the exact steps in that section's `Migration guide`.
Keep consumer steps in the applicable consumer section.

Put all `Internal:` sections after the consumer sections. If the pull request
has only internal changes, start the `Internal:` sections directly after the
summary marker. Do not add a consumer section.

### Add result details in order

Put the detail blocks after the visible text and any example. For each type
that applies, add one collapsed `<details>` block. Use these exact summaries
in this order:

1. `Migration guide`: Give the technical steps for first use or an upgrade.
2. `Technical details`: Give evidence of the implementation and checks.
3. `Related links`: Give closing and non-closing references and any optional
   usage links for the result.

Keep each block in a result section. If several results share evidence, record
it once in a section it supports. Name the other results or interfaces it
supports.

Put the evidence for the
[standards and framework alignment pass](Workflow-Stages/Implement.md#5-standards-and-framework-alignment-pass)
in `Technical details`. Include the consumer and immutable template
compatibility evidence that applies. If a release-bound record has no
applicable template, give the reason.
See the [Release Management requirements](../Capabilities/release-management/spec.md#release-evidence).

Record the [publication baseline and candidate](#resolve-release-coverage-first),
comparison, and freshness evidence once per range. Keep the scoped PR-base
comparison separate. It supports implementation review, not release-note
coverage.

In `Technical details`, give the status of the implementation plan for the
Task or Bug that the PR closes. Give the scope and result of the
[issue convergence sweep](Workflow-Stages/Implement.md#6-issue-convergence-sweep).
Give the result even if the search finds no other issue that the PR resolves.
Put the evidence in a result section that it supports.

For GitHub issues and pull requests on the same instance, use the full
`owner/repository#number` reference. Do this for the current repository, too.
Use closing keywords only for issues that the full change resolves.
For other references, use a term such as `References`, `Depends on`, or
`Followed by` first.

Use absolute Markdown links for Jira, other GitHub instances, and
references that must work outside GitHub. For optional usage
documentation, use an absolute URL to the default branch or published page.
Make sure that the link also works in the release record.

Do not include AI or agent attribution anywhere in the description.

<a id="record-release-decisions-only-when-invoked"></a>

### Record the release decision

If the target route invokes Release Management, put one `<details>` block
after all other content. Use `Release details` as the exact summary.
This block is not part of a result. Use the same labels on the pull request
and in the block:

```markdown
<details>
<summary>Release details</summary>

- **Release:** Yes - the delivered artifact and supported caller contract change.
- **Version bump:** Minor - callers can use a new optional input. Existing inputs still work.
- **Mode:** Stable - the target route publishes stable releases.
- **Labels:** `release:minor`

</details>
```

If the decision is no release, give only the decision and its label. Do not
add a version bump or mode. Validation still runs:

```markdown
<details>
<summary>Release details</summary>

- **Release:** No - the full range changes neither the artifact nor its supported consumer contracts.
- **Labels:** `release:skip`

</details>
```

Give the route, configuration, and effect on consumers as evidence for each
decision. List the exact labels. If the effective configuration supplies the
decision and no override label applies, write `None`. Do not give a predicted
version. Release Management uses the actual base to select the final version.

If the target route does not invoke Release Management, do not add this block.
Do not add any `release:*` label. A missing `.github/release.settings.yml` file
is not a reason to add `release:skip`.

<a id="assemble-the-body"></a>

### Put the sections in order

Use this order:

1. The summary: the effect on consumers or the result of internal-only work.
2. The summary marker. It does not trigger an announcement.
3. Consumer sections in qualifier order. Do not add these sections for
   internal-only work.
4. `Internal:` sections after all consumer sections.
5. `Release details` last, only when the target route invokes Release Management.

In each result section, put the H2 heading first. Give the description next.
Then add the applicable blocks in this order: `Migration guide`,
`Technical details`, and `Related links`.

Do not add a `Summary` heading, empty sections or blocks, or parallel
release-note metadata.

### Complete description example

Follow the [ASD-STE100 writing rule](#write-in-simplified-technical-english)
when you use either example.

#### Mixed change

Use the most important consumer result as the title. Remove sections, examples,
or blocks that do not apply. Replace every placeholder in the sections you use.

If several results have the same qualifier, give each result its own section.
Keep consumer sections in qualifier order. Put all `Internal:` sections after
the consumer sections. If the work is consumer-only, do not add an `Internal:`
section. Use the block order below `Breaking:` for each result. If a result has
technical adoption steps, give them in its `Migration guide`.

If the route invokes Release Management, use the final block. Follow
[Record the release decision](#record-the-release-decision) for both decisions.
If a valid effective `DefaultBump` supplies the correct bump, you do not need
a per-PR bump label. If the route uses release candidates, give that evidence
under `Mode`. Do not use invalid settings or label conflicts as evidence for
a no-action result.

````markdown
{{ Write one or two short paragraphs for consumers. Tell the reader what
changes and why. Identify which supported uses the change applies to. Give
the required action. If no action is necessary, give the reason. Give any
deadline or prerequisite that controls whether or when to upgrade. }}

<!-- ANNOUNCEMENT STOP -->

## Breaking: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify the supported uses that
change. Tell the reader which uses are no longer compatible. Give the required
action. Give any prerequisite or deadline that controls whether or when to
upgrade. }}

{{ If an interface example or table helps explain the result, give it here. }}

<details>
<summary>Migration guide</summary>

{{ Identify the baselines, uses, and prerequisites that apply. Give exact
old and new values or examples. Give the steps in order. Include any necessary
intermediate operation. Give the checks and their expected results. Identify
the earlier steps to remove, replace, or keep. }}

</details>

<details>
<summary>Technical details</summary>

{{ Give the implementation and checks for this result. Give the status of the
delivery plan and the scope and result of the issue search. If the search
finds no other issue that the PR resolves, record that result. }}

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| `{{ Path or interface }}` | {{ Applicable standards }} | {{ Applicable framework docs, or `None (no framework-specific docs)` }} | {{ `Aligned`, `Fixed in this PR`, or `Exception - MSXOrg/repository#123` }} |

{{ For each range, record the publication baseline and receipt. Record the
immutable artifact and source identities and the fixed candidate. Record the
comparison and freshness evidence. Give shared evidence only once. Identify
the results it supports. Record the scoped PR-base comparison separately.
Do not give a predicted version. }}

{{ If an integration template applies, give its repository and compatible
immutable commit. Give evidence of compatibility with the fixed source. If
a release-bound record has no applicable template, give the reason. }}

</details>

<details>
<summary>Related links</summary>

- Resolves MSXOrg/repository#123
- Depends on MSXOrg/other-repository#789

</details>

## Removed: {{ Consumer result }}

{{ Identify the removed interface. Tell the reader why it is no longer
available. Identify who uses it. Give the required action and any timing
constraints. }}

<details>
<summary>Migration guide</summary>

{{ Give the exact steps and checks for consumers who use the removed
interface. }}

</details>

## New: {{ Consumer result }}

{{ Tell the reader what consumers can now do and why it helps. Identify the
uses that stay compatible. If adoption is optional, say so. Give any timing
constraints that apply. }}

<details>
<summary>Migration guide</summary>

{{ Give the exact setup and checks for consumers who adopt the new feature. }}

</details>

## Changed: {{ Consumer result }}

{{ Tell the reader what changes and why. Identify the uses that stay
compatible. Give the reason why no action is necessary. Give any timing
constraints that apply. }}

<details>
<summary>Technical details</summary>

{{ Give the implementation and checks for the compatible change. }}

</details>

## Fixed: {{ Consumer result that needs no migration }}

{{ Tell the reader what the fix changes and why. Identify the supported uses
that stay compatible. Give the reason why consumers do not need to act. }}

## Internal: {{ What changes internally }}

{{ Tell maintainers what changes and why. If they must act, give the
required action here. }}

<details>
<summary>Migration guide</summary>

{{ Give the step-by-step instructions and checks for maintainers only. }}

</details>

<details>
<summary>Technical details</summary>

{{ Give the implementation and checks for this maintainer result. }}

</details>

<details>
<summary>Related links</summary>

- References MSXOrg/repository#456

</details>

<details>
<summary>Release details</summary>

- **Release:** {{ Yes or No }} - {{ Evidence from the artifact, route, and
  supported consumer contract. }}
- **Version bump:** {{ Patch, Minor, or Major }} - {{ Compatibility evidence.
  Give the source of the bump: explicit label, supported caller input,
  repository setting, or documented shared default. If Release is No, remove
  this field. }}
- **Mode:** {{ Stable or Prerelease }} - {{ Target-route or override evidence.
  If the route uses release candidates, give that evidence. If Release is
  No, remove this field. }}
- **Labels:** {{ Exact `release:*` labels, or `None` when effective configuration
  supplies the decision without an override label. }}

</details>
````

#### Internal-only change

Example title: `Docs builds use a cache for Python packages`

This route deploys the docs site. It does not publish a versioned artifact.
This PR does not change the published site. The summary is for reviewers.
The example has no `Release details` block.

On a Release Management route, examine the effect of the full range on the
artifact and its supported consumer contracts. If the range has no effect
on either, use the no-release block.

```markdown
The docs build job keeps Python packages in a cache. Later runs use the cache
and do not download the same packages again.

<!-- ANNOUNCEMENT STOP -->

## Internal: Later docs builds use the package cache

The build job gets Python packages from the cache when the requirements file
has not changed. The build command stays the same.

<details>
<summary>Technical details</summary>

The docs build job uses the requirements file for its cache key. One test
starts with an empty cache. The other test uses the packages from the cache.
Both tests pass. Both give the same site output.

The delivery plan is complete. The search covered open docs CI issues. This
change does not resolve any other issue in that set.

| Changed surface | Standards checked | Framework docs checked | Result |
| --- | --- | --- | --- |
| Docs build job | GitHub Actions, Testing | None (no framework-specific docs) | Aligned |

</details>

<details>
<summary>Related links</summary>

- Resolves MSXOrg/repository#123

</details>
```

<a id="check-readiness"></a>

## Readiness check

Before you mark the pull request ready, use this list:

- Make sure that the title gives one result. Remove any prohibited prefix,
  reference, list, or attribution.
- Apply the [ASD-STE100 writing rule](#write-in-simplified-technical-english)
  to the title and all prose in the description.
- Make sure that the summary is accurate on its own. Use the marker exactly
  once in the required position. Give only consumer results in an announcement.
- Make sure that release-bound claims match the full range. Make sure
  that implementation claims match the separate scoped PR diff.
- For a release-bound record, make sure that the publication baseline and
  exact candidate are correct and current. Include the product, target, and
  channel. Include the successful publication and immutable artifact and source
  evidence. If not all destinations complete, use the receipts for the
  destinations that published. A GitHub hint is not proof.
- Include consumer changes from earlier merges, direct commits, skip
  decisions, and bundled work. Do not make coverage claims until you have
  evidence for the full range. If you do not have evidence for the
  baseline or lineage, stop. If either source changes, examine the range
  again. For a first publication, make sure that the note covers all
  supported uses. Do not invent a prior artifact or a no-action result.
- If the change has an effect on consumers, give only consumer results in
  the title, summary, and consumer sections. Put consumer sections in qualifier
  order.
- Start each result with `## <qualifier>: <result>`. Put the visible
  description next. Put all `Internal:` sections after the consumer sections.
- For each consumer result, give the change and its reason. Identify the
  supported uses in scope. Make compatibility clear. Give the required action
  or the reason why no action is necessary. Show prerequisites and deadlines
  that control whether or when to upgrade.
- If a result has technical adoption steps, give them in its `Migration guide`.
  Give the applicable baselines and uses, exact edits, and steps in order.
  Give the checks and their expected results. If no steps apply, do not add
  the block.
- For a release-bound PR, make sure that the full title and description apply
  to the fixed source. Include all collapsed blocks. Do not put a required step
  only in a diff, link, issue, template, or evergreen document.
- Read the notes in release order. Make sure that the upgrade plan keeps all
  necessary intermediate operations. Do not assume that consumers must install
  every version.
- If you add an example or table, put it after the prose.
- Put the applicable collapsed blocks in this order: `Migration guide`,
  `Technical details`, then `Related links`. Use each block type once per result.
  Give shared evidence once. Identify the results or interfaces it supports.
- For internal-only work, give the internal result in the title. Give the reason
  in the summary. Do not add consumer results or consumer upgrade steps.
- Use full same-instance references. Make sure that each closing keyword
  points to an issue that the change resolves.
- If Release Management does not apply, do not add release metadata or
  `release:*` labels.
- If Release Management applies, put `Release details` last. Make sure that
  it agrees with the labels, effective configuration, and full range.
  If the decision is no release, give `Release: No` with its reason and
  `release:skip`. Do not give a bump or mode.
- Do not include AI or agent attribution in the description.

The pull request still follows the [Definition of Ready for
Review](Definition-of-Ready-and-Done.md#definition-of-ready-for-review).

## Where this connects

- [README-Driven Context](Readme-Driven-Context.md) — where the product audience
  and supported interfaces are declared.
- [Contribution Workflow](Contribution-Workflow.md) — how a draft pull request
  moves through automated and human review.
- [Definition of Ready and Done](Definition-of-Ready-and-Done.md) — the gate
  before review and completion.
- [Consumer Upgrades](Consumer-Upgrades.md) — how consumers use release
  notes to make an upgrade plan.
- [Branching and Merging](Branching-and-Merging.md) — branch, integration, and
  merge rules.
- [Automation Labels](Automation-Labels.md) — ownership and meaning of
  `release:*` labels.
- [Release Management](../Capabilities/release-management/design.md) — release
  invocation, configuration, decision resolution, and publication.
