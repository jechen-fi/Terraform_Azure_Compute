module "shared_image_gallery" {
  source              = "./../../shared_image_gallery"
  name                = var.gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

module "shared_image" {
  depends_on = [module.shared_image_gallery]
  source     = "./../../shared_image/shared_image"

  deploy_image              = true
  image_name                = var.img_name
  source_virtual_machine_id = data.azurerm_virtual_machine.vm.id
  hyper_v_generation        = var.hyper_v_generation
  shrd_img_name             = var.shrd_img_name
  gallery_name              = module.shared_image_gallery.shrd_img_gallery.name
  shared_image_config = {
    hyper_v_generation = var.hyper_v_generation
  }
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = var.os_type
  identifier = {
    publisher = var.identifier.publisher
    offer     = var.identifier.offer
    sku       = var.identifier.sku
  }
  tags = local.tags
}

module "shared_image_version" {
  depends_on          = [module.shared_image]
  source              = "./../../shared_image/shared_image_version"
  name                = var.shrd_img_version
  gallery_name        = module.shared_image.shrd_img.gallery_name
  shared_image_name   = module.shared_image.shrd_img.name
  resource_group_name = module.shared_image.shrd_img.resource_group_name
  location            = module.shared_image.shrd_img.location
  managed_image_id    = module.shared_image.img_id

  target_region = {
    name                   = module.shared_image.shrd_img.location
    regional_replica_count = var.regional_replica_count
  }
  tags = local.tags
}
