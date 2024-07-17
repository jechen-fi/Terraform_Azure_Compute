
locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{name}"
}

module "resource_naming" {
  source = "../../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_shared_image"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_shared_image" "image" {
  name                                = module.resource_naming.name_result
  location                            = var.location != null ? var.location : var.global_settings.location
  resource_group_name                 = var.resource_group_name
  gallery_name                        = var.gallery_name
  os_type                             = var.settings.os_type
  description                         = try(var.settings.description, null)
  disk_types_not_allowed              = try(var.settings.disk_types_not_allowed, null)
  end_of_life_date                    = try(var.settings.end_of_life_date, null)
  eula                                = try(var.settings.eula, null)
  specialized                         = try(var.settings.specialized, null)
  architecture                        = try(var.settings.architecture, null)
  hyper_v_generation                  = try(var.settings.hyper_v_generation, null)
  max_recommended_vcpu_count          = try(var.settings.max_recommended_vcpu_count, null)
  min_recommended_vcpu_count          = try(var.settings.min_recommended_vcpu_count, null)
  max_recommended_memory_in_gb        = try(var.settings.max_recommended_memory_in_gb, null)
  min_recommended_memory_in_gb        = try(var.settings.min_recommended_memory_in_gb, null)
  privacy_statement_uri               = try(var.settings.privacy_statement_uri, null)
  release_note_uri                    = try(var.settings.release_note_uri, null)
  trusted_launch_enabled              = try(var.settings.trusted_launch_enabled, false)
  accelerated_network_support_enabled = try(var.settings.accelerated_network_support_enabled, null)
  tags                                = local.tags

  identifier {
    publisher = var.settings.publisher
    offer     = var.settings.offer
    sku       = var.settings.sku
  }

  dynamic "purchase_plan" {
    for_each = lookup(var.settings, "purchase_plan", {}) == {} ? [] : [1]

    content {
      name      = var.settings.purchase_plan.name
      publisher = try(var.settings.purchase_plan.publisher, null)
      product   = try(var.settings.purchase_plan.product, null)
    }
  }

}
