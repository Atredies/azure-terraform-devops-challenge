variable "vm_size" {
  description = "Azure VM SKU size (e.g., Standard_B1s, Standard_B2s, Standard_D2s_v3)"
  type        = string
  default     = "Standard_B1s"
}

variable "subnet_id" {
  description = "Resource ID of the subnet to attach the VM network interface to"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where VM resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment (e.g., eastus, westeurope)"
  type        = string
  default     = "eastus"
}

variable "admin_username" {
  description = "Administrator username for the Linux virtual machine"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key content for VM authentication (no password auth)"
  type        = string
}

variable "public_ip_enabled" {
  description = "Whether to create and attach a public IP address to the VM"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "Short region identifier used in naming convention (e.g., eus, weu, wus)"
  type        = string
  default     = "eus"
}

variable "instance" {
  description = "Instance number suffix for the naming convention (e.g., 001, 002)"
  type        = string
  default     = "001"
}

variable "project" {
  description = "Project identifier used in resource naming convention"
  type        = string
  default     = "challenge"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}

variable "os_disk_caching" {
  description = "Caching type for the OS disk (None, ReadOnly, ReadWrite)"
  type        = string
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be one of: None, ReadOnly, ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk (Standard_LRS, Premium_LRS, StandardSSD_LRS, UltraSSD_LRS)"
  type        = string
  default     = "Standard_LRS"
  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS", "UltraSSD_LRS"], var.os_disk_storage_account_type)
    error_message = "Storage account type must be one of: Standard_LRS, Premium_LRS, StandardSSD_LRS, UltraSSD_LRS."
  }
}

variable "tags" {
  description = "Additional tags to merge with default mandatory tags"
  type        = map(string)
  default     = {}
}
