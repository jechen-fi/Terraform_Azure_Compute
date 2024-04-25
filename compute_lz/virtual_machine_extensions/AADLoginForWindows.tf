resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  for_each                   = var.extension_name == "AADLoginForWindows" ? toset(["enabled"]) : toset([])
  name                       = "AADLoginForWindows"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, true)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, false)
  tags                       = local.tags

  settings = jsonencode(local.AADLoginForWindows_settings)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

locals {
  AADLoginForWindows_mdmId = try(var.extension.enroll_vm_with_intune, false) != false ? {
    mdmId = try(var.extension.mdmId, "0000000a-0000-0000-c000-000000000000")
  } : { mdmId = "" }

  # Use the merge below if we add any more settings
  # AADLoginForWindows_settings = merge(local.AADLoginForWindows_mdmId)
  AADLoginForWindows_settings = local.AADLoginForWindows_mdmId

  AADJPrivate_ShutdownCmd = "shutdown -r -t 10;"
  AADJPrivate_ExitCode    = "exit 0"
  AADJPrivate_CmdToRun    = "Set-Location HKLM:/SOFTWARE/Microsoft; New-Item -Path HKLM:/SOFTWARE/Microsoft -Name RDInfraAgent -Force; New-Item -Path HKLM:/Software/Microsoft/RDInfraAgent -Name AADJPrivate -Force;"
  AADJPrivate_PS_Command  = "${local.AADJPrivate_CmdToRun} ${local.AADJPrivate_ShutdownCmd} ${local.AADJPrivate_ExitCode}"
}

resource "azurerm_virtual_machine_extension" "AADJPrivate" {
  depends_on = [
    azurerm_virtual_machine_extension.AADLoginForWindows
  ]
  for_each             = var.extension_name == "AADLoginForWindows" ? toset(["enabled"]) : toset([])
  name                 = "AADJPrivate"
  virtual_machine_id   = var.virtual_machine_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  tags                 = local.tags

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.AADJPrivate_PS_Command}\""
    }
  SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
