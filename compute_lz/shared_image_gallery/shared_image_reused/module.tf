
data "azurerm_shared_image" "image" {
  name                = var.settings.name
  gallery_name        = coalesce(var.gallery_name, var.settings.gallery_name)
  resource_group_name = var.settings.rg_name
}
