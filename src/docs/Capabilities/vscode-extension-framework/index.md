---
title: VS Code Extension Framework
description: How a VS Code extension is built, tested, versioned, packaged, and published — one GitHub-native pipeline, opt-in from a template and a single settings file.
---

# VS Code Extension Framework

The framework provides a shared lifecycle for VS Code extensions. It compiles
and bundles the source, tests it on a real editor host, and runs lint and type
checks. It resolves the version, packages a VSIX, and publishes that VSIX to a
GitHub Release. Marketplace publication is optional.

The release resolver uses an explicit owned bump label or the valid effective
default. The framework is the VS Code counterpart to
[Process-PSModule](https://github.com/PSModule/Process-PSModule). A repository
opts in from a template and a single settings file. It never copies the pipeline.

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Spec](spec.md) | Requirements for the VS Code extension framework — an opt-in, GitHub-native pipeline that builds, tests, versions, packages, and publishes a VS Code extension from a single settings file. |
| [Design](design.md) | How the VS Code extension framework is built — a shared reusable workflow that finds the version, builds one VSIX, tests it on a real host, and publishes it, from a template repository and a single settings file. |

<!-- INDEX:END -->
