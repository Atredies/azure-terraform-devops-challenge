variable "storage_account_name" {
  description = "Name for the storage account (must be globally unique, 3-24 chars, lowercase alphanumeric only)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where storage resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment (e.g., eastus, westeurope)"
  type        = string
  default     = "eastus"
}

variable "account_replication_type" {
  description = "Replication type for the storage account (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "container_name" {
  description = "Name of the blob storage container to create within the storage account"
  type        = string
  default     = "data"
}

variable "container_access_type" {
  description = "Access level for the blob container (private, blob, container)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "soft_delete_days" {
  description = "Number of days to retain soft-deleted blobs (7 for dev, 30 for prod recommended)"
  type        = number
  default     = 7
  validation {
    condition     = var.soft_delete_days >= 1 && var.soft_delete_days <= 365
    error_message = "soft_delete_days must be between 1 and 365."
  }
}

variable "enable_versioning" {
  description = "Enable blob versioning to track and restore previous versions of objects"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Additional tags to merge with default mandatory tags"
  type        = map(string)
  default     = {}
}
