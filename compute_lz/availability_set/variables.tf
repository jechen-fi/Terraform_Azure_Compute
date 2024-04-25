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
variable "availability_set" {
  description = "Configuration settings object for the Availability Set"
}
variable "ppg_id" {
  description = "The ID of the Proximity Placement Group to which this Virtual Machine should be assigned. Changing this forces a new resource to be created"
  default     = null
}
variable "proximity_placement_groups" {
  description = "Map of IDs of the Proximity Placement Group to which this Virtual Machine should be assigned."
  default     = {}
}