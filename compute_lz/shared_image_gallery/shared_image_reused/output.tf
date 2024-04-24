output "id" {
  description = "The ID of the Shared Image"
  value       = data.azurerm_shared_image.image.id
}

output "name" {
  description = "The Name of the Shared Image"
  value       = data.azurerm_shared_image.image.name
}
