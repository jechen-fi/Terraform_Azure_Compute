
data "azurerm_shared_image_version" "resource" {
  name                    = var.settings.name
  resource_group_name     = var.settings.rg_name
  image_name              = try(var.image_name, var.settings.image_name)
  gallery_name            = try(var.gallery_name, var.settings.gallery_name)
  sort_versions_by_semver = try(var.settings.sort_versions_by_semver, false)
}
