resource "azurerm_key_vault_access_policy" "des" {
  count = try(var.settings.enable_keyvault_access_policy, false) == false ? 0 : 1

  key_vault_id = var.keyvault_id

  tenant_id = azurerm_disk_encryption_set.encryption_set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.encryption_set.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}
