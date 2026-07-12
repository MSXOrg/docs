---
title: VS Code Extension Framework
description: How a VS Code extension is built, tested, versioned, packaged, and published — one GitHub-native pipeline, opt-in from a template and a single settings file.
---

# VS Code Extension Framework

The end-to-end pipeline for a VS Code extension: compile and bundle the source,
test it on a real editor host, lint and type-check it, version it by
pull-request label, package a VSIX, and publish that VSIX to a GitHub Release
(and, optionally, a marketplace). One behaviour, defined once and consumed by
every extension repository — the VS Code counterpart to
[Process-PSModule](https://github.com/PSModule/Process-PSModule). A repository
opts in from a template and a single settings file; it never copies the
pipeline.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for the VS Code extension framework — an opt-in, GitHub-native pipeline that builds, tests, versions, packages, and publishes a VS Code extension from a single settings file. |
| [Design](design.md) | How the VS Code extension framework is built — a shared reusable workflow that finds the version, builds one VSIX, tests it on a real host, and publishes it, from a template repository and a single settings file. |

<!-- INDEX:END -->
