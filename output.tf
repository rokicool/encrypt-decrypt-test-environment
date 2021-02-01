

/* -----------------------------------------------------------------------
-
Outputs
-
*/


# Win VM Public IP
#output "win-vm-web-left-left_public_ip" {
#  value = module.win-web-one.win_vm_public_ip
#}

# Lin VM Public IP
#output "lin-vm-web-left-left_public_ip" {
#  value = module.lin-web-one.lin_vm_public_ip
#}

# Win VM Name
output "win-vm-one-name" {
  value = module.win-web-one.win_vm_name
}

# Lin VM Name
output "lin-vm-one-name" {
  value = module.lin-web-one.lin_vm_name
}

output "key-vault-id" {
  description = "Key Vault ID"
  value       = module.keyvault.key-vault-id
}

output "key-vault-url" {
  description = "Key Vault URI"
  value       = module.keyvault.key-vault-url
}

output "key-vault-secrets" {
  description = "Key Vault Secrets"
  value       = module.keyvault.key-vault-secrets
}
