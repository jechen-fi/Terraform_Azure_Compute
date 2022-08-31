#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VMs
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key == true && local.os_type == "linux" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#----------------------------------------------------------
# Gather data for Resource Group, VNet, Subnet selection & Random Resources
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

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
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
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                           = 1
  name                            = "nic-${local.virtual_machine_name}"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.rg_location
  dns_servers                     = var.dns_servers
  enable_ip_forwarding            = var.enable_ip_forwarding
  enable_accelerated_networking   = var.enable_accelerated_networking
  tags                            = merge({ "ResourceName" = "nic-${replace(local.virtual_machine_name, "/[[:^alnum:]]/", "")}" }, var.tags, )
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
resource "azurerm_availability_set" "aset" {
  count                           = tobool(var.enable_feature[var.enable_av_set]) ? 1 : 0
  name                            = "avail-${local.virtual_machine_name}-${var.rg_location}"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.rg_location
  platform_fault_domain_count     = 2
  platform_update_domain_count    = 2
  managed                         = true
  tags                            = merge({ "ResourceName" = lower("avail-${local.virtual_machine_name}-${var.rg_location}") }, var.tags, )
}


#---------------------------------------
# Linux Virtual machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linuxvm" {
  depends_on                      = [azurerm_disk_encryption_set.des, azurerm_key_vault_access_policy.desKvPolicy]
  count                           = local.os_type == "linux" ? 1 : 0
  name                            = local.virtual_machine_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.rg_location
  size                            = var.virtual_machine_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids           = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  provision_vm_agent              = true
  allow_extension_operations      = true
  dedicated_host_id               = var.dedicated_host_id
  #availability_set_id             = var.enable_feature[var.enable_av_set] ? element(concat(azurerm_availability_set.aset.*.id, [""]), count.index) : null
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  tags                            = merge({ "ResourceName" = local.virtual_machine_name }, var.tags, )
  virtual_machine_scale_set_id    = var.vm_scale_set
  zone                            = var.zone
  priority                        = var.priority
  custom_data                     = var.custom_data

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
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
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
      name      = lookup(plan.value, "name", null)
      product   = lookup(plan.value, "product", null)
      publisher = lookup(plan.value, "publisher", null)
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
  count                      = local.os_type == "linux" ? 1 : 0
  type = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name = "dcrAzMonitorWindows"
  parent_id = azurerm_linux_virtual_machine.linuxvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionRuleId =  var.data_collection_rule
      description = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

