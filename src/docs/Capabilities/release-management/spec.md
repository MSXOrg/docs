---
title: Spec
description: Requirements for durable, recoverable, policy-driven releases and trustworthy consumer updates.
---

# Release Management — Spec

## Premise

Release management turns approved source into a **versioned, immutable release**
that consumers can trust. A release is normally the result of merging reviewed
change, while a controlled manual request can release already-reviewed
accumulated change. Both paths use the same decision, build, verification,
publication, and evidence controls.

The capability preserves enough durable state to finish an interrupted release
without rebuilding or assigning its version to different content. Consumers can
discover only completed, eligible stable releases and can select an explicit
update policy that matches their trust boundary.

## Problem and importance

A tag or successful workflow run is not enough to prove that a release completed.
Publication can expose one destination before another fails, mutable pull-request
metadata can change before a retry, and a later commit can reach the stable branch
while an earlier artifact is still incomplete. Recomputing from current state can
then publish different bytes under a reserved version, omit accumulated changes
from the notes, or advertise an incomplete release as current.

Release management makes the release intent durable. It fixes the approved source,
decision, version, notes, artifact identity, required destinations, and stage
progress, then advances that intent safely through publication. This gives
contributors a predictable release path, operators a recoverable process, and
consumers an accurate version and update contract.

## Users and jobs

- **A contributor** records the compatibility impact and consumer evidence while
  proposing a change, without operating separate release tooling.
- **A reviewer** approves the source, release decision, and complete consumer
  effect together.
- **A maintainer** can release approved accumulated change, resume an interrupted
  attempt, retire an unrecoverable attempt, or withdraw a completed release
  without rewriting history.
- **A consumer** can discover the current completed stable release and choose how
  far a dependency may move within the applicable trust boundary.

## Scope

In scope:

- Version resolution, release approval, and publication for repositories that
  produce a versioned artifact.
- Stable releases, prereleases, release candidates, manual release requests,
  retries, retirement, and withdrawal.
- Release notes, immutable release evidence, announcements, current-version
  discovery, and optional moving aliases.
- Consumer update policies and the producer references needed to express them.

Out of scope:

- Deploying a released artifact into a runtime environment.
- Processing a release in dependent repositories.
- Repository rulesets and branch protections, except for the release checks they
  must require.

## Requirements

