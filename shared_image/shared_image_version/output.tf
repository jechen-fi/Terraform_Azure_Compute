output "id" {
  description = "The ID of the Shared Image Version."
  value       = azurerm_shared_image_version.shrd_img_version.id
}

output "shrd_img_version" {
  value = azurerm_shared_image_version.shrd_img_version
}
