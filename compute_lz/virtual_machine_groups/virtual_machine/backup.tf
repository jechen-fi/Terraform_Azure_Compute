
resource "azurerm_backup_protected_vm" "backup" {
  count = try(var.settings.backup, null) == null ? 0 : 1

  resource_group_name = coalesce(
    try(var.settings.backup.backup_vault_rg, null),
    try(split("/", var.settings.backup.backup_vault_id)[4], null),
    try(var.recovery_vaults[var.settings.backup.vault_key].resource_group_name, null)
  )
  recovery_vault_name = coalesce(
    try(var.settings.backup.backup_vault_name, null),
    try(split("/", var.settings.backup.backup_vault_id)[8], null),
    try(var.recovery_vaults[var.settings.backup.vault_key].name, null)
  )
  source_vm_id = try(azurerm_linux_virtual_machine.vm[local.os_type].id, azurerm_windows_virtual_machine.vm[local.os_type].id, azurerm_virtual_machine.vm[local.os_type].id, null)
  backup_policy_id = coalesce(
    try(var.settings.backup.backup_policy_id, null),
    try(var.recovery_vaults[var.settings.backup.vault_key].backup_policies.virtual_machines[var.settings.backup.policy_key].id, null)
  )

  timeouts {
    create = "3h"
    delete = "90m"
  }

}