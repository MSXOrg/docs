---
title: Plugin Marketplaces
description: How shared and initiative-owned Agent Plugin marketplaces are named, laid out, versioned, and updated.
---

# Agent Plugin Marketplaces — Design

A marketplace catalogs the plugins owned by one documentation boundary. It
defines their identities, source paths, and versions; the plugins route agents
to canonical guidance.

## Ownership and co-location

MSXOrg owns the shared `msxorg` marketplace and its `msx` plugin, published
from `MSXOrg/docs` for organization-wide standards and ways of working. The
PSModule organization owns the `psmodule` marketplace and plugin, published
from its authoritative repository for PowerShell-module guidance. Consumers
install both when they need both scopes. Neither marketplace republishes the
other's plugin.

A pointer skill MUST be colocated with its canonical governing documentation,
or with the repository that owns that guidance. One pull request can then
update the governing content, pointer skills, plugin metadata and version, and
marketplace entry atomically. A `.github` repository is suitable only when it
is itself the authoritative home of the governing documentation, not when it
only provides organization defaults.

Each skill points to one canonical document. Its body may include runtime
mechanics, but it MUST NOT duplicate the procedure or define a second workflow.

## Layout and names

Each owning repository uses this layout:

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

Plugin IDs are short and lowercase: `msx` for shared guidance and `psmodule`
for PSModule guidance. Skill names use their plugin prefix, such as
`msx-coding-*`, `msx-documentation-*`, `msx-ways-of-working-*`, and
`psmodule-*`.

Every `marketplace.json` `source` is repository-root-relative and resolves to
the named plugin directory: `.github/plugin/msx` or
`.github/plugin/psmodule`. The marketplace entry name and `plugin.json` `name`
MUST match.

## Versions and updates

The plugin version in its marketplace entry and `plugin.json` MUST match and
increment together when the plugin changes. The marketplace metadata version
describes the catalog and changes independently.

1. Change the canonical guidance and its colocated pointer skills.
2. Update the plugin manifest and marketplace entry, including the synchronized
   plugin version when required.
3. Validate JSON, source paths, names, versions, and Agent Skills format.
4. Publish through the owning repository's pull request and release process.

When guidance changes scope, move the canonical documentation and its pointer
skill to the appropriate owner. Do not retain duplicate skills.
