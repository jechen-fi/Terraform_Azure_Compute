# Image Data Resource

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
| [azurerm_image.image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Data Managed Image |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Data Managed Image |
<!-- END_TF_DOCS -->