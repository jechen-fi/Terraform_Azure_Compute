<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_virtual_machines_in_group"></a> [virtual\_machines\_in\_group](#module\_virtual\_machines\_in\_group) | ./virtual_machine | n/a |
| <a name="module_vm_group_vm_extension_AADLoginForWindows"></a> [vm\_group\_vm\_extension\_AADLoginForWindows](#module\_vm\_group\_vm\_extension\_AADLoginForWindows) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_AVD_DSC"></a> [vm\_group\_vm\_extension\_AVD\_DSC](#module\_vm\_group\_vm\_extension\_AVD\_DSC) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_AzureDiskEncryptionLinux"></a> [vm\_group\_vm\_extension\_AzureDiskEncryptionLinux](#module\_vm\_group\_vm\_extension\_AzureDiskEncryptionLinux) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_AzureDiskEncryptionWindows"></a> [vm\_group\_vm\_extension\_AzureDiskEncryptionWindows](#module\_vm\_group\_vm\_extension\_AzureDiskEncryptionWindows) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_InitializeDataDisks"></a> [vm\_group\_vm\_extension\_InitializeDataDisks](#module\_vm\_group\_vm\_extension\_InitializeDataDisks) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_LegacyADLoginForWindows"></a> [vm\_group\_vm\_extension\_LegacyADLoginForWindows](#module\_vm\_group\_vm\_extension\_LegacyADLoginForWindows) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_NvidiaGpuDriverWindows"></a> [vm\_group\_vm\_extension\_NvidiaGpuDriverWindows](#module\_vm\_group\_vm\_extension\_NvidiaGpuDriverWindows) | ./virtual_machine_extensions | n/a |
| <a name="module_vm_group_vm_extension_custom_script"></a> [vm\_group\_vm\_extension\_custom\_script](#module\_vm\_group\_vm\_extension\_custom\_script) | ./virtual_machine_extensions | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_security_groups"></a> [application\_security\_groups](#input\_application\_security\_groups) | Application Security Groups module object | `map` | `{}` | no |
| <a name="input_availability_sets"></a> [availability\_sets](#input\_availability\_sets) | AV Sets object | `map` | `{}` | no |
| <a name="input_avd_host_pools"></a> [avd\_host\_pools](#input\_avd\_host\_pools) | Host Pool object | `map` | `{}` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_keyvault_keys"></a> [keyvault\_keys](#input\_keyvault\_keys) | Keyvault Keys object | `map` | `{}` | no |
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | Keyvault object | `any` | `null` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | VNet object | `any` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Resource Groups object | `any` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object containing Virtual Machines | `any` | n/a | yes |
| <a name="input_shared_images"></a> [shared\_images](#input\_shared\_images) | Shared Images object | `map` | `{}` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Storage Accounts object | `map` | `{}` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | VM local admin password object | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | VM local admin username object | `string` | `null` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Custom variable used in virtual\_machine\_groups module that will create X nbr of VMs | `number` | `0` | no |
| <a name="input_vm_count_format"></a> [vm\_count\_format](#input\_vm\_count\_format) | Custom variable used in virtual\_machine\_groups module that will format the VM name counter value | `string` | `"%01d"` | no |
| <a name="input_vm_count_start_index"></a> [vm\_count\_start\_index](#input\_vm\_count\_start\_index) | Custom variable used in virtual\_machine\_groups module that will format the VM name counter value starting at zero | `number` | `0` | no |
| <a name="input_vm_domain_password"></a> [vm\_domain\_password](#input\_vm\_domain\_password) | VM domain password object | `string` | `null` | no |
| <a name="input_vm_domain_username"></a> [vm\_domain\_username](#input\_vm\_domain\_username) | VM domain username object | `string` | `null` | no |
| <a name="input_vm_name_prefix"></a> [vm\_name\_prefix](#input\_vm\_name\_prefix) | Custom variable used in virtual\_machine\_groups module that will create X nbr of VMs | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_virtual_machines_in_group"></a> [virtual\_machines\_in\_group](#output\_virtual\_machines\_in\_group) | All virtual machines created via virtual\_machine\_groups module |
<!-- END_TF_DOCS -->