output "storage_account_id" {
  description = "The resource ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The primary blob service endpoint URL for the storage account"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_name" {
  description = "The name of the blob storage container"
  value       = azurerm_storage_container.this.name
}

output "primary_access_key" {
  description = "The primary access key for the storage account (sensitive)"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}
