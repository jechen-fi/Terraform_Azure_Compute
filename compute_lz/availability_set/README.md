# Availability Set

## Default Naming Convention
```
name_mask = "{cloudprefix}{delimiter}{locationcode}{delimiter}{envlabel}{delimiter}{avset}{delimiter}{postfix}"

Example Result: AVA-EUS2-DEV-AS-01
```

## Example Settings
```yaml
availability_sets:
  avset1:
    enabled: false
    resource_group_key: "network"
    naming_convention:
      postfix: "01"

##===============================
## Virtual Machine snippet for AS reference
##===============================
virtual_machines:
  vm1:
    os_type: linux
    virtual_machine_settings:
      linux:
        availability_set_key: "avset1"

```

## Example Module Reference

```terraform
module "availability_sets" {
  source = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/availability_set"
  for_each = {
    for key, value in try(local.settings.availability_sets, {}) : key => value
    if try(value.enabled, false) == true
  }

  global_settings     = local.settings
  availability_set    = each.value
  resource_group_name = local.resource_groups[each.value.resource_group_key].name
  tags                = try(each.value.tags, null)
}
```

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
| [azurerm_availability_set.avset](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | Configuration settings object for the Availability Set | `any` | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where to create the resource. Ommitting this variable will default to the var.global\_settings.location value. | `string` | `null` | no |
| <a name="input_ppg_id"></a> [ppg\_id](#input\_ppg\_id) | The ID of the Proximity Placement Group to which this Virtual Machine should be assigned. Changing this forces a new resource to be created | `any` | `null` | no |
| <a name="input_proximity_placement_groups"></a> [proximity\_placement\_groups](#input\_proximity\_placement\_groups) | Map of IDs of the Proximity Placement Group to which this Virtual Machine should be assigned. | `map` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resource is created | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->