data "azurerm_client_config" "current" {}

# Import Workload Resource Group
data "azurerm_resource_group" "rg" {
  name = "a00000-namespace-ctd"
}

data "azurerm_resource_group" "vnet_rg" {
  name = "a00000-namespace-ctd"
}

data "azurerm_virtual_network" "vnet" {
  name                = "a00000-network-ctd"
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "snet" {
  name                 ="a00000-app1-ctd"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_key_vault" "kv" {
  name                = "testkv098"
  resource_group_name = "a00000-namespace-ctd"
}