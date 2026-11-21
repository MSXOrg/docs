---
title: Repository Types
description: The repository type catalog, including branch models, layering types, exemption, and composition rules.
---

# Repository Types

A repository's type selects its governance controls. This catalog defines each
type, its obligations, and valid combinations.

Types have three distinct purposes:

| Kind | Decides | How many a repository has |
| --- | --- | --- |
| **Branch-model type** | Which branches exist, which are protected, and how a change merges | Exactly one, whether declared or defaulted |
| **Layering type** | An additional obligation — a required check, an extra file, a review adjustment | Any number, including none |
| **Exemption type** | That the baseline does not apply | Alone, or not at all |

A branch-model type answers "how does a change reach the protected branch?" A
layering type answers "what else must be true before it does?" These answer
different questions and MUST NOT compete for the same decision. The type
property therefore accepts multiple values ([FR2](spec.md#classification)).

## Branch-model types

### Standard

Standard is the default branch model. It has one protected branch. Topic
branches merge into it by any method the organization permits.

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

A versioned artifact uses one commit per change on its artifact branch.
This gives release comparisons and regression analysis the same change
boundaries. [Release management](../release-management/design.md#branching-model)
depends on this history contract.

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

Two enforced rules define promotion. **The production branch accepts only the
integration branch**. A required check reads the head branch because branch
protection alone cannot express this source constraint.
**Promotion merges rather than squashes**. Individual changes remain visible on
the production branch instead of becoming one commit that says only "promote".

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

Documentation publication and environment promotion are independent. They MUST
be separately declarable. A repository can contain an infrastructure stack and
build documentation. This combination MUST NOT require a combined type.

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

Unmanaged records an **explicit exemption**. It distinguishes a deliberate
exemption from a repository whose classification is missing. The recorded
exemptions form a list that can be reviewed, questioned, and shortened.

Contribution guidance follows the same
[conditional local-file rule](../../Ways-of-Working/Repository-Standard.md#contribution-guidance)
as governed repositories. Supported community guidance may be inherited; its
availability does not require a repository-local copy.

This type applies to archives, scratch mirrors, and repositories whose content
another system generates entirely. It does not apply to repositories with active
development.

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

[Reconciliation](design.md#drift-detection-and-reconciliation) enforces validation
at **Block** severity. A contradictory type produces undefined protection, not
weaker protection. Setting a property MUST NOT permit undefined protection.

## Where this connects

- [Spec](spec.md) — the requirements this catalog satisfies.
- [Design](design.md) — how the types are declared and how controls read them.
- [Repository Type Property](../../Ways-of-Working/Repository-Type-Property.md) — the property mechanism, its condition pattern, and safe migration.
- [Branching and Merging](../../Ways-of-Working/Branching-and-Merging.md) — the merge models the branch-model types select.
- [Repository Standard](../../Ways-of-Working/Repository-Standard.md#required-files-by-type) — the files each type requires.
- [Release Management](../release-management/design.md) — the consumer of the Artifact history contract.
