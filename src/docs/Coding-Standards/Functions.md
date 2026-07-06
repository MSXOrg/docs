---
title: Functions
description: One responsibility, contracts in the signature, and validation at the boundary.
---

# Functions

Functions are the unit of intent. A good function does one thing, says what it does through its name and signature, and can be understood without reading its body.

## One responsibility

- A function does one thing. If describing it needs the word "and", split it.
- Keep it small enough to hold in your head. Whether it fits on a screen is a better test than a line count.
- One level of abstraction per function — don't mix high-level orchestration with low-level detail in the same body.

## Reuse before you build

Before writing new logic, use what already exists — and build only what does not. This is DRY and one responsibility applied across the whole codebase, not just within one function.

- Prefer a built-in. If the language or runtime already does the job, use it instead of a hand-rolled version.
- Reuse an existing function instead of re-implementing it. If it is the weak link — too slow or imprecise on a hot path — fix it there so every caller benefits, rather than working around it.
- Take a dependency on a trusted module for a larger capability that already exists elsewhere; declare it explicitly instead of copying it in.
- Build it only when nothing fits — no built-in, no existing function, no trustworthy dependency. Size the build to the need: small logic lives inline where it is used; a larger, cohesive capability becomes its own module.

## Signatures are contracts

- Type the parameters and return value where the language allows. The signature documents intent and lets tooling catch misuse before it runs.
- Few parameters. A long parameter list signals a missing type or a function doing too much — group related arguments into an object.
- Avoid boolean parameters that select behavior (`render(true)`). Split into two clearly named functions, or pass an explicit, named option.
- Order parameters so the required ones come first — readers scan left to right.

## Validate at the boundary

- Reject bad input where it enters, before it travels deep into the call stack. A clear failure at the edge beats a baffling one three layers down. This is [shift left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left) applied to a single function.
- Inside a validated boundary, trust the data. At the edge, trust nothing.

## Flow reads top to bottom

- Return early. Put guard clauses for edge cases and exits at the top, then let the main path read straight down — no deep nesting.
- Prefer high-level constructs (iterate a collection directly) over manual, error-prone ones (index into it) when the index isn't needed.
- Handle every case. A branch over a closed set of values covers every member or carries an explicit default — an unhandled value is a silent failure.

## Side effects at the edges

- Prefer pure functions: the output depends only on the input, with no hidden state and no side effects. Pure functions are trivial to test and to reason about.
- Push side effects — I/O, mutation, network, time — to the edges of the system, and keep the core logic pure.

## Gate destructive operations

- Operations that create, change, or delete state offer a preview-or-confirm path before they act. Irreversible actions earn a deliberate gate. See [Security](Security.md).
