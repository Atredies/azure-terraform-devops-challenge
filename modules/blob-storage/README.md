# Azure Blob Storage Module

Reusable Terraform module for provisioning an Azure Storage Account with blob container, versioning, and soft-delete.

## Usage

```hcl
module "blob_storage" {
  source = "../../modules/blob-storage"

  project                  = "myproject"
  environment              = "dev"
  region                   = "eus"
  location                 = "eastus"
  resource_group_name      = azurerm_resource_group.this.name
  storage_account_name     = "stmyprojectdeveus001"
  account_replication_type = "LRS"
  soft_delete_days         = 7

  tags = { CostCenter = "dev-workloads" }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.80 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.80 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group where storage resources will be created | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name for the storage account (must be globally unique, 3-24 chars, lowercase alphanumeric only) | `string` | n/a | yes |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Replication type for the storage account (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS) | `string` | `"LRS"` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | Access level for the blob container (private, blob, container) | `string` | `"private"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the blob storage container to create within the storage account | `string` | `"data"` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable blob versioning to track and restore previous versions of objects | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resource deployment (e.g., eastus, westeurope) | `string` | `"eastus"` | no |
| <a name="input_soft_delete_days"></a> [soft\_delete\_days](#input\_soft\_delete\_days) | Number of days to retain soft-deleted blobs (7 for dev, 30 for prod recommended) | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge with default mandatory tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | The name of the blob storage container |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account (sensitive) |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob service endpoint URL for the storage account |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The resource ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
