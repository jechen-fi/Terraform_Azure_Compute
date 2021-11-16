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
       "timestamp": "100000000"
    }
SETTINGS
  tags                       = var.tags
  protected_settings         = <<PROTECTED_SETTINGS
    {
       "commandToExecute": "${var.exec_command}",
       "managedIdentity": { "objectId": "${var.managed_identity}" },
       "fileUris": [
         "${var.script_uris}"
       ]
    }
PROTECTED_SETTINGS
  #       "storageAccountName": "${var.script_storage_account}",
  #       "storageAccountKey": "${var.script_storage_account_key}",
}
