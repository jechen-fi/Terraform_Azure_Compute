resource "azurerm_virtual_machine_extension" "AVD_DSC_Extension" {
  for_each                   = var.extension_name == "AVD_DSC_Extension" ? toset(["enabled"]) : toset([])
  name                       = "AVD_DSC_Extension"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags,
      protected_settings,
      settings
    ]
  }

  settings = jsonencode(
    {
      "modulesURL" : var.extension.modulesURL,
      "configurationFunction" : "Configuration.ps1\\AddSessionHost",
      "properties" : {
        "hostPoolName" : coalesce(
          try(var.extension.host_pool_name, ""),
          try(var.avd_host_pools[var.extension.host_pool.keyvault_key].name, var.avd_host_pools[var.extension.host_pool.host_pool_key].name)
        ),
        "aadJoin" : true
      }
    }
  )
  protected_settings = jsonencode(
    {
      "properties" : {
        "registrationInfoToken" : try(var.extension.host_pool.hostPoolToken, var.avd_host_pools[var.extension.host_pool.host_pool_key].token, data.azurerm_key_vault_secret.hostPoolToken["enabled"].value)
      }
    }
  )
}

data "azurerm_key_vault_secret" "hostPoolToken" {
  for_each = var.extension_name == "AVD_DSC_Extension" && try(var.extension.host_pool.hostPoolToken, null) == null && try(var.extension.host_pool.getTokenFromKeyvault, false) == true ? toset(["enabled"]) : toset([])
  name     = var.extension.host_pool.secret_name
  key_vault_id = try(
    var.extension.host_pool.key_vault_id,
    var.keyvaults[var.extension.host_pool.keyvault_key].id
  )
}

