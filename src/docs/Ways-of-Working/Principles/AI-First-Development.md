---
title: AI-first development
description: Agents as first-class participants, determinism before intelligence, and how humans and agents share the work.
---

# AI-first development

We practice AI-first development. AI agents are part of how we think, build, and deliver — not an afterthought bolted on at the end. Every workflow, every process, and every piece of documentation is designed with agents as first-class participants.

That said, engineering is not fully non-deterministic. Our priority order is clear: **build deterministic software first, invoke AI where determinism falls short.** A script that always produces the correct answer is better than a prompt that usually does. AI fills the gaps that deterministic logic cannot cover — ambiguity, judgment, creativity, natural language, and tasks where the search space is too large for hand-written rules.

The result: AI is always available, always integrated, always ready — but it earns its place by handling what deterministic tools cannot.

## Determinism before intelligence

LLM tokens are not the right tool for work that has a deterministic answer. Use agents to **build** the deterministic tool — a script, a library, a converter — and then run the tool. Don't burn tokens on work a function call can do.

Practices:

- If a problem has a closed-form solution, write code — not a prompt.
- Use AI to generate the deterministic tool, then discard the AI from the runtime path.
- Reserve AI for tasks that genuinely require reasoning, judgment, or natural language understanding.
- Audit existing AI-powered workflows: can any step be replaced by a deterministic function?
- AI is excellent for ad-hoc alignment work — "do X across all repos" — but the end goal is always to codify the result into repeatable, deterministic automation.

## Human-agent coexistence

The workflow is designed for humans and agents working side by side. Agents join a good human way of working — they do not replace it or require a parallel system. The operating model is **human-first, agent-augmented**.

Agents are trained to read documentation. That is their natural skill. By keeping standards, conventions, and principles in documentation format we serve both audiences with a single artifact — no separate "agent manual" required.

Agent context is delivered through three layers, in priority order:

1. **Documentation** — the primary source. Published docs at <https://msxorg.github.io/docs/>, READMEs, and issue bodies are written for humans and naturally consumable by agents.
2. **Central agent configuration** — organization-wide agent files in `.github-private`. Thin orchestrators built mostly from references to the docs. They define roles, boundaries, and procedural steps — not standards or conventions.
3. **Local repository files** — `.github/` instruction files and repo-level overrides for what is unique to a single repository.

## Augmentation, not replacement

Agents amplify the team. They make us faster, more consistent, and free us from work that is mechanical. **Human in the loop** remains the default for decisions that matter.

## Persona, not swarm

Treat the agent ecosystem as one team mate. Many specialized roles, one cohesive bank of knowledge, one consistent voice.

## Self-improving agents

Agents need feedback and a way to process it. Every agent definition should evolve as we learn. Capture lessons in the agent definitions and in this docs section — don't let them live only in someone's head.

## Integration and sensoring

- **Integration** — the agent's ability to act on a platform as if it were human. GitHub, the editor, the terminal.
- **Sensoring** — the agent's ability to notice that it is needed. Webhooks, scheduled checks, signals from the platform.

## Context-first development

Every change flows through context before it touches code:

```text
Intention of change → Update documentation → Update README → Update tests → Update code
```

Code echoes the docs, not the other way around. The README and the docs are the **specification**. Tests validate the interface we want to see. If a change isn't reflected in context first, the code has no contract to implement against — and agents have nothing to read.

This means:

- A new feature starts as a documented intent (issue, README update, or docs change) before any code is written.
- Tests are written or updated to assert the interface the documentation describes — before the implementation exists.
- A refactor updates the relevant documentation **first**, then the tests, then the code follows to match.
- If the docs and the code disagree, the docs are wrong — fix the docs, fix the tests, then fix the code to match.

This is what makes agentic development work at scale. Agents read context. If the context is stale or missing, the agent builds the wrong thing. Keeping context ahead of code is how we stay in control.

See [README-Driven Context](Readme-Driven-Context.md).

## Context as a product

The work of keeping context **right, evergreen, and declarative** runs alongside software delivery:

- **Software delivery** produces code, tests, and releases using source control, CI/CD, and DevOps practices.
- **Context maintenance** produces issues, decisions, READMEs, agent definitions, and documentation — and treats them as products that must be kept current.

Both run continuously. Each iteration of software delivery produces context that needs maintenance; each iteration of context maintenance unblocks the next round of software work.

See [Workflow](Workflow.md) for how these connect in practice.

## 4-eyes (or N-eyes) principle

Every change benefits from a second perspective. With AI in the loop, that can be:

- A human reviewing your work.
- You bouncing ideas off an agent.
- Multiple agents reviewing each other's output against the same standards.

The goal is the same: catch what one perspective misses.

## Code review as shared practice

Pull request reviews are not just a quality gate — they are a cultural practice. Reviewing serves multiple purposes beyond catching defects:

- **Learning and awareness.** Reviews spread knowledge across the team. A reviewer learns how a new area works; an author learns alternative approaches. Over time, the entire team develops a broader understanding of the codebase.
- **Shared responsibility.** Both author and reviewer share ownership of the changes that land. The author is responsible for proposing a sound change; the reviewer is responsible for validating it meets the team's standards. Once merged, the change belongs to both — neither can disclaim it.

This means reviews are not adversarial. They are collaborative. A reviewer who approves a change is co-signing it. An author who receives feedback is gaining a perspective they didn't have alone. Treat both roles with the seriousness they deserve.

## Decision before change

Every change passes at least one deliberate decision point before it takes effect. A pull request approval is a decision — the reviewer actively commits to the change alongside the author. A deployment approval is a decision before a release reaches a protected environment.

The point is not ceremony; it is that nothing irreversible happens automatically and unwitnessed. At least one reviewed gate stands between a proposal and its effect.
