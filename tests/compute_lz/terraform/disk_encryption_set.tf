module "disk_encryption_set" {
  depends_on = [
    module.keyvault_keys,
    #module.roles
  ]
  source = "../modules/compute/disk_encryption_set_lz/disk_encryption_set"
  for_each = {
    for key, value in try(local.settings.disk_encryption_set, {}) : key => value
    if try(value.enabled, false) == true && try(value.reuse, false) == false
  }

  global_settings     = local.settings
  settings            = each.value
  resource_group_name = data.azurerm_resource_group.rg.name
  keyvault_id         = module.keyvault_reused["keyvault1"].id
  key_vault_key_ids   = module.keyvault_keys
  tags                = try(each.value.tags, null)
}

module "keyvault_reused" {
  source = "../modules/keyvault/keyvault_lz/keyvault_reused"
  
  for_each = {
    for key, value in try(local.settings.keyvaults, {}) : key => value
    if try(value.enabled, false) == true && try(value.reuse, false) == true
  }

  global_settings = local.settings
  key_vault       = each.value
  tenant_id       = var.tenant_id
}

module "keyvault_keys" {
  #depends_on = [ module.keyvault_access_policies ]
  source = "../modules/keyvault/keyvault_lz/keyvault_key"
  for_each = {
    for key, value in try(local.settings.kv_key, {}) : key => value
    if try(value.enabled, false) == true && try(value.reuse, false) == false
  }
  settings        = each.value
  global_settings = local.settings
  keyvault_id     = module.keyvault_reused["keyvault1"].id
}


# module "disk_encryption_set_reused" {
#   depends_on = [
#     module.keyvault_keys,
#     module.roles
#   ]
#   source = "../../../Azure-Terraform-Modules//modules/security/disk_encryption_set_reused"
#   for_each = {
#     for key, value in try(local.settings.disk_encryption_set, {}) : key => value
#     if try(value.enabled, false) == true && try(value.reuse, false) == true
#   }

#   global_settings = local.settings
#   settings        = each.value
# }