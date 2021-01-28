#########################################
## Linux VM with              - Output ##
#########################################

# lin VM ID
output "lin_vm_id" {
  value = azurerm_linux_virtual_machine.lin-vm.id
}

# lin VM Name
output "lin_vm_name" {
  value = azurerm_linux_virtual_machine.lin-vm.name
}

# lin VM Public IP
output "lin_vm_public_ip" {
  value = azurerm_public_ip.lin-vm-ip.ip_address
}

# lin VM Admin Username
output "vm_admin_username" {
  value = var.admin_username
}
