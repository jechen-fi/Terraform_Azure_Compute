locals {
  # Name of the VM in the Azure Control Plane
  linux_vm_name_mask = try(var.settings.name, "{vmnameprefix}{delimiter}{postfix}")
  # Name of the Linux computer name
  linux_computer_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].computer_name, "{vmnameprefix}{delimiter}{postfix}")
  # Name for the OS disk
  # linux_osdisk_name_mask = "{vmnameprefix}{delimiter}{postfix}{delimiter}{osdisk}"
  linux_osdisk_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].os_disk.name, "{referenced_name}{delimiter}{osdisk}")
}

module "resource_naming_linux_vm_name" {
  source   = "../../../../resource_naming"
  for_each = local.os_type == "linux" ? var.settings.virtual_machine_settings : {}

  global_settings    = var.global_settings
  settings           = each.value
  resource_type      = "azurerm_linux_virtual_machine"
  name_mask          = try(each.value.naming_convention.name_mask, local.linux_vm_name_mask)
  name               = try(each.value.name, null)
  object_name_prefix = try(var.vm_name_prefix, null)
  object_count       = try(var.vm_count, "0")
}

module "resource_naming_linux_computer_name" {
  source   = "../../../../resource_naming"
  for_each = local.os_type == "linux" ? var.settings.virtual_machine_settings : {}

  global_settings    = var.global_settings
  settings           = each.value
  resource_type      = "azurerm_linux_virtual_machine"
  name_mask          = try(each.value.naming_convention.name_mask, local.linux_computer_name_mask)
  name               = try(each.value.computer_name, each.value.name, null)
  object_name_prefix = try(var.vm_name_prefix, null)
  object_count       = try(var.vm_count, 0)
}

module "resource_naming_linux_os_disk_name" {
  source   = "../../../../resource_naming"
  for_each = local.os_type == "linux" ? var.settings.virtual_machine_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_managed_disk"
  name_mask       = try(each.value.os_disk.naming_convention.name_mask, local.linux_osdisk_name_mask)
  name            = try(each.value.os_disk.name, null)
  referenced_name = module.resource_naming_linux_vm_name[each.key].name_result
}

resource "tls_private_key" "ssh" {
  for_each = local.create_sshkeys ? var.settings.virtual_machine_settings : {}

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.os_type == "linux" ? var.settings.virtual_machine_settings : {}

  admin_password = try(coalesce(try(each.value.admin_password, null), var.admin_password), null)
  admin_username = coalesce(try(each.value.admin_username, null), var.admin_username)

  allow_extension_operations      = try(each.value.allow_extension_operations, null)
  availability_set_id             = try(var.availability_sets[each.value.availability_set_key].id, null)
  computer_name                   = module.resource_naming_linux_computer_name[each.key].name_result
  disable_password_authentication = try(each.value.disable_password_authentication, true)
  eviction_policy                 = try(each.value.eviction_policy, null)
  license_type                    = try(each.value.license_type, null)
  location                        = var.location != null ? var.location : var.global_settings.location
  max_bid_price                   = try(each.value.max_bid_price, null)
  name                            = module.resource_naming_linux_vm_name[each.key].name_result
  network_interface_ids           = local.nic_ids
  priority                        = try(each.value.priority, null)
  provision_vm_agent              = try(each.value.provision_vm_agent, true)
  proximity_placement_group_id    = try(var.proximity_placement_groups[each.value.proximity_placement_group_key].id, var.proximity_placement_groups[each.value.proximity_placement_groups].id, null)
  resource_group_name             = var.resource_group_name
  size                            = each.value.size
  tags                            = local.tags
  zone                            = try(each.value.zone, null)
  encryption_at_host_enabled      = try(each.value.encryption_at_host_enabled, null)
  patch_assessment_mode           = try(each.value.patch_assessment_mode, "ImageDefault")
  patch_mode                      = try(each.value.patch_mode, "ImageDefault")
  vtpm_enabled                    = try(each.value.vtpm_enabled, null)
  secure_boot_enabled             = try(each.value.secure_boot_enabled, null)

  custom_data = try(
    local.dynamic_custom_data[each.value.custom_data][each.value.name],
    try(filebase64(format("%s/%s", path.cwd, each.value.custom_data)), base64encode(each.value.custom_data)),
    null
  )

  dedicated_host_id = try(coalesce(
    try(each.value.dedicated_host.id, null),
    var.dedicated_hosts[each.value.dedicated_host.key].id,
    ),
    null
  )

  dynamic "admin_ssh_key" {
    for_each = lookup(each.value, "disable_password_authentication", true) == true ? [1] : []

    content {
      username   = each.value.admin_username
      public_key = local.create_sshkeys ? tls_private_key.ssh[each.key].public_key_openssh : file(var.settings.public_key_pem_file)
    }
  }

  os_disk {
    caching                   = try(each.value.os_disk.caching, null)
    disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
    name                      = module.resource_naming_linux_os_disk_name[each.key].name_result
    storage_account_type      = try(each.value.os_disk.storage_account_type, null)
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
    disk_encryption_set_id    = try(each.value.os_disk.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[each.value.os_disk.disk_encryption_set_key].id, var.disk_encryption_sets[each.value.os_disk.disk_encryption_set_key].id, null)
  }

  dynamic "source_image_reference" {
    for_each = try(each.value.source_image_reference, null) != null ? [1] : []

    content {
      publisher = try(each.value.source_image_reference.publisher, null)
      offer     = try(each.value.source_image_reference.offer, null)
      sku       = try(each.value.source_image_reference.sku, null)
      version   = try(each.value.source_image_reference.version, null)
    }
  }

  source_image_id = try(each.value.custom_image_id, var.custom_image_ids[each.value.custom_image_key].id, null)

  dynamic "identity" {
    for_each = try(each.value.identity, false) == false ? [] : [1]

    content {
      type         = each.value.identity.type
      identity_ids = concat(local.managed_identities, try(each.value.identity.identity_ids, []))
    }
  }

  dynamic "boot_diagnostics" {
    for_each = try(var.boot_diagnostics_storage_account != null ? [1] : var.global_settings.resource_defaults.virtual_machines.use_azmanaged_storage_for_boot_diagnostics == true ? [1] : [], [])

    content {
      storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
    }
  }

  dynamic "plan" {
    for_each = try(each.value.plan, false) == false ? [] : [1]

    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  lifecycle {
    ignore_changes = [
      resource_group_name,
      location,
      os_disk[0].name,
      availability_set_id,
      admin_password,
      admin_username
    ]
  }

}

#
# SSH keys to be stored in KV only if public_key_pem_file is not set
#

resource "azurerm_key_vault_secret" "ssh_private_key" {
  for_each = local.create_sshkeys ? var.settings.virtual_machine_settings : {}

  name         = format("%s-ssh-private-key", try(module.resource_naming_linux_computer_name[each.key].name_result, module.resource_naming_legacy_computer_name[each.key].name_result))
  value        = tls_private_key.ssh[each.key].private_key_pem
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      value, key_vault_id
    ]
  }
}


resource "azurerm_key_vault_secret" "ssh_public_key_openssh" {
  for_each = local.create_sshkeys ? var.settings.virtual_machine_settings : {}

  name         = format("%s-ssh-public-key-openssh", try(module.resource_naming_linux_computer_name[each.key].name_result, module.resource_naming_legacy_computer_name[each.key].name_result))
  value        = tls_private_key.ssh[each.key].public_key_openssh
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      value, key_vault_id
    ]
  }
}

