

# Virtual_Machines module

Terraform generalized module to build one or more linux or windows virtual machines.  This could also be used to deploy other VMs Azure marketplace images.

## Requirements

| Name (providers)   | Version  |
|--------------------|----------|
| azurerm            |  2.64.0  |
| tls                |  3.1.0   |
| random             |  3.1.0   |


## Inputs / Variables

| Name              | Description                              | Type    | Default Value   | Required |
|-------------------|------------------------------------------|---------|-----------------|:--------:|
| resource_group_name | Resource group name that holds VM, VM NIC, and related resources | `string` | `None`  |   yes     |
| resource_group_vnet | Resource group name for the VM's virtual network | `string` | `None`  |   yes     |
| virtual_network_name | Virtual network name that the VM, NIC & related resources live on | `string` | `None`  |   yes     |
| subnet_name | Subnet name within the virtual network that resources will live on | `string` | `None`  |   yes     |
| log_analytics_workspace_name | Log Analytics workspace name, if one is used for logs | `string` | `null`  |   yes     |
| vm_storage_account | Base vm storage account to store logs | `string` | `null`  |   yes     |
| virtual_machine_name | Virtual machine name provided by pipeline | `string` | `None`  |   yes     |
| virtual_machine_size | SKU for the Virtual Machine | `string` | `"Standard_A2_v2"` |   yes     |
| instances_count | Number of virtual machines to deploy | `number` | `1`  |   yes     |
| enable_ip_forwarding | Enable IP Forwarding or not? Defaults to False | `boolean` | `false`  |   yes     |
| enable_accelerated_networking | Enable Accelerated Networking or not? Defaults to False | `bool` | `false`  |   yes     |
| ultrassd | Enable support for use of the UltraSSD_LRS storage account type or not? Defaults to False | `map` | `{` <br> &nbsp;&nbsp;`"required" = false`<br>` }`  |   yes     |
| private_ip_address_allocation_type | Private IP Address Allocation method to be used. Accepted values are 'Dynamic' or 'Static'. | `map` | `"Dynamic"`  |   yes     |
| private_ip_address | The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` | `string` | `None`  |   no     |
| dns_servers | List of IP Addresses defining the DNS Servers which to use for the network interface | `list` | `None`  |   no     |
| enable_av_set | Enable or disable virtual machine availability set | `bool` | `false`  |   no     |
| enable_feature | Used to manage turning some features on / off | `map` | `default = {` <br> &nbsp;&nbsp;`"yes" = true` <br> &nbsp;&nbsp;`"y" = true` <br> &nbsp;&nbsp;`"true" = true` <br> &nbsp;&nbsp;`"no" = false` <br> &nbsp;&nbsp;`"n"  = false` <br> &nbsp;&nbsp;`"false" = false` <br> `}`  |   yes     |
| enable_public_ip_address | Enable or disable a public ip address for the VM? Defaults to False | `bool` | `false`  | yes |
| priority | Specifies the priority of this VM.  Accepted values are 'Regular' or 'Spot' - A change will force a new resource to be created | `string` | `"Regular"`  |   yes     |
| identity | A block supporting both "type (Required)" and "identity_ids (Optional) - the "type" of managed identity which should be assigned to the virtual machine, includes accepted values 'SystemAssigned, UserAssigned' - For identify_ids, it should be a list of user managed identity IDs assigned to the VM | `map` | `null`  |   yes     |
| admin_ssh_key | Either this or `admin_password` must be specified for authentication. Block supporting the following:<ul><li>`public_key` - (Required) The Public Key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format. Changing this forces a new resource to be created.<\li><li>`username` - (Required) The Username for which this Public SSH Key should be configured. Changing this forces a new resource to be created.<\li><\ul> | `map` | `null`<br>`or, use format:`<br>`admin_ssh_key {`<br>&nbsp;&nbsp;`username   = "adminuser"`<br>&nbsp;&nbsp;`public_key = file("/full_path/to/pubkey/id_rsa.pub")`<br>`}`  |    no     |
| admin_password |  Either this or admin_ssh_key must be specified for authentication.  The Password for the local-administrator account on this Virtual Machine.  When `admin_password` is specified, `disable_password_authentication` must be set to false. Changing this forces a new resource to be created. | `string` | `None`  |    no     |
| certsecret | A block with url = secret URL of a Key Vault cert | `object` | `null`<br>`or, use format:`<br>`{`<br>&nbsp;&nbsp;`url = "https://secret/url"`<br>`}`
  }  | yes |


## Dependencies

| Module Name       | Description of module and why it is required | Link to module's repo |
|-------------------|----------------------------------------------|:---------------------:|
| None              | N/A                                          | N/A                   |


## Example call to module

### main.tf
```HCL
terraform {
  backend "azurerm" {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
  }
}
provider "azurerm" {
  features {}
}

