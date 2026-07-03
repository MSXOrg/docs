---
title: Terraform
description: Stack layout, version pinning, state and secrets, and the fmt/validate/tflint toolchain.
---

# Terraform

How Terraform is written across the ecosystem. Terraform is the tool for provisioning cloud infrastructure as code. Infrastructure changes go through the same review and approval gates as application code — see [Decision before change](../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).

This standard builds on the [language-agnostic baseline](index.md); where the two overlap, the baseline rules apply and the conventions below add the Terraform specifics.

## Stack layout

Split a stack into conventional files so a reader knows where to look:

| File | Holds |
|---|---|
| `providers.tf` | `terraform` block, `required_version`, `required_providers`, backend, `provider` blocks. |
| `variables.tf` | Input variable declarations. |
| `locals.tf` | Local values and computed names. |
| `data.tf` | Data sources. |
| `main.tf` | The resources themselves. |
| `outputs.tf` | Output values. |

Name resources, variables, and outputs in `lower_snake_case`, and name a resource for its role — not its type (`aws_s3_bucket.docs_artifact`, not `aws_s3_bucket.bucket`).

## Pin versions and lock them

- **Constrain `required_version`** for Terraform itself and **constrain every provider** with a pessimistic operator (`version = "~> 5.0"`).
- **Commit the `.terraform.lock.hcl` dependency lockfile.** The constraint bounds the range; the lockfile fixes the exact resolved versions so every apply and every engineer uses the same providers.

```hcl
terraform {
  required_version = ">= 1.5"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## State and secrets

- **Use a remote backend** (such as S3) for shared state — never local state for anything shared or deployed. Configure the backend partially in code and supply the rest at `init`.
- **Never put secrets in `.tf` files or in variables' defaults.** State can contain sensitive values, so treat the state backend as sensitive and mark sensitive outputs `sensitive = true`.
- **Apply default tags** at the provider level (`default_tags`) so every resource is consistently labelled.

## Variables and outputs

- **Type every variable** and give it a `description`; add `validation` blocks where inputs have real constraints.
- Only set a `default` for genuinely optional inputs; required inputs have no default so a missing value fails fast.
- **Describe every output**, and expose only what other stacks or operators actually consume.

## Tooling

- **`terraform fmt`** — canonical formatting; CI runs `terraform fmt -check`.
- **`terraform validate`** — configuration is valid before plan.
- **[`tflint`](https://github.com/terraform-linters/tflint)** — catches provider-specific issues and anti-patterns.
- Review the **`terraform plan`** output before every apply; an apply is never a surprise.
