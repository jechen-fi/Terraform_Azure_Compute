# Image Creation
resource "azurerm_image" "image" {
  count                     = var.deploy_image ? 1 : 0
  name                      = var.image_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  source_virtual_machine_id = var.source_virtual_machine_id
  hyper_v_generation        = var.hyper_v_generation
  zone_resilient            = var.zone_resilient
  dynamic "os_disk" {
    for_each = var.os_disk != null ? var.os_disk : []

    content {
      os_type                = os_disk.value.os_type
      os_state               = os_disk.value.os_state
      managed_disk_id        = os_disk.value.managed_disk_id
      blob_uri               = os_disk.value.blob_uri
      caching                = os_disk.value.caching
      size_gb                = os_disk.value.size_gb
      disk_encryption_set_id = os_disk.value.disk_encryption_set_id
    }
  }

  dynamic "data_disk" {
    for_each = var.data_disk != null ? var.data_disk : []

    content {
      lun             = data_disk.value.lun
      managed_disk_id = data_disk.value.managed_disk_id
      blob_uri        = data_disk.value.blob_uri
      caching         = data_disk.value.caching
      size_gb         = data_disk.value.size_gb
    }

  }
  tags = var.tags
}


# Shared Image
resource "azurerm_shared_image" "shrd_img" {
  name                = var.shrd_img_name
  gallery_name        = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type

  identifier {
    offer     = var.identifier.offer
    publisher = var.identifier.publisher
    sku       = var.identifier.sku
  }

  dynamic "purchase_plan" {
    for_each = var.purchase_plan != null ? var.purchase_plan : []
    content {
      name      = purchase_plan.value.name
      publisher = purchase_plan.value.publisher
      product   = purchase_plan.value.product
    }
  }
  hyper_v_generation                  = try(var.shared_image_config.hyper_v_generation, "V1")
  description                         = try(var.shared_image_config.description, null)
  disk_types_not_allowed              = try(var.shared_image_config.disk_types_not_allowed, null)
  end_of_life_date                    = try(var.shared_image_config.end_of_life_date, null)
  eula                                = try(var.shared_image_config.eula, null)
  specialized                         = try(var.shared_image_config.specialized, null)
  architecture                        = try(var.shared_image_config.architecture, "x64")
  max_recommended_vcpu_count          = try(var.shared_image_config.max_recommended_vcpu_count, null)
  min_recommended_vcpu_count          = try(var.shared_image_config.min_recommended_vcpu_count, null)
  max_recommended_memory_in_gb        = try(var.shared_image_config.maz_recommended_memory_in_gb, null)
  min_recommended_memory_in_gb        = try(var.shared_image_config.min_recommended_memory_in_gb, null)
  privacy_statement_uri               = try(var.shared_image_config.privacy_statement_uri, null)
  release_note_uri                    = try(var.shared_image_config.release_note_uri, null)
  trusted_launch_supported            = try(var.shared_image_config.trusted_launch_supported, null)
  trusted_launch_enabled              = try(var.shared_image_config.trusted_launch_enabled, null)
  confidential_vm_supported           = try(var.shared_image_config.confidential_vm_supported, null)
  confidential_vm_enabled             = try(var.shared_image_config.confidential_vm_enabled, null)
  accelerated_network_support_enabled = try(var.shared_image_config.accelerated_network_support_enabled, null)
  tags                                = var.tags
}
