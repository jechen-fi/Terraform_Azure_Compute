locals {
  # Name of the VM in the Azure Control Plane
  legacy_vm_name_mask = try(var.settings.name, "{vmnameprefix}{delimiter}{postfix}")
  # Name of the Windows computer name
  legacy_computer_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].computer_name, "{vmnameprefix}{delimiter}{postfix}")
  # Name for the OS disk
  legacy_osdisk_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].os_disk.name, "{referenced_name}{delimiter}{osdisk}")
  # Name for the Data disk
  legacy_datadisk_name_mask = "{referenced_name}{delimiter}{datadisk}{delimiter}{postfix}"
}

module "resource_naming_legacy_vm_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "legacy" ? var.settings.virtual_machine_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_virtual_machine"
  name_mask       = try(each.value.naming_convention.name_mask, local.legacy_vm_name_mask)
  name            = try(each.value.name, null)
  object_count    = try(var.vm_count, "0")
}

module "resource_naming_legacy_computer_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "legacy" ? var.settings.virtual_machine_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_virtual_machine"
  name_mask       = try(each.value.naming_convention.name_mask, local.legacy_computer_name_mask)
  name            = try(each.value.computer_name, each.value.name, null)
}

module "resource_naming_legacy_osdisk_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "legacy" ? var.settings.virtual_machine_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_virtual_machine"
  name_mask       = try(each.value.os_disk.naming_convention.name_mask, local.legacy_osdisk_name_mask)
  name            = try(each.value.os_disk.name, null)
  referenced_name = module.resource_naming_legacy_vm_name[each.key].name_result
}

module "resource_naming_legacy_datadisk_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "legacy" ? lookup(var.settings, "storage_data_disks", {}) : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_managed_disk"
  name            = try(each.value.name, null)
  name_mask       = try(each.value.naming_convention.name_mask, local.legacy_datadisk_name_mask)
  referenced_name = local.os_type == "legacy" ? module.resource_naming_legacy_vm_name[each.value.vm_setting_key].name_result : null
}

