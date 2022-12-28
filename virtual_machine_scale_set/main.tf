#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key == true && local.os_type == "linux" ? 1 : 0    
  algorithm = "RSA"
  rsa_bits  = 4096
}

#----------------------------------------------------------
# Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.resource_group_vnet
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "random_string" "str" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = local.virtual_machine_name
  }
}

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.enable_feature[var.enable_public_ip_address] ? 1 : 0
  name                = "pip-vm-${local.virtual_machine_name}-${var.rg_location}"
  location            = var.rg_location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s%s", replace(local.virtual_machine_name, "/[[:^alnum:]]/", ""), random_string.str.result)
  tags                = merge({ "ResourceName" = lower("pip-vm-${local.virtual_machine_name}-${var.rg_location}") }, var.tags, )
}

#---------------------------------------
# External Load Balancer with Public IP
#---------------------------------------
resource "azurerm_lb" "vmsslb" {
  count               = var.enable_load_balancer ? 1 : 0
  name                = var.load_balancer_type == "public" ? lower("lbext-${local.virtual_machine_name}-${var.rg_location}") : lower("lbint-${local.virtual_machine_name}-${data.azurerm_resource_group.rg.location}")
  location            = var.rg_location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.load_balancer_sku
  tags                = merge({ "resourcename" = var.load_balancer_type == "public" ? lower("lbext-${local.virtual_machine_name}-${var.rg_location}") : lower("lbint-${local.virtual_machine_name}-${var.rg_location}") }, var.tags, )

  frontend_ip_configuration {
    name                          = var.load_balancer_type == "public" ? lower("lbext-frontend-${local.virtual_machine_name}") : lower("lbint-frontend-${local.virtual_machine_name}")
    public_ip_address_id          = var.enable_load_balancer == true && var.load_balancer_type == "public" ? azurerm_public_ip.pip[count.index].id : null
    private_ip_address_allocation = var.load_balancer_type == "private" ? var.private_ip_address_allocation_type : null
    private_ip_address            = var.load_balancer_type == "private" && var.private_ip_address_allocation_type == "Static" ? var.lb_private_ip_address : null
    subnet_id                     = var.load_balancer_type == "private" ? data.azurerm_subnet.snet.id : null
  }

}

#---------------------------------------
# Backend address pool for Load Balancer
#---------------------------------------
resource "azurerm_lb_backend_address_pool" "bepool" {
  count           = var.enable_load_balancer ? 1 : 0
  name            = lower("lbe-backend-pool-${local.virtual_machine_name}")
  loadbalancer_id = azurerm_lb.vmsslb[count.index].id
}

#---------------------------------------
# Load Balancer NAT pool
#---------------------------------------
resource "azurerm_lb_nat_pool" "natpol" {
  count                          = var.enable_load_balancer && var.enable_lb_nat_pool ? 1 : 0
  name                           = lower("lbe-nat-pool-${local.virtual_machine_name}-${var.rg_location}")
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.vmsslb.0.id
  protocol                       = "Tcp"
  frontend_port_start            = var.nat_pool_frontend_ports[0]
  frontend_port_end              = var.nat_pool_frontend_ports[1]
  backend_port                   = var.os_type == "linux" ? 22 : 3389
  frontend_ip_configuration_name = azurerm_lb.vmsslb.0.frontend_ip_configuration.0.name
}

#---------------------------------------
# Health Probe for resources
#---------------------------------------
resource "azurerm_lb_probe" "lbp" {
  count               = var.enable_load_balancer ? 1 : 0
  name                = lower("lb-probe-port-${var.load_balancer_health_probe_port}-${local.virtual_machine_name}")
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.vmsslb[count.index].id
  port                = var.load_balancer_health_probe_port
  protocol            = var.lb_probe_protocol
  request_path        = var.lb_probe_protocol != "Tcp" ? var.lb_probe_request_path : null
  number_of_probes    = var.number_of_probes
}

