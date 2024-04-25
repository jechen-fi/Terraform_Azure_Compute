locals {
  # Name of the VM in the Azure Control Plane
  windows_vm_name_mask = try(var.settings.name, "{vmnameprefix}{delimiter}{postfix}")
  # Name of the Windows computer name
  windows_computer_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].computer_name, "{vmnameprefix}{delimiter}{postfix}")
  # Name for the OS disk
  # windows_osdisk_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].os_disk.name, "{vmnameprefix}{delimiter}{postfix}{delimiter}{osdisk}")
  windows_osdisk_name_mask = try(var.settings.virtual_machine_settings[var.settings.os_type].os_disk.name, "{referenced_name}{delimiter}{osdisk}")
}

module "resource_naming_windows_vm_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.virtual_machine_settings : {}

  global_settings    = var.global_settings
  settings           = each.value
  resource_type      = "azurerm_windows_virtual_machine"
  name_mask          = try(each.value.naming_convention.name_mask, local.windows_vm_name_mask)
  name               = try(each.value.name, null)
  object_name_prefix = try(var.vm_name_prefix, null)
  object_count       = try(var.vm_count, "0")
}

module "resource_naming_windows_computer_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.virtual_machine_settings : {}

  global_settings    = var.global_settings
  settings           = each.value
  resource_type      = "azurerm_windows_virtual_machine"
  name_mask          = try(each.value.naming_convention.name_mask, local.windows_computer_name_mask)
  name               = try(each.value.computer_name, each.value.name, null)
  object_name_prefix = try(var.vm_name_prefix, null)
  object_count       = try(var.vm_count, 0)
}

module "resource_naming_windows_os_disk_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.virtual_machine_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_managed_disk"
  name_mask       = try(each.value.os_disk.naming_convention.name_mask, local.windows_osdisk_name_mask)
  name            = try(each.value.os_disk.name, null)
  referenced_name = module.resource_naming_windows_computer_name[each.key].name_result
}

