output "id" {
  description = "The ID of the Managed Image"
  value       = azurerm_image.image.id
}

output "name" {
  description = "The Name of the Managed Image"
  value       = azurerm_image.image.name
}
