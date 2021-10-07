#----------------------------------------------------------------------------------------------------------------------------
# Custom VM Extension Module  
# CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
#----------------------------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "vmextension" {
  name                       = var.name_vmextension
  virtual_machine_id         = var.azure_vm_id
  publisher                  = var.publisher
  type                       = var.extension_type
  type_handler_version       = var.extension_type_version
  auto_upgrade_minor_version = var.auto_upgrade
  settings                   = <<SETTINGS
    {  
       "fileUris": ["${var.script_uri}"],   
       "commandToExecute": "${var.command_run_script}"
    }
SETTINGS
  tags                       = var.tags
  protected_settings         = <<PROTECTED_SETTINGS
    {
       "managedIdentity": ${var.managed_identity}
    }
PROTECTED_SETTINGS
}
