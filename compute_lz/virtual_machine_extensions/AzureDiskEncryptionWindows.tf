resource "azurerm_virtual_machine_extension" "AzureDiskEncryptionWindows" {
  for_each                   = var.extension_name == "AzureDiskEncryptionWindows" ? toset(["enabled"]) : toset([])
  name                       = "AzureDiskEncryption"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = try(var.extension.type_handler_version, "2.2")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(local.adew_settings)
  # protected_settings = jsonencode(local.ade_protected_settings)

}

locals {

  # KeyEncryptionAlgorithm Options: 'RSA-OAEP', 'RSA-OAEP-256', 'RSA1_5'
  # VolumeType Options: OS, Data, All

  adew_EncryptionOperation    = try(var.settings.EncryptionOperation, "EnableEncryption")
  adew_KeyEncryptionKeyURL    = try(var.extension.key_vault_key_key, null) == null ? try(var.settings.KeyEncryptionKeyURL, "") : var.settings.keyvault_keys[var.extension.key_vault_key_key].id
  adew_KeyEncryptionAlgorithm = try(var.settings.KeyEncryptionAlgorithm, "RSA-OAEP")
  adew_VolumeType             = try(var.settings.VolumeType, "All")
  adew_KeyVaultURL            = try(var.extension.keyvault_key, null) == null ? null : var.keyvaults[var.extension.keyvault_key].vault_uri
  adew_KeyVaultResourceId     = try(var.extension.keyvault_key, null) == null ? null : var.keyvaults[var.extension.keyvault_key].id

  adew_settings = {
    "EncryptionOperation" : "${local.adew_EncryptionOperation}",
    "KeyEncryptionAlgorithm" : "${local.adew_KeyEncryptionAlgorithm}",
    "KeyVaultURL" : "${local.adew_KeyVaultURL}",
    "KeyVaultResourceId" : "${local.adew_KeyVaultResourceId}",
    "KeyEncryptionKeyURL" : "${local.adew_KeyEncryptionKeyURL}",
    "KekVaultResourceId" : "${local.adew_KeyVaultResourceId}",
    # "SequenceVersion": "uniqueIdentifier",
    "VolumeType" : "${local.adew_VolumeType}"
  }
}
