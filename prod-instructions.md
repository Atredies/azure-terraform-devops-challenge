# Prod Environment — Deployment Instructions

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI >= 2.50
- RSA SSH key (`ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-challenge -N ""`)
- Authenticated to Azure (`az login`)

## Deploy

```bash
cd <your-repo-path>/environments/prod

# Initialize
terraform init -backend=false

# Plan (15 resources)
terraform plan -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)" -out=tfplan

# Apply (~2-3 minutes)
terraform apply tfplan
```

## Verify

```bash
# List all resources in the prod resource group
az resource list --resource-group rg-challenge-prod-weu-001 -o table

# View outputs
terraform output
```

## Access

Prod has **no public IP** by design. The VM is only accessible via:
- VPN gateway (not deployed in this challenge)
- Azure Bastion (not deployed in this challenge)
- The management subnet (`snet-challenge-mgmt-prod-weu-001`)

To verify the VM exists without SSH:

```bash
az vm show --resource-group rg-challenge-prod-weu-001 --name vm-challenge-prod-weu-001 -o table
```

## Destroy

```bash
terraform destroy -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)"
# Type 'yes' when prompted
```

## Verify Destruction

```bash
# Should return ResourceGroupNotFound
az group show --name rg-challenge-prod-weu-001 2>&1

# Should show no challenge resources
az group list --query "[?contains(name, 'challenge')]" -o table

# Full subscription check
az resource list -o table
```

## What Gets Created (15 Resources)

| Resource | Name | Notes |
|----------|------|-------|
| Resource Group | `rg-challenge-prod-weu-001` | West Europe |
| Virtual Network | `vnet-challenge-prod-weu-001` | 10.1.0.0/16 |
| Subnet (app) | `snet-challenge-app-prod-weu-001` | 10.1.1.0/24 |
| Subnet (data) | `snet-challenge-data-prod-weu-001` | 10.1.2.0/24 |
| Subnet (mgmt) | `snet-challenge-mgmt-prod-weu-001` | 10.1.3.0/24 |
| NSG (app) | `nsg-challenge-app-prod-weu-001` | HTTPS only, deny-all default |
| NSG (data) | `nsg-challenge-data-prod-weu-001` | VNet only, deny internet |
| NSG (mgmt) | `nsg-challenge-mgmt-prod-weu-001` | SSH from mgmt subnet only |
| NSG Association | 3x | Links subnets to NSGs |
| Network Interface | `nic-challenge-prod-weu-001` | Attached to app subnet, no public IP |
| Linux VM | `vm-challenge-prod-weu-001` | Standard_B2s, Ubuntu 22.04, Premium SSD 64GB |
| Storage Account | `stchallengeprodweu001` | GRS (geo-redundant), versioning, 30-day soft delete |
| Storage Container | `data` | Private access |

## Key Differences from Dev

| Aspect | Dev | Prod |
|--------|-----|------|
| Region | East US | West Europe |
| Subnets | 2 (app, data) | 3 (app, data, mgmt) |
| VM Size | Standard_B1s | Standard_B2s |
| VM Public IP | Yes | No |
| OS Disk | Standard_LRS, 30 GB | Premium_LRS, 64 GB |
| Storage Replication | LRS (local) | GRS (geo-redundant) |
| Soft Delete Retention | 7 days | 30 days |
| SSH Access | Open from any IP | Restricted to mgmt subnet |
| HTTP/HTTPS | HTTP allowed | HTTPS only, deny-all default |
