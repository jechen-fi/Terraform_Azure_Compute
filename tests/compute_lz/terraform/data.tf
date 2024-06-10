data "azurerm_client_config" "current" {}

# Import Workload Resource Group
data "azurerm_resource_group" "rg" {
  name = "a00000-namespace-ctd"
}

# data "azurerm_key_vault" "keyvault" {
#   name                = "a00000-servckv1wus3-ctd"
#   resource_group_name = data.azurerm_resource_group.rg.name
# }