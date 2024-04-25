# Virtual Machine

## Default Naming Convention
```
# Name of the VM in the Azure Control Plane
vm_name_mask = "{vmnameprefix}{delimiter}{postfix}"
# Name of the Computer name
computer_name_mask = "{vmnameprefix}{delimiter}{postfix}"
# Name for the OS disk
osdisk_name_mask = "{vmnameprefix}{delimiter}{postfix}{delimiter}{osdisk}"
# Name for the Data disks
datadisk_name_mask = "{referenced_name}{delimiter}{datadisk}{delimiter}{postfix}"

Example Result: 
VM Name: AVAVM-001
Computer Name: AVAVM-001
OS Disk Name: AVAVM-001-OSDisk
Data Disk Name: AVAVM-001-DataDisk-001

Virtual Machines in Groups Naming (creates X nbr of VMs using a counter)
virtual_machine_settings:
  windows:
    naming_convention:
      name_mask: "{object_name_prefix}{delimiter}{object_count}"

Example VM Groups Result: 
VM Name: AVAVM-25
Computer Name: AVAVM-25

```

## Example Settings
```yaml
virtual_machines:
  vm1:
    resource_group_key: "monitoring"
    os_type: linux #options are linux, windows or legacy (azurerm_virtual_machine resource type)
    enabled: true
    provision_vm_agent: true    
    # the auto-generated ssh key in keyvault secret. Secret name being {VM name}-ssh-public and {VM name}-ssh-private
    keyvault_key: "kv1"

    network_interfaces:
      nic0:
        vm_setting_key: "linux" #required for vm name lookup
        vnet_key: "vnet1"
        subnet_key: "subnet1"
        primary: true
        naming_convention:
          postfix: "01"        
        enable_ip_forwarding: false
        # networking_interface_asg_associations:
        #   asgtest1:
        #     key: "asg1"

    virtual_machine_settings:
      linux:
        naming_convention:
          postfix: "01"

        availability_set_key: "avset1"
        size: "Standard_B2s"
        admin_username: "adminuser"
        #admin_password: ""
        disable_password_authentication: true

        # Value of the nic keys to attach the VM. The first one in the list is the default nic
        network_interface_keys: ["nic0"]

        os_disk:
          naming_convention:
            postfix: "01"
          caching: "ReadWrite"
          storage_account_type: "Standard_LRS"
        
        identity:
          type: "SystemAssigned" #SystemAssigned OR UserAssigned OR SystemAssigned, UserAssigned
        
        source_image_reference:
          publisher: "Canonical"
          offer: "UbuntuServer"
          sku: "18.04-LTS"
          version: "latest"

    data_disks:
      data1:
        vm_setting_key: "linux" #required for vm name lookup
        naming_convention:
          postfix: "01"
        storage_account_type: "Standard_LRS"
        # Only Empty is supported. More community contributions required to cover other scenarios
        create_option: "Empty"
        disk_size_gb: "10"
        lun: 0
        #zone: "1" # Only define if the location region supports Availability Zones
```

## Example VM Group Settings
```yaml
virtual_machine_groups:
  ITOps_group:
    vm_count: 2
    vm_name_prefix: "avaprditop"
    enabled: true # VM Group Enabled Flag
    virtual_machine:
      resource_group_key: "monitoring"
      os_type: windows
      provision_vm_agent: true
      tags:
        "Custom Tag1": "Custom Value1"

      network_interfaces:
        nic0:
          vm_setting_key: "windows"
          vnet_key: "vnet1"
          subnet_key: "subnet1"
          primary: true
          naming_convention:
            postfix: "01"
          enable_ip_forwarding: false

      virtual_machine_settings:
        windows:
          naming_convention:
            name_mask: "{object_name_prefix}{delimiter}{object_count}"
          size: "Standard_NC6s_v3"
          admin_username: "GET_FROM_VARIABLE_GROUP"
          admin_password: "GET_FROM_VARIABLE_GROUP" # Only used for testing! Recommended to use var.vm_admin_password
          license_type: "Windows_Client"
          network_interface_keys: ["nic0"]

          os_disk:
            naming_convention:
              postfix: "01"
            caching: "ReadWrite"
            storage_account_type: "Premium_LRS"

          ## Comment out source_image_reference and use custom_image_key for Shared Image Gallery Images
          # custom_image_key: "shrdimg_PersistentAVDImage"

          source_image_reference:
          publisher: "MicrosoftWindowsDesktop"
          offer: "windows11preview"
          sku: "win11-22h2-avd"
          version: "latest"

      data_disks:
        data1:
          vm_setting_key: "windows"
          naming_convention:
            name_mask: "disk{delimiter}{referenced_name}{delimiter}data{delimiter}01"
          storage_account_type: "StandardSSD_LRS"
          create_option: "Empty"
          disk_size_gb: "128"
          caching: "ReadOnly"
          lun: 0
        data2:
          vm_setting_key: "windows"
          naming_convention:
            name_mask: "disk{delimiter}{referenced_name}{delimiter}data{delimiter}02"
          storage_account_type: "StandardSSD_LRS"
          create_option: "Empty"
          disk_size_gb: "128"
          caching: "ReadOnly"
          lun: 1        
    virtual_machine_extensions:
        LegacyADLoginForWindows:
          enabled: true
          name: "LegacyADLoginForWindows"
          ad_domain_name: "avanade.com"
          ad_ou_path: "OU=AVD,OU=PROD,OU=Azure,DC=aadds,DC=avanadepoc,DC=com"
          domain_username: "GET_FROM_VARIABLE_GROUP"
          domain_password: "GET_FROM_VARIABLE_GROUP" # Only used for testing! Recommended to use var.vm_domain_password
        AADLoginForWindows:
          enabled: false
          name: "AADLoginForWindows"
```

