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
| [azurerm_shared_image.image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/shared_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gallery_name"></a> [gallery\_name](#input\_gallery\_name) | Specifies the name of the Shared Image Gallery in which this Shared Image should exist | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Shared Image |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Shared Image |
<!-- END_TF_DOCS -->