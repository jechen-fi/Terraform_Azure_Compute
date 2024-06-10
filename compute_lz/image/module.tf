
locals {
  tags      = merge(var.global_settings.tags, var.tags)
  name_mask = "{name}"
}

module "resource_naming" {
  source = "../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.settings
  resource_type   = "azurerm_image"
  name_mask       = try(var.settings.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_image" "image" {
  name                      = module.resource_naming.name_result
  location                  = var.location != null ? var.location : var.global_settings.location
  resource_group_name       = var.resource_group_name
  source_virtual_machine_id = var.source_virtual_machine_id != null ? var.source_virtual_machine_id : try(var.settings.source_virtual_machine_id, null)
  zone_resilient            = try(var.settings.zone_resilient, null)
  hyper_v_generation        = try(var.settings.hyper_v_generation, null)
  tags                      = local.tags

  dynamic "os_disk" {
    for_each = try(var.settings.os_disks, {})

    content {
      os_type         = os_disk.value.os_type
      os_state        = os_disk.value.os_state
      managed_disk_id = try(os_disk.value.managed_disk_id, null)
      blob_uri        = try(os_disk.value.blob_uri, null)
      caching         = try(os_disk.value.caching, null)
      size_gb         = try(os_disk.value.size_gb, null)
    }
  }

  dynamic "data_disk" {
    for_each = try(var.settings.data_disks, {})

    content {
      lun             = data_disk.value.lun
      managed_disk_id = try(data_disk.value.managed_disk_id, null)
      blob_uri        = try(data_disk.value.blob_uri, null)
      caching         = try(data_disk.value.caching, null)
      size_gb         = try(data_disk.value.size_gb, null)
    }
  }

}
