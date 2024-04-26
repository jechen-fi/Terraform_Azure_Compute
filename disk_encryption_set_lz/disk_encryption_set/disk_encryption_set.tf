locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{cloudprefix}{delimiter}{locationcode}{delimiter}{envlabel}{delimiter}{ade}"
}

module "resource_naming" {
  source = "../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_disk_encryption_set"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_disk_encryption_set" "encryption_set" {
  name                = module.resource_naming.name_result
  resource_group_name = var.resource_group_name
  location            = var.location != null ? var.location : var.global_settings.location
  key_vault_key_id    = var.key_vault_key_ids[var.settings.key_vault_key_key].id

  identity {
    type = "SystemAssigned"
  }
  tags = merge(var.global_settings.tags, var.tags, try(var.settings.tags, null))
}
