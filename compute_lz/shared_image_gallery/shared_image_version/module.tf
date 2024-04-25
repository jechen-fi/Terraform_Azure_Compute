
locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{name}"
}

module "resource_naming" {
  source = "../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_shared_image_version"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_shared_image_version" "image" {
  ## Name == The version number for this Image Version, such as 1.0.0
  name                = module.resource_naming.name_result
  location            = var.location != null ? var.location : var.global_settings.location
  resource_group_name = var.resource_group_name
  gallery_name        = var.gallery_name
  image_name          = var.image_name
  blob_uri            = try(var.settings.blob_uri, null)
  end_of_life_date    = try(var.settings.end_of_life_date, null)
  exclude_from_latest = try(var.settings.exclude_from_latest, null)
  managed_image_id    = var.managed_image_id
  os_disk_snapshot_id = try(var.settings.os_disk_snapshot_id, null)
  replication_mode    = try(var.settings.replication_mode, null)
  storage_account_id  = try(var.settings.sa_key, null) != null ? try(var.storage_accounts[var.settings.sa_key].id, null) : try(var.settings.storage_account_id, null)
  tags                = local.tags

  dynamic "target_region" {
    for_each = try(var.settings.target_regions, {})

    content {
      name                   = target_region.value.name
      regional_replica_count = target_region.value.regional_replica_count
      disk_encryption_set_id = try(target_region.value.disk_encryption_set_id, null)
      storage_account_type   = try(target_region.value.storage_account_type, "Standard_LRS")
    }
  }

}
