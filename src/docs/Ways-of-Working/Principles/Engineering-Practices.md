---
title: Engineering practices
description: Write it down, everything as code, evergreen docs, test-driven development, and shift-left quality.
---

# Engineering practices

## Write it down

If something is only in your head:

- Nobody else can work with you on it.
- You cannot reflect on it.
- It can escape you and be lost.

**Write it down.** Issues, decisions, plans, READMEs. Writing is how knowledge becomes shared and how agents can help.

## Everything as code

Everything — workflows, configuration, infrastructure, processes, agent definitions, even the docs you are reading — lives in source control. This is the bedrock of human-agent interaction. An agent can read code, change code, propose code. It cannot read what's only in someone's memory.

## Code in code files

Code lives in a file of its own language — not embedded as a string inside YAML, JSON, a heredoc, or a template. Code in its own file gets the full benefit of tooling: linting, formatting, type-checking, security scanning, tests, and editor support. The same code inlined into another format gets none of it.

- When one language must invoke another, call out to a script file rather than inlining the script. A workflow step runs a checked-in script; it does not carry a shell program inside a YAML string.
- Keep the host format declarative. Configuration declares *what*; the implementation it points to holds the *how*.

## Documentation lives close to the thing it documents

- Comment-based help lives next to the function.
- README lives at the root of the repo.
- Workflow guidance lives in the org-level docs (this site).
- Decisions live in the issue that produced them.

Distance between a thing and its documentation is the rate at which they drift apart.

## Evergreen documentation

Documentation describes the system as it **is**, in the present tense — not the history of how it got there. A reader (human or agent) should be able to trust any page as the current truth without knowing what changed or when.

- Write the intended state as if it already exists. Cut hedging, status notes, and "we will" or "we did".
- Describe behavior and intent, not the process of building them. A pull request that adds a capability documents the capability, not the act of adding it.
- Keep task lists, TODOs, and change history in issues and pull requests — not in evergreen docs.
- Define a thing by what it is, not by contrast with an abandoned alternative. Lead with the positive fact.
- When something changes, edit the document in place so it stays current. Git history records what changed; the document records what is.

This governs this site, every README, and every specification — and it is why a pull request description states what the change *contributes*, not the steps taken to produce it.

## Test-driven development

Define the tests when you define the behavior. Update them when behavior changes. Tests are the executable specification.

## Shift Left

Move quality gates as early as possible in the development cycle. The later a problem is caught, the more expensive it is to fix — a failing test in the editor is free; a bug in production is not. Design solutions so that validation happens at the earliest possible moment, not as an afterthought.

### Testable locally

A developer (or agent) must be able to run the full test suite locally, without requiring cloud resources, special access, or environment secrets that can't be mocked. If you can't test it on your machine, you can't reason about it in your editor.

This is a design constraint, not an optional addition. A solution that is untestable locally has a hidden cost that compounds with every change. When building new workflows, modules, or automation, ask early: *can someone run this locally?*

### Pre-commit hooks

Validation that runs automatically on `git commit` — before the change enters history and before a PR is opened. Pre-commit hooks close the gap between "I can test it locally if I choose to" and "it is always checked before it leaves my machine."

Typical gates: linting, formatting, static analysis, secret scanning, and fast unit tests. Keep them fast enough to not interrupt flow — if a hook takes more than a few seconds, it will be bypassed.

### Validatable in PRs

Every pull request must trigger automated checks that verify correctness before a human review begins. Tests, linting, module analysis, or any other relevant gate must run in CI on each PR.

A solution without PR validation shifts the cost of catching regressions onto reviewers — and reviewers miss things. Automation catches what humans don't, consistently and at no extra cost per PR.

## Local testing for quick iterations

Make it easy to build, test, and run locally. The inner loop is where most engineering time is spent — every second saved there compounds.

Inner / outer loops to be aware of:

- **Innermost** — write code, save, see result. Sub-second.
- **Inner** — run tests, see result. Seconds to a minute.
- **Outer** — push, CI, review, merge. Minutes to hours.
- **Outermost** — release, deploy, user feedback. Days to weeks.

Push work as far inward as it can go.

## 1-2-Automate

If you've done a thing twice, the third time it should be automated. Sometimes you already know — go straight to automation. Extreme automation is often the right starting point.

## DevOps and SRE

> You build it, you run it.

Everything is continuous — development, integration, delivery, operation. The same team owns the system across the loop. Build the systems, the practices, and the teams that internalize this.
