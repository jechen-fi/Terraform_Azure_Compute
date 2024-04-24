output "id" {
  description = "The ID of the Data Managed Image"
  value       = data.azurerm_image.image.id
}

output "name" {
  description = "The Name of the Data Managed Image"
  value       = data.azurerm_image.image.name
}
