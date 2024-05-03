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

variable "shared_image_gallery_config" {
  description = "(Optional) Configuration of the shared image gallery"
  default     = {}
}

variable "sharing" {
  default = null
}
