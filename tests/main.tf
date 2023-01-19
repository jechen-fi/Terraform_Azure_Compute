
# ##############################################
# ## UiPath Virtual Machine                  ###
# ##############################################

module "virtual-machine" {
  source = "./../virtual_machines"
  resource_group_name      = data.azurerm_resource_group.rg.name
  rg_location              = data.azurerm_resource_group.rg.location
  resource_group_vnet      = "core-shrdsvcmgmt-dev"
  virtual_network_name     = "core-shrdsvcmgmt-dev"
  subnet_name              = "core-shrdsvcbuild-dev"
  virtual_machine_name     = "a0000-tstvm01"
  data_collection_rule     = ["/subscriptions/5efbbb60-3241-492e-a125-47d13e025aa2/resourcegroups/a00000-shrdsvcmgmt-dev/providers/Microsoft.Insights/dataCollectionRules/core-dcrwin-dev"]
  data_collection_endpoint = "/subscriptions/5efbbb60-3241-492e-a125-47d13e025aa2/resourcegroups/a00000-shrdsvcmgmt-dev/providers/Microsoft.Insights/dataCollectionEndpoints/core-dcewestus3-dev"
  os_distribution          = "win2019"
  virtual_machine_size     = "Standard_DS2_v2"
  admin_username           = local.admin_username
  admin_password           = local.admin_password
  tags                     = local.tags
  kv_id                    = data.azurerm_key_vault.kv.id
  identity = { type = "SystemAssigned" }
}




module "custom_extension" {
  depends_on = [
    module.virtual-machine
  ]
  source = "./../virtual_machine_extension"
  name_vmextension = "CustomScriptExtension"
  extension_type = "CustomScriptExtension"
  extension_type_version="1.10"
  publisher = "Microsoft.Compute"
  azure_vm_id = module.virtual-machine.vm_info_windows[0].id
  script_uris = local.script_uri
  exec_command = "powershell -ExecutionPolicy Unrestricted -File wrapper2.ps1 -register_orchestrator $true -add_users_to_group $true -accounts 'pranaya' -local_group 'administrators' -domain 'FIDEV.COM' -key_vault_id '${data.azurerm_key_vault.kv.id}' -app_type 'EC1'"
  managed_identity = lookup(module.virtual-machine.vm_info_windows[0].identity[0], "principal_id")
}


