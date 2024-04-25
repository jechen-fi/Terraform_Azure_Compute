variable "settings" {
  description = "Configuration settings object for the resource"
}
variable "gallery_name" {
  description = "Specifies the name of the Shared Image Gallery in which this Shared Image should exist"
  type        = string
  default     = null
}
