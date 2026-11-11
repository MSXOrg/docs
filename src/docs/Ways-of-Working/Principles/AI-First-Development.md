---
title: AI-first development
description: Agents as first-class participants, determinism before intelligence, and how humans and agents share the work.
---

# AI-first development

Development is AI-first. AI agents participate in planning, implementation, and delivery. Workflows, processes, and documentation support them as first-class participants.

The priority is **build deterministic software first, invoke AI where determinism falls short.** Deterministic tools handle work with a predictable, repeatable answer. AI handles ambiguity, judgment, creativity, natural language, and search spaces too large for handwritten rules.

AI remains available within the workflow for work that deterministic tools cannot handle.

## Determinism before intelligence

Use agents to **build** deterministic tools such as scripts, libraries, and converters. Then run the tool instead of spending LLM tokens on work a function call can do.

Practices:

- If a problem has a closed-form solution, write code — not a prompt.
- Use AI to generate the deterministic tool, then remove AI from the runtime path.
- Reserve AI for tasks that genuinely require reasoning, judgment, or natural language understanding.
- Review AI-powered workflows for steps that a deterministic function can replace.
- AI supports ad-hoc alignment work such as "do X across all repos". Codify the result as repeatable, deterministic automation.

## Human-agent coexistence

The workflow supports humans and agents working together. Agents follow the same process as people rather than a parallel system. The operating model is **human-first, agent-augmented**.

Documentation gives both audiences a shared source of standards, conventions, and principles. A separate "agent manual" is not required.

Agent context is delivered through three layers, in priority order:

1. **Documentation** — the primary source. Published documentation, READMEs, and issue bodies are written for humans and naturally consumable by agents.
2. **Canonical workflow** — one documented process owns the order of work and links to ordinary documentation for each stage procedure. Indexes provide the default discovery path; clear task language may shortcut stage selection without creating separate instructions.
3. **Local pointer files** — each repository's agent router, and the content-free client routes that reach it, which read outward from the repository's own files to the applicable organization and initiative documentation.

## Augmentation, not replacement

Agents automate mechanical work to support faster, more consistent delivery. **Human in the loop** remains the default for decisions that matter.

## One workflow, not a swarm

Treat the agent ecosystem as participants in one shared workflow. Stages and specialized reviews divide responsibility while preserving shared knowledge and a consistent voice.

## Self-improving agents

Agents need feedback and a way to process it. Workflow stages evolve as lessons accumulate. Record those lessons in stage descriptions and shared documentation instead of relying on personal memory.

## Integration and sensoring

- **Integration** — the agent's ability to act on a platform as if it were human. GitHub, the editor, the terminal.
- **Sensoring** — the agent's ability to notice that it is needed. Webhooks, scheduled checks, signals from the platform.

## Context-first development

Every change starts with context before code:

```text
Intention of change → Update documentation → Update README → Update tests → Update code
```

The README and the documentation are the **specification**. Tests validate the intended interface. A change needs documented context before implementation so people and agents know the contract.

This means:

- A new feature starts as a documented intent (issue, README update, or docs change) before any code is written.
- Tests are written or updated to assert the interface the documentation describes — before the implementation exists.
- A refactor updates the relevant documentation **first**, then the tests, then the code follows to match.
- If the docs and the code disagree, the docs are wrong — fix the docs, fix the tests, then fix the code to match.

Agents use documented context to guide changes. Correct, complete context gives them the intended contract before they build.

## Context as a product

Context maintenance keeps shared records **correct, evergreen, and declarative** alongside software delivery:

- **Software delivery** produces code, tests, and releases using source control, CI/CD, and DevOps practices.
- **Context maintenance** produces issues, decisions, READMEs, pointer files, and documentation — and treats them as products that must be kept current.

Both run continuously. Each iteration of software delivery produces context that needs maintenance; each iteration of context maintenance unblocks the next round of software work.

## 4-eyes (or N-eyes) principle

Every change benefits from a second perspective. With AI in the loop, that can be:

- A human reviewing your work.
- You discussing ideas with an agent.
- Multiple agents reviewing each other's output against the same standards.

The goal is to find issues that a single perspective misses.

## Code review as shared practice

Pull request reviews are not just a quality gate — they are a cultural practice. Reviewing serves multiple purposes beyond catching defects:

- **Learning and awareness.** Reviews share knowledge across the team. Reviewers learn how an area works; authors learn alternative approaches. Repeated reviews broaden the team's understanding of the codebase.
- **Shared responsibility.** The author proposes a sound change. The reviewer verifies that it meets the team's standards. Both share ownership and responsibility for the merged result.

Reviews are collaborative rather than adversarial. An approval records the reviewer's support for the change. The author uses feedback to consider another perspective. Both roles carry shared responsibility.

## Decision before change

Every change passes at least one deliberate decision point before it takes effect. A pull request approval is a decision — the reviewer actively commits to the change alongside the author. A deployment approval is a decision before a release reaches a protected environment.

Nothing irreversible happens automatically and without review. At least one reviewed gate separates a proposal from its effect.
