---
title: PR Format
description: Audience-first pull request titles and descriptions with evidence-based, conditional release decisions.
---

# PR Format

A pull request title and description are release-note-ready artifacts. They
explain one complete change to the people who use what the repository delivers,
while carrying the evidence reviewers and maintainers need.

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

### Read the whole change

Inspect the complete base-to-head diff before writing. For a promotion or
bundled release, inspect the complete promoted range rather than only the latest
commit or pull request.

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
- Name required user action precisely. Do not imply that no action is needed
  without checking the supported interfaces.

### Resolve release decisions

Before adding release metadata or changing a `release:*` label, determine
whether the repository invokes [Release
Management](../Capabilities/release-management/spec.md) for the pull request's
target route. Inspect the caller workflows and their effective inputs. The
optional `.github/release.config.yml` file refines that invocation; its absence
alone does not prove that release management is absent.

If the route does not invoke Release Management, omit the entire `Release
decisions` block and do not apply or report any `release:*` label, including
`release:skip`.

If the route does invoke Release Management, resolve these decisions from the
complete change and the effective
[configuration](../Capabilities/release-management/design.md#configuration-surface):

1. **Release or skip.** Release when the change affects the versioned artifact
   or a supported consumer contract. Otherwise select `release:skip`.
2. **Version bump.** For a release, choose Patch, Minor, or Major from the
   compatibility impact. An explicit bump label overrides a valid
   `DefaultBump`; a matching configured default may supply the level without an
   explicit bump label.
3. **Mode.** Record Stable or Prerelease from the target route and any valid
   `release:pre-release` override. Prerelease mode still requires a resolved
   bump.

Use only the labels owned by the
[`release:` namespace](Automation-Labels.md#every-set-is-namespaced). Missing,
invalid, or conflicting decisions are errors to resolve before review, not
reasons to assume a patch release.

### Select the news

Keep the summary and named sections focused on results that matter to the
identified readers. Put implementation facts, validation, and process evidence
in supporting details. Omit internal facts that neither explain a reader-facing
result nor help review it.

Internal-only work can still have a clear result, such as a shared automation
configuration. When it has no reader-facing classified section, summarize the
result and put necessary supporting blocks directly after the summary marker.

### Group related changes

Group changes by audience-facing result or affected interface, not by commit,
file, issue, or implementation step. One section may describe several files
that jointly deliver one result. Separate unrelated reader outcomes into their
own sections and classify each result once.

## Write the title

Use one short statement of the most important user-facing result:

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

End the summary with this exact marker:

```markdown
<!-- SLACK MESSAGE STOP -->
```

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
with one or two prose paragraphs that explain the outcome, affected readers,
and required action. A documentation change uses the classifier that describes
what its guidance now provides.

### Show interfaces after the prose

After the opening prose, add an interface example or compact table only when it
makes the reader's action clearer. Do not lead a section with a code block or
table. Do not use before-and-after examples or diagrams in a pull request
description; keep those in durable documentation and link to them.

Link visible documentation using an absolute default-branch URL or the canonical
published URL so the link survives when the pull request becomes a release
record. Never include secret values.

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
same scoped block.

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

## Check readiness

Before marking the pull request ready, verify:

- the title states one result and contains none of the prohibited prefixes,
  references, lists, or attribution;
- the summary is accurate on its own and the marker appears exactly once in the
  required position;
- every claim matches the complete diff or promotion range;
- classified sections are non-empty, ordered, and grouped by reader-facing
  result;
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
