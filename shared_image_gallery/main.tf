resource "azurerm_shared_image_gallery" "shrd_img_gallery" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  description         = try(var.shared_image_gallery_config.description, null)

  dynamic "sharing" {
    for_each = var.sharing != null ? var.sharing : []
    content {
      permission = try(sharing.value.permission, "Community")

      dynamic "community_gallery" {
        for_each = var.sharing.community_gallery != null ? var.sharing.community_gallery : []
        content {
          eula            = try(community_gallery.value.eula, null)
          prefix          = try(community_gallery.value.prefix, null)
          publisher_email = try(community_gallery.value.publisher_email, null)
          publisher_uri   = try(community_gallery.value.publisher_uri, null)
        }
      }
    }
  }
}

