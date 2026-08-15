---
title: Plugin Marketplaces
description: How shared and initiative-owned Agent Plugin marketplaces are named, laid out, versioned, and updated.
---

# Agent Plugin Marketplaces — Design

Agent Plugins provide a portable entry point to canonical MSX documentation
and initiative guidance. A marketplace is the catalog for one ownership
boundary. The marketplace owner controls its plugin identities, source paths,
versions, and release changes.

## Ownership boundaries

MSXOrg publishes the shared `msxorg` marketplace in `MSXOrg/docs`. It contains
the `msx` plugin for guidance that applies across MSX organizations,
repositories, and initiatives, including the `msx-coding`,
`msx-documentation`, and `msx-ways-of-working` skill families.

An initiative publishes its own marketplace in its owning repository. For
example, PSModule publishes a `psmodule` plugin for PowerShell-module
processes and skills. Initiative guidance belongs there rather than being
copied into the shared MSXOrg marketplace. Consumers install both marketplaces
when they need shared standards and initiative-specific guidance.

This boundary keeps shared standards stable and prevents an initiative release
from changing the organization-wide plugin catalog.

## Canonical identity and layout

Plugin IDs are lowercase and short. `msx` is the shared MSXOrg plugin ID;
`psmodule` is the canonical PSModule initiative plugin ID. Skill names remain
owned by their plugin and use a matching prefix: `msx-*` for shared MSX
skills and `psmodule-*` for PSModule skills.

Each marketplace uses the flatter plugin layout below:

```text
<repository>/
  .github/
    plugin/
      marketplace.json
      <plugin-name>/
        plugin.json
        skills/
          <skill-name>/
            SKILL.md
```

The `source` in `marketplace.json` is repository-root-relative. For the shared
plugin it is `.github/plugin/msx`; an initiative plugin uses the corresponding
path, such as `.github/plugin/psmodule`. A source must resolve to the plugin
directory named by the marketplace entry, and the plugin manifest's `name`
must match that entry.

## Skill granularity

Every skill is one pointer to one canonical document. The shared `msx` plugin
uses `msx-coding-*` for each coding language or tool,
`msx-documentation-*` for each documentation artifact type, and
`msx-ways-of-working-*` for each direct child of the Ways of Working index.
The skill body contains the route, not a duplicate of the documentation.

## Versioning and update flow

Each marketplace entry and its plugin manifest carry the same plugin version.
A plugin change increments both values together. The marketplace metadata
version describes the catalog and is managed independently from the versions
of the plugins it lists.

The update flow is:

1. The marketplace owner changes the plugin manifest, skills, or catalog entry
   in the owning repository.
2. The owner synchronizes the plugin entry and manifest version when the
   plugin changes.
3. Validation confirms that JSON parses, every source resolves, names and
   versions agree, and every skill follows the Agent Skills format.
4. The owner publishes the marketplace change through its normal pull request
   and release process.

An initiative plugin is updated in its initiative repository. The shared `msx`
plugin is updated in `MSXOrg/docs`. Neither repository republishes the other
repository's plugin.

## Shared and initiative guidance

Use the shared `msx` plugin for organization-wide standards and ways of
working. Use an initiative plugin for process, workflow, or tool guidance that
only applies within that initiative. A skill may route to canonical
documentation and add runtime mechanics, but it must not create a second
definition of a shared workflow.

When guidance moves from initiative-specific to organization-wide, update the
canonical documentation and ownership decision first. Then publish it through
the appropriate marketplace rather than keeping duplicate skills under both
plugin IDs.
