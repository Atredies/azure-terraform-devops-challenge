# Azure Terraform Challenge — Command Cheatsheet

## Prerequisites

```bash
# Install prerequisites
# - Terraform >= 1.5.0
# - Azure CLI >= 2.50

# Login to Azure (opens browser for MFA)
az login --tenant <your-tenant-id>

# Verify
terraform version
az account show
```

## SSH Key Setup

```bash
# Azure requires RSA keys (ed25519 not supported)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-challenge -N ""
```

## Deploy Dev Environment

```bash
cd azure-terraform-devops-challenge/environments/dev

# 1. Initialize — downloads provider plugins, loads modules
terraform init -backend=false

# 2. Plan — shows what will be created (13 resources)
terraform plan -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)" -out=tfplan

# 3. Apply — creates resources in Azure (~2-3 min)
terraform apply tfplan

# 4. View outputs
terraform output
terraform output vm_public_ip
```

## Deploy Prod Environment

```bash
cd azure-terraform-devops-challenge/environments/prod

terraform init -backend=false
terraform plan -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)" -out=tfplan
terraform apply tfplan
```

## SSH Into the VM (Dev Only — Prod Has No Public IP)

```bash
ssh -i ~/.ssh/azure-challenge azureadmin@$(terraform output -raw vm_public_ip)
```

## Verify Resources in Azure

```bash
# List all resources in the dev resource group
az resource list --resource-group rg-challenge-dev-eus-001 -o table

# List all resources in the prod resource group
az resource list --resource-group rg-challenge-prod-weu-001 -o table
```

## Destroy (Tear Down All Resources)

```bash
cd azure-terraform-devops-challenge/environments/dev
terraform destroy -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)"
# Type 'yes' when prompted
```

## Verify Destruction

```bash
# Check resource group is gone (should return ResourceGroupNotFound)
az group show --name rg-challenge-dev-eus-001 2>&1

# Check no challenge resource groups remain
az group list --query "[?contains(name, 'challenge')]" -o table

# Check for soft-deleted storage accounts (linger 14 days)
az storage account list --query "[?contains(name, 'stchallenge')]" -o table

# List everything in the subscription (spot orphaned resources)
az resource list -o table

# Verify Terraform state is empty
terraform show
```

## Local Validation (No Azure Account Needed)

```bash
cd azure-terraform-devops-challenge/environments/dev

# Initialize without backend
terraform init -backend=false

# Validate syntax and module references
terraform validate

# Check formatting
terraform fmt -check -recursive ../../

# Run tflint (if installed)
tflint --init && tflint

# Security scan (if installed)
checkov -d . --framework terraform
```

## Makefile Shortcuts

```bash
cd azure-terraform-devops-challenge

# Run all linting/validation
make all-checks

# Plan dev
make plan-dev

# Plan prod
make plan-prod
```

## Useful Azure CLI Commands

```bash
# Show current subscription
az account show -o table

# List all subscriptions
az account list -o table

# Switch subscription
az account set --subscription "<subscription-id>"

# List all resource groups
az group list -o table

# Show cost for a resource group
az consumption usage list --query "[?contains(instanceName, 'challenge')]" -o table
```

## Capture Plan Output for Submission

```bash
cd azure-terraform-devops-challenge/environments/dev
terraform plan -var="ssh_public_key=$(cat ~/.ssh/azure-challenge.pub)" -no-color > ../../plan-output/dev-plan.txt
```
