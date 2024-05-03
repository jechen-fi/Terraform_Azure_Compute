# Shared Image module

Terraform generalized module to add a shared image

## Requirements

| Name (providers)   | Version            |
|--------------------|--------------------|
| azurerm            | >= 3.100.0         |
| terraform          | >= 1.1.7 |


## Inputs / Variables

| Name              | Description                              | Type    | Default Value   | Required | Sensitive |
|-------------------|------------------------------------------|---------|-----------------|:--------:| --------- |
| deploy_image | Create a custom virtual machine image that can be used to create virtual machines. | `boolean` | `false`  | no | no |
| image_name | Specifies the name of the Image. | `string` | `None`  | no | no |
| location | Specifies the supported Azure location where the resource exists. | `string` | `None`  | yes | no |
| resource_group_name | The name of the resource group in which to create the resource. | `string` | `None`  | yes | no |
| source_virtual_machine_id | The Virtual Machine ID from which to create the image. | `string` | `None`  | no | no |
| hyper_v_generation | The HyperVGenerationType of the VirtualMachine created from the image as V1, V2. | `string` | `V1`  | no | no |
| zone_resilient | Specifies whether zone resiliency should be enabled. | `boolean` | `false`  | no | no |
| shrd_img_name | Specifies the name of the Shared Image. | `string` | `None`  | yes | no |
| os_disk | A `os_disk` block supports the following: <br><br> -> os_type - (Optional) Specifies the type of operating system contained in the virtual machine image. Possible values are: Windows or Linux. <br> -> os_state - (Optional) Specifies the state of the operating system contained in the blob. Currently, the only value is Generalized. Possible values are Generalized and Specialized. <br> -> managed_disk_id - (Optional) Specifies the ID of the managed disk resource that you want to use to create the image. <br> -> blob_uri - (Optional) Specifies the URI in Azure storage of the blob that you want to use to create the image. <br> -> caching - (Optional) Specifies the caching mode as ReadWrite, ReadOnly, or None. The default is None. <br> -> size_gb - (Optional) Specifies the size of the image to be created. <br> -> disk_encryption_set_id - (Optional) The ID of the Disk Encryption Set which should be used to encrypt this image. | `map` | `null`  | no | no |
| data_disk | A `data_disk` block supports the following: <br><br> -> lun - (Optional) Specifies the logical unit number of the data disk. <br> -> managed_disk_id - (Optional) Specifies the ID of the managed disk resource that you want to use to create the image. <br> -> blob_uri - (Optional) Specifies the URI in Azure storage of the blob that you want to use to create the image. <br> -> caching - (Optional) Specifies the caching mode as ReadWrite, ReadOnly, or None. The default is None. <br> -> size_gb - (Optional) Specifies the size of the image to be created. | `map` | `null`  | no | no |
| os_type | The type of Operating System present in this Shared Image. Possible values are `Linux` and `Windows`. | `string` | `null`  | yes | no |
| gallery_name | Specifies the name of the Shared Image Gallery in which this Shared Image should exist. | `string` | `None`  | yes | no |
| identifier | A `identifier` block supports the following: <br><br> -> offer - (Required) The Offer Name for this Shared Image <br> -> publisher - (Required) The Publisher Name for this Gallery Image.<br> -> sku - (Required) The Name of the SKU for this Gallery Image.| `map` | `null`  | no | no |
| os_type | The type of Operating System present in this Shared Image. Possible values are `Linux` and `Windows`. | `string` | `null`  | yes | no |
| shared_image_config | An `optional` configuration block of the shared image: <br><br> --> `purchase_plan` - A purchase_plan block supports the following:<br><br> -> name - (Required) The Purchase Plan Name for this Shared Image.<br>->publisher - (Optional) The Purchase Plan Publisher for this Gallery Image.<br>-> product - (Optional) The Purchase Plan Product for this Gallery Image.<br><br> --> `description` - Description for the Shared Image<br> -->`disk_types_not_allowed` - One or more Disk Types not allowed for the Image. Possible values include `Standard_LRS` and `Premium_LRS` <br> --> `end_of_life_date` - The end of life date in RFC3339 format of the Image. <br> --> `eula` - The End User Licence Agreement for the Shared Image.<br> --> `specialized` - Specifies that the Operating System used inside this Image has not been Generalized (for example, sysprep on Windows has not been run).<br><br> `Note:` It's recommended to Generalize images where possible - Specialized Images reuse the same UUID internally within each Virtual Machine, which can have unintended side-effects. <br><br>-->`architecture`- CPU architecture supported by an OS. Possible values are x64 and Arm64. Defaults to `x64`<br>-->`hyper_v_generation` - The generation of HyperV that the Virtual Machine used to create the Shared Image is based on. Possible values are V1 and V2. Defaults to `V1`<br> --> `max_recommended_vcpu_count` - Maximum count of vCPUs recommended for the Image.<br>--> `min_recommended_vcpu_count` - Minimum count of vCPUs recommended for the Image.<br> --> `max_recommended_memory_in_gb` - Maximum memory in GB recommended for the Image.<br> --> `min_recommended_memory_in_gb` - Minimum memory in GB recommended for the Image <br> --> `privacy_statement_uri` - The URI containing the Privacy Statement associated with this Shared Image. <br> --> `release_note_uri` - The URI containing the Release Notes associated with this Shared Image. <br> --> `trusted_launch_supported` - Specifies if supports creation of both Trusted Launch virtual machines and Gen2 virtual machines with standard security created from the Shared Image. <br> --> `trusted_launch_enabled` - Specifies if Trusted Launch has to be enabled for the Virtual Machine created from the Shared Image. <br> --> `confidential_vm_supported` - Specifies if supports creation of both Confidential virtual machines and Gen2 virtual machines with standard security from a compatible Gen2 OS disk VHD or Gen2 Managed image.  <br> --> `confidential_vm_enabled` - Specifies if Confidential Virtual Machines enabled. It will enable all the features of trusted, with higher confidentiality features for isolate machines or encrypted data. Available for Gen2 machines.<br> --> `accelerated_network_support_enabled` - Specifies if the Shared Image supports Accelerated Network. | `map` | `{}`  | no | no |
| tags |  Tags to be assigned to the shared image resource in Azure. | `object` or `map` | `{}`  | yes | no |

