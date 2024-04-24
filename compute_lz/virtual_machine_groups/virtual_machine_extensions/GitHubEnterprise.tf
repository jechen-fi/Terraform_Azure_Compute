resource "azurerm_virtual_machine_extension" "GitHubEnterprise" {
  for_each                   = var.extension_name == "GitHubEnterprise" ? toset(["enabled"]) : toset([])
  name                       = "GitHubEnterprise_CustomScript"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = local.ghe_publisher
  type                       = local.ghe_type
  type_handler_version       = local.ghe_type_handler_version
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, false)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  settings = jsonencode(
    {
      fileUris  = local.ghe_fileuris,
      timestamp = try(toint(var.extension.timestamp), 12345678)
    }
  )

  protected_settings = jsonencode(local.ghe_protected_settings)
}

locals {
  # managed identity
  ghe_identity_type           = try(var.extension.identity_type, "") #userassigned, systemassigned or null
  ghe_managed_local_identity  = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  ghe_managed_remote_identity = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  ghe_provided_identity       = try(var.extension.managed_identity_id, "")
  ghe_managed_identity        = try(coalesce(local.ghe_managed_local_identity, local.ghe_managed_remote_identity, local.ghe_provided_identity), "")

  ghe_map_system_assigned = {
    managedIdentity = {}
  }
  ghe_map_user_assigned = {
    managedIdentity = {
      objectid = local.ghe_managed_identity
    }
  }

  settings_ghe_VMConsolePwd        = try(var.settings.ghe_VMConsolePwd, "")
  settings_ghe_AdminUser           = try(var.settings.ghe_AdminUser, "")
  settings_ghe_AdminPwd            = try(var.settings.ghe_AdminPwd, "")
  settings_ghe_AdminEmail          = try(var.settings.ghe_AdminEmail, "")
  settings_ghe_Org                 = try(var.settings.ghe_Org, "")
  settings_ghe_Repo                = try(var.settings.ghe_Repo, "")
  settings_ghe_Team                = try(var.settings.ghe_Team, "")
  settings_ghe_ActionsSAConnString = try(var.settings.ghe_ActionsSAConnString, "")
  settings_ghe_Hostname            = try(var.settings.ghe_Hostname, "")

  # ghe_commandToExecute_Args_GHE = try(var.extension.use_settings_var_as_args, false) && try(var.extension.enable_ghe_vars, false) ? try(" && chmod +x config_license.sh && chmod +x config_adminuser_org_repo.sh && chmod +x ghe-remaining-configurations.sh && bash config_license.sh ${local.settings_ghe_VMConsolePwd} ${local.settings_ghe_Hostname} && bash config_adminuser_org_repo.sh ${local.settings_ghe_Hostname} ${local.settings_ghe_AdminUser} ${local.settings_ghe_AdminPwd} ${local.settings_ghe_AdminEmail} ${local.settings_ghe_Org} ${local.settings_ghe_Repo} ${local.settings_ghe_Team} && bash ghe-remaining-configurations.sh ${local.settings_ghe_ActionsSAConnString}", null) : null

  # Ignoring execution of ghe-remaining-configurations.sh as ghe-config-apply is not working
  ghe_commandToExecute_Args_GHE = try(var.extension.use_settings_var_as_args, false) && try(var.extension.enable_ghe_vars, false) ? try(" && chmod +x config_license.sh && chmod +x config_adminuser_org_repo.sh && chmod +x ghe-remaining-configurations.sh && bash config_license.sh ${local.settings_ghe_VMConsolePwd} ${local.settings_ghe_Hostname} && bash config_adminuser_org_repo.sh ${local.settings_ghe_Hostname} ${local.settings_ghe_AdminUser} ${local.settings_ghe_AdminPwd} ${local.settings_ghe_AdminEmail} ${local.settings_ghe_Org} ${local.settings_ghe_Repo} ${local.settings_ghe_Team}", null) : null

  ghe_commandToExecute_Args_Generic = try(var.extension.use_settings_var_as_args, false) && try(var.extension.enable_ghe_vars, false) == false ? try("${join(" ", flatten([for k, v in var.settings : [v]]))}", null) : null

  ghe_commandToExecute_Args = try(coalesce(local.ghe_commandToExecute_Args_Generic, local.ghe_commandToExecute_Args_GHE), null)

  ghe_commandToExecute = try(var.extension.commandtoexecute, "")

  ghe_combined_commandToExecute = local.ghe_commandToExecute != "" && try(local.ghe_commandToExecute_Args, null) != null && try(var.extension.use_settings_var_as_args, false) ? try("${local.ghe_commandToExecute} ${local.ghe_commandToExecute_Args}", "") : local.ghe_commandToExecute

  ghe_map_command = {
    commandToExecute = local.ghe_combined_commandToExecute
  }

  ghe_system_assigned_id = local.ghe_identity_type == "SystemAssigned" ? local.ghe_map_system_assigned : null
  ghe_user_assigned_id   = local.ghe_identity_type == "UserAssigned" ? local.ghe_map_user_assigned : null

  ghe_publisher            = var.virtual_machine_os_type == "linux" ? "Microsoft.Azure.Extensions" : "Microsoft.Compute"
  ghe_type_handler_version = var.virtual_machine_os_type == "linux" ? "2.1" : "1.10"
  ghe_type                 = var.virtual_machine_os_type == "linux" ? "CustomScript" : "CustomScriptExtension"

  ghe_tmp_storage_acct_creds = {
    storageAccountKey  = try(var.storage_accounts[var.extension.fileuri_sa_key].primary_access_key, "")
    storageAccountName = try(var.storage_accounts[var.extension.fileuri_sa_key].name, "")
  }

  ghe_storage_acct_creds = try(var.extension.sa_set_storage_creds, false) == true ? local.ghe_tmp_storage_acct_creds : {}

  ghe_protected_settings = merge(local.ghe_map_command, local.ghe_storage_acct_creds, local.ghe_system_assigned_id, local.ghe_user_assigned_id)

  # fileuris
  ghe_fileuri_sa_key       = try(var.extension.fileuri_sa_key, "")
  ghe_fileuri_sa_path      = try(var.extension.fileuri_sa_path, "")
  ghe_fileuri_sa           = local.ghe_fileuri_sa_key != "" ? try(var.storage_accounts[var.extension.fileuri_sa_key].primary_blob_endpoint, "") : ""
  ghe_fileuri_sa_full_path = "${local.ghe_fileuri_sa}${local.ghe_fileuri_sa_path}"
  ghe_fileuri_sa_defined   = try(var.extension.fileuris, "")
  ghe_fileuris             = local.ghe_fileuri_sa_defined == "" ? [local.ghe_fileuri_sa_full_path] : var.extension.fileuris
}
