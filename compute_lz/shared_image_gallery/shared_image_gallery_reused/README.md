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
| [azurerm_shared_image_gallery.gallery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/shared_image_gallery) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Shared Image Gallery |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Shared Image Gallery |
| <a name="output_unique_name"></a> [unique\_name](#output\_unique\_name) | The Unique Name for this Shared Image Gallery |
<!-- END_TF_DOCS -->