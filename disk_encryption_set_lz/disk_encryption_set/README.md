<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_naming"></a> [resource\_naming](#module\_resource\_naming) | ../../resource_naming | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_disk_encryption_set.encryption_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) | resource |
| [azurerm_key_vault_access_policy.des](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_key_vault_key_ids"></a> [key\_vault\_key\_ids](#input\_key\_vault\_key\_ids) | Keyvault Key IDs map - Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret) | `map` | `{}` | no |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | Key Vault resource ID | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global\_settings.location value. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resource is created | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the Disk Encryption Set resource | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Disk Encryption Set |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Disk Encryption Set |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The Identity Principal ID of the Disk Encryption Set |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The Identity Tenant ID of the Disk Encryption Set |
<!-- END_TF_DOCS -->