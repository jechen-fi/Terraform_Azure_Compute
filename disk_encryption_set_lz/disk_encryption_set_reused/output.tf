output "id" {
  description = "The ID of the Disk Encryption Set"
  value       = data.azurerm_disk_encryption_set.encryption_set.id
}
output "name" {
  description = "The Name of the Disk Encryption Set"
  value       = data.azurerm_disk_encryption_set.encryption_set.name
}
output "location" {
  description = "The location where the Disk Encryption exists"
  value       = data.azurerm_disk_encryption_set.encryption_set.location
}
output "auto_key_rotation_enabled" {
  description = "Is the Azure Disk Encryption Set Key automatically rotated to latest version"
  value       = data.azurerm_disk_encryption_set.encryption_set.auto_key_rotation_enabled
}
