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

## Locals

- **Use `locals` for computed values, derived names, and conditional logic** so each value is defined once and every reference reads the same expression. A name assembled twice in two resources will eventually be assembled two different ways.
- **Prefix an intermediate local with `_`** when it exists only to feed another local — `_all_subnet_ids` — so the reader can tell a building block from a value the configuration actually consumes.
- **Multiple `locals` blocks in one file are fine** when each groups related values. One block per concern reads better than one block holding everything.

## Resources and modules

- **Name a single-instance resource `this`** — `aws_lb.this`, `aws_s3_bucket.this` — because the resource type already says what it is and a second name adds nothing. Where more than one instance of a type exists, name each for its role, not its ordinal.
- **Create an optional resource with `count`**, not `for_each` over a boolean: `count = var.enable_logging ? 1 : 0`. `count` expresses "zero or one"; `for_each` expresses "one per key", and forcing a boolean through it obscures both.
- **Migrate state with `moved` blocks**, not `terraform state mv`. A `moved` block is committed, reviewed, and applied by everyone who runs the configuration; a state command runs once on one machine and leaves no trace for the next person.
- **Use `depends_on` only where Terraform cannot infer the edge.** Referencing an attribute already creates the dependency; an explicit `depends_on` on top of that is noise, and a graph full of noise hides the one real ordering constraint.
- **Pass values into a module explicitly through variables.** A module does not reach for a data source to look up something the caller already knows — that couples the module to the caller's environment and makes it untestable in isolation.
- **Configure providers only in the root module.** A child module declares what it needs in `required_providers` and contains no `provider` block, so the root stays the single place provider configuration is decided.
- **Pin a module's Git `source` to an immutable commit SHA**, with the release tag in a trailing comment, following [Pin versions and lock them](#pin-versions-and-lock-them). A tag can be moved; a SHA cannot.

## Tooling

- **`terraform fmt`** — canonical formatting; CI runs `terraform fmt -check`.
- **`terraform validate`** — configuration is valid before plan.
- **[`tflint`](https://github.com/terraform-linters/tflint)** — catches provider-specific issues and anti-patterns.
- Review the **`terraform plan`** output before every apply; an apply is never a surprise.
