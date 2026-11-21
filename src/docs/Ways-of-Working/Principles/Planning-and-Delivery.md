---
title: Planning and delivery
description: Roadmapping, lean delivery, and the loops that keep iteration fast.
---

# Planning and delivery

## Roadmapping

Planning happens in a 3×3 matrix:

|              | Now          | Next           | Later          |
| ------------ | ------------ | -------------- | -------------- |
| Conceptual   | Vision today | Vision next    | Vision later   |
| Logical      | Approach now | Approach next  | Approach later |
| Detailed     | Tasks now    | Tasks next     | Tasks later    |

- **Now / Next / Later** are time horizons without firm dates.
- **Conceptual / Logical / Detailed** are levels of fidelity.

The detail increases as work moves from Later toward Now.

## Lean Software Development

Start with a small deliverable. Invite the team to contribute ideas. Enable more people to contribute. Do not implement a requirement before the current deliverable needs it (**YAGNI**).

Iterations move through these phases quickly, sometimes in parallel:

1. **Spike / Experiment** — can this thing even be built?
2. **Proof of Concept** — does the experiment work under realistic conditions?
3. **MVP** — the first version that can run in production. Start collecting real feedback.
4. **Improvements** — stabilize, add functionality, harden.

Feedback from people who use or observe the deliverable informs the next iteration.

## Ways of working

Ways of working follow these principles, adapt to the work, and evolve with feedback.

- **Start lean** with processes and ceremonies. Get to know each other and the work first.
- **Scrum + Kanban hybrid** — dynamic cycles, no firm sprint end dates. A cycle is over when an Epic is delivered. Estimation is approximate; Epics themselves are kept lean.
- **Limit Work in Progress.** Roughly three concurrent items per person is the typical ceiling for sustained focus.
- **Extreme Programming** — pair programming (human + human, or human + agent) supports learning, decision-making, review, and validation.
