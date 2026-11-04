---
title: Plugin Distribution
description: How recurring workflows are packaged as named intents that point to canonical documentation, and why a packaged shortcut never carries a copy of the procedure.
---

# Plugin Distribution

Recurring workflows can have **named intents**. Examples include "review this pull request",
"open an issue for this", and "wrap up and hand off". Each intent points to a documented
procedure.

Runtimes expose an intent as a command, skill, named agent, or plugin. This page defines what
that packaged entry point can contain.

## An intent is a pointer

A named intent MUST resolve to the canonical documentation for its workflow and MUST contain
only the runtime mechanics needed to get there.

The [client routes](design.md#client-behavior) rule also applies to workflow entry points.
An intent that restates a procedure creates a second definition. Either copy can change
without the other, so the agent's loaded copy can determine the apparent rule.

The content boundary is:

| An intent MAY contain | An intent MUST NOT contain |
| --- | --- |
| A pointer to the canonical procedure | The steps of the procedure |
| Which arguments it takes and how they map to the procedure's inputs | Standards, review criteria, or acceptance rules |
| Runtime mechanics: which tools to enable, how to gather the current artifacts | A workflow stage definition |
| Where to start reading | A copy of anything in `docs` |

The content check compares the intent with its canonical procedure. Repeated process steps
are copied content, not runtime mechanics.

## Why intents are worth having anyway

Named intents provide **reliable entry** to documented procedures.

Without an intent, procedure discovery depends on the prompt. The agent can select the wrong
document or substitute an undocumented process. A named intent maps the request to one
canonical entry point.

A runtime's intent list also makes recurring workflows **visible**. A contributor can
discover a procedure without knowing its file path.

## One model, many runtimes

The set of named intents MUST be one shared model. Each runtime MUST express the same set
in its own format.

If runtimes expose different intent sets, the same request can use different procedures.
A pointer and its runtime mechanics can use each runtime's native format without copying
the procedure.

## Standards profile

MSX distributes named intents as [Agent Plugins 1.0](https://agent-plugins.org/) packages.
That open package standard is the shared model; a supported client loads the portable
components it understands, while client-specific behavior stays namespaced.

| Layer | Standard | MSX use |
| --- | --- | --- |
| Package | [Agent Plugins](https://agent-plugins.org/plugin-authors) | A root `plugin.json` selects the `1.0.0` schema and identifies the package. |
| Intent | [Agent Skills](https://agentskills.io/specification) | Each immediate child of `skills/` contains a `SKILL.md` with a matching `name` and a trigger-oriented `description`. |
| Catalog | [GitHub Copilot marketplace](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-marketplace) | `.github/plugin/marketplace.json` names the marketplace and points each entry at its plugin directory. |
| Client | [GitHub Copilot plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins) | Copilot CLI, the GitHub Copilot app, and managed Copilot environments install the same package. |

The portable package root contains only the Agent Plugins components. Skills live under
`skills/`; an MCP configuration, when needed, lives at `mcp.json`. Copilot-only agents,
commands, hooks, rules, or extensions belong under `com.github.copilot/`, where another
client can ignore them without changing the portable contract.

Agent Skills use progressive disclosure. Clients first discover the `name` and `description`.
When a request matches, they load `SKILL.md`. They read referenced resources only when the
active skill needs them. A description names both the capability and its trigger.
The body stays a short route with runtime mechanics.

## Marketplace structure and skill boundaries

The [Plugin Marketplaces design](design-plugin-marketplaces.md) owns marketplace ownership,
repository layout, plugin identities, and skill granularity. This page describes named-intent
distribution and links to those structural rules.

For consumer upgrades, `msx-ways-of-working-consumer-upgrades` is the shared
pointer to [Consumer Upgrades](../../Ways-of-Working/Consumer-Upgrades.md).
Initiative entry points supply producer-owned discovery under the
[upgrade discovery boundary](design-plugin-marketplaces.md#consumer-upgrade-discovery),
not a second migration procedure.

## GitHub Copilot distribution

An individual registers the marketplace and installs its standards plugin with Copilot CLI:

```shell
copilot plugin marketplace add MSXOrg/docs
copilot plugin install msx@msxorg
```

Skills configured for Copilot CLI are also available in the
[GitHub Copilot app](https://docs.github.com/en/copilot/how-tos/github-copilot-app/customize-github-copilot-app).
The app also exposes installed plugins under **Settings > Plugins**.

An enterprise can publish the same marketplace and plugin through
`copilot/managed-settings.json` in its `.github-private` governance repository. The settings
apply to the app and other supported Copilot clients:

```json
{
  "enabledPlugins": {
    "msx@msxorg": true
  },
  "extraKnownMarketplaces": {
    "msxorg": {
      "source": {
        "source": "github",
        "repo": "MSXOrg/docs"
      }
    }
  }
}
```

`enabledPlugins` and `extraKnownMarketplaces` are additive across enterprise and team
settings. Use `strictKnownMarketplaces` only when governance intends an allowlist; an empty
allowlist blocks every non-built-in marketplace.

## Distribution is by reference

An intent MUST NOT bundle a copy of the documentation it points to.

A bundled procedure is a snapshot that can differ from its canonical source.
Copies across installations can diverge independently. The intent relies on the
[freshness gate](design.md#context-freshness) for current canonical documentation.

If its route remains valid, a procedure update does not require redistributing the intent.
The intent continues to resolve to the canonical procedure.

## Intents do not define process

A named intent MUST NOT define a workflow stage, and MUST NOT add a requirement of its own.

A rule added only to a review intent does not apply to reviews reached by other routes.
If the rule is required, the canonical review procedure owns it. Otherwise, the intent
introduces unreviewed policy.

If an intent contains process content, move that content to its canonical documentation.
Reduce the intent to its pointer and runtime mechanics.

## Where this connects

- [Spec](spec.md#requirements) — the requirement that named intents stay pointer-based and that no client convenience redefines a stage.
- [Design](design.md#pointer-files) — the pointer-file discipline this extends from instructions to behavior.
- [MCP Servers](mcp-servers.md) — the tool layer an intent's mechanics may enable, which likewise defines no procedure.
- [Workflow](../../Ways-of-Working/Workflow.md) — the canonical stage procedures intents point at.
- [Conformance](conformance.md) — the anti-duplication checks that catch an intent carrying a copy.
- [Agent Plugins 1.0](https://agent-plugins.org/) — the portable package standard.
- [Agent Skills](https://agentskills.io/specification) — the skill directory and `SKILL.md` standard.
- [GitHub Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference) — Copilot manifests, marketplaces, commands, and precedence.
- [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings) — cross-client plugin and marketplace governance.
