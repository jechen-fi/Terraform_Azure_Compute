
locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{name}"
}

module "resource_naming" {
  source = "../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_snapshot"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_snapshot" "snapshot" {
  name                = module.resource_naming.name_result
  location            = var.location != null ? var.location : var.global_settings.location
  resource_group_name = var.resource_group_name
  create_option       = try(var.settings.create_option, null)
  source_uri          = var.source_uri != null ? var.source_uri : try(var.settings.source_uri, null)
  source_resource_id  = var.source_resource_id != null ? var.source_resource_id : try(var.settings.source_resource_id, null)
  storage_account_id  = try(coalesce(try(var.settings.storage_account_id, null), try(var.storage_accounts[var.settings.storage_account_key].id, null)), null)
  disk_size_gb        = try(var.settings.disk_size_gb, null)
  tags                = local.tags

  dynamic "encryption_settings" {
    for_each = try(var.settings.encryption_settings, {})

    content {

      dynamic "disk_encryption_key" {
        for_each = try(var.settings.disk_encryption_keys, {})

        content {
          secret_url = try(coalesce(
            try(disk_encryption_key.value.secret_url, null),
            try(var.key_vault_secrets[disk_encryption_key.value.keyvault_secret_key].id, null)
          ), null)
          source_vault_id = try(coalesce(try(disk_encryption_key.value.source_vault_id, null), try(var.key_vaults[disk_encryption_key.value.keyvault_key].id, null)), null)
        }
      }

      dynamic "key_encryption_key" {
        for_each = try(var.settings.key_encryption_keys, {})

        content {
          key_url = try(coalesce(
            try(key_encryption_key.value.key_url, null),
            try(var.key_vault_keys[key_encryption_key.value.keyvault_key_key].id, null)
          ), null)
          source_vault_id = try(coalesce(try(key_encryption_key.value.source_vault_id, null), try(var.key_vaults[key_encryption_key.value.keyvault_key].id, null)), null)
        }
      }

    }

  }

}
