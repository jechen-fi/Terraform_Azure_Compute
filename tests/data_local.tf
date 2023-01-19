data "azurerm_client_config" "current" {}

# Import Workload Resource Group
data "azurerm_resource_group" "rg" {
  name = "a00000-namespace-ctd"
}

data "azurerm_key_vault" "kv" {
  name                = "testkv098"
  resource_group_name = "a00000-namespace-ctd"
}