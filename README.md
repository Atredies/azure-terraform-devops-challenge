# Azure Terraform IaC Challenge

Production-grade Terraform project demonstrating reusable module design, multi-environment infrastructure (dev/prod), GitHub Actions CI/CD, linting, security scanning, and automated documentation for Azure.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                         Azure Subscription                           │
│                                                                      │
│  ┌──────────────────────────────────┐  ┌───────────────────────────┐ │
│  │  Resource Group: rg-challenge-   │  │ Resource Group: rg-       │ │
│  │  dev-eus-001                     │  │ challenge-prod-weu-001    │ │
│  │                                  │  │                           │ │
│  │  ┌─────────────────────────────┐ │  │ ┌───────────────────────┐ │ │
│  │  │  VNET: 10.0.0.0/16          │ │  │ │ VNET: 10.1.0.0/16     │ │ │
│  │  │  ┌──────────┐ ┌──────────┐  │ │  │ │ ┌──────┐ ┌──────┐    │ │ │
│  │  │  │ snet-app │ │snet-data │  │ │  │ │ │app   │ │data  │    │ │ │
│  │  │  │10.0.1/24 │ │10.0.2/24 │  │ │  │ │ │10.1.1│ │10.1.2│    │ │ │
│  │  │  │  NSG     │ │  NSG     │  │ │  │ │ │/24   │ │/24   │    │ │ │
│  │  │  └────┬─────┘ └──────────┘  │ │  │ └──┬───┘ └──────┘    │ │ │
│  │  └───────┼─────────────────────┘ │  │    │  ┌──────────┐    │ │ │
│  │          │                       │  │    │  │ snet-mgmt│    │ │ │
│  │  ┌───────▼──────────────────┐    │  │    │  │10.1.3/24 │    │ │ │
│  │  │  VM: vm-challenge-dev    │    │  │    │  └──────────┘    │ │ │
│  │  │  Size: Standard_B1s      │    │  │ ┌──▼────────────────┐ │ │ │
│  │  │  Public IP: YES          │    │  │ │VM: vm-challenge-   │ │ │ │
│  │  │  Ubuntu 22.04 LTS        │    │  │ │prod  B2s           │ │ │ │
│  │  └──────────────────────────┘    │  │ │Public IP: NO       │ │ │ │
│  │                                  │  │ └───────────────────┘ │ │ │
│  │  ┌──────────────────────────┐    │  │ └───────────────────────┘ │ │
│  │  │  Storage: stchallenge... │    │  │ ┌───────────────────────┐ │ │
│  │  │  LRS, 7-day soft delete  │    │  │ │Storage: stchallenge...│ │ │
│  │  │  Versioning: ON          │    │  │ │GRS, 30-day soft delete│ │ │
│  │  └──────────────────────────┘    │  │ └───────────────────────┘ │ │
│  └──────────────────────────────────┘  └───────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
azure-terraform-devops-challenge/
├── modules/                        # Reusable Terraform modules
│   ├── vnet/                       # Virtual Network module
│   │   ├── main.tf                 # VNET, subnets, NSGs, peering
│   │   ├── variables.tf            # All input variables with descriptions
│   │   ├── outputs.tf              # vnet_id, subnet_ids, nsg_ids, etc.
│   │   └── README.md               # Auto-generated docs (terraform-docs)
│   ├── vm/                         # Linux Virtual Machine module
│   │   ├── main.tf                 # VM, NIC, optional public IP
│   │   ├── variables.tf            # vm_size, ssh key, public_ip_enabled, etc.
│   │   ├── outputs.tf              # vm_id, private_ip, public_ip
│   │   └── README.md               # Auto-generated docs (terraform-docs)
│   └── blob-storage/               # Azure Blob Storage module
│       ├── main.tf                 # Storage account + container, versioning
│       ├── variables.tf            # replication_type, soft_delete_days, etc.
│       ├── outputs.tf              # storage_account_id, primary_blob_endpoint
│       └── README.md               # Auto-generated docs (terraform-docs)
│
├── environments/                   # Per-environment root configurations
│   ├── dev/                        # Development environment
│   │   ├── main.tf                 # Resource group + module calls (dev params)
│   │   ├── providers.tf            # azurerm provider + terraform version
│   │   ├── backend.tf              # Commented remote state config
│   │   ├── variables.tf            # Environment input variables
│   │   ├── outputs.tf              # Useful output values
│   │   └── terraform.tfvars        # Dev-specific variable values
│   └── prod/                       # Production environment
│       ├── main.tf                 # Resource group + module calls (prod params)
│       ├── providers.tf            # azurerm provider + terraform version
│       ├── backend.tf              # Commented remote state config
│       ├── variables.tf            # Environment input variables
│       ├── outputs.tf              # Useful output values
│       └── terraform.tfvars        # Prod-specific variable values
│
├── plan-output/                    # Terraform plan outputs for submission
│   ├── dev-plan.txt                # Dev plan: 13 resources to create
│   └── prod-plan.txt               # Prod plan: 15 resources to create
│
├── tests/                          # Terratest integration tests (Go)
│   ├── go.mod                      # Go module dependencies
│   └── vnet_module_test.go         # 5 tests: naming, outputs, VM, storage, count
│
├── .github/
│   └── workflows/
│       ├── terraform.yml           # Main CI/CD: lint, plan, apply
│       └── terraform-destroy.yml   # Manual destroy with confirmation gate
│
├── .pre-commit-config.yaml         # Pre-commit hooks (fmt, validate, tflint, docs)
├── .tflint.hcl                     # TFLint rules (naming, docs, types, azurerm)
├── .terraform-docs.yml             # terraform-docs output config
├── Makefile                        # Local dev convenience targets
├── cheatsheet.md                   # Quick reference for all CLI commands
├── decisions.md                    # Architecture decisions with rationale
├── dev-instructions.md             # Step-by-step dev deployment guide
├── prod-instructions.md            # Step-by-step prod deployment guide
├── questions.md                    # Anticipated technical questions & answers
└── README.md                       # This file
```

---

## Naming Convention

All resources follow a consistent naming pattern:

```
{abbreviation}-{project}-{environment}-{region_short}-{instance}
```

| Resource Type          | Abbreviation | Example                          |
|------------------------|--------------|----------------------------------|
| Virtual Network        | `vnet`       | `vnet-challenge-dev-eus-001`     |
| Subnet                 | `snet`       | `snet-challenge-app-dev-eus-001` |
| Network Security Group | `nsg`        | `nsg-challenge-app-dev-eus-001`  |
| Virtual Machine        | `vm`         | `vm-challenge-dev-eus-001`       |
| Public IP Address      | `pip`        | `pip-challenge-dev-eus-001`      |
| Network Interface      | `nic`        | `nic-challenge-dev-eus-001`      |
| Storage Account        | `st`         | `stchallengedeveus001`           |
| Storage Container      | `stc`        | `stc-challenge-dev-eus-001`      |
| Resource Group         | `rg`         | `rg-challenge-dev-eus-001`       |

Region short codes:
- `eus` = East US
- `weu` = West Europe
- `wus` = West US 2

---

## Tagging Strategy

All resources share a mandatory baseline tag set, enforced via `locals` in each module.

| Tag Key       | Purpose                                  | Enforcement Method                         |
|---------------|------------------------------------------|--------------------------------------------|
| `Environment` | Identify dev/staging/prod                | Set from `var.environment` in every module |
| `Project`     | Link resource to project                 | Hardcoded `azure-terraform-devops-challenge`      |
| `ManagedBy`   | Indicate IaC management                  | Always `terraform`                         |
| `Owner`       | Responsible party for cost accountability | Set in default_tags locals                 |
| `CreatedDate` | Audit trail for resource creation        | `timestamp()` with lifecycle ignore_changes|

User-provided `var.tags` are merged on top. `CreatedDate` uses:
```hcl
lifecycle {
  ignore_changes = [tags["CreatedDate"]]
}
```
This prevents drift on every plan after initial creation.

---

## Dev vs Prod Environment Differences

| Parameter                | Dev                       | Prod                         | Rationale                                           |
|--------------------------|---------------------------|------------------------------|-----------------------------------------------------|
| Location                 | East US (`eus`)           | West Europe (`weu`)          | Geographic diversity                                |
| VNET Address Space       | `10.0.0.0/16`             | `10.1.0.0/16`                | Non-overlapping for future peering                  |
| Subnet Count             | 2 (app, data)             | 3 (app, data, mgmt)          | Prod needs dedicated management plane               |
| NSG Rules (app subnet)   | Allow SSH + HTTP (wide)   | Allow HTTPS only + deny-all  | Strict prod ingress                                 |
| VM Size                  | `Standard_B1s`            | `Standard_B2s`               | Cost optimisation in dev                            |
| VM Public IP             | Yes                       | No                           | Prod access via mgmt subnet or VPN                 |
| OS Disk Type             | `Standard_LRS`            | `Premium_LRS`                | Prod needs better IOPS                              |
| OS Disk Size             | 30 GB                     | 64 GB                        | Prod workload headroom                              |
| Storage Replication      | `LRS` (local)             | `GRS` (geo-redundant)        | Prod durability + cross-region DR                   |
| Blob Soft Delete         | 7 days                    | 30 days                      | Compliance retention period                         |
| State Backend Key        | `dev/terraform.tfstate`   | `prod/terraform.tfstate`     | Separate state to prevent cross-env destructive ops |

---

## Resource Groups vs Subscriptions: Isolation Strategy

This project separates environments using **Resource Groups** within a single subscription.

### Why Resource Groups for this project

1. **Cost**: A single subscription avoids per-subscription overhead in a portfolio/challenge project.
2. **Simplicity**: One RBAC boundary, one billing view, zero cross-subscription networking complexity.
3. **Sufficient isolation**: Resource Group-level RBAC, policies, and management locks provide adequate separation for non-production workloads.
4. **Speed**: Faster iteration — no subscription vending process or Management Group hierarchy to configure.

### When to use separate Subscriptions instead

| Trigger                             | Reason                                                                         |
|-------------------------------------|--------------------------------------------------------------------------------|
| Blast-radius requirements           | A prod outage must not risk dev; subscription boundary provides hard isolation |
| Compliance mandates (HIPAA, PCI-DSS)| Network segmentation requirements that go beyond NSG/VNET                     |
| Different billing/cost centers      | Finance teams need separate invoices per environment                           |
| Azure Policy at subscription scope  | Policy inheritance targets subscriptions, not Resource Groups                  |
| Subscription quota bottlenecks      | Separate subscriptions = separate quota pools per region                       |

### Real-world recommendation

For production workloads: use **separate subscriptions** under a **Management Group hierarchy**:

```
Management Group (root)
├── Non-Production Subscriptions MG
│   ├── subscription-dev
│   └── subscription-staging
└── Production Subscriptions MG
    └── subscription-prod
        └── Resource Group: rg-challenge-prod-weu-001
