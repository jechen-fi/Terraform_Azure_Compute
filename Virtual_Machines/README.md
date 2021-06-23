

# Virtual_Machines module

Terraform generalized module to build one or more linux or windows virtual machines.  This could also be used to deploy other VMs Azure marketplace images.

## Requirements

| Name (providers)   | Version  |
|--------------------|----------|
| azurerm            |  2.46.0  |
| tls                |  3.1.0   |
| random             |  3.1.0   |


## Inputs / Variables

A description of the settable variables for this module should go here, including those that are in variables.tf, locals.tf, .tfvars, or those to be passed in from the command line, and it should be noted which ones are required parameters for the module to run and whether or not a default value is provided. Any variables that are read from other modules and/or the main.tf that calls this module would be mentioned here as well.  Please use the Table example below for these.  This is modeled after the terraform-docs tool, in case we decide to use it in the future.

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
| ultrassd | Enable support for use of the UltraSSD_LRS storage account type or not? Defaults to False | `map` | `{ "required" = false }`  |   yes     |
| private_ip_address_allocation_type | Private IP Address Allocation method to be used. Values can be Dynamic or Static. | `map` | `"Dynamic"`  |   yes     |
| private_ip_address | The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` | `string` | `None`  |   no     |
| dns_servers | List of IP Addresses defining the DNS Servers which to use for the network interface | `list` | `None`  |   no     |
| enable_av_set | Enable or disable virtual machine availability set | `bool` | `None`  |   no     |
| enable_feature | Used to manage turning some features on / off | `map` | `default = {
    "yes"    = true
    "y"      = true
    "true"   = true
    "no"     = false
    "n"      = false
    "false"  = false
  }`  |   yes     |


## Dependencies

A list of other modules needed for this module in Terraform that should go here and/or details in regards to parameters that may need to be set for other modules and/or variables that are used from other modules.  These depencies should also be visible via the way they are being supplied in the terraform code themselves in the Example section below (ex. depends_on line in module – depends_on = [module.required_module_name]


## Example call to module (main.tf section that calls it, terraform init command with params, and terraform plan/apply command with params)

Include an example of how to use your module (for instance, provide the main.tf lines from the root calling main.tf as well as the variables that need passing in.  Provide a terraform init example for it and a terraform plan/apply example for it with the required command line variables.  This should be easy to understand and use for someone to run the code


## License / Use information

Fisher Investments internal, BSD, MIT License, Apache 2.0, etc.(see https://opensource.org/licenses)


## Author Information

An optional section for the Terraform module author(s) / authoring team to include contact information for them, or a similar web url.
