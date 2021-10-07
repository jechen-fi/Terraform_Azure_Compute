output "vm_info_linux" {
  value       = local.os_type == "linux" ? azurerm_linux_virtual_machine.linuxvm : null
  description = "Output for linux virtual machines"
  sensitive   = true
}

output "vm_info_windows" {
  value       = local.os_type == "windows" ? azurerm_windows_virtual_machine.winvm : null
  description = "Output for windows virtual machines"
  #  sensitive = true
}

output "vm_windows_id" {
  value       = local.os_type == "windows" ? azurerm_windows_virtual_machine.winvm.id : null
  description = "Output VM ID for windows virtual machine"
  #  sensitive = true
}

output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.generate_admin_ssh_key == true && local.os_type == "linux" ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.generate_admin_ssh_key == true && local.os_type == "linux" ? tls_private_key.rsa[0].private_key_pem : null
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine availability set"
  value       = tobool(var.enable_av_set) ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
}
