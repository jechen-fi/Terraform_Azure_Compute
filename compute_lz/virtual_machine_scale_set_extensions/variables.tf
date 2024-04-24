variable "virtual_machine_scale_set_id" {
  description = "The ID of the Virtual Machine Scale Set"
  type        = string
}
variable "extension" {
  description = "Configuration settings object for the extension resource"
}
variable "extension_name" {
  description = "Name of extension type to be used for resource set up"
  type        = string
}
variable "managed_identities" {
  description = "Managed Identities module object"
  default     = {}
}
variable "storage_accounts" {
  description = "Storage Accounts module object"
  default     = {}
}
variable "keyvault_id" {
  description = "Keyvault ID (Overrides option to retrieve keyvault ID from var.keyvaults)"
  type        = string
  default     = null
}
variable "keyvaults" {
  description = "Keyvault module object (used if not explicitly passing var.keyvault_id)"
  default     = {}
}
variable "virtual_machine_scale_set_os_type" {
  description = "VMSS OS Type (linux/windows)"
  type        = string
}
