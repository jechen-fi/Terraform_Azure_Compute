resource "azurerm_virtual_machine_extension" "domainjoin" {
  for_each                   = var.extension_name == "LegacyADLoginForWindows" ? toset(["enabled"]) : toset([])
  name                       = "LegacyADLoginForWindows"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = try(var.extension.type_handler_version, "1.3")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
      tags
    ]
  }

  settings = jsonencode(
    {
      "Name" : local.LegacyADLoginForWindows_name,
      "OUPath" : try(var.extension.ad_ou_path, ""),
      "User" : local.LegacyADLoginForWindows_domain_username,
      "Restart" : try(var.extension.restart, "true"),
      "Options" : try(var.extension.options, "3")
    }
  )

  protected_settings = jsonencode(
    {
      "Password" : local.LegacyADLoginForWindows_domain_password
    }
  )
}

locals {
  LegacyADLoginForWindows_name            = try(coalesce(try(var.extension.ad_domain_name, null), var.ad_domain_name), null)
  LegacyADLoginForWindows_domain_username = try(coalesce(try(var.extension.domain_username, null), var.vm_domain_username, try(data.azurerm_key_vault_secret.LegacyADLoginForWindows_username["enabled"].value, null)), "DOMAIN_USERNAME_NOT_SET")
  LegacyADLoginForWindows_domain_password = try(coalesce(try(var.extension.domain_password, null), var.vm_domain_password, try(data.azurerm_key_vault_secret.LegacyADLoginForWindows_password["enabled"].value, null)), "DOMAIN_PASSWORD_NOT_SET")
}

data "azurerm_key_vault_secret" "LegacyADLoginForWindows_username" {
  for_each = var.extension_name == "LegacyADLoginForWindows" && var.vm_domain_username == null && try(var.extension.domain_username, null) == null ? toset(["enabled"]) : toset([])
  name     = var.extension.vm_domain_username_keyvault.secret_name
  key_vault_id = try(
    var.extension.vm_domain_username_keyvault.key_vault_id,
    var.keyvaults[var.extension.vm_domain_username_keyvault.keyvault_key].id
  )
}

data "azurerm_key_vault_secret" "LegacyADLoginForWindows_password" {
  for_each = var.extension_name == "LegacyADLoginForWindows" && var.vm_domain_password == null && try(var.extension.domain_password, null) == null ? toset(["enabled"]) : toset([])
  name     = var.extension.vm_domain_password_keyvault.secret_name
  key_vault_id = try(
    var.extension.vm_domain_password_keyvault.key_vault_id,
    var.keyvaults[var.extension.vm_domain_password_keyvault.keyvault_key].id
  )
}