resource "azapi_resource" "dce_association_linux" {
  count                      = local.os_type == "linux" ? 1 : 0
  type = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name = "configurationAccessEndpoint"
  parent_id = azurerm_linux_virtual_machine.linuxvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionEndpointId = var.data_collection_endpoint
      description = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

# resource "azurerm_template_deployment" "ama_linux_template" {
#   count               = local.os_type == "linux" ? 1 : 0
#   name                = "${random_string.str.result}-ama-linux-deployment"
#   depends_on          = [azurerm_linux_virtual_machine.linuxvm]
#   resource_group_name = data.azurerm_resource_group.rg.name
#   template_body       = file("${path.module}/ama_linuxvm_template.json",)
#   deployment_mode     = "Incremental"

#   parameters = {
#     vmName                 = local.virtual_machine_name
#     location               = var.rg_location
#     associationName        = "dcr_association_linux"
#     dataCollectionRuleId   = var.data_collection_rule
#     dataCollectionEndpointId = var.data_collection_endpoint
#     vmScope = azurerm_linux_virtual_machine.linuxvm[count.index].id
#   }
# }

# resource "azurerm_template_deployment" "ada_windows_template" {
#   count               = local.os_type == "linux" ? 1 : 0
#   name                = "${random_string.str.result}-ada-win-deployment"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   template_body       = file("${path.module}/ada_linuxvm_template.json",)
#   deployment_mode     = "Incremental"
#   depends_on          = [azurerm_linux_virtual_machine.linuxvm]

#   parameters = {
#     vmName                 = local.virtual_machine_name
#   }
# }

#---------------------------------------
# Windows Virtual machine
#---------------------------------------
resource "azurerm_windows_virtual_machine" "winvm" {
  depends_on = [azurerm_disk_encryption_set.des, azurerm_key_vault_access_policy.desKvPolicy]
  count                      = local.os_type == "windows" ? 1 : 0
  name                       = local.virtual_machine_name
  computer_name              = local.virtual_machine_name
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.rg_location
  size                       = var.virtual_machine_size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  network_interface_ids      = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  provision_vm_agent         = true
  allow_extension_operations = true
  dedicated_host_id          = var.dedicated_host_id
  license_type               = var.license_type
  #availability_set_id        = var.enable_feature[var.enable_av_set] ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  zone                       = var.zone
  tags                       = merge({ "ResourceName" = local.virtual_machine_name }, var.tags, )
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
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }
  dynamic "additional_capabilities" {
    for_each = var.ultrassd[*]
    content {
      ultra_ssd_enabled = lookup(additional_capabilities.value, "required", null)
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
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
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
  count                      = local.os_type == "windows" ? 1 : 0
  type = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name = "dcrAzMonitorWindows"
  parent_id = azurerm_windows_virtual_machine.winvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionRuleId =  var.data_collection_rule
      description = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

resource "azapi_resource" "dce_association_windows" {
  count                      = local.os_type == "windows" ? 1 : 0
  type = "Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview"
  name = "configurationAccessEndpoint"
  parent_id = azurerm_windows_virtual_machine.winvm[count.index].id
  body = jsonencode({
    properties = {
      dataCollectionEndpointId = var.data_collection_endpoint
      description = "Association of data collection rule. Deleting this association will break the data collection for this virtual machine"
    }
  })
}

# resource "azurerm_template_deployment" "ama_windows_template" {
#   count               = local.os_type == "windows" ? 1 : 0
#   name                = "${random_string.str.result}-ama-win-deployment"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   template_body       = file("${path.module}/ama_windowsvm_template.json",)
#   deployment_mode     = "Incremental"

#   parameters = {
#     vmName                 = local.virtual_machine_name
#     location               = var.rg_location
#     associationName        = "dcr_association_windows"
#     dataCollectionRuleId   = var.data_collection_rule
#     dataCollectionEndpointId = var.data_collection_endpoint
#     vmScope                  = azurerm_windows_virtual_machine.winvm[count.index].id
#   }
# }

# resource "azurerm_template_deployment" "ada_windows_template" {
#   count               = local.os_type == "windows" ? 1 : 0
#   name                = "${random_string.str.result}-ada-win-deployment"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   template_body       = file("${path.module}/ada_windowsvm_template.json",)
#   deployment_mode     = "Incremental"
#   depends_on          = [azurerm_windows_virtual_machine.winvm]

#   parameters = {
#     vmName                 = local.virtual_machine_name
#   }
# }

#---------------------------------------
# Virtual Machine Data Disks
#---------------------------------------
resource "azurerm_managed_disk" "data_disk" {
  for_each             = local.vm_data_disks
  name                 = "${local.virtual_machine_name}_DataDisk_${each.value.idx}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = var.rg_location
  storage_account_type = lookup(each.value.data_disk, "storage_account_type", "StandardSSD_LRS")
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk.disk_size_gb
  zones                = var.zones
  tags                 = merge({ "ResourceName" = local.virtual_machine_name }, var.tags, )
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
  key_vault_id    = data.azurerm_key_vault.kv.id
  key_type        = "RSA"
  key_size        = 2048
  expiration_date = time_rotating.cmk_expiration.rotation_rfc3339
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
}

# Enabling KeyVault Access Policy for DES
resource "azurerm_key_vault_access_policy" "desKvPolicy" {
  depends_on   = [azurerm_disk_encryption_set.des]
  key_vault_id = data.azurerm_key_vault.kv.id
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

# # Create a Reader role for DES on the KeyVault
# resource "azurerm_role_assignment" "desRole" {
#   depends_on           = [azurerm_disk_encryption_set.des, azurerm_key_vault_access_policy.desKvPolicy]
#   role_definition_name = "Reader"
#   scope                = var.scope
#   principal_id         = azurerm_disk_encryption_set.des.identity.0.principal_id
# }


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
#   name                       = lower("nsg-${local.virtual_machine_name}-diag")
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
