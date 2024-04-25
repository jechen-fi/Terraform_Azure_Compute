variable "global_settings" {
  description = "Global settings object"
}
variable "settings" {
  description = "Configuration settings object containing Virtual Machines"
}
variable "vm_count" {
  description = "Custom variable used in virtual_machine_groups module that will create X nbr of VMs"
  type        = number
  default     = 0
}
variable "vm_count_format" {
  description = "Custom variable used in virtual_machine_groups module that will format the VM name counter value"
  type        = string
  default     = "%01d"
}
variable "vm_count_start_index" {
  description = "Custom variable used in virtual_machine_groups module that will format the VM name counter value starting at zero"
  type        = number
  default     = 0
}
variable "vm_name_prefix" {
  description = "Custom variable used in virtual_machine_groups module that will create X nbr of VMs"
  type        = string
  default     = null
}
variable "vm_admin_username" {
  description = "VM local admin username object"
  type        = string
  default     = null
}
variable "vm_admin_password" {
  description = "VM local admin password object"
  type        = string
  default     = null
}
variable "vm_domain_username" {
  description = "VM domain username object"
  type        = string
  default     = null
}
variable "vm_domain_password" {
  description = "VM domain password object"
  type        = string
  default     = null
}
variable "resource_groups" {
  description = "Resource Groups object"
}
variable "networking" {
  description = "VNet object"
}
variable "keyvaults" {
  description = "Keyvault object"
  default     = null
}
variable "availability_sets" {
  description = "AV Sets object"
  default     = {}
}
variable "shared_images" {
  description = "Shared Images object"
  default     = {}
}
variable "storage_account" {
  description = "Storage Accounts object"
  default     = {}
}
variable "avd_host_pools" {
  description = "Host Pool object"
  default     = {}
}
variable "keyvault_keys" {
  description = "Keyvault Keys object"
  default     = {}
}
variable "application_security_groups" {
  description = "Application Security Groups module object"
  default     = {}
}
