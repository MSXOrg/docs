---
title: Spec
description: Testable requirements for a generic, policy-driven release-management framework.
---

# Release Management — Specification

## Purpose and scope

Release Management turns approved, artifact-affecting changes into versioned,
immutable artifacts that consumers can adopt safely. The framework applies to
any producer that distributes an artifact by version. It does not prescribe a
source-control provider, package ecosystem, branch name, or deployment
environment.

## Functional requirements

- **FR-001 Exactly-once eligible releases.** The framework MUST create one
  release for each approved, eligible change set. Retrying the same release
  intent MUST continue that release rather than create another one.
- **FR-002 Explicit release decision.** Each release intent MUST resolve to
  `major`, `minor`, `patch`, or `skip`. An explicit valid decision takes
  precedence over a configured default. The default policy MUST be explicit;
  when it is absent, invalid, or inapplicable, resolution MUST fail rather than
  infer a version change. Conflicting decisions MUST be rejected.
- **FR-003 No commit-message dependency.** Release eligibility and version
  decisions MUST NOT require a commit-message convention.
- **FR-004 Stable version authority.** The framework MUST discover the current
  stable version from one configured authoritative source. Prereleases MUST NOT
  be treated as the current stable version.
- **FR-005 Prerelease lifecycle.** A prerelease MUST remain distinct from a
  stable release and MUST NOT advance stable aliases. Cleanup MAY remove only
  prereleases; it MUST NOT remove stable release identities.
- **FR-006 Frozen release intent.** Before building, the framework MUST record
  a durable release intent containing the immutable source identity, resolved
  decision, calculated version, release mode, change scope, and reviewed note
  source. Retries MUST use this intent.
- **FR-007 Build once, publish verified bytes.** The framework MUST build each
  artifact once after resolving its version, test that artifact, and publish
  exactly the verified bytes. An artifact change requires a new version and
  release intent.
- **FR-008 Atomic logical completion.** A release spanning required destinations
  MUST complete only when every destination contains the same immutable artifact
  and release record. A partial failure MUST remain recoverable by safely
  retrying unfinished destinations with the frozen intent.
- **FR-009 Target conventions.** Every target MUST declare its version format,
  prerelease representation, immutability behavior, withdrawal behavior, alias
  behavior, and durable release-record convention before it participates in a
  release.
- **FR-010 Immutable identities.** A stable version identity MUST be
  single-use and immutable. Withdrawal MUST NOT make its version reusable.
- **FR-011 Complete release output.** Each completed release MUST provide a
  version marker, the versioned artifact, and a durable release record that
  identifies the source and artifact.
- **FR-012 Moving aliases.** A target MAY offer the closed alias set `latest`,
  major, and minor. Only an eligible stable release MAY advance an alias, and an
  alias MUST NOT move backwards or across its declared compatibility boundary.
- **FR-013 Artifact-based scope.** Eligibility MUST be calculated from
  artifact-affecting inputs and supported consumer contracts, not from path
  names alone. A non-eligible change MUST resolve to `skip`.
- **FR-014 Per-line serialization.** Releases for the same stable or prerelease
  line MUST be serialized. An in-progress release MUST finish or enter explicit
  recovery before a later intent on that line publishes.
- **FR-015 Recovery and aggregation.** After failure or intervening changes, the
  framework MUST recover by resuming the frozen intent or create an explicitly
  approved aggregate intent. It MUST NOT silently merge change sets or replace
  an existing version.
- **FR-016 Reviewed release notes.** Release notes MUST preserve the complete
  reviewed change description bound to the released source. Generated provenance
  MAY accompany, but MUST NOT replace, that description.
- **FR-017 Consumer-update policy.** A consumer MAY select an update policy.
  When selected, the framework MUST honor it and make its risk explicit.
  Producers MUST support consumer adoption by immutable version identity. Where
  consumers cannot express version bounds, producers MUST offer controlled
  aliases that represent the supported bounds.

## Non-functional requirements

- **NFR-001 Zero configuration.** The framework MUST define strict behavior when
  no optional configuration is supplied. Missing required release decisions
  MUST fail clearly rather than use an implicit fallback.
- **NFR-002 SemVer compatibility.** Stable and prerelease versions, ordering,
  and compatibility boundaries MUST conform to Semantic Versioning.
- **NFR-003 Extensible targets and artifacts.** Adding an artifact type or
  publishing target MUST require only its declared adapter and conventions, not
  a change to this specification.
- **NFR-004 Shared behavior.** Resolution, intent persistence, serialization,
  recovery, artifact verification, and release recording MUST each be defined
  once and reused by all target adapters.

## Acceptance criteria

The framework satisfies this specification when every requirement can be
verified through a release decision, durable intent, artifact identity, target
record, and recovery outcome for the same release.

## Related designs

- [Logical Core Design](design.md)
- [Publishing Target Design](design-publishing-targets.md)
