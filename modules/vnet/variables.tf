variable "address_space" {
  description = "The address space that is used by the virtual network (list of CIDR blocks)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet configurations. Each entry defines a subnet with optional NSG rules."
  type = map(object({
    address_prefix = string
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
  }))
  default = {}
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

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where VNET resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment (e.g., eastus, westeurope)"
  type        = string
  default     = "eastus"
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

variable "enable_vnet_peering" {
  description = "Enable VNET peering to a remote virtual network"
  type        = bool
  default     = false
}

variable "peering_remote_vnet_id" {
  description = "Resource ID of the remote VNET for peering (required if enable_vnet_peering = true)"
  type        = string
  default     = ""
  validation {
    condition     = var.peering_remote_vnet_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+$", var.peering_remote_vnet_id))
    error_message = "peering_remote_vnet_id must be a valid Azure VNET resource ID."
  }
}

variable "peering_allow_forwarded_traffic" {
  description = "Allow forwarded traffic in the VNET peering connection"
  type        = bool
  default     = false
}

variable "peering_allow_gateway_transit" {
  description = "Allow gateway transit in the VNET peering connection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to merge with default mandatory tags"
  type        = map(string)
  default     = {}
}
