output "id" {
  description = "The ID of the Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].id, null) : try(azurerm_windows_virtual_machine.vm["windows"].id, null)
}

output "name" {
  description = "The Name of the Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].name, null) : try(azurerm_windows_virtual_machine.vm["windows"].name, null)
}

output "identity" {
  description = "The Identity block of the Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].identity, null) : try(azurerm_windows_virtual_machine.vm["windows"].identity, null)
}

output "private_ip_address" {
  description = "The Primary Private IP Address assigned to this Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].private_ip_address, null) : try(azurerm_windows_virtual_machine.vm["windows"].private_ip_address, null)
}

output "private_ip_addresses" {
  description = "A list of Private IP Addresses assigned to this Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].private_ip_addresses, null) : try(azurerm_windows_virtual_machine.vm["windows"].private_ip_addresses, null)
}

output "public_ip_address" {
  description = "The Primary Public IP Address assigned to this Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].public_ip_address, null) : try(azurerm_windows_virtual_machine.vm["windows"].public_ip_address, null)
}

output "public_ip_addresses" {
  description = "A list of the Public IP Addresses assigned to this Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].public_ip_addresses, null) : try(azurerm_windows_virtual_machine.vm["windows"].public_ip_addresses, null)
}

output "virtual_machine_id" {
  description = "A 128-bit identifier which uniquely identifies this Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].virtual_machine_id, null) : try(azurerm_windows_virtual_machine.vm["windows"].virtual_machine_id, null)
}

output "os_type" {
  description = "The OS Type (from settings) of the Virtual Machine"
  value       = local.os_type
}

output "internal_fqdns" {
  description = "The NIC FQDNs of the Virtual Machine"
  value = try(var.settings.networking_interfaces, null) != null ? flatten([
    for nic_key in try(var.settings.virtual_machine_settings[local.os_type].network_interface_keys, []) : format("%s.%s", try(azurerm_network_interface.nic[nic_key].internal_dns_name_label, try(azurerm_linux_virtual_machine.vm["linux"].name, azurerm_windows_virtual_machine.vm["windows"].name)), azurerm_network_interface.nic[nic_key].internal_domain_name_suffix)
  ]) : null
}

output "admin_username" {
  description = "The Local Admin Username of the Virtual Machine"
  value       = try(local.admin_username, null) == null ? try(coalesce(var.settings.virtual_machine_settings[local.os_type].admin_username, var.admin_username), null) : local.admin_username
}

output "admin_password_secret_id" {
  description = "The Local Admin Password Key Vault Secret ID of the Virtual Machine"
  value       = try(azurerm_key_vault_secret.admin_password[local.os_type].id, null)
}

output "winrm" {
  description = "The WinRM Info of the Virtual Machine"
  value = local.os_type == "windows" ? {
    keyvault_id     = try(local.keyvault.id, null)
    certificate_url = try(azurerm_key_vault_certificate.self_signed_winrm[local.os_type].secret_id, null)
  } : null
}

output "ssh_keys" {
  description = "The SSH Keys of the Linux Virtual Machine"
  value = local.create_sshkeys ? {
    keyvault_id              = try(local.keyvault.id, null)
    ssh_private_key_pem      = try(azurerm_key_vault_secret.ssh_private_key[local.os_type].name, null)
    ssh_public_key_open_ssh  = try(azurerm_key_vault_secret.ssh_public_key_openssh[local.os_type].name, null)
    ssh_private_key_open_ssh = try(azurerm_key_vault_secret.ssh_public_key_openssh[local.os_type].name, null) #for backard compat, wrong name, will be removed in future version.
  } : null
}

output "nic_id" {
  description = "The NIC IDs of the Virtual Machine"
  value = coalescelist(
    flatten(
      [
        for nic_key in try(var.settings.virtual_machine_settings[local.os_type].network_interface_keys, []) : format("%s.%s", try(azurerm_network_interface.nic[nic_key].id, try(azurerm_linux_virtual_machine.vm["linux"].name, azurerm_windows_virtual_machine.vm["windows"].name)), azurerm_network_interface.nic[nic_key].id)
      ]
    ),
    try(var.settings.networking_interface_ids, [])
  )
}

output "nics" {
  description = "The NIC objects of the Virtual Machine"
  value = {
    for key, value in var.settings.network_interfaces : key => {
      id                   = azurerm_network_interface.nic[key].id
      name                 = azurerm_network_interface.nic[key].name
      ip_configurations    = azurerm_network_interface.nic[key].ip_configuration.*
      mac_address          = azurerm_network_interface.nic[key].mac_address
      private_ip_address   = azurerm_network_interface.nic[key].private_ip_address
      private_ip_addresses = azurerm_network_interface.nic[key].private_ip_addresses
    }
  }
}

# output nic_id {
#   description = "The NIC IDs of the Virtual Machine NIC Resources"
#   value = azurerm_network_interface.nic.*.id
# }

output "network_interface_application_security_group_associations" {
  value = azurerm_network_interface_application_security_group_association.assoc
}

output "management_host_identity_object_id" {
  description = "The VM Managed Identity Object ID of the Virtual Machine"
  value       = local.os_type == "linux" ? try(azurerm_linux_virtual_machine.vm["linux"].identity.0.principal_id, null) : try(azurerm_windows_virtual_machine.vm["windows"].identity.0.principal_id, null)
}
