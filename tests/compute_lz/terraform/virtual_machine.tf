module "networking_reused" {
  
  source = "../modules/networking/networking_lz/virtual_network_reused"
  for_each = {
    for key, value in try(local.settings.vnets, {}) : key => value
    if try(value.enabled, false) == true && try(value.reuse, false) == true
  }

  global_settings = local.settings
  virtual_network = each.value
}

module "virtual_machines" {
  #depends_on = [module.roles, module.roles_cmk]
  source     = "../modules/compute/compute_lz/virtual_machine"
  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.enabled, false) == true
  }

  global_settings                  = local.settings
  settings                         = each.value
  resource_group_name              = data.azurerm_resource_group.rg.name
  tags                             = try(each.value.tags, null)
  virtual_networks                 = local.networking
  availability_sets                = module.availability_sets
  disk_encryption_sets             = local.disk_encryption_sets
  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
}

module "availability_sets" {
  
  source = "../modules/compute/compute_lz/availability_set"
  for_each = {
    for key, value in try(local.settings.availability_sets, {}) : key => value
    if try(value.enabled, false) == true
  }

  global_settings     = local.settings
  availability_set    = each.value
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = try(each.value.tags, null)
}