```

Azure Policy at the MG level enforces guardrails (allowed VM SKUs, required tags, approved regions) across all child subscriptions without duplicating policy definitions.

---

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI >= 2.50 (for local auth: `az login`)
- An Azure Subscription with Owner or Contributor role
- SSH key pair — must be RSA (`ssh-keygen -t rsa -b 4096`), Azure does not support ed25519

Optional (for linting/docs/testing):
- tflint >= 0.50.0
- checkov >= 3.x (`pip install checkov`)
- terraform-docs >= 0.17.0
- pre-commit >= 3.x (`pip install pre-commit`)
- Go >= 1.21 (for Terratest)

---

## How to Use

### 1. Clone and set up SSH key

```bash
git clone <repo>
cd azure-terraform-devops-challenge
```

### 2. Authenticate to Azure

```bash
# Option A: Interactive login (local development)
az login
az account set --subscription "<your-subscription-id>"

# Option B: Service Principal (CI/CD)
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="..."
```

### 3. Set up remote state (optional but recommended)

Uncomment the `backend "azurerm"` block in `environments/{env}/backend.tf` and run:

```bash
# Create state storage (one time)
az group create --name rg-terraform-state-eus-001 --location eastus
az storage account create --name stterraformstateeus001 \
  --resource-group rg-terraform-state-eus-001 \
  --sku Standard_GRS --kind StorageV2
