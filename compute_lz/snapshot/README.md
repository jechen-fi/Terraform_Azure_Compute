# Snapshot Resource

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
| [azurerm_snapshot.snapshot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/snapshot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_key_vault_keys"></a> [key\_vault\_keys](#input\_key\_vault\_keys) | Key Vault Keys module object | `map` | `{}` | no |
| <a name="input_key_vault_secrets"></a> [key\_vault\_secrets](#input\_key\_vault\_secrets) | Key Vault Secrets module object | `map` | `{}` | no |
| <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults) | Key Vaults module object | `map` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global\_settings.location value. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resource is created | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the resource | `any` | n/a | yes |
| <a name="input_source_resource_id"></a> [source\_resource\_id](#input\_source\_resource\_id) | Specifies a reference to an existing snapshot, when create\_option is Copy | `any` | `null` | no |
| <a name="input_source_uri"></a> [source\_uri](#input\_source\_uri) | Specifies the URI to a Managed or Unmanaged Disk | `any` | `null` | no |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Storage Accounts module object | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disk_size_gb"></a> [disk\_size\_gb](#output\_disk\_size\_gb) | The Size of the Snapshotted Disk in GB |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Snapshot |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Snapshot |
| <a name="output_trusted_launch_enabled"></a> [trusted\_launch\_enabled](#output\_trusted\_launch\_enabled) | Whether Trusted Launch is enabled for the Snapshot |
<!-- END_TF_DOCS -->