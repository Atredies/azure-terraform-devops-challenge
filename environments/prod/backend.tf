# Remote State Backend — Azure Storage Account
#
# SETUP INSTRUCTIONS:
# 1. Create an Azure Storage Account and container for Terraform state:
#    az group create --name rg-terraform-state-eus-001 --location eastus
#    az storage account create --name stterraformstateeus001 \
#      --resource-group rg-terraform-state-eus-001 \
#      --sku Standard_GRS --kind StorageV2
#    az storage container create --name tfstate \
#      --account-name stterraformstateeus001
#
# 2. Uncomment the backend block below and set your values.
# 3. Run: terraform init -reconfigure
#
# NOTE: Do NOT store access keys in code. Use ARM_ACCESS_KEY env var or MSI.
# For prod, Workload Identity Federation (OIDC) is strongly recommended.

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state-eus-001"
#     storage_account_name = "stterraformstateeus001"
#     container_name       = "tfstate"
#     key                  = "prod/terraform.tfstate"
#     # use_oidc = true  # for GitHub Actions with OIDC federation (recommended)
#   }
# }
