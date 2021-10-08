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
       "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File helloworld.ps1"
    }
SETTINGS
  tags                       = var.tags
  protected_settings         = <<PROTECTED_SETTINGS
    { 
       "managedIdentity": { "clientId": "0dff075c-ebd9-4a3f-9976-5380ba73d67e" }
    }
PROTECTED_SETTINGS
}
