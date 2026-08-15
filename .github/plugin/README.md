# Agent plugin marketplaces

This repository publishes the shared `msxorg` marketplace for plugins that
route Copilot to MSXOrg-wide standards. Initiative repositories publish their
own marketplaces for plugins that describe initiative-specific processes,
workflows, or tools. Keep an initiative plugin in its owning repository rather
than copying it into this marketplace.

## Layout

The marketplace manifest is `.github/plugin/marketplace.json`. Each entry
points to a plugin directory alongside the manifest:

```text
.github/plugin/marketplace.json
.github/plugin/<plugin-name>/plugin.json
.github/plugin/<plugin-name>/skills/
  <skill-name>/SKILL.md
```

The `source` value is repository-root-relative: use
`.github/plugin/<plugin-name>` in the marketplace entry. It must resolve to the
corresponding directory. Every plugin directory must contain `plugin.json`; its
`skills` directory contains the skills advertised by the manifest.

## Versions

Keep the plugin version in `plugin.json` synchronized with the version of its
entry in `marketplace.json`. Increment both together when the plugin changes.
The marketplace metadata version describes the marketplace itself and is
managed independently.

## Ownership

Use this shared marketplace for guidance that applies across MSX
organizations, repositories, and initiatives, such as `msx-standards`. Use an
initiative-owned marketplace for guidance that depends on one initiative's
process or implementation. Consumers should install both marketplaces when
they need shared standards and initiative-specific guidance; neither replaces
the other.