#--------------------------
# Load Balancer Rules
#--------------------------
resource "azurerm_lb_rule" "lbrule" {
  count                          = var.enable_load_balancer ? length(var.load_balanced_port_list) : 0
  name                           = format("%s-%02d-rule", local.virtual_machine_name, count.index + 1)
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.vmsslb[0].id
  probe_id                       = azurerm_lb_probe.lbp[0].id
  protocol                       = "Tcp"
  frontend_port                  = tostring(var.load_balanced_port_list[count.index])
  backend_port                   = tostring(var.load_balanced_port_list[count.index])
  frontend_ip_configuration_name = azurerm_lb.vmsslb[0].frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool[0].id]
}

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                         = 1
  name                          = "nic-${local.virtual_machine_name}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.rg_location
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  tags                          = merge({ "ResourceName" = "nic-${replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")}" }, var.tags, )
  # tags                            = merge({ "ResourceName" = "nic-${replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")}" }, var.tags, )
  ip_configuration {
    name                          = format("ipconfig-%s", lower(local.virtual_machine_name))
    primary                       = true
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? concat(var.private_ip_address, [""]) : null
    public_ip_address_id          = tobool(var.enable_feature[var.enable_public_ip_address]) ? element(concat(azurerm_public_ip.pip.*.id, [""]), count.index) : null
    private_ip_address_allocation = var.private_ip_address_allocation_type
  }
}


#----------------------------------------------------------------------------------------------------
# Proximity placement group for virtual machines, virtual machine scale sets and availability sets.
#----------------------------------------------------------------------------------------------------
resource "azurerm_proximity_placement_group" "appgrp" {
  count               = var.enable_proximity_placement_group ? 1 : 0
  name                = lower("proxigrp-${local.virtual_machine_name}-${var.rg_location}")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.rg_location
  tags                = merge({ "resourcename" = lower("proxigrp-${local.virtual_machine_name}-${var.rg_location}") }, var.tags, )

}

