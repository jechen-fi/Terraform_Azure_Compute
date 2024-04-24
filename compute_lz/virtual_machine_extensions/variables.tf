variable "global_settings" {
  description = "Global settings object"
  default     = {}
}
variable "tags" {
  description = "Custom tags for the resource"
  default     = {}
}
variable "virtual_machine_id" {
  description = "The ID of the Virtual Machine"
  type        = string
}
variable "extension" {
  description = "Configuration settings object for the Virtual Machine Extension resource"
}
variable "extension_name" {
  description = "The name of the extension which is used to determine extension script in this module"
  type        = string
}
variable "settings" {
  description = "Configuration sub-settings object for the Virtual Machine Extension resource"
  default     = {}
}
variable "virtual_machine_os_type" {
  description = "VM OS Type"
  default     = {}
}
variable "keyvault_id" {
  description = "Keyvault ID"
  type        = string
  default     = null
}
variable "keyvaults" {
  description = "Keyvault module object to store the SSH public and private keys when not provided by the var.public_key_pem_file or retrieve admin username and password"
  default     = {}
}
variable "avd_host_pools" {
  description = "Azure Virtual Desktop Pools module object"
  default     = {}
}
variable "managed_identities" {
  description = "Managed Identities module object"
  default     = {}
}
variable "storage_accounts" {
  description = "Storage Accounts module object"
  default     = {}
}
variable "vm_admin_username" {
  description = "The VM Local Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable."
  type        = string
  default     = null
}
variable "vm_admin_password" {
  description = "The VM Local Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended). This value is used to domain join a VM."
  type        = string
  default     = null
}
variable "vm_domain_username" {
  description = "The VM Domain Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable. This value is used to domain join a VM."
  type        = string
  default     = null
}
variable "vm_domain_password" {
  description = "The VM Domain User Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended). This value is used to domain join a VM."
  type        = string
  default     = null
}
variable "ad_domain_name" {
  description = "Specifies the fully qualified domain name (FQDN) for the domain where the domain controller is installed or added"
  type        = string
  default     = null
}
variable "ad_domain_mode" {
  description = "Specifies the domain functional level of the first domain in the creation of a new forest. Supported values for this parameter can be either a valid integer or a corresponding enumerated string value. For instance, to set the domain mode level to Windows Server 2008 R2, you can specify either a value of 4 or Win2008R2."
  type        = string
  default     = null
}
variable "ad_netbios_name" {
  description = "Specifies the NetBIOS name for the root domain in the new forest. For NetBIOS names to be valid for use with this parameter they must be single label names of 15 characters or less"
  type        = string
  default     = null
}
variable "ad_install_forest" {
  description = "Flag to determine if new Domain Controller will be primary server = new forest. Assume YES"
  type        = bool
  default     = true
}
variable "virtual_machine_name" {
  description = "The Name of the Virtual Machine"
  type        = string
  default     = null
}
variable "resource_group_name" {
  description = "The name of the resource group where the VM is provisioned"
  type        = string
  default     = null
}
variable "location" {
  description = "Specifies the supported Azure location where the VM is provisioned"
  type        = string
  default     = null
}
