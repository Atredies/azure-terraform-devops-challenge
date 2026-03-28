output "vm_id" {
  description = "The resource ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip" {
  description = "The private IP address assigned to the VM's network interface"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "The public IP address of the VM (empty string if public_ip_enabled = false)"
  value       = var.public_ip_enabled ? azurerm_public_ip.this[0].ip_address : ""
}

output "nic_id" {
  description = "The resource ID of the network interface"
  value       = azurerm_network_interface.this.id
}