resource "azurerm_virtual_machine" "vm" {
  for_each = local.os_type == "legacy" ? var.settings.virtual_machine_settings : {}

  name                             = module.resource_naming_legacy_vm_name[each.key].name_result
  location                         = var.location != null ? var.location : var.global_settings.location
  resource_group_name              = var.resource_group_name
  vm_size                          = each.value.size
  network_interface_ids            = local.nic_ids
  zones                            = try([each.value.zones], null)
  tags                             = merge(local.tags, try(each.value.tags, null))
  delete_os_disk_on_termination    = try(each.value.delete_os_disk_on_termination, null)
  delete_data_disks_on_termination = try(each.value.delete_data_disks_on_termination, null)

  # dynamic
  os_profile {
    computer_name  = module.resource_naming_legacy_computer_name[each.key].name_result
    admin_password = coalesce(try(each.value.admin_password, null), var.admin_password, local.admin_password, try(random_password.legacy[local.os_type].result, null))
    admin_username = coalesce(try(each.value.admin_username, null), var.admin_username, local.admin_username)
  }

  # os_profile_secrets

  dynamic "os_profile_linux_config" {
    for_each = try(each.value.os_profile_linux_config, null) == null ? [] : [1]

    content {
      disable_password_authentication = try(each.value.os_profile_linux_config.disable_password_authentication, true)

      dynamic "ssh_keys" {
        for_each = each.value.os_profile_linux_config.disable_password_authentication == false ? [] : [1]

        content {
          key_data = local.create_sshkeys ? tls_private_key.ssh[each.key].public_key_openssh : file(var.settings.public_key_pem_file)
          path     = "/home/${each.value.admin_username}/.ssh/authorized_keys"
        }
      }
    }
  }

  dynamic "os_profile_secrets" {
    for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

    content {

      source_vault_id = local.keyvault.id

      # WinRM certificate
      dynamic "vault_certificates" {
        for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

        content {
          certificate_url   = azurerm_key_vault_certificate.self_signed_winrm[each.key].secret_id
          certificate_store = "My"
        }
      }
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = try(each.value.os_profile_windows_config, null) == null ? [] : [1]

    content {
      provision_vm_agent        = try(each.value.os_profile_windows_config.provision_vm_agent, null)
      enable_automatic_upgrades = try(each.value.os_profile_windows_config.enable_automatic_upgrades, null)
      timezone                  = try(each.value.os_profile_windows_config.timezone, null)

      dynamic "winrm" {
        for_each = {
          for key, value in try(each.value.os_profile_windows_config.winrm, {}) : key => value
        }

        content {
          protocol        = winrm.value.protocol
          certificate_url = try(winrm.value.certificate_url, null)
        }

      }

      dynamic "additional_unattend_config" {
        for_each = {
          for key, value in try(each.value.os_profile_windows_config.additional_unattend_config, {}) : key => value
        }

        content {
          pass         = additional_unattend_config.value.pass
          component    = additional_unattend_config.value.component
          setting_name = additional_unattend_config.value.setting_name
          content      = additional_unattend_config.value.content
        }
      }
    }
  }

  availability_set_id = try(var.availability_sets[each.value.availability_set_key].id, null)

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account != null ? [1] : []

    content {
      storage_uri = var.boot_diagnostics_storage_account
      enabled     = true
    }
  }

  dynamic "additional_capabilities" {
    for_each = try(each.value.additional_capabilities, null) == null ? [] : [1]

    content {
      ultra_ssd_enabled = each.value.additional_capabilities.ultra_ssd_enabled
    }

  }

  proximity_placement_group_id = try(var.proximity_placement_groups[each.value.proximity_placement_group_key].id, null)

  storage_os_disk {
    caching                   = try(each.value.os_disk.caching, null)
    disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
    name                      = module.resource_naming_legacy_osdisk_name[each.key].name_result
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
    create_option             = each.value.os_disk.create_option
    image_uri                 = try(each.value.os_disk.set_image_uri, false) == true ? try("${each.value.storage_image_reference.publisher}:${each.value.storage_image_reference.offer}:${each.value.storage_image_reference.sku}:${each.value.storage_image_reference.version}", null) : null
    os_type                   = try(each.value.os_disk.os_type, null)
    managed_disk_id           = try(each.value.os_disk.managed_disk_id, null)
    managed_disk_type         = try(each.value.os_disk.managed_disk_type, null)
    vhd_uri                   = try(each.value.os_disk.vhd_uri, null)
  }

  dynamic "storage_image_reference" {
    for_each = try(each.value.storage_image_reference, false) == false ? [] : [1]

    content {
      publisher = try(each.value.storage_image_reference.publisher, null)
      offer     = try(each.value.storage_image_reference.offer, null)
      sku       = try(each.value.storage_image_reference.sku, null)
      version   = try(each.value.storage_image_reference.version, null)
      id        = try(each.value.storage_image_reference.custom_image_id, var.custom_image_ids[each.value.storage_image_reference.custom_image_key].id, null)
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

  dynamic "storage_data_disk" {
    for_each = local.os_type == "legacy" ? lookup(var.settings, "storage_data_disks", {}) : {}

    content {
      name                      = module.resource_naming_legacy_datadisk_name[storage_data_disk.key].name_result
      caching                   = try(storage_data_disk.value.caching, null)
      create_option             = storage_data_disk.value.create_option
      disk_size_gb              = try(storage_data_disk.value.disk_size_gb)
      lun                       = storage_data_disk.value.lun
      write_accelerator_enabled = try(storage_data_disk.value.write_accelerator_enabled, null)
      managed_disk_type         = try(storage_data_disk.value.managed_disk_type, null)
      managed_disk_id           = try(storage_data_disk.value.managed_disk_id, null)
      vhd_uri                   = try(storage_data_disk.value.vhd_uri, null)
    }
  }


  dynamic "identity" {
    for_each = try(each.value.identity, false) == false ? [] : [1]

    content {
      type         = each.value.identity.type
      identity_ids = concat(local.managed_identities, try(each.value.identity.identity_ids, []))
    }
  }

  license_type = try(each.value.license_type, null)

  lifecycle {
    ignore_changes = [
      resource_group_name, location
    ]
  }

}

resource "random_password" "legacy" {
  for_each = (local.os_type == "legacy") && var.admin_password == null && try(var.settings.virtual_machine_settings[local.os_type].admin_password, null) == null && (try(var.settings.virtual_machine_settings["legacy"].admin_password_key, null) == null) ? var.settings.virtual_machine_settings : {}

  length           = 123
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}
