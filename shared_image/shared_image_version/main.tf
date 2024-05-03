resource "azurerm_shared_image_version" "shrd_img_version" {
  name                = var.name
  gallery_name        = var.gallery_name
  image_name          = var.shared_image_name
  resource_group_name = var.resource_group_name
  location            = var.location
  managed_image_id    = var.managed_image_id
  tags                = var.tags

  target_region {
    name                        = var.target_region.name
    regional_replica_count      = var.target_region.regional_replica_count
    disk_encryption_set_id      = try(var.target_region.disk_encryption_set_id, null)
    exclude_from_latest_enabled = try(var.target_region.exclude_from_latest_enabled, false)
    storage_account_type        = try(var.target_region.storage_account_type, "Standard_LRS")
  }

  blob_uri                                 = try(var.shared_image_version_config.blob_uri, null)
  end_of_life_date                         = try(var.shared_image_version_config.end_of_life_date, null)
  exclude_from_latest                      = try(var.shared_image_version_config.exclude_from_latest, null)
  os_disk_snapshot_id                      = try(var.shared_image_version_config.os_disk_snapshot_id, null)
  deletion_of_replicated_locations_enabled = try(var.shared_image_version_config.deletion_of_replicated_locations_enabled, null)
  replication_mode                         = try(var.shared_image_version_config.replication_mode, null)
  storage_account_id                       = try(var.shared_image_version_config.storage_account_id, null)
}