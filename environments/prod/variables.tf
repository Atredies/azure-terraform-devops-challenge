variable "environment" {
  description = "Deployment environment identifier"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Primary Azure region for prod resources (West Europe for latency diversity)"
  type        = string
  default     = "westeurope"
}

variable "region_short" {
  description = "Short region code used in resource naming convention"
  type        = string
  default     = "weu"
}

variable "project_name" {
  description = "Project identifier used in naming and tagging"
  type        = string
  default     = "challenge"
}

variable "ssh_public_key" {
  description = "SSH public key content for VM admin access (no password auth)"
  type        = string
  sensitive   = true
}

variable "extra_tags" {
  description = "Additional tags to apply to all resources in this environment"
  type        = map(string)
  default     = {}
}
