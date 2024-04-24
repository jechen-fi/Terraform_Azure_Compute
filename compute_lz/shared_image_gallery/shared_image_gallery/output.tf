output "id" {
  description = "The ID of the Shared Image Gallery"
  value       = azurerm_shared_image_gallery.gallery.id
}

output "name" {
  description = "The Name of the Shared Image Gallery"
  value       = azurerm_shared_image_gallery.gallery.name
}

output "unique_name" {
  description = "The Unique Name for this Shared Image Gallery"
  value       = azurerm_shared_image_gallery.gallery.unique_name
}
