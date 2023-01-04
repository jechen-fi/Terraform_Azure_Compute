## Azure Virtual Machines Scale Sets Terraform Module

Terraform generalized module to deploy linux or windows virtual machines scale set . Azure virtual machine scale sets let you create and manage a group of identical, load balanced VMs. The number of VM instances can automatically increase or decrease in response to demand if autoscaleing is enabled.

## Requirements

| Name (providers)   | Version            |
|--------------------|--------------------|
| azurerm            | >= 2.95.0          |
| tls                | >= 3.1.0           |
| random             | >= 3.1.0           |
| terraform          | >= 0.15.5          |

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`resource_group_name` | The name of the resource group in which resources are created | string | `""`
`virtual_network_name`|The name of the virtual network|string |`""`
`subnet_name`|The name of the subnet to use in VM scale set|string |`""`
`storage_account_name`|The name of the hub storage account to store logs|string | `""`
`public_ip_allocation_method`|Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic`|string|`Static`
`public_ip_sku`|The SKU of the Public IP. Accepted values are `Basic` and `Standard`|string|`Standard`
`public_ip_sku_tier`|The SKU Tier that should be used for the Public IP. Possible values are `Regional` and `Global`|string|`"Regional"`
`enable_load_balancer`|Controls if public load balancer should be created|sting|`true`
`load_balancer_type`|Controls the type of load balancer should be created. Possible values are `public` and `private`|string | `"private"`
`load_balancer_sku`|The SKU of the Azure Load Balancer. Accepted values are `Basic` and `Standard`|string | `"Standard"`
`private_ip_address_allocation_type`|The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`.|string|`Dynamic`
`lb_private_ip_address`|The Static Private IP Address to assign to the Load Balancer. This is valid only when `private_ip_address_allocation_type` is set to `Static` only|string|`null`
`lb_probe_protocol`|Specifies the protocol of the end point. Possible values are `Http`, `Https` or `Tcp`. If `Tcp` is specified, a received ACK is required for the probe to be successful. If `Http` is specified, a `200 OK` response from the specified `URI` is required for the probe to be successful|string|`null`
`lb_probe_request_path`|The URI used for requesting health status from the backend endpoint. Required if protocol is set to `Http` or `Https`. Otherwise, it is not allowed|string|`null`
`number_of_probes`|The number of failed probe attempts after which the backend endpoint is removed from rotation. The default value is `2`. `NumberOfProbes` multiplied by `intervalInSeconds` value must be greater or equal to 10.Endpoints are returned to rotation when at least one probe is successful|number|`null`
`load_balancer_health_probe_port`|Port on which the Probe queries the backend endpoint. Default `80`|number|`80`
`load_balanced_port_list`|List of ports to be forwarded through the load balancer to the VMs|list|`[]`
`enable_proximity_placement_group`|Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets|string|`false`
`os_type`|Specify the  of the operating system image to deploy Virtual Machine. Possible values are `windows` and `linux`|string |`"windows"`
`computer_name_prefix`|Specifies the name of the virtual machine inside the VM scale set|string|`null`
`virtual_machine_size`|The Virtual Machine SKU for the Virtual Machine|string|`"Standard_A2_v2"`
`instances_count`|The number of Virtual Machines required|number|`2`
`admin_username`|The username of the local administrator used for the Virtual Machine|string|`"azureadmin"`
`admin_password`|The Password which should be used for the local-administrator on the Virtual Machines|string|`null`
`custom_data`|Base64 encoded file of a bash script that gets run once by cloud-init upon VM scale set creation|string|`null`
`disable_password_authentication`|Should Password Authentication be disabled on this Virtual Machine scale sets?|string|`true`
`overprovision`|Should Azure over-provision Virtual Machines in this Scale Set? This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota. Defaults to true|string|`false`
`do_not_run_extensions_on_overprovisioned_machines`|Should Virtual Machine Extensions be run on Overprovisioned Virtual Machines in the Scale Set?|string|`false`
`enable_windows_vm_automatic_updates`|Are automatic updates enabled for Windows Virtual Machine in this scale set? Module keep this as `false` if `os_upgrade_mode = "Automatic"` specified.|string|`true`
`enable_encryption_at_host`|Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?|string|`false`
`license_type`|Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are `None`, `Windows_Client` and `Windows_Server`.|string|`"None"`
`platform_fault_domain_count`|Specifies the number of fault domains that are used by this Linux Virtual Machine Scale Set|number|`null`
`scale_in_policy`|The scale-in policy rule that decides which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Possible values for the scale-in policy rules are `Default`, `NewestVM` and `OldestVM`|string|`"Default"`
`single_placement_group`|Allow to have cluster of 100 VMs only per VM scale set|string|`true`
`source_image_id`|The ID of an Image which each Virtual Machine should be based on|string|`null`
`os_upgrade_mode`|Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are `Automatic`, `Manual` and `Rolling`.|string|`Automatic`
`vm_time_zone`|Specifies the Time Zone which should be used by the Virtual Machine. Ex. `"UTC"` or `"W. Europe Standard Time"` [The possible values are defined here](https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/) |string|`null`
`availability_zones`|A list of Availability Zones in which the Virtual Machines in this Scale Set should be created in|list(number)|`null`
`os_distribution`|Pre-defined Azure Windows VM images list|map(object)|`"windows2019"`
`availability_zone_balance`|Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones?|string|`false`
`generate_admin_ssh_key`|Generates a secure private key and encodes it as PEM|string|`false`
`admin_ssh_key_data`|specify the path to the existing SSH key to authenticate Linux virtual machine|string|`null`
`identity` | A block supporting both "type (Required)" and "identity_ids (Optional) - the "type" of managed identity which should be assigned to the virtual machine, includes accepted values 'SystemAssigned, UserAssigned' - For identify_ids, it should be a list of user managed identity IDs assigned to the VM | `map` | `null` 
`os_disk_storage_account_type`|The Type of Storage Account for Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS.|string|`"StandardSSD_LRS"`
`os_disk_caching`|The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`|string|`"ReadWrite"`
`disk_encryption_set_id`|The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault|string|`null`
`disk_size_gb`|The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from|number|`null`
`enable_os_disk_write_accelerator`|Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`|string|`false`
`enable_ultra_ssd_data_disk_storage_support`|Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine|string|`false`
`additional_data_disks`|Adding additional disks capacity to add each instance (GB)|list(number)|`[]`
`additional_data_disks_storage_account_type`|The Type of Storage Account which should back this Data Disk. Possible values include Standard_LRS, StandardSSD_LRS, Premium_LRS and UltraSSD_LRS.|string|`"Standard_LRS"`
`enable_ip_forwarding`|Should IP Forwarding be enabled?|string|`false`
`enable_accelerated_networking`|Should Accelerated Networking be enabled?|string|`false`
`assign_public_ip_to_each_vm_in_vmss`|Create a virtual machine scale set that assigns a public IP address to each VM|string|`false`
`public_ip_prefix_id`|The ID of the Public IP Address Prefix from where Public IP Addresses should be allocated|string|`null`
`rolling_upgrade_policy`|Enabling automatic OS image upgrades on your scale set helps ease update management by safely and automatically upgrading the OS disk for all instances in the scale set|object|`{}`
`enable_automatic_instance_repair`|Should the automatic instance repair be enabled on this Virtual Machine Scale Set?|string|`false`
`grace_period`|Amount of time (in minutes, between 30 and 90, defaults to 30 minutes) for which automatic repairs will be delayed.|string|`"PT30M"`
`winrm_protocol`|Specifies the protocol of winrm listener. Possible values are `Http` or `Https`|string|`null`
`key_vault_certificate_secret_url`|The Secret URL of a Key Vault Certificate, which must be specified when `protocol` is set to `Https`|string|`null`
`additional_unattend_content`|The XML formatted content that is added to the unattend.xml file for the specified path and component|string|`null`
`additional_unattend_content_setting`|The name of the setting to which the content applies. Possible values are `AutoLogon` and `FirstLogonCommands`|string|`null`
`enable_boot_diagnostics`|Should the boot diagnostics enabled?|string|`false`
`storage_account_uri`|The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics|string|`null`
`enable_autoscale_for_vmss`|Manages a AutoScale Setting which can be applied to Virtual Machine Scale Sets|string|`false`
`minimum_instances_count`|The minimum number of instances for this resource. Valid values are between 0 and 1000|string|`null`
`maximum_instances_count`|The maximum number of instances for this resource. Valid values are between 0 and 1000|string|`""`
`scale_out_cpu_percentage_threshold`|Specifies the threshold % of the metric that triggers the scale out action.|number|`80`
`scale_in_cpu_percentage_threshold`|Specifies the threshold % of the metric that triggers the scale in action.|number|`20`
`scaling_action_instances_number`|The number of instances involved in the scaling action|number|`1`
`log_analytics_workspace_name`|The name of log analytics workspace resource |string|`null`
`tags`|A map of tags to add to all resources|map|`{}`
`data_collection_rule` | Data Collection Rules to be associated with Azure Monitoring Agent | `list(string)` | `null` 
`data_collection_endpoint` | Data Collection Endpoint to be associated with Azure Monitoring Agent | `string` | `null` 


