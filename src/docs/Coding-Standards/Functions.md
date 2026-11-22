---
title: Functions
description: One responsibility, contracts in the signature, and validation at the boundary.
---

# Functions

A function has one responsibility. Its name and signature state its purpose and contract, so callers can use it without reading the implementation.

## One responsibility

- A function does one thing. If describing it needs the word "and", split it.
- Keep each function small enough to understand. Use screen fit as a guide rather than a fixed line count.
- Use one level of abstraction per function. Do not mix high-level orchestration with low-level detail in the same body.

## Reuse before you build

Before you write logic, look for an existing implementation. Add logic only when none meets the need. This applies DRY and one responsibility across the codebase, not only within one function.

- Prefer a built-in. If the language or runtime provides the required behavior, use it instead of a custom implementation.
- Reuse an existing function instead of re-implementing it. If it is too slow or imprecise on a hot path, improve that function for all callers. Do not add a separate workaround.
- Prefer shared code you own before introducing a third-party dependency, especially in a shipped library or module. An external package adds a long-term trust and maintenance obligation. Use one only when a large or specialized capability makes an owned implementation less suitable.
- Build new logic only when no suitable built-in, existing function, owned shared code, or justified trusted dependency meets the need. Keep small logic inline where it is used. Put a larger, cohesive capability in its own module.

## Signatures are contracts

- Type the parameters and return value where the language allows. The signature documents intent and lets tooling catch misuse before it runs.
- Few parameters. A long parameter list signals a missing type or a function doing too much — group related arguments into an object.
- Avoid boolean parameters that select behavior (`render(true)`). Split into two clearly named functions, or pass an explicit, named option.
- Order parameters so the required ones come first — readers scan left to right.

## Validate at the boundary

- Reject invalid input at the boundary, before it reaches other call layers. A failure at the boundary is easier to diagnose than one in a later call. This is [shift left](../Ways-of-Working/Principles/Engineering-Practices.md#shift-left) applied to a single function.
- Trust data only inside a validated boundary. Validate all data at the boundary.

## Flow reads top to bottom

- Return early. Put guard clauses for edge cases and exits at the top, then let the main path read straight down — no deep nesting.
- Prefer high-level constructs (iterate a collection directly) over manual, error-prone ones (index into it) when the index is not needed.
- Handle every case. A branch over a closed set of values covers every member or carries an explicit default — an unhandled value is a silent failure.

## Side effects at the edges

- Prefer pure functions: the output depends only on the input, with no hidden state and no side effects. Pure functions are easier to test and understand.
- Keep side effects — I/O, mutation, network, time — at system boundaries. Keep the core logic pure.

## Gate destructive operations

- Operations that create, change, or delete state offer a preview or confirmation before they act. Irreversible actions require a deliberate check. See [Security](Security.md).
