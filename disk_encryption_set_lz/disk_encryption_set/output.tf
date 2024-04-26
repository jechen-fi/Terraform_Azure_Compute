output "id" {
  description = "The ID of the Disk Encryption Set"
  value       = azurerm_disk_encryption_set.encryption_set.id
}
output "name" {
  description = "The Name of the Disk Encryption Set"
  value       = azurerm_disk_encryption_set.encryption_set.name
}
output "principal_id" {
  description = "The Identity Principal ID of the Disk Encryption Set"
  value       = azurerm_disk_encryption_set.encryption_set.identity.0.principal_id
}
output "tenant_id" {
  description = "The Identity Tenant ID of the Disk Encryption Set"
  value       = azurerm_disk_encryption_set.encryption_set.identity.0.tenant_id
}
