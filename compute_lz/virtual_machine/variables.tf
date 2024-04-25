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
  description = "Configuration settings object for the Virtual Machine resource"
}
variable "keyvaults" {
  description = "Keyvault module object to store the SSH public and private keys when not provided by the var.public_key_pem_file or retrieve admin username and password"
  default     = null
}
variable "boot_diagnostics_storage_account" {
  description = "The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor"
  type        = string
  default     = null
}
variable "virtual_networks" {
  description = "Virtual Networks module object"
}
variable "public_key_pem_file" {
  description = "If disable_password_authentication is set to true, ssh authentication is enabled. You can provide a list of file path of the public ssh key in PEM format. If left blank a new RSA/4096 key is created and the key is stored in the keyvault_id. The secret name being the {computer name}-ssh-public and {computer name}-ssh-private"
  type        = string
  default     = ""
}
variable "managed_identities" {
  description = "Managed Identity module object"
  default     = {}
}
variable "public_ip_addresses" {
  description = "Public IP Addresses module object"
  default     = {}
}
variable "recovery_vaults" {
  description = "Recovery Vaults module object"
  default     = {}
}
variable "storage_accounts" {
  description = "Storage Accounts module object"
  default     = {}
}
variable "availability_sets" {
  description = "Availability Sets module object"
  default     = {}
}
variable "proximity_placement_groups" {
  description = "Map of IDs of the Proximity Placement Group to which this Virtual Machine should be assigned."
  default     = {}
}
variable "disk_encryption_sets" {
  description = "Disk Encryption Set module object"
  default     = {}
}
variable "application_security_groups" {
  description = "Application Security Groups module object"
  default     = {}
}
variable "custom_image_ids" {
  description = "Custom Image IDs module object"
  default     = {}
}
variable "network_security_groups" {
  description = "NSGs to be attached to a nic"
  default     = {}
}
variable "dedicated_hosts" {
  description = "Dedicated Hosts module object"
  default     = {}
}
variable "admin_username" {
  description = "The VM Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable"
  type        = string
  default     = null
}
variable "admin_password" {
  description = "The VM Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended)"
  type        = string
  default     = null
}
variable "vm_count" {
  description = "Custom variable used in virtual_machine_groups (module in calling repo) that will create X nbr of VMs with custom name"
  type        = string
  default     = "0"
}
variable "vm_name_prefix" {
  description = "Custom variable used in virtual_machine_groups (module in calling repo) that will create X nbr of VMs with custom name"
  type        = string
  default     = null
}
variable "additional_settings" {
  description = "Custom settings for special use cases (i.e. ADC Controller config)"
  default     = {}
}

variable "keyvault_keys" {
  description = "Keyvault Keys module object"
  default     = {}
}
variable "keyvault_secrets" {
  description = "Keyvault Secrets module object"
  default     = {}
}
