resource "azurerm_virtual_machine_extension" "GitHubRunner" {
  for_each                   = var.extension_name == "GitHubRunner" ? toset(["enabled"]) : toset([])
  name                       = "GitHubRunner_CustomScript"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = local.ghrunner_publisher
  type                       = local.ghrunner_type
  type_handler_version       = local.ghrunner_type_handler_version
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
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
      fileUris  = local.ghrunner_fileuris,
      timestamp = try(toint(var.extension.timestamp), 12345678)
    }
  )

  protected_settings = jsonencode(local.ghrunner_protected_settings)
}

resource "null_resource" "remove_github_runner" {

  count = var.extension_name == "GitHubRunner" ? 1 : 0

  triggers = {
    gh_actions_runner_name = try(var.extension.use_vm_name_as_runner_name, false) ? try(var.virtual_machine_name, "") : try(var.settings.gh_actions_runner_name, "")
    gh_token               = try(var.settings.gh_token, "")
    gh_org                 = try(var.settings.gh_org, "")
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash"]
    when        = destroy
    command     = format("%s/scripts/remove_github_runner.sh", path.module)
    on_failure  = continue
    environment = {
      GH_ACTIONS_RUNNER_NAME = self.triggers.gh_actions_runner_name
      GH_TOKEN               = self.triggers.gh_token
      GH_ORG                 = self.triggers.gh_org
    }
  }
}

locals {
  # managed identity
  ghrunner_identity_type           = try(var.extension.identity_type, "") #userassigned, systemassigned or null
  ghrunner_managed_local_identity  = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  ghrunner_managed_remote_identity = try(var.managed_identities[var.extension.managed_identity_key].principal_id, "")
  ghrunner_provided_identity       = try(var.extension.managed_identity_id, "")
  ghrunner_managed_identity        = try(coalesce(local.ghrunner_managed_local_identity, local.ghrunner_managed_remote_identity, local.ghrunner_provided_identity), "")

  ghrunner_map_system_assigned = {
    managedIdentity = {}
  }
  ghrunner_map_user_assigned = {
    managedIdentity = {
      objectid = local.ghrunner_managed_identity
    }
  }

  settings_ghrunner_url                     = try(var.settings.gh_url, "")
  settings_ghrunner_org                     = try(var.settings.gh_org, "")
  settings_ghrunner_runner_version          = try(var.settings.gh_runner_version, "")
  settings_ghrunner_runner_base_dir         = try(var.settings.gh_runner_base_dir, "")
  settings_ghrunner_actions_runner_label    = try(var.settings.gh_actions_runner_label, "")
  settings_ghrunner_actions_runner_name     = try(var.extension.use_vm_name_as_runner_name, false) ? var.virtual_machine_name : try(var.settings.gh_actions_runner_name, "")
  settings_ghrunner_token                   = try(var.settings.gh_token, "")
  settings_ghrunner_enable_auto_updates     = try(var.settings.gh_enable_auto_updates, "false")
  settings_ghrunner_install_yamllint_config = try(var.settings.gh_install_yamllint_config, "false")

  ghrunner_commandToExecute_Args_GH_Runner = try(var.extension.use_settings_var_as_args, false) && try(var.extension.enable_gh_runner_vars, false) ? try("${local.settings_ghrunner_url} ${local.settings_ghrunner_org} ${local.settings_ghrunner_runner_version} ${local.settings_ghrunner_runner_base_dir} ${local.settings_ghrunner_actions_runner_label} ${local.settings_ghrunner_actions_runner_name} ${local.settings_ghrunner_token} ${local.settings_ghrunner_enable_auto_updates} ${local.settings_ghrunner_install_yamllint_config}", null) : null

  ghrunner_commandToExecute_Args_Generic = try(var.extension.use_settings_var_as_args, false) && try(var.extension.enable_gh_runner_vars, false) == false ? try("${join(" ", flatten([for k, v in var.settings : [v]]))}", null) : null

  # ghrunner_commandToExecute_Args     = try(var.extension.use_settings_var_as_args, false) ? try("${join(" ", flatten([for k, v in var.settings : [format("%q", v)]]))}", null) : null

  ghrunner_commandToExecute_Args = try(coalesce(local.ghrunner_commandToExecute_Args_Generic, local.ghrunner_commandToExecute_Args_GH_Runner), null)

  ghrunner_commandToExecute = try(var.extension.commandtoexecute, "")

  ghrunner_combined_commandToExecute = local.ghrunner_commandToExecute != "" && try(local.ghrunner_commandToExecute_Args, null) != null && try(var.extension.use_settings_var_as_args, false) ? try("${local.ghrunner_commandToExecute} ${local.ghrunner_commandToExecute_Args}", "") : local.ghrunner_commandToExecute

  ghrunner_map_command = {
    commandToExecute = local.ghrunner_combined_commandToExecute
  }

  ghrunner_system_assigned_id = local.ghrunner_identity_type == "SystemAssigned" ? local.ghrunner_map_system_assigned : null
  ghrunner_user_assigned_id   = local.ghrunner_identity_type == "UserAssigned" ? local.ghrunner_map_user_assigned : null

  ghrunner_publisher            = var.virtual_machine_os_type == "linux" ? "Microsoft.Azure.Extensions" : "Microsoft.Compute"
  ghrunner_type_handler_version = var.virtual_machine_os_type == "linux" ? "2.1" : "1.10"
  ghrunner_type                 = var.virtual_machine_os_type == "linux" ? "CustomScript" : "CustomScriptExtension"

  ghrunner_tmp_storage_acct_creds = {
    storageAccountKey  = try(var.storage_accounts[var.extension.fileuri_sa_key].primary_access_key, "")
    storageAccountName = try(var.storage_accounts[var.extension.fileuri_sa_key].name, "")
  }

  ghrunner_storage_acct_creds = try(var.extension.sa_set_storage_creds, false) == true ? local.ghrunner_tmp_storage_acct_creds : {}

  ghrunner_protected_settings = merge(local.ghrunner_map_command, local.ghrunner_storage_acct_creds, local.ghrunner_system_assigned_id, local.ghrunner_user_assigned_id)

  # fileuris
  ghrunner_fileuri_sa_key       = try(var.extension.fileuri_sa_key, "")
  ghrunner_fileuri_sa_path      = try(var.extension.fileuri_sa_path, "")
  ghrunner_fileuri_sa           = local.ghrunner_fileuri_sa_key != "" ? try(var.storage_accounts[var.extension.fileuri_sa_key].primary_blob_endpoint, "") : ""
  ghrunner_fileuri_sa_full_path = "${local.ghrunner_fileuri_sa}${local.ghrunner_fileuri_sa_path}"
  ghrunner_fileuri_sa_defined   = try(var.extension.fileuris, "")
  ghrunner_fileuris             = local.ghrunner_fileuri_sa_defined == "" ? [local.ghrunner_fileuri_sa_full_path] : var.extension.fileuris
}
