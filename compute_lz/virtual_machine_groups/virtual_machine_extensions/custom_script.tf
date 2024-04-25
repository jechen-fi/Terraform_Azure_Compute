resource "azurerm_virtual_machine_extension" "custom_script" {
  for_each                   = var.extension_name == "custom_script" ? toset(["enabled"]) : toset([])
  name                       = try(var.extension.name, "custom_script")
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = local.cscript_publisher
  type                       = local.cscript_type
  type_handler_version       = local.cscript_type_handler_version
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(
    {
      fileUris  = local.cscript_fileuris,
      timestamp = try(toint(var.extension.timestamp), 12345678)
    }
  )

  protected_settings = jsonencode(local.cscript_protected_settings)
}

locals {
  # managed identity
  cscript_identity_type           = try(var.extension.identity_type, "") #userassigned, systemassigned or null
  cscript_managed_local_identity  = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  cscript_managed_remote_identity = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  cscript_provided_identity       = try(var.extension.managed_identity_id, "")
  cscript_managed_identity        = try(coalesce(local.cscript_managed_local_identity, local.cscript_managed_remote_identity, local.cscript_provided_identity), "")

  cscript_map_system_assigned = {
    managedIdentity = {}
  }
  cscript_map_user_assigned = {
    managedIdentity = {
      objectid = local.cscript_managed_identity
    }
  }
  cscript_map_command = {
    commandToExecute = try(var.extension.commandtoexecute, "")
  }

  cscript_system_assigned_id = local.cscript_identity_type == "SystemAssigned" ? local.cscript_map_system_assigned : null
  cscript_user_assigned_id   = local.cscript_identity_type == "UserAssigned" ? local.cscript_map_user_assigned : null

  cscript_publisher            = var.virtual_machine_os_type == "linux" ? "Microsoft.Azure.Extensions" : "Microsoft.Compute"
  cscript_type_handler_version = var.virtual_machine_os_type == "linux" ? "2.1" : "1.10"
  cscript_type                 = var.virtual_machine_os_type == "linux" ? "CustomScript" : "CustomScriptExtension"

  cscript_tmp_storage_acct_creds = {
    storageAccountKey  = try(var.storage_accounts[var.extension.fileuri_sa_key].primary_access_key, "")
    storageAccountName = try(var.storage_accounts[var.extension.fileuri_sa_key].name, "")
  }

  cscript_storage_acct_creds = try(var.extension.sa_set_storage_creds, false) == true ? local.cscript_tmp_storage_acct_creds : {}

  cscript_protected_settings = merge(local.cscript_map_command, local.cscript_storage_acct_creds, local.cscript_system_assigned_id, local.cscript_user_assigned_id)

  # fileuris
  cscript_fileuri_sa_key       = try(var.extension.fileuri_sa_key, "")
  cscript_fileuri_sa_path      = try(var.extension.fileuri_sa_path, "")
  cscript_fileuri_sa           = local.cscript_fileuri_sa_key != "" ? try(var.storage_accounts[var.extension.fileuri_sa_key].primary_blob_endpoint, "") : ""
  cscript_fileuri_sa_full_path = "${local.cscript_fileuri_sa}${local.cscript_fileuri_sa_path}"
  cscript_fileuri_sa_defined   = try(var.extension.fileuris, "")
  cscript_fileuris             = local.cscript_fileuri_sa_defined == "" ? [local.cscript_fileuri_sa_full_path] : var.extension.fileuris
}
