# Azure VNET Module

Reusable Terraform module for provisioning an Azure Virtual Network with dynamic subnets, NSG security rules, and optional VNET peering.

## Usage

```hcl
module "vnet" {
  source = "../../modules/vnet"

  project             = "myproject"
  environment         = "dev"
  region              = "eus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    app = {
      address_prefix = "10.0.1.0/24"
      nsg_rules = [
        {
          name                       = "allow-ssh-inbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

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
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group where VNET resources will be created | `string` | n/a | yes |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network (list of CIDR blocks) | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_enable_vnet_peering"></a> [enable\_vnet\_peering](#input\_enable\_vnet\_peering) | Enable VNET peering to a remote virtual network | `bool` | `false` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance number suffix for the naming convention (e.g., 001, 002) | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resource deployment (e.g., eastus, westeurope) | `string` | `"eastus"` | no |
| <a name="input_peering_allow_forwarded_traffic"></a> [peering\_allow\_forwarded\_traffic](#input\_peering\_allow\_forwarded\_traffic) | Allow forwarded traffic in the VNET peering connection | `bool` | `false` | no |
| <a name="input_peering_allow_gateway_transit"></a> [peering\_allow\_gateway\_transit](#input\_peering\_allow\_gateway\_transit) | Allow gateway transit in the VNET peering connection | `bool` | `false` | no |
| <a name="input_peering_remote_vnet_id"></a> [peering\_remote\_vnet\_id](#input\_peering\_remote\_vnet\_id) | Resource ID of the remote VNET for peering (required if enable\_vnet\_peering = true) | `string` | `""` | no |
| <a name="input_project"></a> [project](#input\_project) | Project identifier used in resource naming convention | `string` | `"challenge"` | no |
| <a name="input_region"></a> [region](#input\_region) | Short region identifier used in naming convention (e.g., eus, weu, wus) | `string` | `"eus"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet configurations. Each entry defines a subnet with optional NSG rules. | <pre>map(object({<br/>    address_prefix = string<br/>    nsg_rules = optional(list(object({<br/>      name                       = string<br/>      priority                   = number<br/>      direction                  = string<br/>      access                     = string<br/>      protocol                   = string<br/>      source_port_range          = string<br/>      destination_port_range     = string<br/>      source_address_prefix      = string<br/>      destination_address_prefix = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge with default mandatory tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | The address space of the virtual network |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of subnet logical names to their NSG resource IDs |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet logical names to their resource IDs |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The resource ID of the virtual network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the virtual network |
<!-- END_TF_DOCS -->
