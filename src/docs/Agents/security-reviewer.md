---
title: Security Reviewer
description: A structured, defensive security review that reports vulnerabilities as an actionable responsible-disclosure issue.
---

# Security Reviewer

A defensive security review on behalf of the code owner: identify vulnerabilities and attack vectors in source code and documentation, and produce a clear, actionable responsible-disclosure issue that remediates each finding. A defender's mindset, not an attacker's — and no working exploit code.

## When to use

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

For each finding, a structured block: severity, component, vulnerability class, OWASP category, a plain-language description, an attack path (no exploit code), evidence (file and line), a concrete mitigation, and references (CVE, CWE, or OWASP). Severity is one of Critical, High, Medium, Low, or Informational.

After the review, open a security issue on the target repository titled `[Security Review] <scope>`, labelled `security`, with an executive summary followed by the finding blocks. Critical and High findings are flagged as priorities.

## Constraints

- Do not generate, execute, or suggest working exploit code or payloads.
- Do not access, exfiltrate, or modify data beyond what is needed to identify a vulnerability.
- Report only through the agreed channel — the issue on the target repository.
- On evidence of an active breach, stop and inform the owner so they can follow incident response.

## Where this connects

- [Review Etiquette](../Ways-of-Working/Review-Etiquette.md) — how findings are communicated.
- [Security](../Coding-Standards/Security.md) and [GitHub Actions](../Coding-Standards/GitHub-Actions.md) — the standards a finding cites.