az storage container create --name tfstate \
  --account-name stterraformstateeus001
```

### 4. Plan and apply dev

```bash
cd environments/dev
terraform init
terraform plan \
  -var-file=terraform.tfvars \
  -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"

terraform apply \
  -var-file=terraform.tfvars \
  -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

Or use the Makefile from the project root:

```bash
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
make plan-dev
```

### 5. Plan and apply prod

```bash
cd environments/prod
terraform init
terraform plan \
  -var-file=terraform.tfvars \
  -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

---

## CI/CD Pipeline

```
PR opened/updated
      │
      ▼
┌─────────────────────────────────┐
│  lint-and-validate              │
│  ─ terraform fmt -check         │
│  ─ tflint (modules + envs)      │
│  ─ checkov (CIS Azure)          │
└────────────┬────────────────────┘
             │ passes
             ▼
┌─────────────────────────────────┐
│  plan (matrix: dev, prod)       │
│  ─ terraform init -backend=false│
│  ─ terraform validate           │
│  ─ terraform plan -out=tfplan   │
│  ─ Post plan as PR comment      │
│  ─ Upload plan artifact         │
└────────────┬────────────────────┘
             │ PR merged to main
             ▼
┌─────────────────────────────────┐
│  apply dev                      │
│  ─ terraform init (with backend)│
│  ─ terraform apply tfplan-dev   │
│  (auto-approve via env gate)    │
└────────────┬────────────────────┘
             │ dev apply success
             ▼
