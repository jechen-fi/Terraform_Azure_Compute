resource "azurerm_virtual_machine_extension" "network_watcher" {
  for_each                   = var.extension_name == "NetworkWatcher" ? toset(["enabled"]) : toset([])
  name                       = "NetworkWatcher"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = try(var.extension.type_handler_version, "1.4")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, null)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, null)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(
    {
      "commandToExecute" : "powershell.exe -Command \"${local.powershell_command}\""
    }
  )

}

locals {
  resource_group_name  = try(coalesce(var.resource_group_name, var.extension.resource_group_name), "VAR_NOT_SET")
  location             = try(coalesce(var.location, var.extension.location), "VAR_NOT_SET")
  virtual_machine_name = try(coalesce(var.virtual_machine_name, var.extension.virtual_machine_name), "VAR_NOT_SET")
  powershell_command   = "Set-AzVMExtension -ResourceGroupName ${local.resource_group_name} -Location ${local.location} -VMName ${local.virtual_machine_name}"
}
