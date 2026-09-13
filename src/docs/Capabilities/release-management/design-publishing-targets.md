---
title: Publishing Target Design
description: The generic adapter contract for publishing versioned release artifacts and records.
---

# Release Management — Publishing Target Design

A publishing target adapter receives a resolved version, a verified immutable
artifact, a frozen release-note snapshot, and provenance. The core pipeline does
not depend on target-specific behavior.

## Adapter contract

Each adapter declares the following conventions before the target enters a
required target set.

| Convention | Adapter responsibility |
| --- | --- |
| Version | Map the semantic version to the target's accepted version form. |
| Prerelease | Map and order prerelease versions below their related stable version. |
| Immutability | Reject replacement of an existing stable version with different bytes. |
| Withdrawal | Define how availability is removed while preserving version reservation. |
| Aliases | Declare whether `latest`, major, and minor aliases are supported. |
| Release record | Persist a durable record that joins source, artifact, version, and notes. |

An adapter reports one of three outcomes: unpublished, published with a
matching immutable identity, or conflicting. A matching existing publication is
a successful retry. A conflict fails the release and requires a new version.

## Target transaction behavior

The framework stages every required adapter under the frozen release intent.
Adapters publish in a deterministic order. Completion is recorded only after all
required adapters report a matching immutable identity and release record.
There is no claim that independently operated targets provide a distributed
transaction; atomic completion is the framework's durable state rule.

Withdrawal is exceptional. It changes availability but never permits a stable
version identity to be reused. Prerelease cleanup uses the same rule and is
restricted to prerelease identities.

## Alias behavior

Aliases are optional controlled references, not release identities. If enabled,
the adapter supports only:

| Alias | Eligible destination |
| --- | --- |
| `latest` | Newest eligible stable version |
| Major | Newest eligible stable version in that major compatibility line |
| Minor | Newest eligible stable version in that minor compatibility line |

The adapter updates aliases after immutable publication completes. Prereleases
never advance aliases. An alias update that would move backward, cross its
compatibility line, or point to an unverified artifact fails.

## Release hosting adapter

A release-hosting adapter is appropriate when the target repository already
uses a public release-record feature. It publishes a version marker, attaches
or references the verified artifact, records the complete reviewed notes and
provenance, and marks prereleases so they are excluded from the current stable
release.

For a GitHub Releases adapter, use the public platform documentation for the
target behavior: <https://docs.github.com/repositories/releasing-projects-on-github/about-releases>.
The adapter treats the version tag and release assets as immutable release
identities, records stable and prerelease state separately, and never reuses a
withdrawn version.

## Adding an adapter

Adding an artifact or destination consists of implementing this contract,
declaring it in the target set, and proving it handles matching retries and
conflicting identities. The core resolution, build, verification, recovery,
and release-record behavior remains unchanged.

## Related records

- [Specification](spec.md)
- [Logical Core Design](design.md)
