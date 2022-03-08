#----------------------------------------------------------
# Gather data for Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_shared_image" "search" {
  name                = var.server_image_name
  gallery_name        = var.compute_gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
  provider            = azurerm.image-sub
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.resource_group_vnet
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.vm_storage_account != null ? 1 : 0
  name                = var.vm_storage_account
  resource_group_name = data.azurerm_resource_group.rg.name
}