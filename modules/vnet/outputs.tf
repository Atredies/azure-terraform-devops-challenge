output "vnet_id" {
  description = "The resource ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet logical names to their resource IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "nsg_ids" {
  description = "Map of subnet logical names to their NSG resource IDs"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.this.address_space
}
