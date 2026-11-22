---
title: Deployment
description: How a change to managed resources is approved together with its effect and deployed exactly as approved — one spec, and one design for each combination of deploying a service provider from a CI/CD platform.
---

# Deployment

The deployment capability governs changes to resources that Platform manages.
Before deployment, the process computes and shows the **effect on the resources**
for every environment in the promotion path. The team approves the code change
and all these effects as one decision. Deployment applies exactly the approved
effect and records every action.

The **spec** defines a technology-independent contract. Each **design** delivers
this contract for one service-provider and CI/CD-platform combination. Designs use
the name **"deploying &lt;service provider&gt; from &lt;CI/CD platform&gt;"**.

The **service provider** hosts the resources (Azure, AWS, GitHub). The **CI/CD
platform** runs the deployment (GitHub, Azure DevOps). Examples include deploying
Azure from GitHub, deploying Azure from Azure DevOps, deploying AWS from GitHub,
and deploying GitHub from GitHub. Each additional combination needs a separate
design, not a change to the spec.

## Spec

| Page | Description |
| --- | --- |
| [Spec](spec.md) | The why and what — a change is approved together with its effect, and the approved effect is exactly what deploys. |

## Designs

| Design | Service provider | CI/CD platform | Description |
| --- | --- | --- | --- |
| [Designs](designs/index.md) | — | — | Deployment designs, one for each service-provider and CI/CD-platform combination. |
