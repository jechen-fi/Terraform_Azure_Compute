/*
variable "custom_data_file" {
  description = "Custom data file for running through cloud-init - passed in through TF root main.tf that calls this module"
  default = null
}
*/

variable "application_env" {
  description = ""
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name that holds VM, VM NIC, and related resources"
}

variable "resource_group_vnet" {
  description = "Resource group name for the VM's virtual network"
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual network name that the VM, NIC & related resources live on"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name within the virtual network that resources will live on"
}

variable "bootstrap_sub_name" {
  type = string
  description = "Subscription name for the bootstrap storage account"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name, if one is used for logs"
  default     = null
}

variable "vm_storage_account" {
  description = "Base VM storage account to store logs"
  type        = string
}

variable "virtual_machine_name" {
  description = "Virtual machine name provided by user or root main.tf that calls module"
  default     = null
}

variable "virtual_machine_name_prepend" {
  description = "Prepend to the VM's hostname - a string that follows the [app-function] name convention without the [-env] portion at the end, which will be added in module"
  default     = null
}

variable "virtual_machine_size" {
  description = "Virtual Machine SKU for the Virtual Machine"
  default     = "Standard_A2_v2"
}

# variable "instances_count" {
#   description = "The number of Virtual Machines required."
#   default     = 1
# }

variable "enable_ip_forwarding" {
  description = "Enable IP Forwarding or not? Defaults to False."
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Enable Accelerated Networking or not?? Defaults to false."
  default     = false
}

variable "ultrassd" {
  description = "Ability to enable additional capabilities for the VM to enable the support for use of the UltraSSD_LRS storage account type"
  type        = map(any)
  default = {
    "required" = false
  }
}

variable "private_ip_address_allocation_type" {
  description = "Private IP Address Allocation method used. Values should be Dynamic or Static."
  default     = "Dynamic"
  type        = string
}

