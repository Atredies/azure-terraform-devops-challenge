# Architecture Decisions

This document captures the critical design decisions made in this project, the reasoning behind each, and what alternatives were considered.

---

## 1. Environment-per-Directory over Workspaces

**Decision:** Each environment (dev, prod) is a separate Terraform root directory with its own state.

**Why:** Workspaces share a state backend, making it easy to `apply` to the wrong environment. They also force conditional logic throughout the code (`var.environment == "prod" ? ... : ...`), which pollutes readability. Most Terraform practitioners consider workspaces an anti-pattern for environment separation.

**What we get:**
- Hard isolation — each env is an independent deployment unit
- Separate `terraform apply` per environment, separate state files
- Adding staging = copy `dev/`, change `terraform.tfvars`, add to pipeline matrix

**Alternative considered:** Terraform workspaces. Rejected because shared state backend creates operational risk and conditional logic reduces code clarity.

---

## 2. Resource Groups over Subscriptions

**Decision:** Separate Resource Groups in a single Azure subscription.

**Why:** Subscriptions provide harder isolation (separate quotas, blast radius, billing), but require subscription vending and Management Group hierarchy setup. For a 2-environment project, RGs are sufficient and dramatically simpler.

**When to switch to subscriptions:**
- Production workloads with strict blast-radius requirements
- Compliance mandates (HIPAA, PCI-DSS) requiring network isolation
- Different billing/cost centers per environment
- Subscription-level quota bottlenecks

**Real-world recommendation:** Separate subscriptions under a Management Group hierarchy for prod vs non-prod, with Azure Policy enforcing guardrails across all child subscriptions.

---

## 3. Dynamic Subnets via `for_each` over Hardcoded Subnets

**Decision:** The VNET module takes a `subnets` map variable and creates resources dynamically.

**Why:** This is what makes the module genuinely reusable. Dev passes 2 subnet entries (app, data), prod passes 3 (app, data, mgmt). If someone needs 5 subnets, they pass 5 entries — no module code changes required.

**How it works:**
```hcl
subnets = {
  app  = { address_prefix = "10.0.1.0/24", nsg_rules = [...] }
  data = { address_prefix = "10.0.2.0/24", nsg_rules = [...] }
}
```

The same `for_each` key drives subnet creation, NSG creation, and NSG-to-subnet association — guaranteeing they stay in sync.

**Alternative considered:** Hardcoded subnet resources. Rejected because it means the module only works for one specific topology.

---

## 4. OIDC Authentication over Service Principal Secrets

**Decision:** The CI/CD pipeline uses Workload Identity Federation (OIDC) for Azure authentication.

**Why:** A Service Principal secret is a long-lived credential stored in GitHub Secrets. If it leaks, anyone can deploy to your Azure subscription until you rotate it. OIDC tokens are short-lived (minutes), scoped to the specific workflow run, and never stored anywhere.

**Trade-off:** Harder initial setup (Azure AD app registration + federated credential), but eliminates an entire class of credential exposure risk.

**Industry context:** Microsoft and GitHub's recommended approach since 2023.

---

## 5. Pinned VM Image Version over `latest`

**Decision:** Ubuntu image pinned to `version = "22.04.202503010"` instead of `"latest"`.

**Why:** `latest` means two identical `terraform apply` runs a week apart could produce VMs with different OS versions. This violates infrastructure-as-code principles — deployments should be deterministic and reproducible.

**Trade-off:** Requires manual version bumps when upgrading. This is intentional — you choose when to upgrade, not the upstream publisher.

---

## 6. Tag Enforcement via `merge()` over Trusting Callers

**Decision:** Every module applies mandatory tags using `merge(local.default_tags, var.tags)`.

**Why:** Even if a caller forgets to pass tags, the baseline set always exists:
- `Environment` — which env this belongs to
- `Project` — which project owns it
- `ManagedBy` — confirms IaC management
- `Owner` — cost accountability
- `CreatedDate` — audit trail

The `lifecycle { ignore_changes = [tags["CreatedDate"]] }` block prevents Terraform from seeing the `timestamp()` value as drift on every plan.

**Alternative considered:** Relying on callers to pass correct tags. Rejected because it only takes one forgotten tag to break cost allocation and compliance reporting.

---

## 7. SSH Key Auth Only, No Passwords

**Decision:** `disable_password_authentication = true` is hardcoded on every VM.

**Why:** Passwords are brute-forceable. SSH keys are not. This is a security baseline that should not be configurable — making it a variable would imply that password auth is a valid option.