#---------------------------------------
# Linux Virutal machine scale set
#---------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  depends_on                                        = [azurerm_disk_encryption_set.des, azurerm_key_vault_access_policy.desKvPolicy]
  count                                             = var.os_type == "linux" ? 1 : 0
  name                                              = format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)
  computer_name_prefix                              = var.computer_name_prefix == null && var.instances_count == 1 ? substr(local.virtual_machine_name, 0, 15) : substr(format("%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  resource_group_name                               = data.azurerm_resource_group.rg.name
  location                                          = var.rg_location
  sku                                               = var.virtual_machine_size
  instances                                         = var.instances_count
  admin_username                                    = var.admin_username
  admin_password                                    = var.admin_password
  custom_data                                       = var.custom_data
  disable_password_authentication                   = var.disable_password_authentication
  overprovision                                     = var.overprovision
  do_not_run_extensions_on_overprovisioned_machines = var.do_not_run_extensions_on_overprovisioned_machines
  encryption_at_host_enabled                        = var.enable_encryption_at_host
  health_probe_id                                   = var.enable_load_balancer ? azurerm_lb_probe.lbp[0].id : null
  platform_fault_domain_count                       = var.platform_fault_domain_count
  provision_vm_agent                                = true
  proximity_placement_group_id                      = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  scale_in_policy                                   = var.scale_in_policy
  single_placement_group                            = var.single_placement_group
  source_image_id                                   = var.source_image_id != null ? var.source_image_id : null
  upgrade_mode                                      = var.os_upgrade_mode
  zones                                             = var.availability_zones
  priority                                          = var.priority
  zone_balance                                      = var.availability_zone_balance
  tags                                              = merge({ "resourcename" = format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.tags, )

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_key_data == null ? tls_private_key.rsa[0].public_key_openssh : file(var.admin_ssh_key_data)
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : var.os_distribution_list[var.os_distribution][*]
    content {
      publisher = lookup(source_image_reference.value, "publisher", null)
      offer     = lookup(source_image_reference.value, "offer", null)
      sku       = lookup(source_image_reference.value, "sku", null)
      version   = lookup(source_image_reference.value, "version", null)
    }
  }

  dynamic "os_disk" {
    for_each = var.os_disk[local.os_type][*]
    content {
      name                      = lookup(os_disk.value, "name", null)
      disk_size_gb              = lookup(os_disk.value, "disk_size_gb", null)
      storage_account_type      = lookup(os_disk.value, "storage_account_type", null)
      caching                   = lookup(os_disk.value, "caching", null)
      disk_encryption_set_id    = azurerm_disk_encryption_set.des.id
      write_accelerator_enabled = lookup(os_disk.value, "write_accelerator_enabled", null)
    }
  }

  dynamic "additional_capabilities" {
    for_each = var.enable_ultra_ssd_data_disk_storage_support ? [1] : []
    content {
      ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
    }
  }

  dynamic "data_disk" {
    for_each = var.additional_data_disks
    content {
      lun                  = data_disk.key
      disk_size_gb         = data_disk.value
      caching              = "ReadWrite"
      create_option        = "Empty"
      storage_account_type = var.additional_data_disks_storage_account_type
    }
  }

  network_interface {
    name                          = lower("nic-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    dns_servers                   = var.dns_servers
    enable_ip_forwarding          = var.enable_ip_forwarding
    enable_accelerated_networking = var.enable_accelerated_networking
    network_security_group_id     = var.existing_network_security_group_id == null ? azurerm_network_security_group.nsg.0.id : var.existing_network_security_group_id

    ip_configuration {
      name                                   = lower("ipconig-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
      primary                                = true
      subnet_id                              = data.azurerm_subnet.snet.id
      load_balancer_backend_address_pool_ids = var.enable_load_balancer ? [azurerm_lb_backend_address_pool.bepool[0].id] : null
      load_balancer_inbound_nat_rules_ids    = var.enable_load_balancer && var.enable_lb_nat_pool ? [azurerm_lb_nat_pool.natpol[0].id] : null

      dynamic "public_ip_address" {
        for_each = var.assign_public_ip_to_each_vm_in_vmss ? [1] : []
        content {
          name                = lower("pip-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), "0${count.index + 1}")}")
          public_ip_prefix_id = var.public_ip_prefix_id
        }
      }
    }
  }

  dynamic "secret" {
    for_each = var.secret[*]
    content {
      dynamic "certificate" {
        for_each = var.certsecret[*]
        content {
          url = lookup(certificate.value, "url", null)
        }
      }
      key_vault_id = lookup(secret.value, "key_vault_id", null)
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.os_upgrade_mode == "Automatic" ? [1] : []
    content {
      disable_automatic_rollback  = true
      enable_automatic_os_upgrade = true
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.os_upgrade_mode != "Manual" ? [1] : []
    content {
      max_batch_instance_percent              = var.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_policy.pause_time_between_batches
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.enable_automatic_instance_repair ? [1] : []
    content {
      enabled      = var.enable_automatic_instance_repair
      grace_period = var.grace_period
    }
  }

  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  # As per the recomendation by Terraform documentation
  # depends_on = [azurerm_lb_rule.lbrule]
}

#---------------------------------------
# Linux VM Guest Configuration Extension
#---------------------------------------
resource "azurerm_virtual_machine_extension" "vm_guest_config_linux" {
  count                      = local.os_type == "linux" ? 1 : 0
  name                       = "VMGuestConfigExtensionLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.linuxvm[0].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
}

#-----------------------------------------------------
# Linux Azure Monitoring Agent Configuration Extension
#-----------------------------------------------------
resource "azurerm_virtual_machine_extension" "azure_monitoring_agent_linux" {
  count                      = local.os_type == "linux" ? 1 : 0
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.linuxvm[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.2"
  auto_upgrade_minor_version = "true"
  depends_on = [
    azurerm_linux_virtual_machine.linuxvm
  ]
}

resource "azapi_resource" "dcr_association_linux" {
  count     = local.os_type == "linux" ? length(var.data_collection_rule) : 0
  type      = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name      = format("%s%s", "dcrAzMonitorLinux", count.index + 1)
  parent_id = azurerm_linux_virtual_machine.linuxvm[0].id
  body = jsonencode({
    properties = {
      dataCollectionRuleId = var.data_collection_rule[count.index]
      description          = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

resource "azapi_resource" "dce_association_linux" {
  count     = local.os_type == "linux" ? 1 : 0
  type      = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name      = "configurationAccessEndpoint"
  parent_id = azurerm_linux_virtual_machine.linuxvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionEndpointId = var.data_collection_endpoint
      description              = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

#---------------------------------------
# Windows Virutal machine scale set
#---------------------------------------
resource "azurerm_windows_virtual_machine_scale_set" "winsrv_vmss" {
  depends_on                                        = [azurerm_disk_encryption_set.des, azurerm_key_vault_access_policy.desKvPolicy]
  count                                             = var.os_type == "windows" ? 1 : 0
  name                                              = format("%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")))
  computer_name_prefix                              = var.computer_name_prefix == null && var.instances_count == 1 ? substr(local.virtual_machine_name, 0, 15) : substr(format("%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  resource_group_name                               = data.azurerm_resource_group.rg.name
  location                                          = var.rg_location
  sku                                               = var.virtual_machine_size
  instances                                         = var.instances_count
  admin_username                                    = var.admin_username
  admin_password                                    = var.admin_password
  custom_data                                       = var.custom_data
  overprovision                                     = var.overprovision
  do_not_run_extensions_on_overprovisioned_machines = var.do_not_run_extensions_on_overprovisioned_machines
  enable_automatic_updates                          = var.os_upgrade_mode != "Automatic" ? var.enable_windows_vm_automatic_updates : false
  encryption_at_host_enabled                        = var.enable_encryption_at_host
  health_probe_id                                   = var.enable_load_balancer ? azurerm_lb_probe.lbp[0].id : null
  license_type                                      = var.license_type
  platform_fault_domain_count                       = var.platform_fault_domain_count
  provision_vm_agent                                = true
  proximity_placement_group_id                      = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  scale_in_policy                                   = var.scale_in_policy
  single_placement_group                            = var.single_placement_group
  source_image_id                                   = var.source_image_id != null ? var.source_image_id : null
  upgrade_mode                                      = var.os_upgrade_mode
  timezone                                          = var.vm_time_zone
  zone                                              = var.availability_zones
  zone_balance                                      = var.availability_zone_balance
  tags                                              = merge({ "ResourceName" = local.virtual_machine_name }, var.tags, )

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : var.os_distribution_list[var.os_distribution][*]
    content {
      publisher = lookup(source_image_reference.value, "publisher", null)
      offer     = lookup(source_image_reference.value, "offer", null)
      sku       = lookup(source_image_reference.value, "sku", null)
      version   = lookup(source_image_reference.value, "version", null)
    }
  }

  dynamic "os_disk" {
    for_each = var.os_disk[local.os_type][*]
    content {
      name                      = lookup(os_disk.value, "name", null)
      disk_size_gb              = lookup(os_disk.value, "disk_size_gb", null)
      storage_account_type      = lookup(os_disk.value, "storage_account_type", null)
      caching                   = lookup(os_disk.value, "caching", null)
      disk_encryption_set_id    = azurerm_disk_encryption_set.des.id
      write_accelerator_enabled = lookup(os_disk.value, "write_accelerator_enabled", null)
    }
  }

  dynamic "additional_capabilities" {
    for_each = var.enable_ultra_ssd_data_disk_storage_support ? [1] : []
    content {
      ultra_ssd_enabled = lookup(additional_capabilities.value, "required", null)
    }
  }

  dynamic "data_disk" {
    for_each = var.additional_data_disks
    content {
      lun                  = data_disk.key
      disk_size_gb         = data_disk.value
      caching              = "ReadWrite"
      create_option        = "Empty"
      storage_account_type = var.additional_data_disks_storage_account_type
    }
  }

  network_interface {
    name                          = lower("nic-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    dns_servers                   = var.dns_servers
    enable_ip_forwarding          = var.enable_ip_forwarding
    enable_accelerated_networking = var.enable_accelerated_networking
    network_security_group_id     = var.existing_network_security_group_id == null ? azurerm_network_security_group.nsg.0.id : var.existing_network_security_group_id

    ip_configuration {
      name                                   = lower("ipconfig-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
      primary                                = true
      subnet_id                              = data.azurerm_subnet.snet.id
      load_balancer_backend_address_pool_ids = var.enable_load_balancer ? [azurerm_lb_backend_address_pool.bepool[0].id] : null
      load_balancer_inbound_nat_rules_ids    = var.enable_load_balancer && var.enable_lb_nat_pool ? [azurerm_lb_nat_pool.natpol.0.id] : null

      dynamic "public_ip_address" {
        for_each = var.assign_public_ip_to_each_vm_in_vmss ? [{}] : []
        content {
          name                = lower("pip-${format("vm%s%s", lower(replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
          public_ip_prefix_id = var.public_ip_prefix_id
        }
      }
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.os_upgrade_mode == "Automatic" ? [1] : []
    content {
      disable_automatic_rollback  = true
      enable_automatic_os_upgrade = true
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.os_upgrade_mode != "Manual" ? [1] : []
    content {
      max_batch_instance_percent              = var.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_policy.pause_time_between_batches
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.enable_automatic_instance_repair ? [1] : []
    content {
      enabled      = var.enable_automatic_instance_repair
      grace_period = var.grace_period
    }
  }

  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "winrm_listener" {
    for_each = var.winrm_protocol != null ? [1] : []
    content {
      protocol        = var.winrm_protocol
      certificate_url = var.winrm_protocol == "Https" ? var.key_vault_certificate_secret_url : null
    }
  }

  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_content != null ? [1] : []
    content {
      content = var.additional_unattend_content
      setting = var.additional_unattend_content_setting
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diag[*]
    content {
      # below ensures boot diag is stored in a managed storage account
      storage_account_uri = lookup(boot_diagnostics.value, "storage_uri", null)
    }
  }

  # As per the recomendation by Terraform documentation
  # depends_on = [azurerm_lb_rule.lbrule]
}

resource "azurerm_virtual_machine_extension" "vm_guest_config_windows" {
  count                      = local.os_type == "windows" ? 1 : 0
  name                       = "VMGuestConfigExtensionWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm[0].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
}

#-------------------------------------------------------
# Windows Azure Monitoring Agent Configuration Extension
#-------------------------------------------------------
resource "azurerm_virtual_machine_extension" "azure_monitoring_agent_windows" {
  count                      = local.os_type == "windows" ? 1 : 0
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.2"
  auto_upgrade_minor_version = "true"
  depends_on = [
    azurerm_windows_virtual_machine.winvm
  ]
}

resource "azapi_resource" "dcr_association_windows" {
  count     = local.os_type == "windows" ? length(var.data_collection_rule) : 0
  type      = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name      = format("%s%s", "dcrAzMonitorWindows", count.index + 1)
  parent_id = azurerm_windows_virtual_machine.winvm[0].id
  body = jsonencode({
    properties = {
      dataCollectionRuleId = var.data_collection_rule[count.index]
      description          = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

resource "azapi_resource" "dce_association_windows" {
  count     = local.os_type == "windows" ? 1 : 0
  type      = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name      = "configurationAccessEndpoint"
  parent_id = azurerm_windows_virtual_machine.winvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionEndpointId = var.data_collection_endpoint
      description              = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}


#-----------------------------------------------
# Auto Scaling for Virtual machine scale set
#-----------------------------------------------
resource "azurerm_monitor_autoscale_setting" "auto" {
  count               = var.enable_autoscale_for_vmss ? 1 : 0
  name                = lower("auto-scale-set-${local.virtual_machine_name}")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.rg_location
  target_resource_id  = var.os_type == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id

  profile {
    name = "default"
    capacity {
      default = var.instances_count
      minimum = var.minimum_instances_count == null ? var.instances_count : var.minimum_instances_count
      maximum = var.maximum_instances_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.os_type == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_cpu_percentage_threshold
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.os_type == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_cpu_percentage_threshold
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = "PT1M"
      }
    }
  }
}

#---------------------------------------
# Virtual Machine Data Disks
#---------------------------------------
resource "azurerm_managed_disk" "data_disk" {
  for_each               = local.vm_data_disks
  name                   = "${local.virtual_machine_name}_DataDisk_${each.value.idx}"
  resource_group_name    = data.azurerm_resource_group.rg.name
  location               = var.rg_location
  storage_account_type   = lookup(each.value.data_disk, "storage_account_type", "StandardSSD_LRS")
  create_option          = "Empty"
  disk_size_gb           = each.value.data_disk.disk_size_gb
  zone                  = var.zone
  tags                   = merge({ "ResourceName" = local.virtual_machine_name }, var.tags, )
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each           = local.vm_data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = local.os_type == "windows" ? azurerm_windows_virtual_machine.winvm[0].id : azurerm_linux_virtual_machine.linuxvm[0].id
  lun                = each.value.idx
  caching            = "ReadWrite"
}

# Creating Disk Encryption Set
resource "azurerm_disk_encryption_set" "des" {
  depends_on                = [azurerm_key_vault_key.cmk]
  name                      = "des_${local.virtual_machine_name}"
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = var.rg_location
  key_vault_key_id          = azurerm_key_vault_key.cmk.id
  encryption_type           = "EncryptionAtRestWithCustomerKey"
  auto_key_rotation_enabled = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      location,
    ]
  }
}

# CMK Expiration
resource "time_rotating" "cmk_expiration" {
  rotation_days = 720
}

# Create Customer Manage Key to be used for encryption
resource "azurerm_key_vault_key" "cmk" {
  name            = "cmk-${local.virtual_machine_name}"
  key_vault_id    = var.kv_id
  key_type        = "RSA"
  key_size        = 2048
  expiration_date = time_rotating.cmk_expiration.rotation_rfc3339
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
}

# Enabling KeyVault Access Policy for DES
resource "azurerm_key_vault_access_policy" "desKvPolicy" {
  depends_on   = [azurerm_disk_encryption_set.des]
  key_vault_id = var.kv_id
  tenant_id    = azurerm_disk_encryption_set.des.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.des.identity.0.principal_id

  key_permissions = [
    "Get", "WrapKey", "UnwrapKey"
  ]
}

# Key Rotation Policy
resource "azapi_update_resource" "cmk_rotate_policy" {
  type      = "Microsoft.KeyVault/vaults/keys@2021-11-01-preview"
  name      = azurerm_key_vault_key.cmk.name
  parent_id = azurerm_key_vault_key.cmk.key_vault_id

  body = jsonencode({
    properties = {
      rotationPolicy = {
        lifetimeActions = [
          {
            action = {
              type = "Rotate"
            }
            trigger = {
              timeAfterCreate  = "P180D"
              timeBeforeExpiry = null
            }
          },
          {
            action = {
              type = "Notify"
            }
            trigger = {
              timeAfterCreate  = null
              timeBeforeExpiry = "P20D"
            }
          }
        ],
        attributes = {
          expiryTime = "P2Y"
        }
      }
    }
  })
}


# #--------------------------------------------------------------
# # Azure Log Analytics Workspace Agent Installation for windows
# #--------------------------------------------------------------
# resource "azurerm_virtual_machine_scale_set_extension" "omsagentwin" {
#   count                        = var.deploy_log_analytics_agent && var.log_analytics_workspace_id != null && var.os_type == "windows" ? 1 : 0
#   name                         = "OmsAgentForWindows"
#   publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
#   type                         = "MicrosoftMonitoringAgent"
#   type_handler_version         = "1.0"
#   auto_upgrade_minor_version   = true
#   virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id

#   settings = <<SETTINGS
#     {
#       "workspaceId": "${var.log_analytics_customer_id}"
#     }
#   SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#     "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
#     }
#   PROTECTED_SETTINGS
# }

# #--------------------------------------------------------------
# # Azure Log Analytics Workspace Agent Installation for Linux
# #--------------------------------------------------------------
# resource "azurerm_virtual_machine_scale_set_extension" "omsagentlinux" {
#   count                        = var.deploy_log_analytics_agent && var.log_analytics_workspace_id != null && var.os_type == "linux" ? 1 : 0
#   name                         = "OmsAgentForLinux"
#   publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
#   type                         = "OmsAgentForLinux"
#   type_handler_version         = "1.13"
#   auto_upgrade_minor_version   = true
#   virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id

#   settings = <<SETTINGS
#     {
#       "workspaceId": "${var.log_analytics_customer_id}"
#     }
#   SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#     "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
#     }
#   PROTECTED_SETTINGS
# }

# #--------------------------------------
# # azurerm monitoring diagnostics 
# #--------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "vmmsdiag" {
#   count                      = var.log_analytics_workspace_id != null ? 1 : 0
#   name                       = lower("${local.virtual_machine_name}-diag")
#   target_resource_id         = var.os_type == "windows" ? azurerm_windows_virtual_machine_scale_set.winsrv_vmss.0.id : azurerm_linux_virtual_machine_scale_set.linux_vmss.0.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "nsg" {
#   count                      = var.existing_network_security_group_id == null && var.log_analytics_workspace_id != null ? 1 : 0
#   name                       = lower("nsg-${local.virtual_machine_name}-diag")
#   target_resource_id         = azurerm_network_security_group.nsg.0.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.nsg_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "lb-pip" {
#   count                      = var.load_balancer_type == "public" && var.log_analytics_workspace_id != null ? 1 : 0
#   name                       = "${local.virtual_machine_name}-pip-diag"
#   target_resource_id         = azurerm_public_ip.pip.0.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.pip_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "lb" {
#   count                      = var.load_balancer_type == "public" && var.log_analytics_workspace_id != null && var.storage_account_name != null ? 1 : 0
#   name                       = "${local.virtual_machine_name}-lb-diag"
#   target_resource_id         = azurerm_lb.vmsslb.0.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = var.lb_diag_logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#     }
#   }
# }
