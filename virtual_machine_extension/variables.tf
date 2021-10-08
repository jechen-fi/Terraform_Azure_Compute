variable "auto_upgrade" {
  description = "Optional. Value to determine whether to automatically run / upgrade to use of the latest extension available. Value needs to be true/false."
  type        = bool
  default     = false
}

variable "azure_vm_id" {
  description = "Required. The ID of the virtual machine that this module will be running / applying the extension onto"
  default     = null
}

variable "command_run_script" {
  description = "Required. Command to run script that will be downloaded or pulled down."
  default     = null
}

variable "extension_type" {
  description = "Required. Type of virtual machine extension"
  type        = string
  default     = "CustomScriptExtension"
}

variable "extension_type_version" {
  description = "Required. Version of the virtual machine extension type."
  type        = string
  default     = "1.10"
}

variable "managed_identity" {
  description = "Required.  This variable has multiple options - if it is passed in as '{ }' only, it will use a system-assigned managed identity.  If it is to use a user-assigned managed identity, it needs either the objectId or clientId of the user-assigned identity."
  default     = null
  # ex. default = "{ \"objectId\": \"abcde1f2-3gh4-5678-i9jk-0l1m2o34p567\" }"
  # (optional, json object) the managed identity for downloading file(s)
  #   {} --> if empty brackets are provided, the machine will assume a system-assigned managed identity for the authentication
  #   clientId: (optional, string) the client ID of the managed identity
  #   objectId: (optional, string) the object ID of the managed identity
}

variable "name_vmextension" {
  description = "Required. The name of the vm extension resource provided by the user for deployment in Azure.  This should follow FI's Azure naming standards in confluence."
  default     = null
}

variable "publisher" {
  description = "Required. Publisher for the virtual machine extension being used."
  type        = string
  default     = "Microsoft.Compute"
}

variable "script_uri" {
  description = "Required. Command to run script that will be downloaded or pulled down."
  default     = null
}

variable "tags" {
  description = "Azure tags to appropriately label the resource"
  type        = map(any)
  default     = null
}