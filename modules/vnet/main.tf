terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

locals {
  # Naming convention: {resource_abbreviation}-{project}-{environment}-{region_short}-{instance}
  vnet_name = "vnet-${var.project}-${var.environment}-${var.region}-${var.instance}"

  default_tags = {
    Environment = var.environment
    Project     = "azure-terraform-devops-challenge"
    ManagedBy   = "terraform"
    Owner       = "opella"
    CreatedDate = timestamp()
  }
  tags = merge(local.default_tags, var.tags)
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

# Network Security Groups — one per subnet
resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${var.project}-${each.key}-${var.environment}-${var.region}-${var.instance}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = each.value.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

# Subnets — one per entry in var.subnets
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = "snet-${var.project}-${each.key}-${var.environment}-${var.region}-${var.instance}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}

# Associate each NSG with its corresponding subnet
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# Optional VNET Peering — only created when enable_vnet_peering = true
resource "azurerm_virtual_network_peering" "this" {
  count = var.enable_vnet_peering ? 1 : 0

  name                         = "peer-${local.vnet_name}-to-remote"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peering_remote_vnet_id
  allow_forwarded_traffic      = var.peering_allow_forwarded_traffic
  allow_gateway_transit        = var.peering_allow_gateway_transit
  allow_virtual_network_access = true
}
