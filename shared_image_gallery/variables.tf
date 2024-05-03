variable "name" {
  description = "(Required) Name for the shared image gallery."
}

variable "resource_group_name" {
  description = "(Required) Resource group for the shared image gallery."
}

variable "location" {
  description = "(Required) Location for the shared image gallery."
}

variable "tags" {
  description = "(Optional) map of the tags associated with shared image gallery."
  default     = null
}

variable "description" {
  description = "(Optional) A description for this Shared Image Gallery"
  default     = {}
}

variable "sharing" {
  description = "variable for sharing block"
  default     = null
}