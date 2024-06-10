locals {
  datadisk_name_mask = "{referenced_name}{delimiter}{datadisk}{delimiter}{postfix}"
}

module "resource_naming_datadisk_name" {
  source   = "../../../../resource_naming"
  for_each = lookup(var.settings, "data_disks", {})

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_managed_disk"
  name            = try(each.value.name, null)
  name_mask       = try(each.value.naming_convention.name_mask, local.datadisk_name_mask)
  referenced_name = local.os_type == "linux" ? module.resource_naming_linux_vm_name[each.value.vm_setting_key].name_result : local.os_type == "windows" ? module.resource_naming_windows_vm_name[each.value.vm_setting_key].name_result : module.resource_naming_legacy_vm_name[each.value.vm_setting_key].name_result
}

resource "azurerm_managed_disk" "disk" {
  for_each = lookup(var.settings, "data_disks", {})

  name                             = module.resource_naming_datadisk_name[each.key].name_result
  location                         = var.location != null ? var.location : var.global_settings.location
  resource_group_name              = var.resource_group_name
  tags                             = local.tags
  storage_account_type             = each.value.storage_account_type
  create_option                    = each.value.create_option
  disk_size_gb                     = each.value.disk_size_gb
  zone                             = try(each.value.zone, null)
  disk_iops_read_write             = try(each.value.disk_iops_read_write, null)
  disk_mbps_read_write             = try(each.value.disk.disk_mbps_read_write, null)
  disk_iops_read_only              = try(each.value.disk_iops_read_only, null)
  disk_mbps_read_only              = try(each.value.disk_mbps_read_only, null)
  upload_size_bytes                = try(each.value.upload_size_bytes, null)
  edge_zone                        = try(each.value.edge_zone, null)
  hyper_v_generation               = try(each.value.hyper_v_generation, null)
  image_reference_id               = try(each.value.image_reference_id, null)
  gallery_image_reference_id       = try(each.value.gallery_image_reference_id, null)
  logical_sector_size              = try(each.value.logical_sector_size, null)
  source_resource_id               = try(each.value.source_resource_id, null)
  source_uri                       = try(each.value.source_uri, null)
  storage_account_id               = try(each.value.storage_account_id, var.storage_accounts[each.value.sa_key].id, null)
  tier                             = try(each.value.tier, null)
  max_shares                       = try(each.value.max_shares, null)
  trusted_launch_enabled           = try(each.value.trusted_launch_enabled, null)
  security_type                    = try(each.value.security_type, null)
  secure_vm_disk_encryption_set_id = try(each.value.secure_vm_disk_encryption_set_id, null)
  on_demand_bursting_enabled       = try(each.value.on_demand_bursting_enabled, null)
  network_access_policy            = try(each.value.network_access_policy, null)
  disk_access_id                   = try(each.value.disk_access_id, null)
  public_network_access_enabled    = try(each.value.public_network_access_enabled, null)

  disk_encryption_set_id = try(each.value.disk_encryption_set_key, null) == null ? null : var.disk_encryption_sets[each.value.disk_encryption_set_key].id

  dynamic "encryption_settings" {
    for_each = try(each.value.encryption_settings, {})
    content {

      # enabled = true

      dynamic "disk_encryption_key" {
        for_each = try(encryption_settings.value.disk_encryption_key, {})
        content {
          secret_url      = try(disk_encryption_key.value.key_vault_secret_key, null) == null ? try(disk_encryption_key.value.secret_url, null) : var.keyvault_secrets[disk_encryption_key.value.key_vault_secret_key].id
          source_vault_id = try(disk_encryption_key.value.keyvault_key, null) == null ? try(disk_encryption_key.value.source_vault_id, null) : var.keyvaults[disk_encryption_key.value.keyvault_key].id
        }
      }
      dynamic "key_encryption_key" {
        for_each = try(encryption_settings.value.key_encryption_key, {})
        content {
          key_url         = try(key_encryption_key.value.key_vault_key_key, null) == null ? try(key_encryption_key.value.key_url, null) : var.keyvault_keys[key_encryption_key.value.key_vault_key_key].id
          source_vault_id = try(key_encryption_key.value.keyvault_key, null) == null ? try(key_encryption_key.value.source_vault_id, null) : var.keyvaults[key_encryption_key.value.keyvault_key].id
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      name, resource_group_name, location, encryption_settings
    ]
  }

}

resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  for_each = lookup(var.settings, "data_disks", {})

  managed_disk_id = coalesce(
    try(each.value.restored_disk_id, null),
    try(azurerm_managed_disk.disk[each.key].id, null)
  )
  virtual_machine_id        = local.os_type == "linux" ? azurerm_linux_virtual_machine.vm["linux"].id : local.os_type == "windows" ? azurerm_windows_virtual_machine.vm["windows"].id : azurerm_virtual_machine.vm["legacy"].id
  lun                       = each.value.lun
  caching                   = lookup(each.value, "caching", "None")
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", false)
  create_option             = lookup(each.value, "disk_attach_create_option", "Attach")
}