resource "azurerm_windows_virtual_machine" "vm" {
  depends_on = [azurerm_network_interface.nic, azurerm_network_interface_security_group_association.nic_nsg]
  for_each   = local.os_type == "windows" ? var.settings.virtual_machine_settings : {}

  admin_password = coalesce(try(each.value.admin_password, null), var.admin_password, local.admin_password, try(random_password.admin[local.os_type].result, null))
  admin_username = coalesce(try(each.value.admin_username, null), var.admin_username, local.admin_username)

  allow_extension_operations   = try(each.value.allow_extension_operations, null)
  availability_set_id          = try(var.availability_sets[each.value.availability_set_key].id, null)
  computer_name                = module.resource_naming_windows_computer_name[each.key].name_result
  enable_automatic_updates     = try(each.value.enable_automatic_updates, null)
  eviction_policy              = try(each.value.eviction_policy, null)
  license_type                 = try(each.value.license_type, null)
  location                     = var.location != null ? var.location : var.global_settings.location
  max_bid_price                = try(each.value.max_bid_price, null)
  name                         = module.resource_naming_windows_vm_name[each.key].name_result
  network_interface_ids        = local.nic_ids
  priority                     = try(each.value.priority, null)
  provision_vm_agent           = try(each.value.provision_vm_agent, true)
  proximity_placement_group_id = try(var.proximity_placement_groups[each.value.proximity_placement_group_key].id, var.proximity_placement_groups[each.value.proximity_placement_groups].id, null)
  resource_group_name          = var.resource_group_name
  size                         = each.value.size
  tags                         = merge(local.tags, try(each.value.tags, null))
  timezone                     = try(each.value.timezone, null)
  zone                         = try(each.value.zone, null)
  encryption_at_host_enabled   = try(each.value.encryption_at_host_enabled, null)
  patch_assessment_mode        = try(each.value.patch_assessment_mode, "ImageDefault")
  patch_mode                   = try(each.value.patch_mode, "AutomaticByOS")
  vtpm_enabled                 = try(each.value.vtpm_enabled, null)
  secure_boot_enabled          = try(each.value.secure_boot_enabled, null)

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

  os_disk {
    caching                   = each.value.os_disk.caching
    disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
    name                      = module.resource_naming_windows_os_disk_name[each.key].name_result
    storage_account_type      = each.value.os_disk.storage_account_type
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
    disk_encryption_set_id    = try(each.value.os_disk.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[each.value.os_disk.disk_encryption_set_key].id, null)

    dynamic "diff_disk_settings" {
      for_each = try(each.value.diff_disk_settings, false) == false ? [] : [1]

      content {
        option = each.value.diff_disk_settings.option
      }
    }
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

  dynamic "additional_capabilities" {
    for_each = try(each.value.additional_capabilities, false) == false ? [] : [1]

    content {
      ultra_ssd_enabled = each.value.additional_capabilities.ultra_ssd_enabled
    }
  }

  dynamic "additional_unattend_content" {
    for_each = try(each.value.additional_unattend_content, false) == false ? [] : [1]

    content {
      content = each.value.additional_unattend_content.content
      setting = each.value.additional_unattend_content.setting
    }
  }

  dynamic "boot_diagnostics" {
    for_each = try(var.boot_diagnostics_storage_account != null ? [1] : var.global_settings.resource_defaults.virtual_machines.use_azmanaged_storage_for_boot_diagnostics == true ? [1] : [], [])

    content {
      storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
    }
  }

  dynamic "secret" {
    for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

    content {

      key_vault_id = local.keyvault.id

      # WinRM certificate
      dynamic "certificate" {
        for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

        content {
          url   = azurerm_key_vault_certificate.self_signed_winrm[each.key].secret_id
          store = "My"
        }
      }
    }
  }

  dynamic "identity" {
    for_each = try(each.value.identity, false) == false ? [] : [1]

    content {
      type         = each.value.identity.type
      identity_ids = concat(local.managed_identities, try(each.value.identity.identity_ids, []))
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

  dynamic "winrm_listener" {
    for_each = try(each.value.winrm, false) == false ? [] : [1]

    content {
      protocol        = try(each.value.winrm.protocol, "Https")
      certificate_url = try(each.value.winrm.enable_self_signed, false) ? azurerm_key_vault_certificate.self_signed_winrm[each.key].secret_id : each.value.winrm.certificate_url
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

resource "random_password" "admin" {
  for_each         = (local.os_type == "windows") && var.admin_password == null && try(var.settings.virtual_machine_settings[local.os_type].admin_password, null) == null && (try(var.settings.virtual_machine_settings["windows"].admin_password_key, null) == null) ? var.settings.virtual_machine_settings : {}
  length           = 123
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each = local.os_type == "windows" && var.admin_password == null && try(var.settings.virtual_machine_settings[local.os_type].admin_password, null) == null && try(var.settings.virtual_machine_settings[local.os_type].admin_password_key, null) == null ? var.settings.virtual_machine_settings : {}

  name         = format("%s-admin-password", module.resource_naming_windows_computer_name[each.key].name_result)
  value        = random_password.admin[local.os_type].result
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      value, key_vault_id
    ]
  }
}

#
# Use data external to retrieve value from azure keyvault
#
# With for_each it is not possible to change the provider's subscription at runtime so using the following pattern.
#
data "external" "windows_admin_username" {
  count = try(var.settings.virtual_machine_settings["windows"].admin_username_key, var.settings.virtual_machine_settings["legacy"].admin_password_key, null) == null ? 0 : 1
  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      try(var.settings.virtual_machine_settings["windows"].admin_username_key, var.settings.virtual_machine_settings["legacy"].admin_username_key, null),
      local.keyvault.name
    )
  ]
}

data "external" "windows_admin_password" {
  count = try(var.settings.virtual_machine_settings["windows"].admin_password_key, var.settings.virtual_machine_settings["legacy"].admin_password_key, null) == null ? 0 : 1
  program = [
    "bash", "-c",
    format(
      "az keyvault secret show -n '%s' --vault-name '%s' --query '{value: value }' -o json",
      try(var.settings.virtual_machine_settings["windows"].admin_password_key, var.settings.virtual_machine_settings["legacy"].admin_password_key),
      local.keyvault.name
    )
  ]
}
