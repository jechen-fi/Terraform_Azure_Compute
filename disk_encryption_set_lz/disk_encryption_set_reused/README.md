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
| [azurerm_disk_encryption_set.encryption_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/disk_encryption_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the Disk Encryption Set resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_key_rotation_enabled"></a> [auto\_key\_rotation\_enabled](#output\_auto\_key\_rotation\_enabled) | Is the Azure Disk Encryption Set Key automatically rotated to latest version |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Disk Encryption Set |
| <a name="output_location"></a> [location](#output\_location) | The location where the Disk Encryption exists |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Disk Encryption Set |
<!-- END_TF_DOCS -->