
data "azurerm_shared_image_gallery" "gallery" {
  name                = var.settings.name
  resource_group_name = var.settings.rg_name
}