Requirements use [BCP 14](https://www.rfc-editor.org/info/bcp14) keywords.
Identifiers are append-only and MUST NOT be renumbered or reused.

### FR1 — Every release has an approved decision and fixed source {#fr1}

The release decision MUST be major, minor, patch, or skip. For a change with an
associated pull request, one explicit owned decision MUST override the
repository's configured fallback. Missing, invalid, or conflicting decisions
MUST fail closed. A skip decision MUST suppress immediate publication without
removing the change from a later release range. Commit-message syntax MUST NOT
select the decision.

The ordinary stable release path MUST be an approved pull request merged to the
stable line. A direct push with no associated review MUST validate but MUST NOT
inherit the repository fallback or publish a stable release.

A manual stable release MUST name a fixed source revision on the stable line, an
explicit aggregate increment, complete release-note context, and approval that
covers the entire included change range. Invoking the release mechanism is not
approval. A retry MUST identify an existing release intent and reuse its frozen
decision.

#### FR1 scenarios

```gherkin
Scenario: An explicit decision overrides the fallback
  Given the repository fallback is patch
  And an approved pull request carries the owned minor decision
  When release resolution runs
  Then the resolved decision is minor
  And the fallback is recorded as not used

Scenario: A direct push does not inherit the fallback
  Given the repository fallback is patch
  And a direct push has no associated pull request
  When release resolution runs
  Then validation runs
  And no release is published
```

### FR2 — The increment states the complete compatibility impact {#fr2}

Versions MUST follow [Semantic Versioning 2.0.0](https://semver.org/). For a
stable public contract at `1.0.0` or later, breaking change requires major,
backward-compatible capability requires minor, and backward-compatible repair
requires patch. Before `1.0.0`, breaking or additive change requires minor and a
compatible repair requires patch; reaching `1.0.0` remains a deliberate major
decision.

The effective increment MUST cover every unreleased change included from the
previous completed stable source through the fixed release source. Known pending
increments establish a minimum aggregate increment: major takes precedence over
minor, which takes precedence over patch. Skipped and direct changes remain in
the range and require an explicit reviewed aggregate decision when their
compatibility impact is not already approved.

#### FR2 scenarios

```gherkin
Scenario: Accumulated decisions establish a minimum increment
  Given the unreleased range contains approved patch and major changes
  When an aggregate release decision is resolved
  Then the effective increment is at least major
  And a patch decision is rejected
```

### FR3 — One stable authority produces one discoverable current version {#fr3}

Exactly one source line MUST be authorized to produce stable releases.
Current-version discovery MUST select the greatest eligible completed stable
version by SemVer precedence, independently of tag listing order or optional
aliases.

Incomplete, failed, retired, and explicitly withdrawn releases MUST NOT be
current. If no eligible completed stable release remains, discovery MUST report
that no current stable version exists. A lookup error MUST be surfaced and MUST
NOT be interpreted as withdrawal or absence.

#### FR3 scenarios

```gherkin
Scenario: Partial publication is not current
  Given version 2.4.0 has reached only one of two required destinations
  And version 2.3.2 is the greatest eligible completed stable release
  When current-version discovery runs
  Then it returns version 2.3.2
  And version 2.4.0 remains incomplete
```

### FR4 — Prereleases and release candidates identify the next stable candidate {#fr4}

A published prerelease MUST use the core version produced by applying its
resolved aggregate increment to the stable baseline and permanent reservations.
It MUST sort before the normal version with the same core and MUST NOT consume
that stable version. Successive versions in one prerelease series MUST increase
by SemVer precedence.

An ordinary prerelease MUST identify its source series. A dedicated release
candidate MUST use the constant `rc` identifier and an unpadded increasing
counter, such as `2.5.0-rc.1`. A single request MUST NOT select both ordinary
prerelease and release-candidate modes.

A prerelease MUST be testable but MUST NOT become the current stable release or
advance stable aliases. Cleanup MAY remove an exact prerelease and its record,
but MUST NOT reuse its identifier for different content.

#### FR4 scenarios

```gherkin
Scenario: A release candidate leaves its stable version available
  Given the stable baseline is 2.4.1
  And the approved aggregate decision is minor
  When release candidates are published
  Then they use 2.5.0-rc.1, 2.5.0-rc.2, and later counters
  And the stable version 2.5.0 remains available
```

### FR5 — A durable record is authoritative for release lifecycle state {#fr5}

Before build, the capability MUST persist a release intent containing its
identity, fixed source and included range, approval evidence, aggregate decision,
resolved version, notes, required destinations, and current stage. After build it
MUST also retain the artifact fingerprint and verification and publication
progress.

The lifecycle MUST distinguish pending or resolved work, successful build,
successful verification, partial publication, completion, failure, explicit
retirement, and withdrawal of a completed release. Workflow runs, tags, and
destination listings are observations of that lifecycle; none alone is the
authoritative state.

Resolve MAY allocate a version before build. The reservation becomes permanent
when a build succeeds or any release coordinate becomes externally visible. A
permanent reservation survives failure, retirement, withdrawal, and deletion at
a destination. A resolved request with no successful build and no external
visibility MAY be explicitly superseded while coalescing pending work.

#### FR5 scenarios

```gherkin
Scenario: External visibility permanently reserves a version
  Given a release exposes version 3.1.0 at one destination
  And publication then fails elsewhere
  When a later release is resolved
  Then version 3.1.0 remains reserved for the original source and artifact
  And the later release cannot reuse it
```

### FR6 — The verified artifact is the artifact that is published {#fr6}

The version MUST be fixed before the artifact is built. Build MUST create the
artifact once, after which the artifact MUST remain unchanged. Verification and
every publishing destination MUST consume those same bytes.

The successful artifact, its fingerprint, and verification evidence MUST remain
available for the entire unresolved lifetime of its release intent. A failed
build that produced no complete artifact MAY run again. A correction that changes
bytes MUST resolve a new version and produce a new artifact.

#### FR6 scenarios

```gherkin
Scenario: Build, verification, and publication share one artifact
  Given a release is resolved to version 1.8.0
  When build, verification, and publication succeed
  Then the published fingerprint equals the verified build fingerprint
  And no later stage rebuilt or modified the artifact
```

### FR7 — Recovery resumes the recorded phase without changing identity {#fr7}

A retry MUST load the original release intent and resume only unfinished or
failed work. It MUST reuse the frozen source, decision, version, notes,
destinations, successful artifact fingerprint, verification evidence, and
completed publications. It MUST NOT re-resolve from edited labels, changed
configuration, a later branch tip, or a later pull-request description.

If the retained artifact is missing, recovery MUST stop with an explicit error.
Restoring bytes that match the recorded fingerprint MAY permit resumption;
rebuilding under the same permanently reserved version MUST NOT.

An unrecoverable built or externally visible intent MAY be explicitly retired.
Retirement MUST preserve its failure record and permanent reservation and MUST
NOT mark it complete. A corrective release requires separate approval and a new
version.

#### FR7 scenarios

```gherkin
Scenario: A partial publication resumes at the missing destination
  Given a verified artifact reached one of two required destinations
  When the release is retried
  Then the completed publication is verified and reused
  And the same artifact is published only to the unfinished destination

Scenario: Missing retained bytes stop recovery
  Given a release has a successful recorded build
  And no retained or published copy matches its fingerprint
  When recovery runs
  Then recovery fails with a missing-artifact error
  And no rebuild occurs under the reserved version
```

### FR8 — Every required destination completes before the release completes {#fr8}

One release MAY publish to multiple destinations, but MUST use the same canonical
identity and notes at each. The release MUST remain incomplete until every
required artifact and release record is published successfully. Completed
destination work MUST be recorded and reused idempotently.

Completion announcements MUST be separate from artifact publication. Delivery
progress MUST be retained per release and destination, and an unacknowledged
delivery MAY be retried with at-least-once semantics. Announcement failure MUST
NOT create another version, rebuild, republish the artifact, or revoke an
otherwise complete release.

#### FR8 scenarios

```gherkin
Scenario: Announcement retry does not create another release
  Given version 4.2.0 is complete
  And one announcement destination did not acknowledge delivery
  When announcement delivery is retried
  Then the same release identity and message context are reused
  And no new version, build, or artifact publication occurs
```

### FR9 — Every destination satisfies the publishing-target contract {#fr9}

Every publishing destination MUST document:

- its native version syntax and canonical SemVer mapping;
- prerelease representation, validation, and ordering;
- immutability and the strongest consumer reference;
- withdrawal, unpublish, or yank behavior;
- supported moving-alias families;
- native version-constraint support; and
- the location of its durable release record.

Distinct canonical releases MUST NOT map to one native coordinate. A mapping
collision or disagreement between the canonical prerelease status and a native
prerelease flag MUST fail rather than overwrite or misrepresent a release.

#### FR9 scenarios

```gherkin
Scenario: A native coordinate collision blocks publication
  Given two canonical releases map to one destination version
  When the second mapping is validated
  Then publication fails before content is overwritten
  And the original coordinate remains unchanged
```

### FR10 — The release record covers the complete included change {#fr10}

Release notes MUST account for every change from the previous completed stable
source through the fixed release source, including skipped and direct changes.
They MUST preserve contributor-authored title, description, adoption guidance,
consumer-change evidence, and maintainer evidence under
[PR Format](../../Ways-of-Working/PR-Format.md), or equivalent reviewed aggregate
context for a manual release.

The resolved version, version baseline, change baseline, fixed source, artifact
fingerprint, effective decision and source, destination coordinates, and note
snapshot provenance MUST be retained as a publication envelope without replacing
or rewriting the authored note.

#### FR10 scenarios

```gherkin
Scenario: A later release includes a skipped change
  Given change A was merged with a skip decision
  And approved change B triggers the next release
  When release notes are frozen
  Then the notes and aggregate decision cover A and B exactly once
```

### FR11 — Eligibility evaluates the complete unreleased artifact scope {#fr11}

Only changes that affect the delivered artifact or a supported consumer contract
MUST produce a release. Eligibility MUST evaluate the complete unreleased range,
including direct and transitive build inputs, rather than only the latest change.
Validation MUST still run when publication is skipped.

Without configured scope, every changed path MUST be treated conservatively as
release-affecting. A repository MAY narrow the scope explicitly. File categories
such as documentation or workflow definitions MUST NOT be universally excluded,
because they can be the product or an artifact input.

#### FR11 scenarios

```gherkin
Scenario: An out-of-scope change validates without publishing
  Given the repository declares its artifact-affecting scope
  And the full unreleased range contains no matching change
  When release processing runs
  Then validation runs
  And no version or release is published
```

### FR12 — Release requests are serialized and accounted for in source order {#fr12}

Release work on the same release line MUST NOT run concurrently and MUST queue
rather than cancel in-flight publication. Requests MUST be reconciled in source
history order, independently of worker start order. Duplicate event delivery
MUST return the same intent or outcome.

A missed event, replaced worker, or bounded execution queue MUST NOT silently
discard a release request. Pending work MUST remain recoverable from durable
state or source history before later source revisions advance the line.

After intervening changes, a built or externally visible intent MUST first be
resumed or explicitly retired. Remaining unbuilt and unexposed requests MAY be
backfilled individually or coalesced under a reviewed aggregate decision. Every
original request MUST record the release that accounts for it.

#### FR12 scenarios

```gherkin
Scenario: Later work cannot overtake an unresolved intent
  Given changes A and B reached the stable line in that order
  And A has a built incomplete release
  When B is processed
  Then A is resumed or explicitly retired first
  And B cannot replace A's reserved version or artifact
```

### FR13 — Moving aliases are closed, optional, and withdrawal-aware {#fr13}

The available moving-alias families MUST be exactly `latest`, major, and minor.
Each family MUST be enabled independently and MUST default to disabled. Unknown
families or unsupported target combinations MUST fail configuration validation.

An enabled alias MUST resolve to the greatest eligible completed stable version
matching its family. A new older release MUST NOT move an alias backward.
Withdrawal MUST reselect the greatest remaining eligible match, which may be an
older version. If no eligible match remains, the alias MUST be removed or
disabled rather than left on an ineligible release. Prereleases MUST NOT move a
stable alias.

#### FR13 scenarios

```gherkin
Scenario: Withdrawal reselects an alias
  Given the major alias points to completed stable version 3.4.0
  And completed stable version 3.3.2 remains eligible
  When version 3.4.0 is explicitly withdrawn
  Then the major alias is reconciled to 3.3.2
  And the withdrawn version remains reserved
```

### FR14 — Consumer update policy is explicit and trust-aware {#fr14}

A consumer MAY select exactly one of these policies:

| Policy | Accepted movement |
| --- | --- |
| `latest` | The newest eligible stable release, including a new major. |
| `lock-major-boundary` | Minor and patch releases within one selected major. |
| `lock-minor-boundary` | Patch releases within one selected major and minor. |
| `lock-specific-version` | No automatic movement from one exact version. |
| `lock-immutable-fingerprint` | No automatic movement from one exact content identity. |

When no policy is selected, the consumer MUST use the most immutable reference
available. A boundary policy MUST be available only when the producer and target
publish the corresponding major or minor alias. Where the consumer syntax
accepts no version range, the producer alias carries that bound; a range-like
string MUST NOT be treated as a resolver expression.

Mutable aliases MAY be used only within the consumer's permitted trust boundary.
An external producer, including one owned by another team in the same company,
MUST be pinned to an immutable fingerprint or exact immutable version. `latest`
MAY discover a release without an alias, then resolve it to the reference allowed
by the trust boundary.

#### FR14 scenarios

```gherkin
Scenario: An unsupported boundary policy fails explicitly
  Given a consumer requests lock-minor-boundary
  And the producer does not publish the minor alias family
  When the policy is resolved
  Then the request fails as unsupported
  And it is not widened to latest or a major boundary

Scenario: An external producer remains immutable
  Given a consumer selects latest for a producer outside its trust boundary
  When the current release is discovered
  Then the durable consumer reference is its immutable fingerprint
  And no moving producer alias is retained
```

### FR15 — Release-decision validation blocks an invalid merge {#fr15}

Every pull request targeting a release line MUST receive a named release-decision
check required by branch policy. The check MUST re-evaluate when source, owned
release markers, or release settings change. A missing, conflicting, or invalid
decision MUST fail; a valid skip MUST pass with an explicit no-release result.
A failed, pending, absent, or stale required result MUST block manual and
automated merge.

#### FR15 scenarios

```gherkin
Scenario: Decision input changes invalidate the prior result
  Given a pull request has a successful release-decision check
  When its only owned decision is removed
  Then the check is rerun
  And merge remains blocked until the new inputs resolve validly
```

### FR16 — Withdrawal preserves history and requires explicit authorization {#fr16}

A completed release MAY be withdrawn only through an explicit
maintainer-authorized operation. Withdrawal MUST be recorded separately from the
original completion and MUST preserve source history, approval evidence,
artifact identity, destination outcomes, announcements, and version reservation.
Ordinary deprecation or a temporary lookup failure MUST NOT imply withdrawal.

Replaying a withdrawn release MUST report its withdrawn outcome. It MUST NOT
recreate removed records, resend the completion announcement, or make the
release current again. Correcting a bad release MUST roll forward with a newly
approved version.

#### FR16 scenarios

```gherkin
Scenario: Withdrawal does not erase completion
  Given version 5.1.0 completed and was announced
  When an authorized maintainer withdraws it
  Then its completion and announcement history remain recorded
  And replay reports the withdrawal without recreating or re-announcing it
```

### FR17 — Published-note corrections are auditable metadata changes {#fr17}

A correction to published explanatory metadata MUST retain the original and
corrected content, reason, source evidence, actor, and time. It MUST NOT change
the artifact, exact version reference, fixed source, release decision, or
behavior attributed to that version. Unverifiable historical facts MUST be
recorded as evidence gaps rather than guessed.

#### FR17 scenarios

```gherkin
Scenario: A note correction cannot change release identity
  Given a completed release has incorrect explanatory text
  When an authorized correction is applied
  Then the original and corrected text and evidence are retained
  And the version, source, and artifact fingerprint remain unchanged
```

## Non-functional requirements

### NFR1 — Published versions are immutable {#nfr1}

One hundred percent of published stable versions MUST remain bound permanently
to their original source and artifact. A version identifier MUST NOT be reused
after failure, retirement, withdrawal, unpublish, or repository recreation.
Destination-native immutability controls MUST be enabled where available.

#### NFR1 scenarios

```gherkin
Scenario: A withdrawn version cannot be reused
  Given stable version 2.0.0 was published and later withdrawn
  When different content requests version 2.0.0
  Then publication is rejected
  And the original reservation remains authoritative
```

### NFR2 — Recovery retains all unresolved release evidence {#nfr2}

One hundred percent of unresolved built release intents MUST retain the artifact
fingerprint, frozen inputs, and phase progress required for safe resumption until
they complete or are explicitly retired.

#### NFR2 scenarios

```gherkin
Scenario: An unresolved release remains recoverable
  Given a verified release is incomplete
  When its worker and workflow run no longer exist
  Then its durable record still identifies the artifact and remaining work
```

### NFR3 — Release behavior is shared and GitHub-native {#nfr3}

One hundred percent of governed repositories MUST inherit one shared release
behavior, with zero repository-local copies of the resolution or lifecycle
algorithm. Contributors and maintainers MUST be able to drive decisions, manual
requests, retries, retirement, withdrawal, and evidence through GitHub pull
requests, owned labels, comments, checks, and workflow dispatch without a
separate local release tool.

#### NFR3 scenarios

```gherkin
Scenario: Equivalent repositories resolve equivalent requests consistently
  Given two repositories inherit the same release capability and policy
  When equivalent approved release requests are processed
  Then they apply the same lifecycle, version, and recovery rules
```

### NFR4 — New destinations do not change the lifecycle contract {#nfr4}

One hundred percent of new artifact types and destinations MUST be added through
the publishing-target contract without changing the requirements or release
lifecycle.

#### NFR4 scenarios

```gherkin
Scenario: A new destination uses the existing lifecycle
  Given a destination satisfies the publishing-target contract
  When it is added to a release
  Then Resolve, Build, Verify, Publish, completion, and recovery retain their existing meaning
```

## Acceptance criteria

```gherkin
Scenario: AC1 A reviewed merge completes one durable stable release
  # Verifies: FR1, FR2, FR3, FR5, FR6, FR8, FR10
  Given the current stable release is 1.4.2
  And an approved in-scope pull request resolves to minor
  When every required destination succeeds
  Then exactly one completed release 1.5.0 is recorded
  And its notes, fixed source, artifact fingerprint, and destination coordinates are durable
  And current-version discovery returns 1.5.0

Scenario: AC2 An interrupted release resumes without identity drift
  # Verifies: FR5, FR6, FR7, FR8, FR12
  Given a verified artifact is published to only one required destination
  And later commits reach the stable line
  When the original release is retried
  Then it completes the missing destination with the recorded artifact
  And its source, version, notes, and completed publication remain unchanged

Scenario: AC3 Withdrawal changes eligibility without changing history
  # Verifies: FR3, FR5, FR13, FR16, NFR1
  Given two completed stable releases and aliases pointing to the newer one
  When the newer release is explicitly withdrawn
  Then discovery and aliases select the older eligible release
  And the withdrawn release's completion history and version reservation remain
```

## Where this connects

- [Design](design.md) — how the intended lifecycle and current implementation
  coverage realize these requirements.
- [Publishing Targets](design-publishing-targets.md) — the destination contract
  and native behavior.
- [Automation Labels](../../Ways-of-Working/Automation-Labels.md) — the owned
  release instruction vocabulary.
- [PR Format](../../Ways-of-Working/PR-Format.md) — the authored release note and
  consumer evidence.
- [Dependencies](../../Coding-Standards/Dependencies.md) — dependency pinning and
  update trade-offs.
