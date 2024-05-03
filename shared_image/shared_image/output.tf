output "img_id" {
  value = var.deploy_image ? azurerm_image.image[0].id : null
}

output "image" {
  value = azurerm_image.image
}

output "shrd_img_id" {
  description = "The ID of the Shared Image."
  value       = azurerm_shared_image.shrd_img.id
}

output "shrd_img" {
  value = azurerm_shared_image.shrd_img
}