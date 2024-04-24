
data "azurerm_image" "image" {
  name                = var.settings.name
  resource_group_name = var.settings.rg_name
  # name_regex          = try(var.settings.name_regex, null)
  # sort_descending     = try(var.settings.sort_descending, null)  
}
