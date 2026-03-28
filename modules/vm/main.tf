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
  vm_name  = "vm-${var.project}-${var.environment}-${var.region}-${var.instance}"
  pip_name = "pip-${var.project}-${var.environment}-${var.region}-${var.instance}"
  nic_name = "nic-${var.project}-${var.environment}-${var.region}-${var.instance}"

  default_tags = {
    Environment = var.environment
    Project     = "azure-terraform-devops-challenge"
    ManagedBy   = "terraform"
    Owner       = "opella"
    CreatedDate = timestamp()
  }
  tags = merge(local.default_tags, var.tags)
}

# Public IP — only created when public_ip_enabled = true
resource "azurerm_public_ip" "this" {
  count = var.public_ip_enabled ? 1 : 0

  name                = local.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

# Network Interface
resource "azurerm_network_interface" "this" {
  name                = local.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.this[0].id : null
  }

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

# Linux Virtual Machine — Ubuntu 22.04 LTS, SSH key auth only
resource "azurerm_linux_virtual_machine" "this" {
  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = local.tags

  # SSH key authentication — no password auth allowed
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Ubuntu 22.04 LTS — canonical image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202512181"
  }

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}
