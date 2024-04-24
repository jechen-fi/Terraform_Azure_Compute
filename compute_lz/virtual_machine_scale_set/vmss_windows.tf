locals {
  # Name of the VM in the Azure Control Plane
  windows_vm_name_mask = "{vmnameprefix}{delimiter}{postfix}{delimiter}{vmss}"
  # Name of the Windows computer name
  windows_computer_name_mask = "{vmnameprefix}{delimiter}{postfix}{delimiter}{vmss}"
  # Name for the NIC
  windows_nic_name_mask = "{referenced_name}{delimiter}{nic}{delimiter}{postfix}"
}

module "resource_naming_windows_vm_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.vmss_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_windows_virtual_machine_scale_set"
  name_mask       = try(each.value.naming_convention.name_mask, local.windows_vm_name_mask)
  name            = try(each.value.name, null)
}
module "resource_naming_windows_computer_name" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.vmss_settings : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_windows_virtual_machine_scale_set"
  name_mask       = try(each.value.naming_convention.name_mask, local.windows_computer_name_mask)
  name            = try(each.value.computer_name_prefix, each.value.name)
}
module "resource_naming_windows_nic" {
  source   = "../../resource_naming"
  for_each = local.os_type == "windows" ? var.settings.network_interfaces : {}

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_network_interface"
  name_mask       = try(each.value.naming_convention.name_mask, local.windows_nic_name_mask)
  name            = try(each.value.name, null)
  referenced_name = local.os_type == "windows" ? module.resource_naming_windows_vm_name[each.value.vm_setting_key].name_result : null
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  for_each = local.os_type == "windows" ? var.settings.vmss_settings : {}

  admin_password               = coalesce(try(each.value.admin_password, null), var.admin_password, local.admin_password, try(random_password.admin[local.os_type].result, null))
  admin_username               = coalesce(try(each.value.admin_username, null), var.admin_username, local.admin_username)
  instances                    = each.value.instances
  location                     = var.location != null ? var.location : var.global_settings.location
  name                         = module.resource_naming_windows_vm_name[each.key].name_result
  resource_group_name          = var.resource_group_name
  sku                          = each.value.sku
  tags                         = merge(local.tags, try(each.value.tags, null))
  computer_name_prefix         = module.resource_naming_windows_computer_name[each.key].name_result
  custom_data                  = try(each.value.custom_data, null) == null ? null : filebase64(format("%s/%s", path.cwd, each.value.custom_data))
  eviction_policy              = try(each.value.eviction_policy, null)
  max_bid_price                = try(each.value.max_bid_price, null)
  priority                     = try(each.value.priority, null)
  provision_vm_agent           = try(each.value.provision_vm_agent, true)
  proximity_placement_group_id = try(var.proximity_placement_groups[each.value.proximity_placement_group_key].id, null)
  zone_balance                 = try(each.value.zone_balance, null)
  zones                        = try(each.value.zones, null)
  timezone                     = try(each.value.timezone, null)
  license_type                 = try(each.value.license_type, null)
  encryption_at_host_enabled   = try(each.value.encryption_at_host_enabled, false)
  vtpm_enabled                 = try(each.value.vtpm_enabled, null)
  secure_boot_enabled          = try(each.value.secure_boot_enabled, null)
  single_placement_group       = try(each.value.single_placement_group, true)

  dynamic "scale_in" {
    for_each = try(each.value.scale_in, null) != null ? [each.value.scale_in] : []

    content {
      rule                   = try(scale_in.value.rule, "Default")
      force_deletion_enabled = try(scale_in.value.force_deletion_enabled, false)
    }
  }

