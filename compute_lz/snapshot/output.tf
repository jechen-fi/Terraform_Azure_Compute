output "id" {
  description = "The ID of the Snapshot"
  value       = azurerm_snapshot.snapshot.id
}

output "name" {
  description = "The Name of the Snapshot"
  value       = azurerm_snapshot.snapshot.name
}

output "disk_size_gb" {
  description = "The Size of the Snapshotted Disk in GB"
  value       = azurerm_snapshot.snapshot.disk_size_gb
}

output "trusted_launch_enabled" {
  description = "Whether Trusted Launch is enabled for the Snapshot"
  value       = azurerm_snapshot.snapshot.trusted_launch_enabled
}
