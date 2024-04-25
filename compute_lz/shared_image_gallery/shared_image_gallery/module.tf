
locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{name}"
}

module "resource_naming" {
  source = "../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_shared_image_gallery"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_shared_image_gallery" "gallery" {
  name                = module.resource_naming.name_result
  location            = var.location != null ? var.location : var.global_settings.location
  resource_group_name = var.resource_group_name
  description         = try(var.settings.description, null)
  tags                = local.tags
}
