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
| <a name="module_resource_naming_linux_computer_name"></a> [resource\_naming\_linux\_computer\_name](#module\_resource\_naming\_linux\_computer\_name) | ../../resource_naming | n/a |
| <a name="module_resource_naming_linux_nic"></a> [resource\_naming\_linux\_nic](#module\_resource\_naming\_linux\_nic) | ../../resource_naming | n/a |
| <a name="module_resource_naming_linux_vm_name"></a> [resource\_naming\_linux\_vm\_name](#module\_resource\_naming\_linux\_vm\_name) | ../../resource_naming | n/a |
| <a name="module_resource_naming_windows_computer_name"></a> [resource\_naming\_windows\_computer\_name](#module\_resource\_naming\_windows\_computer\_name) | ../../resource_naming | n/a |
| <a name="module_resource_naming_windows_nic"></a> [resource\_naming\_windows\_nic](#module\_resource\_naming\_windows\_nic) | ../../resource_naming | n/a |
| <a name="module_resource_naming_windows_vm_name"></a> [resource\_naming\_windows\_vm\_name](#module\_resource\_naming\_windows\_vm\_name) | ../../resource_naming | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_certificate.self_signed_winrm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.ssh_private_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.ssh_public_key_openssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine_scale_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_windows_virtual_machine_scale_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [external_external.windows_admin_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.windows_admin_username](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_settings"></a> [additional\_settings](#input\_additional\_settings) | Custom settings for special use cases (i.e. ADC Controller config) | `map` | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The VM Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended) | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The VM Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable | `string` | `null` | no |
| <a name="input_application_gateways"></a> [application\_gateways](#input\_application\_gateways) | Application Gateways module object | `any` | n/a | yes |
| <a name="input_application_security_groups"></a> [application\_security\_groups](#input\_application\_security\_groups) | Application Security Groups module object | `any` | n/a | yes |
| <a name="input_availability_sets"></a> [availability\_sets](#input\_availability\_sets) | Availability Sets module object | `map` | `{}` | no |
| <a name="input_boot_diagnostics_storage_account"></a> [boot\_diagnostics\_storage\_account](#input\_boot\_diagnostics\_storage\_account) | The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor | `map` | `{}` | no |
| <a name="input_custom_image_ids"></a> [custom\_image\_ids](#input\_custom\_image\_ids) | Custom Image IDs module object | `map` | `{}` | no |
| <a name="input_disk_encryption_sets"></a> [disk\_encryption\_sets](#input\_disk\_encryption\_sets) | Disk Encryption Set module object | `map` | `{}` | no |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_keyvault_keys"></a> [keyvault\_keys](#input\_keyvault\_keys) | Keyvault Keys module object | `map` | `{}` | no |
| <a name="input_keyvault_secrets"></a> [keyvault\_secrets](#input\_keyvault\_secrets) | Keyvault Secrets module object | `map` | `{}` | no |
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | Keyvault module object to store the SSH public and private keys when not provided by the var.public\_key\_pem\_file or retrieve admin username and password | `any` | `null` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | Load Balancers module object | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global\_settings.location value. | `string` | `null` | no |
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | Managed Identity module object | `map` | `{}` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | NSGs to be attached to a nic | `map` | `{}` | no |
| <a name="input_proximity_placement_groups"></a> [proximity\_placement\_groups](#input\_proximity\_placement\_groups) | Map of IDs of the Proximity Placement Group to which this Virtual Machine should be assigned. | `map` | `{}` | no |
| <a name="input_public_ip_addresses"></a> [public\_ip\_addresses](#input\_public\_ip\_addresses) | Public IP Addresses module object | `map` | `{}` | no |
| <a name="input_public_key_pem_file"></a> [public\_key\_pem\_file](#input\_public\_key\_pem\_file) | If disable\_password\_authentication is set to true, ssh authentication is enabled. You can provide a list of file path of the public ssh key in PEM format. If left blank a new RSA/4096 key is created and the key is stored in the keyvault\_id. The secret name being the {computer name}-ssh-public and {computer name}-ssh-private | `string` | `""` | no |
| <a name="input_recovery_vaults"></a> [recovery\_vaults](#input\_recovery\_vaults) | Recovery Vaults module object | `map` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resource is created | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the Virtual Machine Scale set resource | `any` | n/a | yes |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Storage Accounts module object | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |
| <a name="input_virtual_networks"></a> [virtual\_networks](#input\_virtual\_networks) | Virtual Networks module object | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password_secret_id"></a> [admin\_password\_secret\_id](#output\_admin\_password\_secret\_id) | The Local Admin Password Key Vault Secret ID of the Virtual Machine Scale Set |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | The Local Admin Username of the Virtual Machine Scale Set |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Virtual Machine Scale Set |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The OS Type (from settings) of the Virtual Machine Scale Set |
| <a name="output_ssh_keys"></a> [ssh\_keys](#output\_ssh\_keys) | The SSH Keys of the Virtual Machine Scale Set |
<!-- END_TF_DOCS -->