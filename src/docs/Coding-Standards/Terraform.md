---
title: Terraform
description: Stack layout, version pinning, state and secrets, and the fmt/validate/tflint toolchain.
---

# Terraform

Terraform provisions cloud infrastructure as code. Infrastructure changes follow the same review and approval gates as application code. See [Decision before change](../Ways-of-Working/Principles/AI-First-Development.md#decision-before-change).

This standard builds on the [language-agnostic baseline](index.md). Where the two overlap, the baseline rules apply and this standard adds Terraform-specific conventions.

## Stack layout

Split a stack into conventional files so readers can find each definition:

| File | Holds |
|---|---|
| `providers.tf` | `terraform` block, `required_version`, `required_providers`, backend, `provider` blocks. |
| `variables.tf` | Input variable declarations. |
| `locals.tf` | Local values and computed names. |
| `data.tf` | Data sources. |
| `main.tf` | Resource definitions. |
| `outputs.tf` | Output values. |

Name resources, variables, and outputs in `lower_snake_case`. Name a resource for its role, not its type (`aws_s3_bucket.docs_artifact`, not `aws_s3_bucket.bucket`).

## Pin versions and lock them

- **Constrain `required_version`** for Terraform itself. **Constrain every provider** with a pessimistic operator (`version = "~> 5.0"`).
- **Commit the `.terraform.lock.hcl` dependency lockfile.** The constraint bounds the range. The lockfile records the exact resolved provider versions so every apply uses the same providers.

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
- **Apply default tags** at the provider level (`default_tags`) so every resource is consistently labeled.

## Variables and outputs

- **Type every variable** and give it a `description`; add `validation` blocks where inputs have real constraints.
- Only set a `default` for optional inputs. Required inputs have no default, so a missing value fails immediately.
- **Describe every output**, and expose only what other stacks or operators actually consume.

## Locals

- **Use `locals` for computed values, derived names, and conditional logic** so each value has one definition. Repeated name expressions can produce different names after an edit.
- **Prefix an intermediate local with `_`** when it exists only to supply another local, such as `_all_subnet_ids`. This distinguishes intermediate values from values the configuration consumes.
- **Multiple `locals` blocks in one file are allowed** when each groups related values. One block per concern is clearer than one block with unrelated values.

## Resources and modules

- **Name a single-instance resource `this`** — `aws_lb.this`, `aws_s3_bucket.this`. The resource type already identifies the resource. If more than one instance of a type exists, name each for its role, not its ordinal.
- **Create an optional resource with `count`**, not `for_each` over a boolean: `count = var.enable_logging ? 1 : 0`. `count` expresses "zero or one"; `for_each` expresses "one per key". A boolean does not express a set of keys.
- **Migrate state with `moved` blocks**, not `terraform state mv`. A `moved` block is committed, reviewed, and applied by everyone who runs the configuration. A state command changes one environment once and does not record the change in the configuration.
- **Use `depends_on` only where Terraform cannot infer the dependency.** An attribute reference already creates the dependency. Redundant `depends_on` entries make actual ordering constraints harder to identify.
- **Pass values into a module explicitly through variables.** A module does not query a data source for a value the caller already knows. Such a query couples the module to the caller's environment and prevents isolated tests.
- **Configure providers only in the root module.** A child module declares what it needs in `required_providers` and contains no `provider` block. The root is the single place for provider configuration.
- **Pin a module's Git `source` to an immutable commit SHA**, with the release tag in a trailing comment, following [Pin versions and lock them](#pin-versions-and-lock-them). A tag can be moved; a SHA cannot.

## Tooling

- **`terraform fmt`** — canonical formatting; CI runs `terraform fmt -check`.
- **`terraform validate`** — configuration is valid before plan.
- **[`tflint`](https://github.com/terraform-linters/tflint)** — detects provider-specific issues and anti-patterns.
- Review the **`terraform plan`** output before every apply to verify the intended changes.