module "virtual-machine" {
  # version = github.com/FisherInvestments/tf_arm_virtualmachines?ref=development
  # tags = 0.0.1
  source                       = "./modules/tf_arm_virtualmachines"
  # Resource Group, location, VNet and Subnet details
  boot_diag                    = local.boot_diag
  resource_group_name          = var.rg_name
  resource_group_vnet          = var.vnet_rg_name
  virtual_network_name         = var.vnet_name
  subnet_name                  = var.subnet_name
  virtual_machine_name         = lower(var.vm_hostname)
  # (Optional) To enable Azure Monitoring and install log analytics agents
  log_analytics_workspace_name = var.log_analytics_workspace_name
  vm_storage_account           = var.vm_storage_account
  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Linux images: ubuntu1804, ubuntu2004, centos7, centos8, coreos, rhel7, rhel8
  # Windows Images: windows2016dc, windows2019dc, windows2016dccore
  # MSSQL 2017 images: mssql2017exp, mssql2017dev, mssql2017std, mssql2017ent
  # MSSQL 2019 images: mssql2019dev, mssql2019std, mssql2019ent
  # MSSQL 2019 Linux OS Images:
  # SQL RHEL8 images: mssql2019ent-rhel8, mssql2019std-rhel8, mssql2019dev-rhel8
  # SQL Ubuntu images: mssql2019ent-ubuntu1804, mssql2019std-ubuntu1804, mssql2019dev-ubuntu1804
  # Bring your own License (BOYL) images: mssql2019ent-byol, mssql2019std-byol
  os_distribution               = var.os_distribution
  virtual_machine_size          = var.vm_sizes[var.vm_size]
  admin_username                = var.local_account
  admin_password                = var.local_account_cred
  # generate_admin_ssh_key     = false
  # admin_ssh_key_data         = "~/.ssh/id_rsa.pub"
  instances_count               = var.resource_count
  enable_av_set                 = var.enable_availability_set[var.enable_av_set]
  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # SSH port 22 and 3389 is exposed to the Internet recommended for only testing. 
  # For production environments, recommended to use a VPN or private connection.
  nsg_inbound_rules = [
    {
      name                   = "ssh"
      destination_port_range = "22"
      source_address_prefix  = "*"
    },
  ]

  # Use the block below to add TAG's to your Azure resources (Required)
  # ProjectName and Env are already declared above, to use them here, create a varible. 
  tags = {
    applicationName  = "Cloud Infrastructure Virtual Machine"
    environment      = "Development"
    applicationOwner = "~AzureSupport@fi.com"
    businessUnit     = "IT Infrastructure Engineering"
    costCenter       = "[Cost Center number for Infra Eng here]"
    dataClass        = "Non-Restricted"
    disasterRecovery = "Non-Critical"
    serviceClass     = "Bronze"
    supportOwner     = "~AzureSupport@fi.com"
  }
}
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
Set-PSReadlineOption -HistorySaveStyle SaveNothing
(terraform plan -var "rg_name=[main RG where VM will reside]" -var "vnet_name=[VM NIC virtual network name]" \
  -var "vnet_rg_name=[vnet rg name]" -var "subnet_name=[subnet within vnet for VM NIC]" \
  -var "vm_storage_account=[vm storage account for logs]" -var "vm_size=[small / medium /large]" \
  -var "os_distribution=[centos7 / centos8 / rhel7 / rhel8 / ubuntu18 / ubuntu20 / win2019 / win2016]" \
  -var "vm_hostname=[VM hostname ex. app-function-env]" \
  -var "enable_av_set=[Enable vm availability set - no / yes]" \
  -var "resource_count=[Number of VMs to build - 1]" \
  -var "local_account=[local account name to create on VM]" \
  -var "local_account_cred=[local account login pwd]" -auto-approve) -and (Clear-History)
```
```Shell
# Linux Bash to run terraform plan / apply line
terraform plan -var "rg_name=[main RG where VM will reside]" -var "vnet_name=[VM NIC virtual network name]" \
  -var "vnet_rg_name=[vnet rg name]" -var "subnet_name=[subnet within vnet for VM NIC]" \
  -var "vm_storage_account=[vm storage account for logs]" -var "vm_size=[small / medium /large]" \
  -var "os_distribution=[centos7 / centos8 / rhel7 / rhel8 / ubuntu18 / ubuntu20 / win2019 / win2016]" \
  -var "vm_hostname=[VM hostname ex. app-function-env]" \
  -var "enable_av_set=[Enable vm availability set - no / yes]" \
  -var "resource_count=[Number of VMs to build - 1]" \
  -var "local_account=[local account name to create on VM]" \
  -var "local_account_cred=[local account login pwd]" -auto-approve && history -c
```


## License / Use information

Fisher Investments internal


## Author Information

Cloud Infra Team - ~CloudInfrastructure@fi.com
