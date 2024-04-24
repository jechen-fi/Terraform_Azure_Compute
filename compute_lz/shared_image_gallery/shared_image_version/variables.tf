variable "global_settings" {
  description = "Global settings object"
}
variable "resource_group_name" {
  description = "The name of the resource group in which the resource is created"
  type        = string
}
variable "tags" {
  description = "Custom tags for the resource"
  default     = {}
}
variable "location" {
  description = "Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global_settings.location value."
  type        = string
  default     = null
}
variable "settings" {
  description = "Configuration settings object for the resource"
}
variable "gallery_name" {
  description = "The name of the Shared Image Gallery in which the Shared Image exists"
  type        = string
}
variable "image_name" {
  description = "The name of the Shared Image within the Shared Image Gallery in which this Version should be created"
  type        = string
}
variable "managed_image_id" {
  description = "The ID of the Managed Image or Virtual Machine ID which should be used for this Shared Image Version"
  type        = string
  default     = null
}
variable "storage_accounts" {
  description = "Storage Accounts module object"
  default     = {}
}
