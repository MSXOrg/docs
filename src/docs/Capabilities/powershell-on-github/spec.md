---
title: Spec
description: Requirements and boundaries for PowerShell parity on GitHub using reusable modules, actions, and platform advocacy.
---

# Spec

## Problem

GitHub offers strong language-native experiences for mainstream ecosystems, but PowerShell still has capability gaps in dependency intelligence, security signals, publishing ergonomics, and first-party tooling support.

## Goal

Provide a PowerShell-first GitHub development experience that is easy, fast, and safe by default.

## Requirements

1. Reusable automation should be packaged as versioned, SHA-pinnable actions and modules.
2. Module and action delivery must be orchestrated through standardized CI/CD workflows.
3. Missing platform support should be addressed through either:
   - build-it paths (when APIs exist)
   - advocacy paths (when only platform vendors can close the gap)
4. Documentation for this capability must remain canonical in MSXOrg/docs.
5. Initiative repositories can reference this capability but not fork its canonical guidance.

## Scope

In scope:

- module and action architecture for PowerShell on GitHub
- dependency, security, release, and publishing parity goals
- implementation patterns and inventory-level framing

Out of scope:

- module-specific operational docs
- repository-specific runbooks unrelated to reusable capability behavior

## Success criteria

- Capability guidance is discoverable under MSX capabilities.
- Initiative-local copies are replaced with pointers.
- PowerShell parity gaps are documented with a clear build-versus-advocate classification.
