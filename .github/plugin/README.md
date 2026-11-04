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

## Skill granularity

Each skill is a single pointer to one canonical document. The shared `msx`
plugin uses `msx-writing` for reader-facing technical and collaboration text,
`msx-coding-*` for testing and each coding language or tool, and
`msx-ways-of-working-*` for process and format guidance. Skill bodies do not
copy the documentation; they identify the one page to read.

The shared writing entry point reaches the
[Technical Writing Guide](../../src/docs/Coding-Standards/Writing-Guide.md).
Documentation templates and issue/PR formats remain separate contracts selected
through that guide, not separate copies of the writing method. The
[writing-discovery boundary](../../src/docs/Capabilities/agentic-development/design-plugin-marketplaces.md#writing-discovery)
defines this grouping.

## Consumer upgrades

`msx-ways-of-working-consumer-upgrades` points to the shared
[Consumer Upgrades](../../src/docs/Ways-of-Working/Consumer-Upgrades.md)
procedure. It is a discovery shortcut, not a prerequisite for following the
procedure or a bundle of migration instructions.

Source/version discovery and compatible immutable template identity remain
producer-owned. Initiative documentation and plugins supply those entry points
under the [marketplace ownership boundary](../../src/docs/Capabilities/agentic-development/design-plugin-marketplaces.md#consumer-upgrade-discovery);
the shared skill supplies only the common method.

## Versions

Keep the plugin version in `plugin.json` synchronized with the version of its
entry in `marketplace.json`. Increment both together when the plugin changes.
The marketplace metadata version describes the marketplace itself and is
managed independently.

A changed skill catalog requires refreshing a GitHub-backed installed copy.
Refresh the marketplace, then update the MSX plugin:

```shell
copilot plugin marketplace update msxorg
copilot plugin update msx
```

The [CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference#cli-commands)
owns these commands. Other clients use their plugin-update action. A local
directory-sourced plugin loads changes in a new session instead. Updating
canonical prose alone does not require reinstalling a pointer skill.

## Ownership

Use this shared marketplace for guidance that applies across MSX
organizations, repositories, and initiatives, such as `msx`. Use an
initiative-owned marketplace for guidance that depends on one initiative's
process or implementation. Consumers should install both marketplaces when
they need shared standards and initiative-specific guidance; neither replaces
the other.
