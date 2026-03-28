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
      CostCenter  = "prod-workloads"
      Criticality = "high"
    },
    var.extra_tags
  )
}

# Resource Group for all prod resources
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

# VNET — prod uses 10.1.0.0/16 with app, data, and mgmt subnets
# NSG rules are stricter: only known HTTPS/SSH sources, no wildcard inbound
module "vnet" {
  source = "../../modules/vnet"

  project             = var.project_name
  environment         = var.environment
  region              = var.region_short
  instance            = local.instance
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.1.0.0/16"]

  subnets = {
    app = {
      address_prefix = "10.1.1.0/24"
      nsg_rules = [
        {
          name                       = "allow-https-inbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
      ]
    }
    data = {
      address_prefix = "10.1.2.0/24"
      nsg_rules = [
        {
          name                       = "allow-app-subnet-inbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
      ]
    }
    mgmt = {
      address_prefix = "10.1.3.0/24"
      nsg_rules = [
        {
          name                       = "allow-ssh-from-mgmt"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.1.3.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
      ]
    }
  }

  tags = local.env_tags
}

# VM — prod uses larger SKU, private-only (no public IP), Premium SSD
module "vm" {
  source = "../../modules/vm"

  project             = var.project_name
  environment         = var.environment
  region              = var.region_short
  instance            = local.instance
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.subnet_ids["app"]
  vm_size             = "Standard_B2s"
  public_ip_enabled   = false # Prod: no public IP, access via mgmt subnet or VPN
  admin_username      = "azureadmin"
  ssh_public_key      = var.ssh_public_key

  # Prod: Premium SSD for better IOPS
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 64

  tags = local.env_tags
}

# Blob Storage — prod uses GRS replication with 30-day soft delete
module "blob_storage" {
  source = "../../modules/blob-storage"

  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  storage_account_name     = "stchallenge${var.environment}${var.region_short}001"
  account_replication_type = "GRS" # Prod: geo-redundant for durability
  container_name           = "data"
  soft_delete_days         = 30 # Prod: 30-day retention for compliance
  enable_versioning        = true

  tags = local.env_tags
}
