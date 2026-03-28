# Dev Environment — Deployment Instructions

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI >= 2.50
- RSA SSH key (`ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-challenge -N ""`)
- Authenticated to Azure (`az login`)

## Deploy

```bash
cd <your-repo-path>/environments/dev

# Initialize
terraform init -backend=false

# Plan (13 resources)
terraform plan -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)" -out=tfplan

# Apply (~2-3 minutes)
terraform apply tfplan
```

## Verify

```bash
# List all resources in the dev resource group
az resource list --resource-group rg-challenge-dev-eus-001 -o table

# View outputs
terraform output
```

## SSH Into the VM

Dev has a public IP, so you can SSH directly:

```bash
ssh -i ~/.ssh/azure-challenge azureadmin@$(terraform output -raw vm_public_ip)
```

## Destroy

```bash
terraform destroy -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)"
# Type 'yes' when prompted
```

## Verify Destruction

```bash
# Should return ResourceGroupNotFound
az group show --name rg-challenge-dev-eus-001 2>&1

# Should show no challenge resources
az group list --query "[?contains(name, 'challenge')]" -o table

# Full subscription check
az resource list -o table
```

## What Gets Created (13 Resources)

| Resource | Name | Notes |
|----------|------|-------|
| Resource Group | `rg-challenge-dev-eus-001` | East US |
| Virtual Network | `vnet-challenge-dev-eus-001` | 10.0.0.0/16 |
| Subnet (app) | `snet-challenge-app-dev-eus-001` | 10.0.1.0/24 |
| Subnet (data) | `snet-challenge-data-dev-eus-001` | 10.0.2.0/24 |
| NSG (app) | `nsg-challenge-app-dev-eus-001` | SSH + HTTP allowed |
| NSG (data) | `nsg-challenge-data-dev-eus-001` | VNet only, deny internet |
| NSG Association | 2x | Links subnets to NSGs |
| Public IP | `pip-challenge-dev-eus-001` | Static, Standard SKU |
| Network Interface | `nic-challenge-dev-eus-001` | Attached to app subnet |
| Linux VM | `vm-challenge-dev-eus-001` | Standard_B1s, Ubuntu 22.04 |
| Storage Account | `stchallengedeveus001` | LRS, versioning, 7-day soft delete |
| Storage Container | `data` | Private access |

## Cost Notes

- Standard_B1s VMs are free-tier eligible (750 hrs/month)
- 5 GB of LRS Blob Storage is free
- Run `terraform destroy` when done to avoid charges