## Outputs

|Name | Description|
|---- | -----------|
`load_balancer_private_ip`|The Private IP address allocated for load balancer
`linux_virtual_machine_scale_set_name`|The name of the Linux Virtual Machine Scale Set
`windows_virtual_machine_scale_set_name`|The name of the windows Virtual Machine Scale Set


## Example call to module

### main.tf
```HCL
# Recommend placing below lines would normally be placed in version.tf file instead of main.tf
#############################version.tf####################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.64.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.0"
    }
  }
  required_version = ">= 0.14.1, < 1.0.0"
}

provider "azurerm" {
  features {}
}

# Import Resource Group
data "azurerm_resource_group" "rg" {
  name = "rg-jtchoffo-sbx"
}

data "azurerm_key_vault" "serviceKV" {
  name = "rg-jimmyt-kv"
  resource_group_name = data.azurerm_resource_group.rg.name
}

#############################main.tf####################################

module "neoload_virtual_machine_scale_set" {
  source   = "./modules/Terraform_Azure_Compute/virtual_machine_scale_set"
  virtual_network_name          = "${var.app_id}-${var.vnet_name}-${var.environment}"
  subnet_name                   = "${var.app_id}-${var.subnet_name}-${var.environment}"
  virtual_machine_name          = "${var.app_id}-${var.vmscaleset_name}-${var.environment}"
  computer_name_prefix          = var.app_id
  boot_diag                     = local.neo_vm.boot_diag
  enable_boot_diagnostics       = true
  resource_group_name           = data.azurerm_resource_group.rg.name
  resource_group_vnet           = data.azurerm_resource_group.rg.name
  os_type                       = "windows"
  log_analytics_workspace_name    = var.log_analytics_workspace_name
  os_distribution               = var.os_distribution
  virtual_machine_size          = var.vmss_size
  instances_count               = 2
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  kv_id                         = data.azurerm_key_vault.servicekv1.id
  tags                          = local.tags
  #data_collection_rule          = ["/subscriptions/${var.subid_ctd}/resourceGroups/${var.dcr_resource_group_name}/providers/Microsoft.Insights/dataCollectionRules/${var.dcr_name[0]}"] 
  #data_collection_endpoint      = "/subscriptions/${var.subid_ctd}/resourceGroups/t00002-namespace-${var.dce_env}/providers/Microsoft.Insights/dataCollectionEndpoints/${var.dce_name}"
  rg_location                   = var.location
  availability_zones            = var.availability_zones
  zone                         = var.zones
  identity                      = local.neo_vm.identity
  enable_proximity_placement_group    = true
  assign_public_ip_to_each_vm_in_vmss = false
  enable_load_balancer                = false
  enable_automatic_instance_repair    = false
  enable_autoscale_for_vmss          = true
  os_upgrade_mode                    = "Manual"
  minimum_instances_count            = 2
  maximum_instances_count            = 5
  scale_out_cpu_percentage_threshold = 75
  additional_data_disks              = [200]
  additional_data_disks_storage_account_type = "Premium_LRS"
  scale_in_cpu_percentage_threshold  = 30
  os_disk = {
     windows = {
       name                      = null
       disk_size_gb              = 500
       storage_account_type      = "Premium_LRS"
       caching                   = "ReadWrite"
       disk_encryption_set_id    = null
       write_accelerator_enabled = null
     },
   }
}


