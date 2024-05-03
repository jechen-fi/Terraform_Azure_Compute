variable "name" {
  description = "(Required) The version number for this Image Version, such as 1.0.0."
}

variable "gallery_name" {
  description = "(Required) The name of the Shared Image Gallery in which the Shared Image exists."
}

variable "shared_image_name" {
  description = "(Required) The name of the Resource Group in which the Shared Image Gallery exists."
}

variable "resource_group_name" {
  description = "(Required) Resource group for the shared image gallery."
}

variable "location" {
  description = "(Required) The Azure Region in which the Shared Image Gallery exists."
}

variable "target_region" {
  description = "(Required) configuration of the shared image version target region"  
}

variable "tags" {
  description = "(Optional) map of the tags associated with shared image gallery version."
  default     = null
}

variable "managed_image_id" {
  description = "(Required) The ID of the Managed Image or Virtual Machine ID which should be used for this Shared Image Version."
}

variable "shared_image_version_config" {
  description = "(Optional) Configuration of the shared image version"
  default     = {}
}


