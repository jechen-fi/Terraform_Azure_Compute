variable "global_settings" {
  description = "Global settings object"
}
variable "resource_group_name" {
  description = "The name of the resource group in which the resource is created"
  type        = string
}
variable "location" {
  description = "Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global_settings.location value."
  type        = string
  default     = null
}
variable "tags" {
  description = "Custom tags for the resource"
  default     = {}
}
variable "settings" {
  description = "Configuration settings object for the Disk Encryption Set resource"
}
variable "key_vault_key_ids" {
  description = "Keyvault Key IDs map - Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret)"
  default     = {}
}
variable "keyvault_id" {
  description = "Key Vault resource ID"
  type        = string
}
