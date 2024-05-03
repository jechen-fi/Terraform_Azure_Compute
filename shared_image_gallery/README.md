# Shared Image Gallery module

Terraform generalized module to add a shared image galley

## Requirements

| Name (providers)   | Version            |
|--------------------|--------------------|
| azurerm            | >= 3.100.0         |
| terraform          | >= 1.1.7  |


## Inputs / Variables

| Name              | Description                              | Type    | Default Value   | Required | Sensitive |
|-------------------|------------------------------------------|---------|-----------------|:--------:| --------- |
| name | Specifies the name of the Shared Image Gallery. | `string` | `None`  | yes | no |
| resource_group_name | The name of the resource group in which to create the Shared Image Gallery. | `string` | `None`  | yes | no |
| location | Specifies the supported Azure location where the resource exists. | `string` | `None`  | yes | no |
| sharing | A `sharing` configuration block of the shared image gallery: <br><br> --> `description` - Description for the Shared Image Gallery. <br><br> --> `sharing` -  A sharing block supports the following: <br><br> -> permission - (Required) The permission of the Shared Image Gallery when sharing. Possible values are Community, Groups and Private. <br><br> -> community_gallery - (Optional) A community_gallery supports the following :<br>* eula - (Required) The End User Licence Agreement for the Shared Image Gallery.<br>* prefix - (Required) Prefix of the community public name for the Shared Image Gallery.<br>* publisher_email - (Required) Email of the publisher for the Shared Image Gallery.<br>* publisher_uri - (Required) URI of the publisher for the Shared Image Gallery.<br><br>`Note`: `community_gallery` must be set when `permission` is set to `Community`.| `map` | `{}`  | no | no |
| tags | Tags to be assigned to the shared image gallery resource in Azure. | `object` or `map` | `null` | yes | no |

## Outputs
| Name              | Description                              |
|-------------------|------------------------------------------|
| ID | ID of the Shared Image Gallery |

## Dependencies

| Module Name       | Description of module and why it is required | Link to module's repo |
|-------------------|----------------------------------------------|:---------------------:|
| None              | N/A                                          | N/A                   |


## Example call to module

### main.tf
```HCL
# Recommend placing below lines would normally be placed in version.tf file instead of main.tf
#############################version.tf####################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
  required_version = ">= 0.15.0"
}

provider "azurerm" {
  features {}
}
#############################version.tf####################################
##############################main.tf######################################
data "azurerm_resource_group" "rg" {
    name = "a00000-namespace-ctd"
}

module "shared_image_gallery" {
  # github repo ==> github.com/FisherInvestments/Terraform_Azure_Compute/    folder ==> ./shared_image_gallery
  source                 = "./modules/shared_image_gallery
  name                = "example_image_gallery"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  description         = "Shared images and things."
  tags = {
    applicationName  = "Cloud Infrastructure Shared Image Gallery"
    environment      = "Development"
    applicationOwner = "~CloudInfrastructure@fi.com"
    businessUnit     = "IT Infrastructure Engineering"
    costCenter       = var.cost_center
    dataClass        = "Non-Restricted"
    disasterRecovery = "Non-Critical"
    serviceClass     = "Development"
    supportOwner     = "~CloudInfrastructure@fi.com"
  }
}
##############################main.tf######################################
```

## License / Use information

Fisher Investments internal


## Author Information

Cloud Infra Team - ~CloudInfrastructure@fi.com
