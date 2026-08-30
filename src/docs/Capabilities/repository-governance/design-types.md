---
title: Repository Types
description: The repository type catalogue — the branch-model types, the layering types, the exemption type, and the rules by which they compose.
---

# Repository Types

A repository's type is the whole of its governance input. This page is the
catalogue: what each type means, what it implies, and which combinations are
valid.

Types divide into three kinds, and the distinction is what makes them
composable:

| Kind | Decides | How many a repository has |
| --- | --- | --- |
| **Branch-model type** | Which branches exist, which are protected, and how a change merges | Exactly one, whether declared or defaulted |
| **Layering type** | An additional obligation — a required check, an extra file, a review adjustment | Any number, including none |
| **Exemption type** | That the baseline does not apply | Alone, or not at all |

A branch-model type answers "how does a change reach the protected branch?" A
layering type answers "what else must be true before it does?" Because those are
different questions, they MUST NOT be values in competition — which is why the
type property is multi-valued ([FR2](spec.md#classification)).

## Branch-model types

### Standard

The default. One protected branch. Topic branches merge into it by any method the
organization permits.

| | |
| --- | --- |
| Protected branches | The default branch |
| Merge methods | Any the organization permits |
| Applies to | Repositories whose history does not need to be one-commit-per-change, and which do not promote between environments |

Standard is what a repository gets when it declares nothing. That is deliberate:
the absence of a decision MUST produce protection, not the absence of protection
([FR1](spec.md#classification)).

### Artifact

Artifact is a **layering type**, not a branch model. It adds a linear-history
contract to whichever branch model applies.

| | |
| --- | --- |
| Branch model | None of its own — Standard applies by default, or Infrastructure when declared |
| Protected branches | The default branch, or the Infrastructure integration branch |
| Merge methods | Squash only where the artifact history rule applies |
| Additional rule | Linear history required |
| Applies to | Anything published under a version — packages, modules, container images, Actions, reusable workflows, extensions |

The constraint exists because a versioned artifact's history is read backwards. A
regression is traced by bisecting releases, and a release note is assembled from
the commits between two tags. Both work when one commit is one change and fail
when a merge commit hides five. This is the history contract [release
management](../release-management/design.md#branching-model) depends on.

### Infrastructure

Two protected branches and a **promotion flow** between them: changes integrate
on one branch and are promoted to the other.

| | |
| --- | --- |
| Protected branches | The integration branch (the default) and the production branch |
| Merge into the integration branch | Squash only, from topic branches |
| Merge into the production branch | Merge commit, from the integration branch only |
| Additional check | A promotion-source check that fails when the head branch is not the integration branch |
| Applies to | Repositories whose changes must be observed working in one place before reaching another |

Two rules make the flow real rather than conventional. **The production branch
accepts only the integration branch** — enforced by a required check that reads
the head branch, because branch protection alone cannot express "from this branch
only". And **promotion merges rather than squashes**, so the individual changes
promoted stay individually visible on the production branch, rather than
collapsing into one commit that says only "promote".

A repository on this model MAY keep a [standing promotion pull
request](../../Ways-of-Working/Branching-and-Merging.md#the-standing-promotion-pull-request)
so the difference between integrated and live is always one link away.

## Layering types

### Docs

**Docs is a layering type, not a branch model.** It declares that the repository
publishes documentation, and it adds the obligation that the documentation
**builds** before a change lands.

| | |
| --- | --- |
| Branch model | None of its own — the repository's branch-model type decides, defaulting to Standard |
| Adds | A required documentation-build check on every protected branch |
| Adds | The documentation source root and its build configuration to the required files |

This orthogonality is the point. How documentation is published has nothing to do
with whether the repository promotes between environments, so the two MUST be
separately declarable: a repository can be an infrastructure stack whose
documentation also builds, and expressing that MUST NOT require inventing a
combined type.

A repository that is Docs **and nothing else** — where the published site is the
product — MAY carry a weaker review gate than a repository shipping executable
code, because its build check verifies more of what could break. Whether it does
is an organization decision ([FR12](spec.md#the-review-gate)).

## The exemption type

### Unmanaged

Declares that the baseline does not apply to this repository, and why.

| | |
| --- | --- |
| Branch model | None |
| Baseline | Not applied |
| Requires | A recorded reason ([FR14](spec.md#exemption)) |
| Still requires | The files that make the repository understandable — a README, a security policy, and its agent router ([FR15](spec.md#exemption)) |

Unmanaged exists so that "this repository is not governed" is a **statement**
rather than an oversight. Without it, the only way to express an exemption is to
leave a repository unclassified, and an unclassified repository is
indistinguishable from a forgotten one. With it, the exemptions are a list that
can be reviewed, questioned, and shortened.

An archive, a scratch mirror, or a repository whose content is generated wholesale
by another system are the shapes this fits. A repository people actively develop
in is not.

## Composition and precedence

| Declared | Resulting governance |
| --- | --- |
| Nothing | Standard branch model, baseline applied |
| Standard | Standard branch model, baseline applied |
| Artifact | Standard branch model by default, plus the artifact history rule |
| Infrastructure | Promotion flow, baseline applied |
| Standard **+** Docs | Standard branch model, plus the documentation-build check |
| Artifact **+** Docs | Standard branch model by default, plus the artifact history and documentation-build rules |
| Infrastructure **+** Docs | Promotion flow, plus the documentation-build check on both protected branches |
| Infrastructure **+** Artifact | Promotion flow; the artifact history rule applies to merges into the integration branch, and the promotion merge remains a merge commit |
| Docs alone | Standard branch model by default, plus the documentation-build check |
| Unmanaged | No baseline; the recorded reason applies |

Precedence, stated once:

1. **Unmanaged wins over everything, and combines with nothing.** If it is
   declared alongside another type, the declaration is contradictory, not
   permissive.
2. **Exactly one branch model applies.** Standard is the default where no
   branch-model value is declared; Infrastructure replaces that default when it is
   declared. Artifact is a layering type, so it never competes for the branch
   model.
3. **Layering types always apply.** A layering type never loses to a branch-model
   type; it adds to whichever one wins.

## Validation rules

A declaration MUST be rejected when:

- It contains a value outside the organization's allowed list ([FR3](spec.md#classification)).
- It contains **Unmanaged together with any other type**. Exemption is total or absent.
- It contains more than one explicit branch-model type. Standard and Infrastructure
  cannot both be declared because each decides the protected-branch shape.
- It declares **Unmanaged without a reason** ([FR14](spec.md#exemption)).

A declaration MUST be accepted when it contains one branch-model type and any set
of layering types, and when it contains only layering types — the branch model
then defaults to Standard.

Validation belongs in [reconciliation](design.md#drift-detection-and-reconciliation)
at **Block** severity: a contradictory type does not produce weaker protection, it
produces undefined protection, and undefined protection MUST NOT be reachable by
setting a property.

## Where this connects

- [Spec](spec.md) — the requirements this catalogue satisfies.
- [Design](design.md) — how the types are declared and how controls read them.
- [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) — the property mechanism, its condition pattern, and safe migration.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — the merge models the branch-model types select.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md#required-files-by-type) — the files each type requires.
- [Release Management](../release-management/design.md) — the consumer of the Artifact history contract.