**Azure constraint:** Azure requires RSA keys. Ed25519 is not supported by the azurerm provider.

---

## 8. Dev Permissive, Prod Locked Down

**Decision:** NSG rules differ significantly between environments.

| Aspect | Dev | Prod |
|--------|-----|------|
| SSH (port 22) | Open from any IP | Restricted to mgmt subnet only |
| HTTP (port 80) | Open from any IP | Not allowed |
| HTTPS (port 443) | Not configured | Open (public-facing apps) |
| Public IP on VM | Yes | No |
| Default inbound | Allow | Deny-all |

**Why:** Dev needs to be reachable for development and testing. Prod needs to be hardened. This mirrors how real teams operate — the security posture is defined by the environment config, not the module.

---

## 9. Plan-Based Tests over Deploy-and-Destroy Tests

**Decision:** Terratest validates against `terraform plan` output, not deployed resources.

**Why:**
- Deploy tests take 5-10 minutes and require Azure credentials
- Plan-based tests take seconds and run anywhere
- They catch naming bugs, missing variables, wrong defaults, and structural regressions without spending money

**What the tests cover:**
- Naming conventions across all resource types
- Output presence and correctness
- VM configuration (SKU, admin user, public IP)
- Storage security (TLS 1.2, HTTPS-only, private access)
- Resource count (13 for dev, 15 for prod)

**Trade-off:** Plan tests cannot verify runtime behavior (e.g., "can the VM actually reach the internet?"). For that, you would need deploy-and-destroy integration tests, which are better suited for a CI environment with Azure credentials.

---

## 10. Pre-commit Hooks as First Quality Gate

**Decision:** Pre-commit hooks run `terraform fmt`, `validate`, `tflint`, `terraform-docs`, and `detect-private-key` on every commit.

**Why:** Issues are caught in seconds on the developer's machine, not minutes later in CI. The CI pipeline serves as a second line of defense for anything that slips through (or if someone bypasses hooks).

**What each hook does:**
- `terraform_fmt` — rejects unformatted HCL
- `terraform_validate` — catches syntax and module reference errors
- `terraform_tflint` — Azure-specific linting, naming conventions
- `terraform_docs` — regenerates module READMEs so docs never go stale
- `detect-private-key` — prevents accidental credential commits

---

## 11. Three-Stage Pipeline with Manual Prod Gate

**Decision:** CI/CD pipeline has 3 stages: lint → plan → apply, with manual approval for prod.

```
PR opened → lint + plan (automatic)
Merge to main → apply dev (automatic) → apply prod (manual approval)
```

**Why:**
- **Lint stage** catches formatting, naming, and security issues before human review
- **Plan stage** generates the exact change set and posts it as a PR comment
- **Apply stage** uses the saved plan artifact — what was reviewed is what gets deployed
- **Manual prod gate** ensures a human verifies before production changes go live
- `max-parallel: 1` guarantees dev deploys before prod (sequential, not parallel)

**Alternative considered:** Auto-apply to both environments. Rejected because production changes should always have human oversight.

---

## 12. Automated Module Documentation over Manual READMEs

**Decision:** Module READMEs are auto-generated by `terraform-docs` from HCL variable/output descriptions.

**Why:** Manual documentation goes stale. When you add a variable to `variables.tf`, the README updates automatically on the next commit (via pre-commit hook) or CI run.

**How it works:**
- Each module README has `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` markers
- `terraform-docs` injects tables for inputs, outputs, resources, and providers
- Content between markers is fully auto-generated — manual edits above/below markers are preserved

---

## Decision Summary

| # | Decision | Key Reason |
|---|----------|------------|
| 1 | Environment-per-directory | Hard state isolation between envs |
| 2 | Resource Groups | Sufficient isolation, simpler than subscriptions |
| 3 | Dynamic subnets | Genuine module reusability |
| 4 | OIDC auth | No long-lived credentials |
| 5 | Pinned image version | Deterministic deployments |
| 6 | Tag enforcement | Mandatory tags cannot be forgotten |
| 7 | SSH key only | Security baseline, not configurable |
| 8 | Dev permissive, prod strict | Security posture matches environment purpose |
| 9 | Plan-based tests | Fast, credential-free validation |
| 10 | Pre-commit hooks | Shift-left quality gate |
| 11 | Three-stage pipeline | Human oversight for production |
| 12 | Auto-generated docs | Documentation never goes stale |
