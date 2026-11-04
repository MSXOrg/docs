---
title: Security Review
description: Procedure for the specialized Workflow stage for defensive security review and responsible disclosure.
---

# Security Review

Security Review is a specialized path in the canonical [Workflow](../Workflow.md). It identifies vulnerabilities and attack vectors in source code and documentation for the code owner. For each finding, it produces a clear, actionable responsible-disclosure issue. The stage supports defensive review and produces no working exploit code.

## Enter this stage when

Perform a security review, audit code for vulnerabilities, threat-model a change, or review OWASP Top 10 risks — injection, secrets exposure, path traversal, privilege escalation, supply-chain risk, information disclosure.

## Scope

### Source code

- **Injection** — command, script, SQL, NoSQL, or LDAP injection.
- **Secrets** — hardcoded tokens, keys, or passwords committed to source.
- **Insecure deserialization** — unsafe evaluation of untrusted input.
- **Path traversal** — user-controlled input used to build file paths.
- **Privilege escalation** — actions running beyond least privilege.
- **Dependency and supply-chain risk** — floating versions, and actions referenced by a mutable tag rather than a pinned SHA.
- **Information disclosure** — stack traces or debug output that leak sensitive data.
- **Race conditions** — checks that can be bypassed between the check and the use.

### Documentation

- Misleading security guidance, exposed internal endpoints, overly permissive examples, and social-engineering surface.

## Output

Each finding has a structured block with severity, component, vulnerability class, and OWASP category. It includes a plain-language description, an attack path without exploit code, evidence with file and line, a concrete mitigation, and references. References identify the applicable CVE, CWE, or OWASP guidance. Severity is one of Critical, High, Medium, Low, or Informational.

After the review, open a security issue on the target repository titled `[Security Review] <scope>`, labeled `security`. Include an executive summary followed by the finding blocks. Flag Critical and High findings as priorities.

## Constraints

- Do not generate, execute, or suggest working exploit code or payloads.
- Do not access, exfiltrate, or modify data beyond what is needed to identify a vulnerability.
- Report only through the agreed channel — the issue on the target repository.
- On evidence of an active breach, stop and inform the owner so they can follow incident response.

## Where this connects

- [Review Etiquette](../Review-Etiquette.md) — how findings are communicated.
- [Security](../../Coding-Standards/Security.md) and [GitHub Actions](../../Coding-Standards/GitHub-Actions.md) — the standards a finding cites.
