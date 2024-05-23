variable "deploy_image" {
  description = "Whether to create a custom virtual machine image that can be used to create virtual machines."
  default     = false
}

variable "image_name" {
  description = "Specifies the name of the image to be created."
  default     = null
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the resource."
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
}

variable "source_virtual_machine_id" {
  description = "The Virtual Machine ID from which to create the image."
  default     = null
}

variable "os_disk" {
  description = "(Optional) variable for os_disk block"
  default     = null
}

variable "data_disk" {
  description = "(Optional) variable for data_disk block"
  default     = null
}

variable "purchase_plan" {
  description = "(Optional) variable for purchase plan block"
  default     = null
}

variable "hyper_v_generation" {
  description = "The HyperVGenerationType of the VirtualMachine created from the image as V1, V2. Defaults to V1."
  default     = "V1"
}

variable "zone_resilient" {
  description = "Specifies whether zone resiliency should be enabled? Defaults to false"
  default     = false
}

variable "shrd_img_name" {
  description = "(Required) Name for the shared image."
}

variable "gallery_name" {
  description = "(Required) Name for the shared image gallery."
}

variable "identifier" {
  description = "(Required) Identifier config of the shared image"
}

variable "os_type" {
  description = "(Required) The type of Operating System present in this Shared Image. Possible values are Linux and Windows."
}

variable "tags" {
  description = "(Optional) map of the tags associated with the resource."
  default     = null
}

variable "shared_image_config" {
  description = "(Optional) Configuration of the shared image."
  default     = {}
}