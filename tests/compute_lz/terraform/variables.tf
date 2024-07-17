variable "admin_username" {
  description = "The VM Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable"
  type        = string
  default     = "vmosadmin"
}
variable "admin_password" {
  description = "The VM Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended)"
  type        = string
  default     = "Test@123456user"
}

variable "tenant_id" {}