## Outputs
| Name              | Description                              |
|-------------------|------------------------------------------|
| img_id | ID of the Image |
| img | Output configuration of the Image |
| shrd_img_id | ID of the Shared Image |
| shrd_img | Output configuration of the Shared Image |

## Dependencies

| Module Name       | Description of module and why it is required | Link to module's repo |
|-------------------|----------------------------------------------|:---------------------:|
| Azure Shared Image Gallery              | Name of the Shared Image Gallery is required to created a shared image            | [azurerm_shared_image_gallery](https://github.com/FisherInvestments/Terraform_Azure_Compute/tree/main/shared_image_gallery) |


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
  required_version = ">= 1.1.7"
}

provider "azurerm" {
  features {}
}

#############################versions.tf####################################
##############################main.tf######################################
data "azurerm_resource_group" "rg" {
    name = "a00000-namespace-ctd"
}

data "azurerm_virtual_machine" "vm" {
  name                = "a00000-tstvm-ctd"
  resource_group_name = "a00000-namespace-ctd"
}

resource "azurerm_image" "vm" {
  name                      = "a00000vmimage"
  location                  = data.azurerm_virtual_machine.vm.location
  resource_group_name       = data.azurerm_virtual_machine.vm.resource_group_name
  source_virtual_machine_id = data.azurerm_virtual_machine.vm.id
  hyper_v_generation        = "V2"
}

module "shared_image" {
  # github repo ==> github.com/FisherInvestments/Terraform_Azure_Compute/    folder ==> ./shared_image/shared_image
  source              = "./modules/shared_image/shared_image"
  name                = "example-image"
  gallery_name        = data.azurerm_shared_image_gallery.shrd_img_gallery.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"

  identifier {
    publisher = "PublisherName"
    offer     = "OfferName"
    sku       = "ExampleSku"
  }

  tags = {
    applicationName  = "Cloud Infrastructure Shared Image" 
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