
##==============================================================
## Name:    virtual_machine_groups
## Purpose: Module will generate multiple virtual machines
##          using a counter and vm_name_prefix
##          and apply the applicable VM extensions per VM.
##
## ** To create individual VMs, continue to use the 
##    virtual_machines module
##==============================================================

module "virtual_machines_in_group" {
  source = "./virtual_machine"

  count = var.settings.vm_count

  global_settings             = var.global_settings
  location                    = try(var.settings.virtual_machine.location, null)
  settings                    = var.settings.virtual_machine
  resource_group_name         = var.resource_groups[var.settings.virtual_machine.resource_group_key].name
  tags                        = try(var.settings.virtual_machine.tags, null)
  virtual_networks            = var.networking
  keyvaults                   = var.keyvaults
  availability_sets           = var.availability_sets
  custom_image_ids            = var.shared_images
  admin_username              = var.vm_admin_username
  admin_password              = var.vm_admin_password
  vm_name_prefix              = var.vm_name_prefix
  application_security_groups = var.application_security_groups

  # NOTE: VM Count formatting is driven by the YAML settings
  # Example formatting as XX1, starting the index at 1 instead of 0
  # vm_count_format = "%03d"
  # vm_count_start_index = 1
  vm_count = format(var.vm_count_format, count.index + var.vm_count_start_index)
}

module "vm_group_vm_extension_InitializeDataDisks" {
  source     = "./virtual_machine_extensions"
  depends_on = [module.virtual_machines_in_group]

  count = try(var.settings.virtual_machine_extensions.InitializeDataDisks, null) != null && lookup(try(var.settings.virtual_machine_extensions.InitializeDataDisks, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.InitializeDataDisks
  extension_name     = "InitializeDataDisks"
}

module "vm_group_vm_extension_custom_script" {
  source     = "./virtual_machine_extensions"
  depends_on = [module.virtual_machines_in_group, module.vm_group_vm_extension_InitializeDataDisks]

  count = try(var.settings.virtual_machine_extensions.custom_script, null) != null && lookup(try(var.settings.virtual_machine_extensions.custom_script, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings         = var.global_settings
  virtual_machine_id      = module.virtual_machines_in_group[count.index].id
  virtual_machine_os_type = var.settings.virtual_machine.os_type
  extension               = var.settings.virtual_machine_extensions.custom_script
  extension_name          = "custom_script"
  storage_accounts        = var.storage_account
}

module "vm_group_vm_extension_AADLoginForWindows" {
  depends_on = [module.vm_group_vm_extension_InitializeDataDisks]
  source     = "./virtual_machine_extensions"

  count = try(var.settings.virtual_machine_extensions.AADLoginForWindows, null) != null && lookup(try(var.settings.virtual_machine_extensions.AADLoginForWindows, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.AADLoginForWindows
  extension_name     = "AADLoginForWindows"
}

module "vm_group_vm_extension_LegacyADLoginForWindows" {
  depends_on = [module.vm_group_vm_extension_InitializeDataDisks]
  source     = "./virtual_machine_extensions"

  count = try(var.settings.virtual_machine_extensions.LegacyADLoginForWindows, null) != null && lookup(try(var.settings.virtual_machine_extensions.LegacyADLoginForWindows, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.LegacyADLoginForWindows
  extension_name     = "LegacyADLoginForWindows"
  vm_domain_username = var.vm_domain_username != null ? var.vm_domain_username : try(var.settings.virtual_machine.virtual_machine_settings.windows.domain_username, null)
  vm_domain_password = var.vm_domain_password != null ? var.vm_domain_password : try(var.settings.virtual_machine.virtual_machine_settings.windows.domain_password, null)
  keyvaults          = var.keyvaults
}

module "vm_group_vm_extension_AVD_DSC" {
  source = "./virtual_machine_extensions"
  depends_on = [
    module.virtual_machines_in_group,
    module.vm_group_vm_extension_AADLoginForWindows,
    module.vm_group_vm_extension_LegacyADLoginForWindows,
    module.vm_group_vm_extension_InitializeDataDisks
  ]

  count = try(var.settings.virtual_machine_extensions.AVD_DSC_Extension, null) != null && lookup(try(var.settings.virtual_machine_extensions.AVD_DSC_Extension, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.AVD_DSC_Extension
  extension_name     = "AVD_DSC_Extension"
  avd_host_pools     = var.avd_host_pools
}

module "vm_group_vm_extension_NvidiaGpuDriverWindows" {
  source     = "./virtual_machine_extensions"
  depends_on = [module.virtual_machines_in_group]

  count = try(var.settings.virtual_machine_extensions.NvidiaGpuDriverWindows, null) != null && lookup(try(var.settings.virtual_machine_extensions.NvidiaGpuDriverWindows, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.NvidiaGpuDriverWindows
  extension_name     = "NvidiaGpuDriverWindows"
}

# ============================== 
# !!!  DISCLAIMER  !!!
# Data Disks will NOT be updated with SSE with PMK & ADE 
# if they are not initialized and formatted to the VM before this extension is enabled
# ==============================
module "vm_group_vm_extension_AzureDiskEncryptionWindows" {
  depends_on = [module.virtual_machines_in_group, module.vm_group_vm_extension_InitializeDataDisks]
  source     = "./virtual_machine_extensions"

  count = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows, null) != null && lookup(try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows
  extension_name     = "AzureDiskEncryptionWindows"
  keyvaults          = var.keyvaults

  settings = {
    keyvault_keys          = var.keyvault_keys,
    EncryptionOperation    = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows.EncryptionOperation, null),
    KeyEncryptionKeyURL    = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows.KeyEncryptionKeyURL, null),
    KeyEncryptionAlgorithm = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows.KeyEncryptionAlgorithm, null),
    VolumeType             = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionWindows.VolumeType, null)
  }

}

# ============================== 
# !!!  DISCLAIMER  !!!
# Data Disks will NOT be updated with SSE with PMK & ADE 
# if they are not initialized and formatted to the VM before this extension is enabled
# ==============================
module "vm_group_vm_extension_AzureDiskEncryptionLinux" {
  depends_on = [module.virtual_machines_in_group, module.vm_group_vm_extension_InitializeDataDisks]
  source     = "./virtual_machine_extensions"

  count = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux, null) != null && lookup(try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux, {}), "enabled", false) == true ? var.settings.vm_count : 0

  global_settings    = var.global_settings
  virtual_machine_id = module.virtual_machines_in_group[count.index].id
  extension          = var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux
  extension_name     = "AzureDiskEncryptionLinux"
  keyvaults          = var.keyvaults

  settings = {
    keyvault_keys          = var.keyvault_keys,
    EncryptionOperation    = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux.EncryptionOperation, null),
    KeyEncryptionKeyURL    = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux.KeyEncryptionKeyURL, null),
    KeyEncryptionAlgorithm = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux.KeyEncryptionAlgorithm, null),
    VolumeType             = try(var.settings.virtual_machine_extensions.AzureDiskEncryptionLinux.VolumeType, null)
  }

}
