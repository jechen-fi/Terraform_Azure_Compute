output "id" {
  description = "The ID of the SSH Public Key"
  value       = azurerm_ssh_public_key.ssh_key.id
}
output "name" {
  description = "The Name of the SSH Public Key"
  value       = azurerm_ssh_public_key.ssh_key.name
}
output "public_key" {
  description = "The Public Key of the SSH Public Key"
  value       = azurerm_ssh_public_key.ssh_key.public_key #public_key_openssh
  sensitive   = true
}
