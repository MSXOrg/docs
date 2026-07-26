---
title: Issue Lifecycle
description: How issue bodies, types, readiness, and relationships evolve through the workflow.
---

# Issue Lifecycle

[Workflow](../../Workflow.md) is the sole definition of the Capture, Refine, Plan, Build, Review, Ship, and Operate phases. This page maps only how an issue's body, native type, readiness, and relationships evolve while work passes through those phases.

| Workflow phase | Issue evolution |
| --- | --- |
| **Capture** | Create the issue with the known need, affected user or operator, and desired outcome. Assign the best provisional native type. The item is not ready merely because it exists; add native relationships only when they are already known. |
| **Refine** | Correct the body until the problem, local purpose, scope, and observable acceptance criteria are clear. Correct the type when the planning altitude becomes known. Discover containment and dependencies and record them as [native relationships](Relationships.md). |
| **Plan** | Add the decisions and decomposition appropriate to the type's [planning altitude](Planning.md). Promote, demote, or split the issue when its scope requires a different type. Establish sub-issues and dependency edges, then mark the item ready only when it meets the [Definition of Ready](../../Definition-of-Ready-and-Done.md#definition-of-ready). |
| **Build** | Pull a ready Task or Bug whose blockers are clear. Keep its body and checklist current as implementation changes the plan. Parent progress comes from native sub-issue completion, while blocked-by edges continue to gate execution. |
| **Review** | Verify the delivered change against the issue's current acceptance criteria and decisions. Keep the pull request draft until it meets the separate [Definition of Ready for Review](../../Definition-of-Ready-and-Done.md#definition-of-ready-for-review). Record plan or scope corrections in the issue body and audit them in comments. |
| **Ship** | Merge the reviewed delivery pull request and close its Task or Bug through the pull request's closing link. Native completion updates parent progress. Close a PBI or Epic only when its native children and aggregate acceptance criteria are complete. |
| **Operate** | Feed production signals and learning back into the issue model. Reopen the issue when its accepted outcome is no longer true, or capture a new issue and relate it natively when the signal describes distinct work. |

Readiness is a gate, not a phase label. A captured or refined issue remains unready until its intent, acceptance criteria, scope, dependencies, and open questions satisfy the shared readiness contract. Relationship and type changes follow the same [audit-trail rule](Format.md#audit-trail) as body changes.
