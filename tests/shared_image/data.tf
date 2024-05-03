data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_machine" "vm" {
  name                = "a00000-tstvm-ctd"
  resource_group_name = "a00000-namespace-ctd"
}
