variable "settings" {
  description = "Configuration settings object for the resource"
}
variable "gallery_name" {
  description = "The name of the Shared Image Gallery in which the Shared Image exists"
  type        = string
  default     = null
}
variable "image_name" {
  description = "The name of the Shared Image within the Shared Image Gallery in which this Version should be created"
  type        = string
  default     = null
}
