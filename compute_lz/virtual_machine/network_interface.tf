locals {
  nic_ids = flatten(
    [
      local.network_interface_ids,
      try(var.settings.networking_interface_ids, [])
    ]
  )

  network_interface_ids = flatten(
    [
      for nic_key in try(var.settings.virtual_machine_settings[var.settings.os_type].network_interface_keys, []) : [
        azurerm_network_interface.nic[nic_key].id
      ]
    ]
  )

  name_mask = "{referenced_name}{delimiter}{nic}{delimiter}{postfix}"

}

module "resource_naming" {
  source   = "../../resource_naming"
  for_each = var.settings.network_interfaces

  global_settings = var.global_settings
  settings        = each.value
  resource_type   = "azurerm_network_interface"
  name            = try(each.value.name, null)
  name_mask       = try(each.value.naming_convention.name_mask, local.name_mask)
  referenced_name = local.os_type == "linux" ? module.resource_naming_linux_vm_name[each.value.vm_setting_key].name_result : local.os_type == "windows" ? module.resource_naming_windows_vm_name[each.value.vm_setting_key].name_result : module.resource_naming_legacy_vm_name[each.value.vm_setting_key].name_result
}

resource "azurerm_network_interface" "nic" {
  for_each = var.settings.network_interfaces
  lifecycle {
    ignore_changes = [resource_group_name, location]
  }
  name                = module.resource_naming[each.key].name_result
  location            = var.location != null ? var.location : var.global_settings.location
  resource_group_name = var.resource_group_name

  dns_servers                   = lookup(each.value, "dns_servers", null)
  enable_ip_forwarding          = lookup(each.value, "enable_ip_forwarding", false)
  enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", false)
  internal_dns_name_label       = lookup(each.value, "internal_dns_name_label", null)
  tags                          = merge(local.tags, try(each.value.tags, null))

  ip_configuration {
    name                          = module.resource_naming[each.key].name_result
    subnet_id                     = try(each.value.subnet_id, var.virtual_networks[each.value.vnet_key].subnets[each.value.subnet_key].id)
    private_ip_address_allocation = lookup(each.value, "private_ip_address_allocation", "Dynamic")
    private_ip_address_version    = lookup(each.value, "private_ip_address_version", null)
    private_ip_address            = lookup(each.value, "private_ip_address", null)
    primary                       = lookup(each.value, "primary", null)
    public_ip_address_id          = try(each.value.public_address_id, lookup(each.value, "public_ip_address_key", null) == null ? null : var.public_ip_addresses[each.value.public_ip_address_key].id)
  }

  dynamic "ip_configuration" {
    for_each = try(each.value.ip_configurations, {})

    content {
      name                          = ip_configuration.value.name
      subnet_id                     = try(each.value.subnet_id, null) != null ? each.value.subnet_id : var.virtual_networks[each.value.vnet_key].subnets[each.value.subnet_key].id
      private_ip_address_allocation = try(ip_configuration.value.private_ip_address_allocation, "Dynamic")
      private_ip_address_version    = lookup(ip_configuration.value, "private_ip_address_version", null)
      private_ip_address            = lookup(ip_configuration.value, "private_ip_address", null)
      primary                       = lookup(ip_configuration.value, "primary", null)
      public_ip_address_id          = try(each.value.public_address_id, lookup(each.value, "public_ip_address_key", null) == null ? null : var.public_ip_addresses[each.value.public_ip_address_key].id)
    }
  }
}

resource "azurerm_network_interface_security_group_association" "nic" {
  for_each = {
    for key, value in try(var.settings.network_interfaces, {}) : key => value
    if try(try(value.nsg_key, value.nsg_id), null) != null
  }

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = try(each.value.nsg_id, var.network_security_groups[each.value.nsg_key].id)
}


resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  for_each = {
    for key, value in try(var.settings.network_interfaces, {}) : key => value
    if try(value.network_security_group, null) != null
  }

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = var.network_security_groups[each.value.network_security_group.key].id
}