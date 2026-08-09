---
title: Document architecture and memory boundaries
description: The topic-and-artifact documentation model, minimal OKF-style metadata, and separate durable memory repository.
---

# Document architecture and memory boundaries

## Context

MSX documentation is navigable cheaply by humans and agents, agent
configuration points to canonical knowledge, and durable lessons have a shared
home. The architecture establishes those boundaries without duplicating
documentation across classifications or repositories.

## Decision

MSX uses the [Documentation Model](../../../Ways-of-Working/Documentation-Model.md)
as the documentation architecture:

- Paths are topic- and scope-oriented, and every area is navigated through
  `index.md`.
- The spec, design, guide, reference, decision-record, and research artifact
  tiers classify content by the reader's need.
- Pages use the minimal OKF-style model: Markdown, YAML `title` and
  `description` front matter, one primary concept per page, and stable paths.
- `MSXOrg/docs` remains the reviewed, pull-request-only canonical knowledge
  base. Durable working knowledge belongs in the separate private
  `MSXOrg/memory` repository; session notes remain local and ignored.

MSX does not add Diataxis quadrant directories or `diataxis` metadata. The
artifact tiers already route the same reader needs while keeping related
subject matter together. MSX also does not adopt strict OKF conformance fields
or per-area `log.md` files: the only metadata queried by navigation is title
and description, and Git history is the authoritative changelog.

## Consequences

Contributors file a page by subject and artifact tier, then run the index
generator. Readers and agents traverse the same indexes without loading an
unrelated quadrant. Tooling validates the metadata it consumes and validates
links, while review keeps page boundaries and cross-references coherent.

Agents propose changes to canonical documentation through pull requests.
Agents commit durable, factual lessons to `MSXOrg/memory` under its
[memory-writing rules](../design.md#memory-writing-rules); they never use this
public documentation repository as a low-ceremony dump.

Changes to these boundaries use a new decision record that supersedes this one.
