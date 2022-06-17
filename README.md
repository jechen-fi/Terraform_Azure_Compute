# Terraform Azure Compute repo
## Terraform Azure Compute Service Modules
### Virtual Machines (/virtual_machines) - Terraform Module

## Version compatibility

| Terraform version | AzureRM version |
| ----------------- | --------------- |
| >= 0.14.0         | >= 2.78.0        |

## Testing Module

```
# Configure Microsoft Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Import Resource Group
data "azurerm_resource_group" "rg" {
  name = "rg-jtchoffo-sbx"
}

data "azurerm_key_vault" "commonKV" {
  name = "rg-jimmyt-kv"
  resource_group_name = data.azurerm_resource_group.rg.name
}

locals {
  tags = {
    "applicationOwner" = "~CloudInfrastructure@fi.com"
  }
  virtual_machine = {
    subnet_name     = "a00002apimdev"
    vm_hostname     = "a00002des-VM"
    os_distribution = "windows2019"
    vm_size         = var.vm_size
    local_account   = "fivmadmin"
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = "rg-jtchoffo-VNET"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = "rg-jtchoffo-backend"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "windows_virtual_machine" {
  source               = "C:\\Users\\jtchoffo\\Documents\\VitualMachineAgents\\Terraform_Azure_Compute\\virtual_machines"


  resource_group_name  = data.azurerm_resource_group.rg.name
  resource_group_vnet  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  subnet_name          = data.azurerm_subnet.subnet.name
  virtual_machine_name = local.virtual_machine.vm_hostname
  os_distribution      = local.virtual_machine.os_distribution
  virtual_machine_size = local.virtual_machine.vm_size
  admin_username       = local.virtual_machine.local_account
  admin_password       = var.local_account_cred
  tags                 = local.tags
  identity             = {
    type               = var.identity_type
    identity_ids       = null
  }
  rg_location          = "westus2"
  data_collection_rule = "/subscriptions/dc8d3140-b19c-40d6-89a1-3d1576e5d00f/resourcegroups/rg-jtchoffo-sbx/providers/Microsoft.Insights/dataCollectionRules/dcrAzMonitorWindows"
  scope                = "/subscriptions/dc8d3140-b19c-40d6-89a1-3d1576e5d00f/resourceGroups/rg-jtchoffo-sbx/providers/Microsoft.KeyVault/vaults/rg-jimmyt-kv"
  kv                   = data.azurerm_key_vault.commonKV.name
}
```
## License / Use information

Fisher Investments internal, BSD, MIT License, Apache 2.0, etc. (see https://opensource.org/licenses)

ex.
Fisher Investments internal


## Author Information

An optional section for the Terraform module author(s) / authoring team to include contact information for them, or a similar web url.

ex.
Cloud Infra Team - ~CloudInfrastructure@fi.com