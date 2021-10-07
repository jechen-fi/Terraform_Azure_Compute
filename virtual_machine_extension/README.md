# Virtual_Machines module

Terraform generalized module to add a virtual machine extension to one or more linux or windows virtual machines.

## Requirements

| Name (providers)   | Version            |
|--------------------|--------------------|
| azurerm            | >= 2.64.0          |
| terraform          | >= 0.14.1, < 1.0.0 |


## Inputs / Variables

| Name              | Description                              | Type    | Default Value   | Required | Sensitive |
|-------------------|------------------------------------------|---------|-----------------|:--------:| --------- |
| auto_upgrade | Resource group name for the VM's virtual network | `string` | `None`  | yes | no |
| azure_vm_id | Virtual network name that the VM, NIC & related resources live on | `string` | `None`  | yes | no |
| command_run_script | Subnet name within the virtual network that resources will live on | `string` | `None`  | yes | no |
| extension_type | Log Analytics workspace name, if one is used for logs | `string` | `null`  | yes | no |
| extension_type_version | Base vm storage account to store logs | `string` | `null`  | yes | no |
| managed_identity | Virtual machine name provided by pipeline | `string` | `None`  | yes | no |
| name_vmextension | User provided/created name for the virtual machine extension azure resource | `string` | `None` | yes | no |
| publisher | Publisher for the virtual machine extension being used. | `string` | `Microsoft.Azure.Extensions`  | yes | no |
| script_uri | the URLs for file(s) to be downloaded. If URLs are sensitive (such as URLs containing keys), this field should be specified in protectedSettings | `string array` | `null` | no | no |
| tags | Tags to be assigned to the Azure resource in Azure | `object` or `map` | `null` | yes | no |

## Outputs
| Name              | Description                              | Sensitive |
|-------------------|------------------------------------------|-----------|
| vm_extension | Output for azurerm_virtual_machine_extension resource | No |

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
      version = "= 2.64.0"
    }
  }
  required_version = ">= 0.14.1, < 1.0.0"
}

provider "azurerm" {
  features {}
}
#############################version.tf####################################
##############################main.tf######################################
module "virtual-machine-extension" {
  # github repo ==> github.com/FisherInvestments/Terraform_Azure_Compute/    folder ==> ./virtual_machine_extension
  source                 = "./modules/virtual_machine_extension"
  azure_vm_id            = module.virtual-machine.vm_info_windows.id
  command_run_script     = "powershell -ExecutionPolicy Unrestricted -File helloworld.ps1"
  name_vmextension       = "unique_name_here_sbx"
  script_uri             = var.script_uri
  managed_identity       = var.managed_identity
  extension_type_version = var.extension_type_version
  tags = {
    applicationName  = "Cloud Infrastructure VMExtension"
    environment      = "Development"
    applicationOwner = "~AzureSupport@fi.com"
    businessUnit     = "IT Infrastructure Engineering"
    costCenter       = var.cost_center
    dataClass        = "Non-Restricted"
    disasterRecovery = "Non-Critical"
    serviceClass     = "Development"
    supportOwner     = "~AzureSupport@fi.com"
  }
}
##############################main.tf######################################
```
### terraform init:
```PowerShell
# PowerShell example below
# below line ensures your PowerShell (PS) command history is disabled so it will not save powershell commands below (including  secrets) to a text file on your local system
Set-PSReadlineOption -HistorySaveStyle SaveNothing
# set environment variable with storage account (SA) ARM access key secret
$env:ARM_ACCESS_KEY = '[storage account access key for below SA to write tfstate backend]'
# Terraform init command
terraform init -backend-config="resource_group_name=[resource group name for below storage account]" \
  -backend-config="storage_account_name=[storage account name where tfstate will be stored]" \
  -backend-config="container_name=[container name within the storage account]" \
  -backend-config="key=[tfstate_unique_name].terraform.tfstate"
# Run below powershell command after your init to clear active window history to protect secret
Clear-History
```
```Shell
# Linux Bash example below
# Below lines run 'history -c' to ensure shell history is not saved on linux command line
export ARM_ACCESS_KEY="[storage account access key for below SA to write tfstate backend]" && history -c
terraform init -backend-config="resource_group_name=[resource group name for below storage account]" \
  -backend-config="storage_account_name=[storage account name where tfstate will be stored]" \
  -backend-config="container_name=[container name within the storage account]" \
  -backend-config="key=[tfstate_unique_name].terraform.tfstate" && history -c
```
### terraform workspace and validate
```PowerShell
# PowerShell to create new workspace or select existing one before running apply/plan
(terraform workspace new "[workspace_name]") -or (terraform workspace select "workspace_name")
```
```Shell
# Linux Bash to create new workspace or select existing one before running apply/plan
terraform workspace new "[workspace_name]" 2> /dev/null || terraform workspace select "workspace_name" 2> /dev/null
```
```
# PowerShell or Bash to run in same directory where root main.tf is run to validate code
terraform validate
```
### terraform plan/apply
```PowerShell
# PowerShell to run terraform plan / apply line
terraform plan -auto-approve
terraform apply -auto-approve
```
```Shell
# Linux Bash to run terraform plan / apply line
terraform plan -auto-approve
terraform apply -auto-approve
```


## License / Use information

Fisher Investments internal


## Author Information

Cloud Infra Team - ~CloudInfrastructure@fi.com
