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
| [azurerm_shared_image_version.resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/shared_image_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gallery_name"></a> [gallery\_name](#input\_gallery\_name) | The name of the Shared Image Gallery in which the Shared Image exists | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the Shared Image within the Shared Image Gallery in which this Version should be created | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration settings object for the resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exclude_from_latest"></a> [exclude\_from\_latest](#output\_exclude\_from\_latest) | Is this Image Version excluded from the latest filter |
| <a name="output_gallery_name"></a> [gallery\_name](#output\_gallery\_name) | The name of the Shared Image Gallery in which the Shared Image exists |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Shared Image Version |
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | The Shared Image name in which this Shared Image Version exists |
| <a name="output_managed_image_id"></a> [managed\_image\_id](#output\_managed\_image\_id) | The ID of the Managed Image which was the source of this Shared Image Version |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Shared Image Version |
| <a name="output_os_disk_image_size_gb"></a> [os\_disk\_image\_size\_gb](#output\_os\_disk\_image\_size\_gb) | The size of the OS disk snapshot (in Gigabytes) which was the source of this Shared Image Version |
| <a name="output_os_disk_snapshot_id"></a> [os\_disk\_snapshot\_id](#output\_os\_disk\_snapshot\_id) | The ID of the OS disk snapshot which was the source of this Shared Image Version |
| <a name="output_target_region"></a> [target\_region](#output\_target\_region) | Target Region block |
<!-- END_TF_DOCS -->