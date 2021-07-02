#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's (Dev Environment only)
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key == true && local.os_type == "linux" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#----------------------------------------------------------
# Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.resource_group_vnet
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.vm_storage_account != null ? 1 : 0
  name                = var.vm_storage_account
  resource_group_name = data.azurerm_resource_group.rg.name
}

# resource "random_password" "passwd" {
#   count       = var.disable_password_authentication != true || local.os_type == "windows" && var.admin_password == null ? 1 : 0
#   length      = 24
#   min_upper   = 4
#   min_lower   = 2
#   min_numeric = 4
#   special     = false

#   keepers = {
#     admin_password = local.os_type
#   }
# }

resource "random_string" "str" {
  count   = tobool(var.enable_feature[var.enable_public_ip_address]) ? var.instances_count : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = var.virtual_machine_name
  }
}

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.enable_feature[var.enable_public_ip_address] ? var.instances_count : 0
  name                = lower("pip-vm-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}-0${count.index + 1}")
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), random_string.str[count.index].result)
  tags                = merge({ "ResourceName" = lower("pip-vm-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}-0${count.index + 1}") }, var.tags, )
}

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                         = var.instances_count
  name                          = var.instances_count == "1" ? format("nic-%s%02d", lower(var.virtual_machine_name), 1) : format("nic-%s%02d", lower(var.virtual_machine_name), count.index + 1)
  #name                          = var.instances_count == "1" ? lower("nic-${format("%s%02d", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")))}") : lower("nic-${format("%s%02d", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  tags                          = merge({ "ResourceName" = var.instances_count == 1 ? lower("nic-${format("%s%02d", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), 1)}") : lower("nic-${format("%s%02d", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}") }, var.tags, )
# The ip configuration portion is planned to be converted to dynamic soon
  ip_configuration {
    name                          = var.instances_count == "1" ? format("ipconfig-%s%02d", lower(var.virtual_machine_name), 1) : format("ipconfig-%s%02d", lower(var.virtual_machine_name), count.index + 1)
    primary                       = true
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? element(concat(var.private_ip_address, [""]), count.index) : null
    public_ip_address_id          = tobool(var.enable_feature[var.enable_public_ip_address]) ? element(concat(azurerm_public_ip.pip.*.id, [""]), count.index) : null
    private_ip_address_allocation = var.private_ip_address_allocation_type
  }
}
resource "azurerm_availability_set" "aset" {
  count                        = tobool(var.enable_feature[var.enable_av_set]) ? 1 : 0
  name                         = lower("avail-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}")
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = merge({ "ResourceName" = lower("avail-${var.virtual_machine_name}-${data.azurerm_resource_group.rg.location}") }, var.tags, )
}

