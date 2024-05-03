output "id" {
  description = "The ID of the Shared Image Gallery."
  value       = azurerm_shared_image_gallery.shrd_img_gallery.id
}

output "shrd_img_gallery" {
  value = azurerm_shared_image_gallery.shrd_img_gallery
}