## Example Module Reference

```yaml
module "virtual_machines" {
  source = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine"
  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.enabled, false) == true
  }

  global_settings             = local.settings
  settings                    = each.value
  resource_group_name         = local.resource_groups[each.value.resource_group_key].name
  tags                        = try(each.value.tags, null)
  virtual_networks            = local.networking
  keyvaults                   = module.keyvault_reused
  availability_sets           = module.availability_sets
  application_security_groups = module.app_security_groups_reused
}
```

## Example VM Groups Module Reference

VM Group logic creates multiple VMs derived by the vm_count value. It ignores local.settings.virtual_machine_groups instead contains a child virtual_machine object. Virtual Machine Extensions are at the root of the virtual machine group object, not under the virtual_machine. Individual VMs can still be created alongside this group module and all objects can be merged in the locals.tf.

```terraform
module "virtual_machine_groups" {
  source = "./virtual_machine_groups"
  for_each = {
    for key, value in try(local.settings.virtual_machine_groups, {}) : key => value
    if try(value.enabled, false) == true
  }

  global_settings    = local.settings
  settings           = each.value
  vm_count           = each.value.vm_count
  vm_name_prefix     = each.value.vm_name_prefix
  vm_admin_username  = var.vm_admin_username
  vm_admin_password  = var.vm_admin_password
  vm_domain_username = var.vm_domain_username
  vm_domain_password = var.vm_domain_password
  resource_groups    = local.resource_groups
  networking         = local.networking
  keyvaults          = local.keyvaults
  availability_sets  = module.availability_sets
  shared_images      = module.shared_images
  storage_account    = module.storage_account
  avd_host_pools     = module.avd_host_pools
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_naming"></a> [resource\_naming](#module\_resource\_naming) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_datadisk_name"></a> [resource\_naming\_datadisk\_name](#module\_resource\_naming\_datadisk\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_legacy_computer_name"></a> [resource\_naming\_legacy\_computer\_name](#module\_resource\_naming\_legacy\_computer\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_legacy_datadisk_name"></a> [resource\_naming\_legacy\_datadisk\_name](#module\_resource\_naming\_legacy\_datadisk\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_legacy_osdisk_name"></a> [resource\_naming\_legacy\_osdisk\_name](#module\_resource\_naming\_legacy\_osdisk\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_legacy_vm_name"></a> [resource\_naming\_legacy\_vm\_name](#module\_resource\_naming\_legacy\_vm\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_linux_computer_name"></a> [resource\_naming\_linux\_computer\_name](#module\_resource\_naming\_linux\_computer\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_linux_os_disk_name"></a> [resource\_naming\_linux\_os\_disk\_name](#module\_resource\_naming\_linux\_os\_disk\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_linux_vm_name"></a> [resource\_naming\_linux\_vm\_name](#module\_resource\_naming\_linux\_vm\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_windows_computer_name"></a> [resource\_naming\_windows\_computer\_name](#module\_resource\_naming\_windows\_computer\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_windows_os_disk_name"></a> [resource\_naming\_windows\_os\_disk\_name](#module\_resource\_naming\_windows\_os\_disk\_name) | ../../../resource_naming | n/a |
| <a name="module_resource_naming_windows_vm_name"></a> [resource\_naming\_windows\_vm\_name](#module\_resource\_naming\_windows\_vm\_name) | ../../../resource_naming | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_protected_vm.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_dev_test_global_vm_shutdown_schedule.enabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule) | resource |
| [azurerm_key_vault_certificate.self_signed_winrm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.backup_encryption_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.sql_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.ssh_private_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.ssh_public_key_openssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_mssql_virtual_machine.mssqlvm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.nic_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.encryption_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.legacy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.sql_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_storage_account.mssqlvm_backup_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [external_external.backup_encryption_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.sp_client_id](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.sp_client_secret](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.sql_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.sql_username](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.windows_admin_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.windows_admin_username](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_settings"></a> [additional\_settings](#input\_additional\_settings) | Custom settings for special use cases (i.e. ADC Controller config) | `map` | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The VM Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended) | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The VM Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable | `string` | `null` | no |
| <a name="input_application_security_groups"></a> [application\_security\_groups](#input\_application\_security\_groups) | Application Security Groups module object | `map` | `{}` | no |
| <a name="input_availability_sets"></a> [availability\_sets](#input\_availability\_sets) | Availability Sets module object | `map` | `{}` | no |
| <a name="input_boot_diagnostics_storage_account"></a> [boot\_diagnostics\_storage\_account](#input\_boot\_diagnostics\_storage\_account) | The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor | `string` | `null` | no |
| <a name="input_custom_image_ids"></a> [custom\_image\_ids](#input\_custom\_image\_ids) | Custom Image IDs module object | `map` | `{}` | no |
| <a name="input_dedicated_hosts"></a> [dedicated\_hosts](#input\_dedicated\_hosts) | Dedicated Hosts module object | `map` | `{}` | no |
| <a name="input_disk_encryption_sets"></a> [disk\_encryption\_sets](#input\_disk\_encryption\_sets) | Disk Encryption Set module object | `map` | `{}` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_keyvault_keys"></a> [keyvault\_keys](#input\_keyvault\_keys) | Keyvault Keys module object | `map` | `{}` | no |
| <a name="input_keyvault_secrets"></a> [keyvault\_secrets](#input\_keyvault\_secrets) | Keyvault Secrets module object | `map` | `{}` | no |
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | Keyvault module object to store the SSH public and private keys when not provided by the var.public\_key\_pem\_file or retrieve admin username and password | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global\_settings.location value. | `string` | `null` | no |
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | Managed Identity module object | `map` | `{}` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | NSGs to be attached to a nic | `map` | `{}` | no |
| <a name="input_proximity_placement_groups"></a> [proximity\_placement\_groups](#input\_proximity\_placement\_groups) | Map of IDs of the Proximity Placement Group to which this Virtual Machine should be assigned. | `map` | `{}` | no |
| <a name="input_public_ip_addresses"></a> [public\_ip\_addresses](#input\_public\_ip\_addresses) | Public IP Addresses module object | `map` | `{}` | no |
| <a name="input_public_key_pem_file"></a> [public\_key\_pem\_file](#input\_public\_key\_pem\_file) | If disable\_password\_authentication is set to true, ssh authentication is enabled. You can provide a list of file path of the public ssh key in PEM format. If left blank a new RSA/4096 key is created and the key is stored in the keyvault\_id. The secret name being the {computer name}-ssh-public and {computer name}-ssh-private | `string` | `""` | no |
| <a name="input_recovery_vaults"></a> [recovery\_vaults](#input\_recovery\_vaults) | Recovery Vaults module object | `map` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resource is created | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the Virtual Machine resource | `any` | n/a | yes |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Storage Accounts module object | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |
| <a name="input_virtual_networks"></a> [virtual\_networks](#input\_virtual\_networks) | Virtual Networks module object | `any` | n/a | yes |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Custom variable used in virtual\_machine\_groups (module in calling repo) that will create X nbr of VMs with custom name | `string` | `"0"` | no |
| <a name="input_vm_name_prefix"></a> [vm\_name\_prefix](#input\_vm\_name\_prefix) | Custom variable used in virtual\_machine\_groups (module in calling repo) that will create X nbr of VMs with custom name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password_secret_id"></a> [admin\_password\_secret\_id](#output\_admin\_password\_secret\_id) | The Local Admin Password Key Vault Secret ID of the Virtual Machine |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | The Local Admin Username of the Virtual Machine |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Virtual Machine |
| <a name="output_identity"></a> [identity](#output\_identity) | The Identity block of the Virtual Machine |
| <a name="output_internal_fqdns"></a> [internal\_fqdns](#output\_internal\_fqdns) | The NIC FQDNs of the Virtual Machine |
| <a name="output_management_host_identity_object_id"></a> [management\_host\_identity\_object\_id](#output\_management\_host\_identity\_object\_id) | The VM Managed Identity Object ID of the Virtual Machine |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Virtual Machine |
| <a name="output_network_interface_application_security_group_associations"></a> [network\_interface\_application\_security\_group\_associations](#output\_network\_interface\_application\_security\_group\_associations) | n/a |
| <a name="output_nic_id"></a> [nic\_id](#output\_nic\_id) | The NIC IDs of the Virtual Machine |
| <a name="output_nics"></a> [nics](#output\_nics) | The NIC objects of the Virtual Machine |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The OS Type (from settings) of the Virtual Machine |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | The Primary Private IP Address assigned to this Virtual Machine |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | A list of Private IP Addresses assigned to this Virtual Machine |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The Primary Public IP Address assigned to this Virtual Machine |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | A list of the Public IP Addresses assigned to this Virtual Machine |
| <a name="output_ssh_keys"></a> [ssh\_keys](#output\_ssh\_keys) | The SSH Keys of the Linux Virtual Machine |
| <a name="output_virtual_machine_id"></a> [virtual\_machine\_id](#output\_virtual\_machine\_id) | A 128-bit identifier which uniquely identifies this Virtual Machine |
| <a name="output_winrm"></a> [winrm](#output\_winrm) | The WinRM Info of the Virtual Machine |
<!-- END_TF_DOCS -->