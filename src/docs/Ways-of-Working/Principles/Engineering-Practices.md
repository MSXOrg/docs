---
title: Engineering practices
description: Write it down, everything as code, evergreen documentation, test-driven development, fleet-wide change, and shift-left quality.
---

# Engineering practices

## Write it down

Knowledge held only in personal memory has three limitations:

- Other people cannot review it.
- It is not available for shared reflection.
- People can forget it.

**Write it down.** Record knowledge in issues, decisions, plans, and READMEs. Shared records let people and agents review, discuss, and act on that knowledge.

## Everything as code

Everything lives in source control, including workflows, configuration, infrastructure, processes, pointer files, and documentation. Source control gives people and agents a shared record to read, change, and review. An agent cannot read information held only in someone's memory.

## Code in code files

Code lives in a file of its own language — not embedded as a string inside YAML, JSON, a heredoc, or a template. Native code files support linting, formatting, type-checking, security scanning, tests, and editor features. Embedding code in another format hides it from tools that expect native source files.

- When one language must invoke another, call out to a script file rather than inlining the script. A workflow step runs a checked-in script; it does not carry a shell program inside a YAML string.
- Keep the host format declarative. Configuration declares *what*; the implementation it points to holds the *how*.

## Documentation lives close to the thing it documents

- Comment-based help lives next to the function.
- README lives at the root of the repo.
- Workflow guidance lives in the org-level docs (this site).
- Decisions live in the issue that produced them.

Documentation becomes harder to keep aligned when it is separate from the thing it describes.

## Evergreen documentation

Documentation states the **supported target state** in the present tense. Readers use it as the contract without reconstructing change history.

- Write the intended state as if it already exists. Remove hedging, status notes, and future or past framing of the work itself.
- Describe behavior and intent, not the process of building them. A pull request that adds a capability documents the capability, not the act of adding it.
- Keep task lists, TODOs, and change history in issues and pull requests — not in evergreen docs.
- Define a thing by what it is, not by contrast with an abandoned alternative. Lead with the positive fact.
- When something changes, edit the document in place so it stays current. Git history records what changed; the document records what is.

A documented target-state contract is not evidence that implementation or enforcement exists.

This applies to this site, every README, and every specification. A pull request description explains the result rather than the steps used to produce it.

## Intent is the source of truth

The documented intent is the source of truth for what the system is meant to be. It is recorded in default-branch specs and docs, and in issue descriptions. Implementation represents that intent. Running code shows actual behavior, not necessarily desired behavior.

Either intent or implementation can be wrong. When they disagree, **diagnose it** rather than assuming which is correct. If the intent is wrong, correct the doc, spec, or issue. If the implementation is wrong, correct the code. Reconcile the mismatch instead of silently trusting the code or rewriting the intent to match it.

## Test-driven development

Define the tests when you define the behavior. Update them when behavior changes. Tests are the executable specification.

## Shift Left

Move quality gates as early as possible in the development cycle. Earlier validation limits the work affected by a defect. Design solutions so validation occurs at the earliest possible point.

### Testable locally

Keep a fast local inner loop so a developer or agent can reason about behavior in the editor. The [Testing standard](../../Coding-Standards/Testing.md#testable-locally) owns the local-loop requirements, real-API checks, test-double exceptions, and execution evidence.

### Pre-commit hooks

Pre-commit hooks run validation on `git commit`, before the change enters history or a PR opens. Hooks make selected checks automatic instead of relying on the contributor to run them.

Typical gates include linting, formatting, static analysis, secret scanning, and fast unit tests. Keep them fast enough to avoid interrupting work. Slow hooks encourage bypass.

### Validatable in PRs

Every pull request must trigger automated checks that verify correctness before a human review begins. Tests, linting, module analysis, or any other relevant gate must run in CI on each PR.

Automated checks find regressions before review. Reviewers remain responsible for assessing the change.

## Local testing for quick iterations

Make it easy to build, test, and run locally. Short local feedback cycles reduce delays during implementation.

Feedback cycles include:

- **Innermost** — write code, save, see result. Sub-second.
- **Inner** — run tests, see result. Seconds to a minute.
- **Outer** — push, CI, review, merge. Minutes to hours.
- **Outermost** — release, deploy, user feedback. Days to weeks.

Run a check in the earliest cycle that can verify its result.

## 1-2-Automate

If a thing has been done twice, the third time it is automated. Start with automation when repetition is known in advance.

## Manage the fleet, not the repository

A change for a class of repositories applies to the whole class, not only one member. Treat repositories that share a declared property as a single managed population.

Source-controlled configuration, workflows, and policy let one mechanism apply a decision and verify the result across many repositories.

The obligations that follow:

- A change intended for a class of repositories is applied by a mechanism that covers the whole class, so no member is silently skipped.
- Membership is derived from a declared property of the repository, never from a hand-maintained list that drifts as repositories are created and retired.
- The desired state is expressed once, centrally, and distributed. A member that needs to differ records the deviation locally rather than quietly diverging.
- Drift is expected, not exceptional. Because a population changes underneath any decision, conformance is re-checked continuously and reconciled, rather than assumed to hold because it once did.
- The scale of the population is a design input. A step that is acceptable once by hand is not acceptable when it repeats across every member.

The goal is to keep manual effort independent of repository count. Per-repository manual work indicates that the mechanism needs improvement.

## DevOps and SRE

> You build it, you run it.

The same team owns development, integration, delivery, and operation as a continuous cycle. Build systems, practices, and teams that support this ownership.
