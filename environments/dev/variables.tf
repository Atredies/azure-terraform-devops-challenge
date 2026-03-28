variable "environment" {
  description = "Deployment environment identifier"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Primary Azure region for dev resources"
  type        = string
  default     = "eastus"
}

variable "region_short" {
  description = "Short region code used in resource naming convention"
  type        = string
  default     = "eus"
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