  dynamic "network_interface" {
    for_each = try(var.settings.network_interfaces, {})

    content {
      name                          = module.resource_naming_windows_nic[network_interface.key].name_result
      primary                       = try(network_interface.value.primary, false)
      enable_accelerated_networking = try(network_interface.value.enable_accelerated_networking, false)
      enable_ip_forwarding          = try(network_interface.value.enable_ip_forwarding, false)
      network_security_group_id     = try(network_interface.value.network_security_group_id, null)

      ip_configuration {
        name    = module.resource_naming_windows_nic[network_interface.key].name_result
        primary = try(network_interface.value.primary, false)
        subnet_id = coalesce(
          try(network_interface.value.subnet_id, null),
          try(var.virtual_networks[network_interface.value.vnet_key].subnets[network_interface.value.subnet_key].id, null)
        )
        load_balancer_backend_address_pool_ids       = try(local.load_balancer_backend_address_pool_ids, null)
        application_gateway_backend_address_pool_ids = try(local.application_gateway_backend_address_pool_ids, null)
        application_security_group_ids               = try(local.application_security_group_ids, null)
      }
    }
  }

  os_disk {
    caching                   = try(each.value.os_disk.caching, null)
    disk_encryption_set_id    = try(each.value.os_disk.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[each.value.os_disk.disk_encryption_set_key].id, null)
    disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
    storage_account_type      = try(each.value.os_disk.storage_account_type, null)
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
  }

  dynamic "data_disk" {
    for_each = try(var.settings.data_disks, {})

    content {
      caching                        = data_disk.value.caching
      create_option                  = try(data_disk.value.create_option, null)
      disk_encryption_set_id         = try(data_disk.value.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[data_disk.value.disk_encryption_set_key].id, null)
      ultra_ssd_disk_iops_read_write = try(data_disk.value.storage_account_type == "UltraSSD_LRS" ? data_disk.value.disk_iops_read_write : null, null)
      ultra_ssd_disk_mbps_read_write = try(data_disk.value.storage_account_type == "UltraSSD_LRS" ? data_disk.value.disk_mbps_read_write : null, null)
      disk_size_gb                   = data_disk.value.disk_size_gb
      lun                            = data_disk.value.lun
      storage_account_type           = data_disk.value.storage_account_type
      write_accelerator_enabled      = try(data_disk.value.write_accelerator_enabled, null)
    }
  }

  dynamic "source_image_reference" {
    for_each = try(each.value.source_image_reference, null) != null ? [1] : []

    content {
      publisher = try(each.value.source_image_reference.publisher, null)
      offer     = try(each.value.source_image_reference.offer, null)
      sku       = try(each.value.source_image_reference.sku, null)
      version   = try(each.value.source_image_reference.version, null)
    }
  }

  source_image_id = try(each.value.custom_image_id, var.custom_image_ids[each.value.custom_image_key].id, null)