┌─────────────────────────────────┐
│  apply prod                     │
│  ─ Awaiting manual approval     │◄─── GitHub Environment reviewer
│  ─ terraform apply tfplan-prod  │
└─────────────────────────────────┘
```

### GitHub Environment Setup

1. Go to **Settings > Environments** in your GitHub repo
2. Create `dev` — no protection rules (auto-deploy)
3. Create `prod` — add Required reviewers (yourself or team lead)
4. Add secrets to each environment: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `TF_VAR_ssh_public_key`

### OIDC Federation (recommended over static secrets)

```bash
# Create Azure AD app registration for GitHub Actions
az ad app create --display-name "github-actions-terraform"

# Add federated credential for main branch apply
az ad app federated-credential create \
  --id <app-id> \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<owner>/<repo>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## Module Testing with Terratest

Automated plan-based tests live in `tests/` using [Terratest](https://terratest.gruntwork.io/) (Go). These tests validate the plan output without deploying real resources — no Azure credentials needed.

### Running Tests

```bash
cd tests
go mod tidy
go test -v -timeout 10m
```

### Test Coverage

The test suite (`tests/vnet_module_test.go`) includes 5 tests:

| Test | What It Validates |
|------|-------------------|
| `TestVnetModuleValidation` | Resource group, VNET, subnets, and NSGs follow naming convention |
| `TestVnetModuleOutputs` | All expected outputs are present with correct static values |
| `TestVmModuleNaming` | VM, NIC, and public IP naming; correct SKU and admin username |
| `TestStorageModuleConfig` | Storage account naming, TLS 1.2, HTTPS-only, private access, LRS replication |
| `TestResourceCount` | Dev environment plans exactly 13 resources |

### What to test in each module

| Module        | Key Assertions                                              |
|---------------|-------------------------------------------------------------|
| vnet          | vnet_id not empty, subnet count matches input, NSG attached |
| vm            | vm_id not empty, private_ip in subnet CIDR, public_ip empty when disabled |
| blob-storage  | storage_account_name matches convention, primary_blob_endpoint contains HTTPS |

---

## Scaling to Multi-Region

The folder structure supports adding regions without code changes to existing modules.

### Adding a dev environment in West US 2

```bash
cp -r environments/dev environments/dev-westus
# Edit environments/dev-westus/terraform.tfvars:
#   location     = "westus2"
#   region_short = "wus"
```

The `instance` variable handles collision avoidance:
- East US dev: `vnet-challenge-dev-eus-001`
- West US 2 dev: `vnet-challenge-dev-wus-001`

For active-active multi-region, add VNET peering by setting:
```hcl
enable_vnet_peering        = true
peering_remote_vnet_id     = module.vnet_westus.vnet_id
```

### Management Group layout for multi-region prod

```
environments/
├── dev/           # Primary region dev (East US)
├── dev-westus/    # Secondary region dev (West US 2) — optional
├── prod/          # Primary region prod (West Europe)
└── prod-westus/   # DR region prod (West US 2) — for active-passive
```

---

## Cleanup / Destroy

### Via Makefile (local)

```bash
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

# Destroy dev first
cd environments/dev && terraform destroy -var-file=terraform.tfvars

# Then prod
cd ../prod && terraform destroy -var-file=terraform.tfvars
```

### Via GitHub Actions (manual workflow)

1. Go to **Actions > Terraform Destroy**
2. Click **Run workflow**
3. Select environment (`dev` or `prod`)
4. Type the confirmation string: `destroy-dev` or `destroy-prod`
5. Click **Run workflow**

The workflow validates the confirmation string before executing destroy.

---

## Local Development Quick Reference

### Pre-commit Hooks

Pre-commit hooks run automatically on every `git commit` to catch issues early:

```bash
# Install hooks (one time)
pre-commit install

# Run all hooks manually
pre-commit run --all-files
```

Hooks configured (`.pre-commit-config.yaml`):
- `terraform_fmt` — enforces canonical formatting
- `terraform_validate` — checks syntax and module references
- `terraform_tflint` — linting with azurerm rules
- `terraform_docs` — auto-regenerates module READMEs
- `detect-private-key` — prevents accidental secret commits
- `trailing-whitespace` / `end-of-file-fixer` — code hygiene

### Automated Module Documentation

Module READMEs are auto-generated by `terraform-docs` from HCL comments. They include usage examples, inputs/outputs tables, and resource listings.

```bash
# Regenerate all module docs
make docs

# Or manually per module
terraform-docs modules/vnet/
terraform-docs modules/vm/
terraform-docs modules/blob-storage/
```

The `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` markers in each module README define the injection zone. Content between markers is fully auto-generated — do not edit manually.

### Makefile Targets

```bash
# Format all files
make fmt

# Run all checks (fmt, lint, validate, security)
make all-checks

# Generate module documentation
make docs

# Security scan only
make security-scan

# Plan specific environment
make plan-dev
make plan-prod

# Run Terratest suite
cd tests && go test -v -timeout 10m

# Clean artifacts
make clean
```
