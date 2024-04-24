output "id" {
  description = "The ID of the Shared Image Version"
  value       = azurerm_shared_image_version.image.id
}

output "name" {
  description = "The Name of the Shared Image Version"
  value       = azurerm_shared_image_version.image.name
}
