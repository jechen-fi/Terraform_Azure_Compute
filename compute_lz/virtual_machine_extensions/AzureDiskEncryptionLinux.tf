resource "azurerm_virtual_machine_extension" "AzureDiskEncryptionLinux" {
  for_each                   = var.extension_name == "AzureDiskEncryptionLinux" ? toset(["enabled"]) : toset([])
  name                       = "AzureDiskEncryption"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = try(var.extension.type_handler_version, "1.1")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(local.adel_settings)
  # protected_settings = jsonencode(local.ade_protected_settings)

}

locals {

  # KeyEncryptionAlgorithm Options: 'RSA-OAEP', 'RSA-OAEP-256', 'RSA1_5'
  # VolumeType Options: OS, Data, All
  # EncryptionOperation Options: EnableEncryption, EnableEncryptionFormatAll
  # DiskFormatQuery is deprecated, use EncryptionOperation=EnableEncryptionFormatAll

  # ade_DiskFormatQuery        = try(var.extension.DiskFormatQuery, "{\"dev_path\":\"\",\"name\":\"\",\"file_system\":\"\"}")
  adel_EncryptionOperation    = try(var.settings.EncryptionOperation, "EnableEncryption")
  adel_KeyEncryptionKeyURL    = try(var.extension.key_vault_key_key, null) == null ? try(var.settings.KeyEncryptionKeyURL, "") : var.settings.keyvault_keys[var.extension.key_vault_key_key].id
  adel_KeyEncryptionAlgorithm = try(var.settings.KeyEncryptionAlgorithm, "RSA-OAEP")
  adel_VolumeType             = try(var.settings.VolumeType, "All")
  adel_KeyVaultURL            = try(var.extension.keyvault_key, null) == null ? null : var.keyvaults[var.extension.keyvault_key].vault_uri
  adel_KeyVaultResourceId     = try(var.extension.keyvault_key, null) == null ? null : var.keyvaults[var.extension.keyvault_key].id

  adel_settings = {
    # "DiskFormatQuery" : "${local.ade_DiskFormatQuery}",
    "EncryptionOperation" : "${local.adel_EncryptionOperation}",
    "KeyEncryptionAlgorithm" : "${local.adel_KeyEncryptionAlgorithm}",
    "KeyVaultURL" : "${local.adel_KeyVaultURL}",
    "KeyVaultResourceId" : "${local.adel_KeyVaultResourceId}",
    "KeyEncryptionKeyURL" : "${local.adel_KeyEncryptionKeyURL}",
    "KekVaultResourceId" : "${local.adel_KeyVaultResourceId}",
    # "SequenceVersion": "uniqueIdentifier",
    "VolumeType" : "${local.adel_VolumeType}"
  }

}
