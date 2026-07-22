# ADR 01: Standardizing Documentation Architecture with Diátaxis and Open Knowledge Format (OKF)

**Status:** Accepted (Proposed/Ready for Implementation Phase 1)
**Author:** EMP\_Agent
**Date:** October 26, 2023
**Scope:** Defines the canonical structure, format, and maintenance workflow for all technical documentation related to MSX operations, standards, and agent functionality.

---

## 📜 1. Overview and Goals

The current repository (`MSXOrg/docs`) lacks a unifying architectural blueprint, leading to scattered information, redundant content, and inefficient context loading for agents. This ADR proposes adopting a combined framework: **Diátaxis** to structure the *content* (what the user needs) and **Open Knowledge Format (OKF)** to define the *physical storage mechanism* (how it lives in Git).

The core goal is to establish a single, version-controlled "Remote Brain" — a living knowledge graph that serves both high-speed agent context loading and seamless human readability.

### 1.1. Fulfillment of Core Requirements

| Goal | Proposed Solution Component | Mechanism Achieved |
| :--- | :--- | :--- |
| One coherent body of docs | **ADR 01** + Canonical Folder Structure | Establishes governance rules and physical location for all knowledge. |
| Discoverable, predictable filing | **OKF `index.md` files & Diátaxis Typing** | Forces progressive disclosure at every level; paths are canonical identity. |
| Small, context-cheap pages | **OKF Structure (`index.md` / single concept per file)** | Agents only load the necessary index/concept page, minimizing token bloat. |
| Human- and agent-native format | **Plain Markdown + YAML Frontmatter** | Requires no translation layer; Git tooling inherently supports both readers. |
| Thin agent config | **Decoupling Instructions from Config (Docs)** | Agent configurations (`agent_config.yaml`) only reference paths (e.g., `docs/ways-of-working/runbooks/data-ingestion.md`). |
| Self-updating remote brain | **OKF `log.md` + Dedicated `brain/` area** | Agents write and correct content by updating a predictable, traceable log file structure via PRs. |

---

## 🧠 2. Architectural Synthesis: Diátaxis $\times$ OKF

We are adopting an *orthogonal* relationship where Diátaxis provides the information taxonomy (the **Why/What**) and OKF provides the structural implementation (the **How**). They do not conflict; they complete each other.

### 2.1. The Information Architecture (Diátaxis)

We commit to using the four types:
1.  **Tutorial:** For *learning* (e.g., "Getting Started with MSX").
2.  **How-to Guide:** For *tasks* and processes (e.g., contribution flow, running a specific agent workflow). **(Primary home for ways of working.)**
3.  **Reference:** For *facts*, constants, and definitions (e.g., coding standards, API schemas, config keys). **(Primary home for technical specs.)**
4.  **Explanation:** For *understanding* rationale (e.g., ADRs, design decisions, principles).

### 2.2. The Physical Format (OKF)

Every single concept document will adhere to the OKF structure: a path-based identity, containing frontmatter and markdown body content. This ensures progressive disclosure through nested `index.md` files (`src/docs/{topic}/index.md`).

---

## 📂 3. Proposed Canonical Structure & File Schema

The final layout is **Topic-Based Hierarchy with Frontmatter Typing**. We resist forcing a rigid top-level folder based solely on Diátaxis type, as this would violate the principle of "one correct place" (e.g., an ADR might contain both explanatory content *and* how-to steps). Instead, the Type becomes a **metadata tag** applied via frontmatter.

### 3.1. The Root Structure (`src/docs/`)

```
src/docs/
├── index.md           # OKF Root Index: High-level entry point for all users. Describes MSX overview.
|
├── coding-standards/  # Topic Area: