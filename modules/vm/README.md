# Azure Linux VM Module

Reusable Terraform module for provisioning an Azure Linux Virtual Machine with NIC and optional public IP.

## Usage

```hcl
module "vm" {
  source = "../../modules/vm"

  project             = "myproject"
  environment         = "dev"
  region              = "eus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.subnet_ids["app"]
  vm_size             = "Standard_B1s"
  public_ip_enabled   = true
  ssh_public_key      = var.ssh_public_key

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
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group where VM resources will be created | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key content for VM authentication (no password auth) | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Resource ID of the subnet to attach the VM network interface to | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Administrator username for the Linux virtual machine | `string` | `"azureadmin"` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance number suffix for the naming convention (e.g., 001, 002) | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resource deployment (e.g., eastus, westeurope) | `string` | `"eastus"` | no |
| <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching) | Caching type for the OS disk (None, ReadOnly, ReadWrite) | `string` | `"ReadWrite"` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Size of the OS disk in GB | `number` | `30` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | Storage account type for the OS disk (Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS) | `string` | `"Standard_LRS"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project identifier used in resource naming convention | `string` | `"challenge"` | no |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | Whether to create and attach a public IP address to the VM | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Short region identifier used in naming convention (e.g., eus, weu, wus) | `string` | `"eus"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge with default mandatory tags | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM SKU size (e.g., Standard\_B1s, Standard\_B2s, Standard\_D2s\_v3) | `string` | `"Standard_B1s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nic_id"></a> [nic\_id](#output\_nic\_id) | The resource ID of the network interface |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP address assigned to the VM's network interface |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP address of the VM (empty string if public\_ip\_enabled = false) |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The resource ID of the virtual machine |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | The name of the virtual machine |
<!-- END_TF_DOCS -->
