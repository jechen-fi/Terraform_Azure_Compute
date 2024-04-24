resource "azurerm_virtual_machine_extension" "promote_vm_domain_controller" {
  for_each                   = var.extension_name == "Promote_VM_DomainController" ? toset(["enabled"]) : toset([])
  name                       = "Promote_VM_DomainController"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = try(var.extension.type_handler_version, "1.9")
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
      "commandToExecute" : "powershell.exe -Command \"${local.Promote_DC_powershell_command}\""
    }
  )

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

##=========================================================================
## Required variables for this extension to successfully execute
##=========================================================================
##      var.vm_admin_password (if ommitted, need to have Keyvault Secret reference)
##      var.vm_domain_username (if ommitted, need to have Keyvault Secret reference)
##      var.ad_domain_name (if ommitted, reference from var.extension)

locals {
  Promote_DC_domain_username   = try(coalesce(var.vm_domain_username, try(var.extension.domain_username, null), try(data.azurerm_key_vault_secret.promote_vm_domain_controller_domain_username["enabled"].value, null)), "VAR_NOT_SET")
  Promote_DC_admin_password    = try(coalesce(var.vm_admin_password, try(var.extension.admin_password, null), try(data.azurerm_key_vault_secret.promote_vm_domain_controller_admin_password["enabled"].value, null)), "VAR_NOT_SET")
  Promote_DC_ad_domain_name    = try(coalesce(var.ad_domain_name, var.extension.ad_domain_name), "VAR_NOT_SET")
  Promote_DC_ad_netbios_name   = try(coalesce(var.ad_netbios_name, var.extension.ad_netbios_name), "VAR_NOT_SET")
  Promote_DC_ad_domain_mode    = coalesce(var.ad_domain_mode, try(var.extension.ad_domain_mode, null), "WinThreshold")
  Promote_DC_ad_install_forest = try(var.extension.ad_install_forest, var.ad_install_forest)

  Promote_DC_password_command    = "$password = ConvertTo-SecureString ${local.Promote_DC_admin_password} -AsPlainText -Force"
  Promote_DC_credentials_command = "$domain_username = ${local.Promote_DC_ad_domain_name}; $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($domain_username, $password)"

  Promote_DC_import_command     = "Import-Module ADDSDeployment"
  Promote_DC_install_ad_command = "Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools"

  Promote_DC_configure_ad_and_forest_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode ${local.Promote_DC_ad_domain_mode} -DomainName ${local.Promote_DC_ad_domain_name} -DomainNetbiosName ${local.Promote_DC_ad_netbios_name} -ForestMode ${local.Promote_DC_ad_domain_mode} -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  Promote_DC_configure_ad_command            = "Install-ADDSDomainController -DomainName ${local.Promote_DC_ad_domain_name} -InstallDns -Credential $credentials -SafeModeAdministratorPassword $password -Force:$true"
  Promote_DC_configure_ad_commands           = local.Promote_DC_ad_install_forest == true ? local.Promote_DC_configure_ad_and_forest_command : "${local.Promote_DC_credentials_command}; ${local.Promote_DC_configure_ad_command};"

  Promote_DC_shutdown_command = "shutdown -r -t 60"
  Promote_DC_exit_code_hack   = "exit 0"

  Promote_DC_powershell_command = "${local.Promote_DC_import_command}; ${local.Promote_DC_password_command}; ${local.Promote_DC_install_ad_command}; ${local.Promote_DC_configure_ad_commands}; ${local.Promote_DC_shutdown_command}; ${local.Promote_DC_exit_code_hack}"
}

data "azurerm_key_vault_secret" "promote_vm_domain_controller_domain_username" {
  for_each = var.extension_name == "Promote_VM_DomainController" && try(var.extension.use_kv_creds, false) == true ? toset(["enabled"]) : toset([])
  name     = var.extension.vm_domain_username_keyvault.secret_name
  key_vault_id = try(
    var.extension.vm_domain_username_keyvault.key_vault_id,
    var.keyvaults[var.extension.vm_domain_username_keyvault.keyvault_key].id
  )
}

data "azurerm_key_vault_secret" "promote_vm_domain_controller_admin_password" {
  for_each = var.extension_name == "Promote_VM_DomainController" && try(var.extension.use_kv_creds, false) == true ? toset(["enabled"]) : toset([])
  name     = var.extension.vm_admin_password_keyvault.secret_name
  key_vault_id = try(
    var.extension.vm_admin_password_keyvault.key_vault_id,
    var.keyvaults[var.extension.vm_admin_password_keyvault.keyvault_key].id
  )
}
