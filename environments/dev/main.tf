# Environment Isolation Strategy: Resource Groups vs Subscriptions
#
# This project uses RESOURCE GROUPS for environment separation because:
# 1. Cost: Single subscription avoids per-subscription overhead
# 2. Simplicity: One set of RBAC, one billing boundary for a challenge project
# 3. Sufficient isolation: RG-level locks, policies, and RBAC provide adequate separation
#
# When to use SUBSCRIPTIONS instead:
# - Production workloads with strict blast-radius requirements
# - Compliance mandates (HIPAA, PCI-DSS) requiring network isolation
# - Different billing/cost centers per environment
# - Azure Policy inheritance at subscription scope
# - Subscription-level quotas becoming a bottleneck
#
# Recommendation for real-world: Use separate subscriptions under a Management Group
# hierarchy for prod vs non-prod, with Azure Policy enforcing guardrails.

locals {
  instance = "001"
  env_tags = merge(
    {
      CostCenter = "dev-workloads"
    },
    var.extra_tags
  )
}

# Resource Group for all dev resources
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}-${var.environment}-${var.region_short}-${local.instance}"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = "azure-terraform-devops-challenge"
    ManagedBy   = "terraform"
    Owner       = "opella"
  }
}

# VNET — dev uses 10.0.0.0/16 with app and data subnets
# NSG rules are permissive for development (no inbound HTTPS restriction)
module "vnet" {
  source = "../../modules/vnet"

  project             = var.project_name
  environment         = var.environment
  region              = var.region_short
  instance            = local.instance
  location            = var.location
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
        },
        {
          name                       = "allow-http-inbound"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
      ]
    }
    data = {
      address_prefix = "10.0.2.0/24"
      nsg_rules = [
        {
          name                       = "allow-vnet-inbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-internet-inbound"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        },
      ]
    }
  }

  tags = local.env_tags
}

# VM — dev uses smallest SKU with public IP for easy access
module "vm" {
  source = "../../modules/vm"

  project             = var.project_name
  environment         = var.environment
  region              = var.region_short
  instance            = local.instance
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.subnet_ids["app"]
  vm_size             = "Standard_B1s"
  public_ip_enabled   = true # Dev: public IP for direct SSH access
  admin_username      = "azureadmin"
  ssh_public_key      = var.ssh_public_key

  # Dev: use cheaper Standard_LRS disk
  os_disk_storage_account_type = "Standard_LRS"

  tags = local.env_tags
}

# Blob Storage — dev uses LRS replication with 7-day soft delete
module "blob_storage" {
  source = "../../modules/blob-storage"

  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  storage_account_name     = "stchallenge${var.environment}${var.region_short}001"
  account_replication_type = "LRS" # Dev: cheaper local redundancy
  container_name           = "data"
  soft_delete_days         = 7 # Dev: 7-day retention
  enable_versioning        = true

  tags = local.env_tags
}
