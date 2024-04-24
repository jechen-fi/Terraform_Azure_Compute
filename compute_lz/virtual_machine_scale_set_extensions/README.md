<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_scale_set_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.domainjoin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_key_vault_secret.domain_join_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.domain_join_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extension"></a> [extension](#input\_extension) | Configuration settings object for the extension resource | `any` | n/a | yes |
| <a name="input_extension_name"></a> [extension\_name](#input\_extension\_name) | Name of extension type to be used for resource set up | `string` | n/a | yes |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | Keyvault ID (Overrides option to retrieve keyvault ID from var.keyvaults) | `string` | `null` | no |
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | Keyvault module object (used if not explicitly passing var.keyvault\_id) | `map` | `{}` | no |
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | Managed Identities module object | `map` | `{}` | no |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Storage Accounts module object | `map` | `{}` | no |
| <a name="input_virtual_machine_scale_set_id"></a> [virtual\_machine\_scale\_set\_id](#input\_virtual\_machine\_scale\_set\_id) | The ID of the Virtual Machine Scale Set | `string` | n/a | yes |
| <a name="input_virtual_machine_scale_set_os_type"></a> [virtual\_machine\_scale\_set\_os\_type](#input\_virtual\_machine\_scale\_set\_os\_type) | VMSS OS Type (linux/windows) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->