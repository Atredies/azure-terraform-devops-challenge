output "resource_group_name" {
  description = "Name of the prod resource group containing all resources"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "Resource ID of the prod virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the prod virtual network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet logical names to resource IDs in prod"
  value       = module.vnet.subnet_ids
}

output "vm_private_ip" {
  description = "Private IP address of the prod virtual machine"
  value       = module.vm.private_ip
}

output "storage_account_name" {
  description = "Name of the prod storage account"
  value       = module.blob_storage.storage_account_name
}

output "storage_primary_endpoint" {
  description = "Primary blob endpoint URL for the prod storage account"
  value       = module.blob_storage.primary_blob_endpoint
}
