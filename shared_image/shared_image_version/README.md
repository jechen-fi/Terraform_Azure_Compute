# Shared Image Version module

Terraform generalized module to add a shared image version

## Requirements

| Name (providers)   | Version            |
|--------------------|--------------------|
| azurerm            | >= 3.100.0         |
| terraform          | >= 1.1.7 |


## Inputs / Variables

| Name              | Description                              | Type    | Default Value   | Required | Sensitive |
|-------------------|------------------------------------------|---------|-----------------|:--------:| --------- |
| name | Specifies the name of the Shared Image Version. | `string` | `None`  | yes | no |
| gallery_name | Specifies the name of the Shared Image Gallery in which this Shared Image should exist. | `string` | `None`  | yes | no |
| shared image_name | The name of the Shared Image within the Shared Image Gallery in which this Version should be created. | `string` | `None`  | yes | no |
| resource_group_name | The name of the resource group in which to create the Shared Image Gallery. | `string` | `None`  | yes | no |
| location | Specifies the supported Azure location where the resource exists. | `string` | `None`  | yes | no |
| managed_image_id | The ID of the Managed Image or Virtual Machine ID which should be used for this Shared Image Version. | `string` | `None`  | yes | no |
| target_region | The target_region block supports the following: <br><br> --> `name` - (Required) The Azure Region in which this Image Version should exist.<br>-->`regional_replica_count` - (Required) The number of replicas of the Image Version to be created per region.<br> --> `disk_encryption_set_id` - (Optional) The ID of the Disk Encryption Set to encrypt the Image Version in the target region. Changing this forces a new resource to be created.<br> --> `exclude_from_latest_enabled` - (Optional) Specifies whether this Shared Image Version should be excluded when querying for the latest version. Defaults to `false`.<br> --> `storage_account_type` - (Optional) The storage account type for the image version. Possible values are `Standard_LRS, Premium_LRS and Standard_ZRS`. Defaults to `Standard_LRS`. You can store all of your image version replicas in Zone Redundant Storage by specifying `Standard_ZRS`. | `map` | `None`  | yes | no |
| shared_image_version_config | An `optional` configuration block of the shared image version: <br><br> --> `blob_uri` - (Optional) URI of the Azure Storage Blob used to create the Image Version.<br> --> `end_of_life_date` -  (Optional) he end of life date in RFC3339 format of the Image Version.<br> --> `exclude_from_latest` - (Optional) Should this Image Version be excluded from the latest filter? If set to true this Image Version won't be returned for the latest version. Defaults to `false`. <br> --> `os_disk_snapshot_id` - (Optional) The ID of the OS disk snapshot which should be used for this Shared Image Version. <br> --> `deletion_of_replicated_locations_enabled` - (Optional) Specifies whether this Shared Image Version can be deleted from the Azure Regions this is replicated to. Defaults to false. <br> --> `replication_mode` - (Optional) Mode to be used for replication. Possible values are `Full and Shallow`. Defaults to 'Full'. <br> --> `storage_account_id` - (Optional) The ID of the Storage Account where the Blob exists. <br><br> `Note:`<br> `blob_uri and storage_account_id` must be specified together.<br> You must specify exact one of `blob_uri, managed_image_id and os_disk_snapshot_id`. | `map` | `{}`  | no | no |
| tags | Tags to be assigned to the shared image gallery resource in Azure. | `object` or `map` | `null` | yes | no |

## Outputs
| Name              | Description                              |
|-------------------|------------------------------------------|
| ID | ID of the Shared Image Version |

## Dependencies

| Module Name       | Description of module and why it is required | Link to module's repo |
|-------------------|----------------------------------------------|:---------------------:|
| Azure Shared Image              | Name of the Shared Image & Shared Image Gallery are required to created a shared image version            | [azurerm_shared_image_gallery](https://github.com/FisherInvestments/Terraform_Azure_Compute/tree/main/shared_image/shared_image) |


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
data "azurerm_shared_image" "shrd_img" {
  name                = "a00000_sharedimage_ctd"
  gallery_name        = "a00000_shrdimggallery_ctd"
  resource_group_name = "a00000-namespace-ctd"
}

resource "azurerm_image" "image" {
  name                      = var.image_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  source_virtual_machine_id = var.source_virtual_machine_id
}

module "shared_image_version" {
  # github repo ==> github.com/FisherInvestments/Terraform_Azure_Compute/    folder ==> ./shared_image/shared_image_version
  source                 = "./modules/shared_image/shared_image_version"
  name                = "0.0.1"
  gallery_name        = data.azurerm_shared_image.existing.gallery_name
  image_name          = data.azurerm_shared_image.existing.name
  resource_group_name = data.azurerm_shared_image.existing.resource_group_name
  location            = data.azurerm_shared_image.existing.location 
  managed_image_id    = azurerm_image.image.id
  target_region {
    name                   = data.azurerm_shared_image.shrd_img.location
    regional_replica_count = 5
    storage_account_type   = "Standard_LRS"
  }
  tags = {
    applicationName  = "Cloud Infrastructure Shared Image Version"
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
