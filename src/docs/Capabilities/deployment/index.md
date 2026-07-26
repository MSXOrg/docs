---
title: Deployment
description: How a change to managed resources is approved together with its effect and deployed exactly as approved — one spec, one design per deployment platform and service provider.
---

# Deployment

How a change to the resources Platform manages moves from a proposal to live: its
**effect on the resources** is computed and shown, the team approves the code
change together with that effect across every environment it will pass through,
and the approved effect is exactly what is deployed — with every action recorded.

The **spec** is the durable contract and is deliberately free of any technology.
Each **design** delivers that contract for one combination of **deployment
platform** and **service provider** (for example GitHub with Azure, Azure DevOps
with Azure, GitHub with AWS, or GitHub with GitHub). Adding a combination adds a
design; it never changes the spec.

## Spec

| Page | Description |
| --- | --- |
| [Spec](spec.md) | The why and what — a change is approved together with its effect, and the approved effect is exactly what deploys. |

## Designs

| Design | Deployment platform | Service provider | Description |
| --- | --- | --- | --- |
| [GitHub + Azure](designs/github-azure.md) | GitHub | Azure | GitHub Actions and Terraform deploy Azure and Entra resources with passwordless identity, approving the code change together with its per-environment effect. |
