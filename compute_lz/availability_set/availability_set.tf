locals {
  tags      = merge(var.tags, var.global_settings.tags)
  name_mask = "{cloudprefix}{delimiter}{locationcode}{delimiter}{envlabel}{delimiter}{avset}{delimiter}{postfix}"
}

module "resource_naming" {
  source = "../../../resource_naming"

  global_settings = var.global_settings
  settings        = var.availability_set
  resource_type   = "azurerm_availability_set"
  name_mask       = try(var.availability_set.naming_convention.name_mask, local.name_mask)
}

resource "azurerm_availability_set" "avset" {
  name                         = module.resource_naming.name_result
  location                     = var.location != null ? var.location : var.global_settings.location
  resource_group_name          = var.resource_group_name
  tags                         = local.tags
  platform_update_domain_count = try(var.availability_set.platform_update_domain_count, null)
  platform_fault_domain_count  = try(var.availability_set.platform_fault_domain_count, null)
  managed                      = try(var.availability_set.managed, true)
  proximity_placement_group_id = var.ppg_id
}
