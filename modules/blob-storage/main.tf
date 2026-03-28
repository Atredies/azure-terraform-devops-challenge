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
  # Naming convention: st{project}{environment}{region}{instance} (no dashes — storage accounts don't allow them)
  # Max 24 chars: "st" + project(9) + env(4) + region(3) + instance(3) = fits within limit
  storage_account_name = var.storage_account_name

  default_tags = {
    Environment = var.environment
    Project     = "azure-terraform-devops-challenge"
    ManagedBy   = "terraform"
    Owner       = "opella"
    CreatedDate = timestamp()
  }
  tags = merge(local.default_tags, var.tags)
}

# Storage Account
resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  tags                     = local.tags

  # Secure defaults
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  blob_properties {
    versioning_enabled = var.enable_versioning

    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }
  }

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

# Blob Container
resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = var.container_access_type
}
