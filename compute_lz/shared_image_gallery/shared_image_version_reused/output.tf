output "id" {
  description = "The ID of the Shared Image Version"
  value       = data.azurerm_shared_image_version.resource.id
}

output "name" {
  description = "The Name of the Shared Image Version"
  value       = data.azurerm_shared_image_version.resource.name
}

output "image_name" {
  description = "The Shared Image name in which this Shared Image Version exists"
  value       = data.azurerm_shared_image_version.resource.image_name
}

output "gallery_name" {
  description = "The name of the Shared Image Gallery in which the Shared Image exists"
  value       = data.azurerm_shared_image_version.resource.gallery_name
}

output "exclude_from_latest" {
  description = "Is this Image Version excluded from the latest filter"
  value       = data.azurerm_shared_image_version.resource.exclude_from_latest
}

output "managed_image_id" {
  description = "The ID of the Managed Image which was the source of this Shared Image Version"
  value       = data.azurerm_shared_image_version.resource.managed_image_id
}

output "target_region" {
  description = "Target Region block"
  value       = data.azurerm_shared_image_version.resource.target_region
}

output "os_disk_snapshot_id" {
  description = "The ID of the OS disk snapshot which was the source of this Shared Image Version"
  value       = data.azurerm_shared_image_version.resource.os_disk_snapshot_id
}

output "os_disk_image_size_gb" {
  description = "The size of the OS disk snapshot (in Gigabytes) which was the source of this Shared Image Version"
  value       = data.azurerm_shared_image_version.resource.os_disk_image_size_gb
}