  dynamic "plan" {
    for_each = try(each.value.plan, null) != null ? [1] : []

    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  dynamic "identity" {
    for_each = try(each.value.identity, false) == false ? [] : [1]

    content {
      type         = each.value.identity.type
      identity_ids = concat(local.managed_identities, try(each.value.identity.identity_ids, []))
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account == {} ? [] : [1]

    content {
      storage_account_uri = var.boot_diagnostics_storage_account
    }
  }

  dynamic "extension" {
    for_each = try(each.value.extensions, {})

    content {
      name                       = try(extension.value.name, null)
      publisher                  = try(extension.value.publisher, null)
      type                       = try(extension.value.type, null)
      type_handler_version       = try(extension.value.type_handler_version, null)
      auto_upgrade_minor_version = try(extension.value.auto_upgrade_minor_version, null)
      force_update_tag           = try(extension.value.force_update_tag, null)
      protected_settings         = try(extension.value.protected_settings, null)
      provision_after_extensions = try(extension.value.provision_after_extensions, null)
      settings                   = try(extension.value.settings, null)
    }
  }

  dynamic "additional_capabilities" {
    for_each = try(each.value.ultra_ssd_enabled, false) == false ? [] : [1]

    content {
      ultra_ssd_enabled = each.value.ultra_ssd_enabled
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = try(each.value.rolling_upgrade_policy, false) == false ? [] : [1]

    content {
      max_batch_instance_percent              = each.value.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = each.value.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = each.value.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = each.value.rolling_upgrade_policy.pause_time_between_batches
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = try(each.value.automatic_os_upgrade_policy, false) == false ? [] : [1]

    content {
      disable_automatic_rollback  = each.value.automatic_os_upgrade_policy.disable_automatic_rollback
      enable_automatic_os_upgrade = each.value.automatic_os_upgrade_policy.enable_automatic_os_upgrade
    }
  }

  dynamic "additional_unattend_content" {
    for_each = try(each.value.additional_unattend_content, false) == false ? [] : [1]

    content {
      content = each.value.additional_unattend_content.content
      setting = each.value.additional_unattend_content.setting
    }
  }

  # TODO - Need to figure out how to get this working

  # dynamic "secret" {
  #   for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

  #   content {

  #     key_vault_id = local.keyvault.id

  #     WinRM certificate      
  #     dynamic "certificate" {
  #       for_each = try(each.value.winrm.enable_self_signed, false) == false ? [] : [1]

  #       content {
  #         url   = azurerm_key_vault_certificate.self_signed_winrm[each.key].secret_id
  #         store = "My"
  #       }
  #     }
  #   }
  # }

  dynamic "plan" {
    for_each = try(each.value.plan, false) == false ? [] : [1]

    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  # TODO - Need to figure out how to get this working

  # dynamic "winrm_listener" {
  #   for_each = try(each.value.winrm, false) == false ? [] : [1]

  #   content {
  #     protocol        = try(each.value.winrm.protocol, "Https")
  #     certificate_url = try(each.value.winrm.enable_self_signed, false) ? azurerm_key_vault_certificate.self_signed_winrm[each.key].secret_id : each.value.winrm.certificate_url
  #   }
  # }

  dynamic "automatic_instance_repair" {
    for_each = try(each.value.automatic_instance_repair, false) == false ? [] : [1]
    content {
      enabled      = each.value.automatic_instance_repair.enabled
      grace_period = each.value.automatic_instance_repair.grace_period
    }
  }

  health_probe_id = try(var.load_balancers[each.value.health_probe.loadbalancer_key].probes[each.value.health_probe.probe_key].id, null)

  lifecycle {
    ignore_changes = [
      resource_group_name,
      location,
      admin_password,
      admin_username,
      custom_data
    ]
  }

}


resource "random_password" "admin" {
  for_each         = (local.os_type == "windows") && var.admin_password == null && try(var.settings.vmss_settings[local.os_type].admin_password, null) == null && (try(var.settings.vmss_settings["windows"].admin_password_key, null) == null) ? var.settings.vmss_settings : {}
  length           = 123
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each = local.os_type == "windows" && var.admin_password == null && try(var.settings.vmss_settings[local.os_type].admin_password, null) == null && try(var.settings.vmss_settings[local.os_type].admin_password_key, null) == null ? var.settings.virtual_machine_settings : {}

  name         = format("%s-admin-password", module.resource_naming_windows_computer_name[each.key].name_result)
  value        = random_password.admin[local.os_type].result
  key_vault_id = local.keyvault.id

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

#
# Use data external to retrieve value from azure keyvault
#
# With for_each it is not possible to change the provider's subscription at runtime so using the following pattern.
#
data "external" "windows_admin_username" {
  count = try(var.settings.vmss_settings["windows"].admin_username_key, null) == null ? 0 : 1
  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      var.settings.vmss_settings["windows"].admin_username_key,
      local.keyvault.name
    )
  ]
}

data "external" "windows_admin_password" {
  count = try(var.settings.vmss_settings["windows"].admin_password_key, null) == null ? 0 : 1
  program = [
    "bash", "-c",
    format(
      "az keyvault secret show -n '%s' --vault-name '%s' --query '{value: value }' -o json",
      var.settings.vmss_settings["windows"].admin_password_key,
      local.keyvault.name
    )
  ]
}