variable "private_ip_address" {
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static`"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "A List of dns servers to use for network interface"
  default     = null
  type        = list(any)
  #  default     = []
}

variable "enable_av_set" {
  description = "Enable or disable virtual machine availability set"
  default     = "false"
}

variable "enable_feature" {
  description = "Manages turning other features on / off"
  type        = map(any)
  default = {
    "yes"   = true
    "y"     = true
    "true"  = true
    "no"    = false
    "n"     = false
    "false" = false
  }
}

variable "enable_public_ip_address" {
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = "false"
}

variable "priority" {
  description = "Specifies the priority of this VM.  Possible values are 'Regular' or 'Spot' - a change will force a new resource to be created"
  type        = string
  default     = "Regular"
}

variable "identity" {
  description = "Type of Managed Identity which should be assigned to the virtual machine. Possible values are SystemAssigned, UserAssigned, and SystemAssigned, UserAssigned"
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = null
  # {
  #   type         = null
  #   identity_ids = null
  # }
}

variable "win_vm_identity" {
  description = "Type of Managed Identity which should be assigned to the virtual machine. Possible values are SystemAssigned, UserAssigned, and SystemAssigned, UserAssigned"
  default     = null
}

variable "admin_ssh_key" {
  description = "Admin ssh key map variable to setup auth to VM via ssh keys"
  type        = map(any)
  default     = null
  sensitive   = true
}

variable "certsecret" {
  description = "the URL of a KV Certificate"
  type = object({
    url = string
  })
  default   = null
  sensitive = true
}

variable "secret" {
  description = "Block with info for one or more certsecret blocks defined above and the ID for a Key Vault from which all secrets should be sourced"
  type = object({
    key_vault_id = string
    certificate = object({
      url = string
    })
  })
  default   = null
  sensitive = true
}

variable "boot_diag" {
  description = "Whether or not to turn on boot diagnostics and proper settings"
  type        = map(any)
  default     = null
}

variable "plan" {
  description = "Whether or not to turn on boot diagnostics and proper settings"
  type        = map(any)
  default     = null
}

variable "os_distribution" {
  default     = "ubuntu18"
  description = "Variable to pick an OS flavor. Possible values include: ubuntu18, centos7, centos8, win2019, win2016, etc."
}

variable "os_distribution_list" {
  description = "Pre-defined Azure Linux VM images list"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
    os_type   = string
  }))

  default = {
    ubuntu20 = {
      "publisher" = "Canonical"
      "offer"     = "0001-com-ubuntu-server-focal"
      "sku"       = "20_04-lts-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    ubuntu18 = {
      "publisher" = "Canonical"
      "offer"     = "UbuntuServer"
      "sku"       = "18_04-lts-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    centos7 = {
      "publisher" = "OpenLogic"
      "offer"     = "CentOS-LVM"
      "sku"       = "7-lvm-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    centos8 = {
      "publisher" = "OpenLogic"
      "offer"     = "CentOS-LVM"
      "sku"       = "8-lvm-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    rhel7 = {
      "publisher" = "RedHat"
      "offer"     = "RHEL"
      "sku"       = "7lvm-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    rhel8 = {
      "publisher" = "RedHat"
      "offer"     = "RHEL"
      "sku"       = "8-lvm-gen2"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    coreos = {
      "publisher" = "CoreOS"
      "offer"     = "CoreOS"
      "sku"       = "Stable"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    mssql2019ent-rhel8 = {
      "publisher" = "MicrosoftSQLServer"
      "offer"     = "sql2019-rhel8"
      "sku"       = "enterprise"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    mssql2019std-rhel8 = {
      "publisher" = "MicrosoftSQLServer"
      "offer"     = "sql2019-rhel8"
      "sku"       = "standard"
      "version"   = "latest"
      "os_type"   = "linux"
    },

    mssql2019dev-rhel8 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-rhel8"
      sku       = "sqldev"
      version   = "latest"
      "os_type" = "linux"
    },

    mssql2019ent-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "enterprise"
      version   = "latest"
      "os_type" = "linux"
    },

    mssql2019std-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "standard"
      version   = "latest"
      "os_type" = "linux"
    },

    mssql2019dev-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "sqldev"
      version   = "latest"
      "os_type" = "linux"
    },

    win2016 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
      "os_type" = "windows"
    },

    windows2016 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
      "os_type" = "windows"
    },

    win2019 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
      "os_type" = "windows"
    },

    windows2019 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
      "os_type" = "windows"
    },

    windows2016dccore = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter-Server-Core"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2017exp = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "express"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2017dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "sqldev"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2017std = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "standard"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2017ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "enterprise"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2019std = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "standard"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2019dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "sqldev"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2019ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "enterprise"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2019ent-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "enterprise"
      version   = "latest"
      "os_type" = "windows"
    },

    mssql2019std-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "standard"
      version   = "latest"
      "os_type" = "windows"
    },
  }
}

variable "encryption_at_host_enabled" {
  description = "Variable to determine if all disks, including temp, attached to the VM should be encrypted by enabling 'Encryption at Host'"
  default     = "false"
}

# variable "os_disk_storage_account_type" {
#   description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
#   default     = "StandardSSD_LRS"
# }

variable "os_disk" {
  type = map(object({
    name                      = string
    disk_size_gb              = string
    storage_account_type      = string
    caching                   = string
    disk_encryption_set_id    = string
    write_accelerator_enabled = bool
  }))

  default = {
    linux = {
      name                      = null
      disk_size_gb              = null
      storage_account_type      = "StandardSSD_LRS"
      caching                   = "ReadWrite"
      disk_encryption_set_id    = null
      write_accelerator_enabled = null
    },
    windows = {
      name                      = null
      disk_size_gb              = null
      storage_account_type      = "StandardSSD_LRS"
      caching                   = "ReadWrite"
      disk_encryption_set_id    = null
      write_accelerator_enabled = null
    },
  }
}

variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
}

variable "admin_ssh_key_data" {
  description = "specify the path to the existing SSH key to authenticate Linux virtual machine"
  default     = ""
}

variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  default     = false
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  default     = null
  sensitive   = true
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  default     = null
  sensitive   = true
}

variable "nsg_inbound_rules" {
  description = "List of network rules to apply to network interface."
  default     = []
}

variable "dedicated_host_id" {
  description = "The ID of a Dedicated Host where this machine should be run on."
  default     = null
}

variable "vm_scale_set" {
  description = "Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within. Changing this forces a new resource to be created."
  default     = null
}

variable "zone" {
  description = "Optional - the Zone in which this VM should be created.  Changing this forces a new resource to be created."
  default     = null
}

variable "source_image_id" {
  description = "The optional source image id which the virtual machine should be created from - if this is null, you will have to use source_image_reference, instead"
  default     = null
}


variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}

variable "nsg_diag_logs" {
  description = "NSG Monitoring Category details for Azure Diagnostic setting"
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = null
}

locals {

  virtual_machine_name = try(lower(var.virtual_machine_name), lower(format("%s%s%s", var.virtual_machine_name_prepend, "-", var.application_env)))

  os_type = var.os_distribution_list[var.os_distribution]["os_type"]

  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }
}
