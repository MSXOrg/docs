---
title: Continuous Practices
description: The Continuous X family, Continuous AI, and the DevOps Dojo pillars.
---

# Continuous Practices

## 1. The "Continuous X" Practices

### Microsoft DevOps Dojo's eight pillars (White Belt)

The [DevOps Dojo White Belt Foundation](https://learn.microsoft.com/en-us/training/paths/devops-dojo-white-belt-foundation/) learning path organizes these practices into eight capabilities.

| # | Practice | What it covers |
|---|----------|----------------|
| 1 | Continuous Planning | Lean product, hypothesis-driven development, backlog management, OKRs |
| 2 | Continuous Integration | Trunk-based development, automated build and test on every commit |
| 3 | Continuous Delivery | Every commit potentially releasable; automated pipeline to production |
| 4 | Continuous Quality | Test pyramid, shift-left testing, code review, static analysis |
| 5 | Continuous Security | Shift-left security, SAST/DAST/SCA, secrets, supply chain |
| 6 | Continuous Operations | SRE, observability, SLOs, incident response, on-call |
| 7 | Continuous Collaboration | ChatOps, docs-as-code, transparent communication, shared ownership |
| 8 | Continuous Improvement | Kaizen, retrospectives, blameless postmortems, value-stream mapping |

### Full inventory with provenance

| Practice | Origin / canonical source |
|----------|--------------------------|
| **Continuous Integration** | Coined in Grady Booch's 1991 method; popularized by XP and [Martin Fowler's 2006 article](https://martinfowler.com/articles/continuousIntegration.html). |
| **Continuous Delivery** | Jez Humble & David Farley, [*Continuous Delivery*](https://continuousdelivery.com/), 2010. |
| **Continuous Deployment** | Every passing build deploys to production with no human gate. Continuous delivery makes the build *deployable*. |
| **Continuous Testing** | Tests run throughout the pipeline and in production, including synthetic tests and canary analysis. |
| **Continuous Verification** | Netflix's term for chaos-engineering-style continuous resilience validation. Rosenthal & Jones, [*Chaos Engineering*](https://www.oreilly.com/library/view/chaos-engineering/9781492043850/), O'Reilly. |
| **Continuous Monitoring → Continuous Observability** | Dashboards describe known conditions; ad-hoc queries investigate unexpected conditions. [Honeycomb's Observability Manifesto](https://www.honeycomb.io/blog/observability-a-manifesto). |
| **Continuous Feedback** | Feedback from production reaches development teams. DevOps Second Way (*Phoenix Project*). |
| **Continuous Improvement** | Toyota *kaizen*; Deming PDCA cycle. |
| **Continuous Learning** | DevOps Third Way (Kim, *Phoenix Project*). |
| **Continuous Security / DevSecOps** | OWASP; [DoD Enterprise DevSecOps Reference Design](https://dodcio.defense.gov/Portals/0/Documents/DoD%20Enterprise%20DevSecOps%20Reference%20Design%20v1.0_Public%20Release.pdf). |
| **Continuous Compliance** | Compliance-as-code: Chef InSpec, OPA, AWS Config. |
| **Continuous Configuration Automation (CCA)** | Gartner term covering Ansible/Puppet/Chef/Salt. |
| **Continuous Inspection** | SonarSource's term for always-on code-quality scanning. [docs.sonarsource.com](https://docs.sonarsource.com/). |
| **Continuous Profiling** | Always-on production profiling. Pyroscope/Grafana, Polar Signals, Google-Wide Profiling paper (2010). |
| **Continuous Documentation / docs-as-code** | Write the Docs community; treat docs like code. |
| **Continuous Experimentation** | A/B testing, hypothesis-driven development. Kohavi et al., [*Trustworthy Online Controlled Experiments*](https://experimentguide.com/), 2020. |
| **Continuous Discovery** | Teresa Torres, [*Continuous Discovery Habits*](https://www.producttalk.org/continuous-discovery-habits/), 2021. |
| **Continuous Architecture** | Erder & Pureur, *Continuous Architecture in Practice*, 2021. |
| **Continuous Refactoring** | XP practice; Fowler's [*Refactoring*](https://martinfowler.com/books/refactoring.html). |
| **Continuous Reliability** | Vendor-popularized (Catchpoint, Gremlin); combines SRE, chaos engineering, and observability. |
| **Continuous Code Review** | Modern PR workflows + always-on reviewers. |
| **Continuous Training (CT)** in MLOps | Google's [MLOps Levels 1–2](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning) — automatic retraining on fresh data. |

---

## 2. Continuous AI

**Canonical source:** [GitHub Next — Continuous AI](https://githubnext.com/projects/continuous-ai/), published June 2025 by Eddie Aftandilian, Peli de Halleux, Russell Horton, Don Syme.

### Definition (verbatim)
> "All uses of automated AI to support software collaboration on any platform."

GitHub Next describes the relationship to CI/CD as follows: *"Just as CI/CD transformed software development by automating integration and deployment, Continuous AI covers the ways in which AI can be used to automate and enhance collaboration workflows."*

GitHub Next uses Continuous AI as an industry category, **not** a GitHub product or an owned term.

### Seven characteristics (GitHub Next's taxonomy)
GitHub Next identifies seven characteristics: **automatable, repetitive, collaborative, integrated, auditable, event-triggered**, and **many variants**.

### GitHub Next's example workflows
The source gives examples of tasks that AI can assist with:

- **Continuous Documentation** — documentation suggestions and updates
- **Continuous Code Improvement** — comments, tests, and small refactors
- **Continuous Triage** — label, summarize, and respond to issues in natural language
- **Continuous Summarization** — summaries of project activity
- **Continuous Fault Analysis** — explanations of failed CI runs
- **Continuous Quality** — LLM-assisted code quality analysis
- **Continuous Team Motivation** — convert pull request activity into poetry, zines, or podcasts
- **Continuous Accessibility** — accessibility checks and improvements

### Continuous AI vs. its cousins

| Term | What it is |
|------|-----------|
| **Continuous AI** | AI participating *in* the SDLC continuously (review, docs, triage, fault analysis). The AI is the actor. |
| **MLOps** | CI/CD/CT *for* ML models — training, evaluation, deployment, monitoring. The model is the product. |
| **LLMOps** | MLOps specialized for LLM apps: prompt versioning, evaluations, retrieval, guardrails, cost/latency monitoring. |
| **AIOps** | AI/ML applied to IT operations — anomaly detection, alert correlation, RCA. Gartner term, ~2017. |

### How Continuous AI augments each Continuous X practice

The examples below retain the 2025 tool snapshot. They illustrate possible uses, not current product availability or support guarantees.

| Traditional practice | Continuous-AI augmentation | Example tools (2025) |
|---------------------|---------------------------|----------------------|
| Continuous Integration | AI summarizes broken builds; suggests fixes | GitHub Copilot Workspace, Sweep |
| Continuous Delivery | Agents drive multi-step deployments; AI-authored release notes | GitHub Copilot agents, Devin |
| Continuous Testing | Test generation, flaky-test detection, auto-repair | Diffblue, Qodo (CodiumAI), Meta TestGen-LLM |
| Continuous Quality | LLM PR review beyond linters | CodeRabbit, Greptile, Graphite Diamond, Copilot review |
| Continuous Security | LLM-aware SAST, auto-remediation PRs | Snyk DeepCode, Semgrep Assistant, Copilot Autofix |
| Continuous Operations | "AI SRE" — autonomous triage, RCA, runbook execution | Resolve.ai, Cleric, PagerDuty AIOps, Rootly AI |
| Continuous Documentation | Docs stay in sync with code | Mintlify, GitHub Next *Continuous Documentation* |
| Continuous Code Review | Always-on AI reviewer | CodeRabbit, Greptile, Copilot review |
| Continuous Refactoring | Background agents propose refactors | Cursor background agents, Sourcegraph Cody, Grit.io |
| Continuous Triage | Issue labeling, deduplication, and summarization | GitHub Models + Actions recipes, Linear AI |
| Continuous Improvement | Automated postmortems and retrospective summaries | incident.io, Rootly, Jeli (Atlassian) |
| Continuous Discovery | LLM synthesis of user research | Dovetail AI, Maze AI |
| Continuous Training (MLOps) | Model retraining combined with evaluation-driven LLM development | Vertex AI, Databricks, Weights & Biases |

### What structurally changes

- **Evaluations test AI behavior.** AI regression suites use evaluations graded by LLM judges or humans. Evaluation drift counts as a test failure.
- **Pipelines include non-deterministic actors.** Each Continuous AI step needs an audit record of the agent, model version, prompt, tools, and affected resources.
- **Cost and runaway risk.** Agentic steps can recurse. Use budgets, timeouts, and concurrency caps to bound execution and cost.
- **Prompt injection is a CI/CD threat.** Treat untrusted issue text, PR descriptions, error messages, and third-party docs as potential prompt-injection inputs.
- **Governance.** Provenance for an AI-generated change is a governance concern, with signed commits as a comparison for source evidence. Applicable compliance obligations determine the evidence needed for a specific system.

### Tooling stack referenced by GitHub Next
- [GitHub Actions](https://github.com/features/actions)
- [GitHub Models](https://github.com/features/models)
- [GenAIScript (Microsoft)](https://microsoft.github.io/genaiscript/)
- [Datasette `llm`](https://llm.datasette.io/)
- [GitHub Agentic Workflows](https://githubnext.com/projects/agentic-workflows/) — related GitHub Next project
- [The Agentics](https://github.com/githubnext/agentics/) — example workflows

---

## 3. Microsoft DevOps Dojo — Status

The linked Microsoft Learn path provides the White Belt curriculum. The linked blog posts describe the broader belt model.

### History
Started ~2018–2019 inside Microsoft (catalyzed by a 2019 conversation with German CIOs); grew into a cross-org community spanning Services, Customer Success, Digital Advisory, and product groups. Public face was largely **April Edwards** (Senior Cloud Advocate). Authoritative intro: [*Intro of DevOps Dojo*](https://devblogs.microsoft.com/devops/intro-of-devops-dojo/) on Azure DevOps Blog (July 2022).

### Belt curriculum
- **White Belt** — standardized DevOps fundamentals, with a Microsoft Learn path
- **Orange Belt** — scaled DevOps (enterprise/program/portfolio), described in the linked blog introduction
- **Green Belts** — domain lenses (e.g. UX/Accessibility), described in the linked blog introduction
- **Black Belt** — data-driven, intelligent DevOps for executives. The linked introduction describes the Black Belt.

Four pillars: Culture & Mindset, Lean Product, Architecture, Technology.

### Where the content lives today

**Microsoft Learn — White Belt (six modules):**
- [DevOps Dojo White Belt Foundation](https://learn.microsoft.com/en-us/training/paths/devops-dojo-white-belt-foundation/)

**Azure DevOps Blog (the deeper belts):**
- [Intro of DevOps Dojo](https://devblogs.microsoft.com/devops/intro-of-devops-dojo/)
- [People & Teams (Orange)](https://devblogs.microsoft.com/devops/devops-dojo-people-teams/)
- [UX/Accessibility (Green)](https://devblogs.microsoft.com/devops/devops-dojo-ux-accessibility/)
- [Culture and Mindset](https://devblogs.microsoft.com/devops/devops-dojo-culture-and-mindset/)
- [Experiential Learning](https://devblogs.microsoft.com/devops/devops-dojo-experiential-learning/)
- [Lean Product Part 1 / Part 2](https://devblogs.microsoft.com/devops/devops-dojo-lean-product-part-1/)

**DevOps Lab video series:** [learn.microsoft.com/shows/devops-lab](https://learn.microsoft.com/en-us/shows/devops-lab/)

**GitHub:** [github.com/microsoftdevopsdojo](https://github.com/microsoftdevopsdojo) — public organization entry point.

### What to use today
1. **Dojo White Belt** on Learn — for the eight Continuous X practices
2. **[Evolve your DevOps practices](https://learn.microsoft.com/en-us/training/paths/evolve-your-devops-practices/)** — practical follow-on
3. **[ISE Engineering Fundamentals Playbook](https://microsoft.github.io/code-with-engineering-playbook/)** — Microsoft's public engineering playbook.
4. **[AZ-400 Enterprise DevOps](https://learn.microsoft.com/en-us/credentials/certifications/devops-engineer/)** — certification track

The references serve different purposes: the Dojo materials describe its curriculum; the ISE Playbook documents engineering practices.
