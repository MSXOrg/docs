---
title: Spec
description: Requirements and boundaries for PowerShell parity on GitHub using reusable modules, actions, and platform advocacy.
---

# Spec

## Problem

PowerShell development on GitHub has gaps in dependency intelligence, security
signals, publication workflows, and first-party tooling.

## Goal

The capability provides a PowerShell-first GitHub development experience that is
easy, fast, and safe by default.
The [design](design.md) describes the architecture that supports this goal.

## Requirements

1. Repositories SHOULD package reusable automation as versioned, SHA-pinnable actions and modules.
2. Standardized CI/CD workflows MUST orchestrate module and action delivery.
3. The capability SHOULD address a platform-support gap through one of two paths:
   - Build path: use available APIs.
   - Advocacy path: request vendor support when only the platform vendor can close the gap.
4. MSXOrg/docs MUST remain the canonical source for this capability's documentation.
5. Initiative repositories can reference this capability but cannot fork its canonical guidance.

## Scope

In scope:

- module and action architecture for PowerShell on GitHub
- dependency, security, release, and publishing parity goals
- implementation patterns and inventory-level framing

Out of scope:

- module-specific operational docs
- repository-specific runbooks unrelated to reusable capability behavior

## Success criteria

- Capability guidance is available through the MSX capabilities index.
- Initiative repositories link to canonical guidance instead of maintaining local copies.
- PowerShell platform gaps have an explicit build or advocacy classification.
