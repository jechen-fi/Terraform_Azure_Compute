variable "sku_name_standard" {
  default = "Standard"
}

variable "location" {
  default = "westus3"
}

variable "environment" {
  default = "CTD"
}

variable "mgmt_subscription_id" {
  default = "5efbbb60-3241-492e-a125-47d13e025aa2"
}

variable "app_id" {
  default = "a00000"
}
variable "resource_group_name" {
  description = "Resource group name that holds VM, VM NIC, and related resources"
  default = "a00000-namespace-ctd"
}

variable "resource_group_vnet" {
  description = "Resource group name for the VM's virtual network"
  type        = string
  default = "a00000-namespace-ctd"
}

variable "virtual_network_name" {
  description = "Virtual network name that the VM, NIC & related resources live on"
  type        = string
  default = "a00000-network-ctd"
}

variable "subnet_name" {
  description = "Subnet name within the virtual network that resources will live on"
  default = "a00000-app1-ctd"
}