# ---------------------------------------------------------------
# Network security group for Virtual Machine Network Interface
# ---------------------------------------------------------------
# resource "azurerm_network_security_group" "nsg" {
#   name                = lower("nsg_${var.virtual_machine_name}_${data.azurerm_resource_group.rg.location}_in")
#   resource_group_name = data.azurerm_resource_group.rg.name
#   location            = data.azurerm_resource_group.rg.location
#   tags                = merge({ "ResourceName" = lower("nsg_${var.virtual_machine_name}_${data.azurerm_resource_group.rg.location}_in") }, var.tags, )
# }
# resource "azurerm_network_security_rule" "nsg_rule" {
#   for_each                    = local.nsg_inbound_rules
#   name                        = each.key
#   priority                    = 100 * (each.value.idx + 1)
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = each.value.security_rule.destination_port_range
#   source_address_prefix       = each.value.security_rule.source_address_prefix
#   destination_address_prefix  = element(concat(data.azurerm_subnet.snet.address_prefixes, [""]), 0)
#   description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
#   resource_group_name         = data.azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.nsg.name
#   depends_on                  = [azurerm_network_security_group.nsg]
# }
# resource "azurerm_network_interface_security_group_association" "nsgassoc" {
#   count                     = var.instances_count
#   network_interface_id      = element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }
#---------------------------------------
# Linux Virtual machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linuxvm" {
  count                            = local.os_type == "linux" ? var.instances_count : 0
  name                             = var.instances_count == "1" ? format("%s%02d", lower(var.virtual_machine_name), 1) : format("%s%02d", lower(var.virtual_machine_name), count.index + 1)
  #name                             = var.instances_count == "1" ? join("", [var.virtual_machine_name, "01"]) : format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = data.azurerm_resource_group.rg.location
  size                             = var.virtual_machine_size
  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
  #admin_password                   = var.disable_password_authentication != true && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  disable_password_authentication  = var.disable_password_authentication
  network_interface_ids            = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id                  = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent               = true
  allow_extension_operations       = true
  dedicated_host_id                = var.dedicated_host_id
  availability_set_id              = tobool(var.enable_feature[var.enable_av_set]) ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  encryption_at_host_enabled       = var.encryption_at_host_enabled
  tags                             = merge({ "ResourceName" = var.instances_count == 1 ? format("%s%02d", lower(var.virtual_machine_name), 1) : format("%s%02d", lower(var.virtual_machine_name), count.index + 1) }, var.tags, )
  virtual_machine_scale_set_id     = var.vm_scale_set
  zone                             = var.zone
  priority                         = var.priority
  custom_data                      = base64encode(<<-EOT
                                                  #!/bin/bash
                                                  /bin/echo Test custom data here - the time is now $(/bin/date -R)! | /bin/tee /tmp/custom.out
                                                  EOT
                                                  )
  
  dynamic "additional_capabilities" {
    for_each = var.ultrassd[*]
    content {
      ultra_ssd_enabled = lookup(additional_capabilities.value, "required", null)
    }
  }
  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_key[*]
    content {
      username   = var.admin_username
      public_key = lookup(admin_ssh_key.value, "public_key", null)
      # var.generate_admin_ssh_key == true && local.os_type == "linux" ? tls_private_key.rsa[0].public_key_openssh : file(var.admin_ssh_key_data)
    }
  }
  dynamic "boot_diagnostics" {
    for_each = var.boot_diag[*]
    content {
      # below ensures boot diag is stored in a managed storage account
      storage_account_uri = lookup(boot_diagnostics.value, "storage_uri", null)
    }
  }
  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type             = lookup(identity.value, "type", null)
      identity_ids     = lookup(identity.value, "identity_ids", null)
    }
  }
  dynamic "secret" {
    for_each = var.secret[*]
    content {
      dynamic "certificate" {
        for_each = var.certsecret[*]
        content {
          url       = lookup(certificate.value, "url", null)
        }
      }
      key_vault_id  = lookup(secret.value, "key_vault_id", null)
    }
  }
  dynamic "source_image_reference" {
    for_each = var.os_distribution_list[var.os_distribution][*]
    content {
      publisher = lookup(source_image_reference.value, "publisher", null)
      offer     = lookup(source_image_reference.value, "offer", null)
      sku       = lookup(source_image_reference.value, "sku", null)
      version   = lookup(source_image_reference.value, "version", null)
    }
  }
  dynamic "plan" {
    for_each = var.plan[*]
    content {
      name          = lookup(plan.value, "name", null)
      product       = lookup(plan.value, "product", null)
      publisher     = lookup(plan.value, "publisher", null)
    }
  }
  dynamic "os_disk" {
    for_each = var.os_disk[local.os_type][*]
    #for_each = var.os_disk[local.os_type][*]
    content {
      name                       = lookup(os_disk.value, "name", null)
      disk_size_gb               = lookup(os_disk.value, "disk_size_gb", null)
      storage_account_type       = lookup(os_disk.value, "storage_account_type", null)
      caching                    = lookup(os_disk.value, "caching", null)
      disk_encryption_set_id     = lookup(os_disk.value, "disk_encryption_set_id", null)
      write_accelerator_enabled  = lookup(os_disk.value, "write_accelerator_enabled", null)
    }
  }
}
#---------------------------------------
# Windows Virtual machine
#---------------------------------------
resource "azurerm_windows_virtual_machine" "winvm" {
  count                      = local.os_type == "windows" ? var.instances_count : 0
  name                       = var.instances_count == "1" ? format("%s%02d", lower(var.virtual_machine_name), 1) : format("%s%02d", lower(var.virtual_machine_name), count.index + 1)
  #name                       = var.instances_count == 1 ? var.virtual_machine_name : format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)
  computer_name              = var.instances_count == "1" ? format("%s%02d", lower(var.virtual_machine_name), 1) : format("%s%02d", lower(var.virtual_machine_name), count.index + 1)
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  size                       = var.virtual_machine_size
  admin_username             = var.admin_username
  #admin_password             = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  admin_password             = var.admin_password
  network_interface_ids      = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id            = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent         = true
  allow_extension_operations = true
  dedicated_host_id          = var.dedicated_host_id
  license_type               = var.license_type
  availability_set_id        = tobool(var.enable_feature[var.enable_av_set]) ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  tags                       = merge({ "ResourceName" = var.instances_count == 1 ? format("%s%02d", lower(var.virtual_machine_name), 1) : format("%s%02d", lower(var.virtual_machine_name), count.index + 1) }, var.tags, )
  dynamic "source_image_reference" {
    for_each = var.os_distribution_list[var.os_distribution][*]
    content {
      publisher = lookup(source_image_reference.value, "publisher", null)
      offer     = lookup(source_image_reference.value, "offer", null)
      sku       = lookup(source_image_reference.value, "sku", null)
      version   = lookup(source_image_reference.value, "version", null)
    }
  }
  os_disk {
    storage_account_type = var.os_disk["windows"]["storage_account_type"]
    caching              = var.os_disk["windows"]["caching"]
  }
}
#--------------------------------------------------------------
# Azure Log Analytics Workspace Agent Installation for windows
#--------------------------------------------------------------
# resource "azurerm_virtual_machine_extension" "omsagentwin" {
#   count                      = var.log_analytics_workspace_name != null && local.os_type == "windows" ? var.instances_count : 0
#   name                       = var.instances_count == 1 ? "OmsAgentForWindows" : format("%s%s", "OmsAgentForWindows", count.index + 1)
#   virtual_machine_id         = azurerm_windows_virtual_machine.win_vm[count.index].id
#   publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
#   type                       = "MicrosoftMonitoringAgent"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   settings = <<SETTINGS
#     {
#       "workspaceId": "${data.azurerm_log_analytics_workspace.logws.0.workspace_id}"
#     }
#   SETTINGS
#   protected_settings = <<PROTECTED_SETTINGS
#     {
#     "workspaceKey": "${data.azurerm_log_analytics_workspace.logws.0.primary_shared_key}"
#     }
#   PROTECTED_SETTINGS
# }
#--------------------------------------------------------------
# Azure Log Analytics Workspace Agent Installation for Linux
#--------------------------------------------------------------
# resource "azurerm_virtual_machine_extension" "omsagentlinux" {
#   count                      = var.log_analytics_workspace_name != null && local.os_type == "linux" ? var.instances_count : 0
#   name                       = var.instances_count == 1 ? "OmsAgentForLinux" : format("%s%s", "OmsAgentForLinux", count.index + 1)
#   virtual_machine_id         = azurerm_linux_virtual_machine.linux_vm[count.index].id
#   publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
#   type                       = "OmsAgentForLinux"
#   type_handler_version       = "1.13"
#   auto_upgrade_minor_version = true
#   settings = <<SETTINGS
#     {
#       "workspaceId": "${data.azurerm_log_analytics_workspace.logws.0.workspace_id}"
#     }
#   SETTINGS
#   protected_settings = <<PROTECTED_SETTINGS
#     {
#     "workspaceKey": "${data.azurerm_log_analytics_workspace.logws.0.primary_shared_key}"
#     }
#   PROTECTED_SETTINGS
# }
#--------------------------------------
# azurerm monitoring diagnostics 
#--------------------------------------
# resource "azurerm_monitor_diagnostic_setting" "nsg" {
#   count                      = var.log_analytics_workspace_name != null && var.vm_storage_account != null ? 1 : 0
#   name                       = lower("nsg-${var.virtual_machine_name}-diag")
#   target_resource_id         = azurerm_network_security_group.nsg.id
#   storage_account_id         = data.azurerm_storage_account.storeacc.0.id
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logws.0.id
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
