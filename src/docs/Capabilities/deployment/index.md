---
title: Deployment
description: How a change to managed resources is approved together with its effect and deployed exactly as approved — one spec, and one design for each combination of deploying a service provider from a CI/CD platform.
---

# Deployment

How a change to the resources Platform manages moves from a proposal to live: its
**effect on the resources** is computed and shown, the team approves the code
change together with that effect across every environment it will pass through,
and the approved effect is exactly what is deployed — with every action recorded.

The **spec** is the durable contract and is deliberately free of any technology.
Each **design** delivers that contract for one combination, named **"deploying
&lt;service provider&gt; from &lt;CI/CD platform&gt;"** so the two parts are
clear: the **service provider** is where the resources live (Azure, AWS,
GitHub), and the **CI/CD platform** is what runs the deployment (GitHub, Azure
DevOps) — for example deploying Azure from GitHub, deploying Azure from Azure
DevOps, deploying AWS from GitHub, or deploying GitHub from GitHub. Adding a
combination adds a design; it never changes the spec.

## Spec

| Page | Description |
| --- | --- |
| [Spec](spec.md) | The why and what — a change is approved together with its effect, and the approved effect is exactly what deploys. |

## Designs

| Design | Service provider | CI/CD platform | Description |
| --- | --- | --- | --- |
| [Deploying Azure from GitHub](designs/azure-from-github.md) | Azure | GitHub | GitHub Actions and Terraform deploy Azure and Entra resources with passwordless identity, approving the code change together with its per-environment effect. |
