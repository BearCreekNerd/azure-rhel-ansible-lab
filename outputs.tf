output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.rhel_vm.name
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm_nic.private_ip_address
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.rhel_vm.id
}

output "admin_username" {
  value = var.admin_username
}
