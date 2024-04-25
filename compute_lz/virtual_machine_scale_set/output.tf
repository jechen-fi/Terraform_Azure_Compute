output "id" {
  description = "The ID of the Virtual Machine Scale Set"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine_scale_set.vmss["linux"].id, null) : try(azurerm_windows_virtual_machine_scale_set.vmss["windows"].id, null)
}

output "os_type" {
  description = "The OS Type (from settings) of the Virtual Machine Scale Set"
  value       = local.os_type
}

output "admin_username" {
  description = "The Local Admin Username of the Virtual Machine Scale Set"
  value       = try(local.admin_username, null) == null ? try(coalesce(var.settings.vmss_settings[local.os_type].admin_username, var.admin_username), null) : local.admin_username
}

output "admin_password_secret_id" {
  description = "The Local Admin Password Key Vault Secret ID of the Virtual Machine Scale Set"
  value       = try(azurerm_key_vault_secret.admin_password[local.os_type].id, null)
}

# TODO - Need to figure out how to get this working

# output "winrm" {
#   description = "The WinRM Key Vault Info of the Virtual Machine Scale Set"
#   value = local.os_type == "windows" ? {
#     keyvault_id     = local.keyvault.id
#     certificate_url = try(azurerm_key_vault_certificate.self_signed_winrm[local.os_type].secret_id, null)
#   } : null
# }

output "ssh_keys" {
  description = "The SSH Keys of the Virtual Machine Scale Set"
  value = local.create_sshkeys ? {
    keyvault_id              = local.keyvault.id
    ssh_private_key_pem      = azurerm_key_vault_secret.ssh_private_key[local.os_type].name
    ssh_public_key_open_ssh  = azurerm_key_vault_secret.ssh_public_key_openssh[local.os_type].name
    ssh_private_key_open_ssh = azurerm_key_vault_secret.ssh_public_key_openssh[local.os_type].name #for backard compat, wrong name, will be removed in future version.
  } : null
}
