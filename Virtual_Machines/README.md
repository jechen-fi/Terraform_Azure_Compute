

# Virtual_Machines module

Terraform generalized module to build one or more linux or windows virtual machines.  This could also be used to deploy other VMs Azure marketplace images.

## Requirements

|-------------------|---------|
| Name              | Version |
|-------------------|---------|
| null              | n/a     |


## Inputs / Variables
## -----------------------------------

A description of the settable variables for this module should go here, including those that are in variables.tf, locals.tf, .tfvars, or those to be passed in from the command line, and it should be noted which ones are required parameters for the module to run and whether or not a default value is provided. Any variables that are read from other modules and/or the main.tf that calls this module would be mentioned here as well.  Please use the Table example below for these.  This is modeled after the terraform-docs tool, in case we decide to use it in the future.


|-------------------|------------------------------------------|---------|-----------------|----------|
| Name              | Description                              | Type    | Default Value   | Required |
|-------------------|------------------------------------------|---------|-----------------|:--------:|
| test              | Example test variable that does a, b, c… | `string`| `”valid_test”`  |   no     |


## Dependencies
## -----------------------------------

A list of other modules needed for this module in Terraform that should go here and/or details in regards to parameters that may need to be set for other modules and/or variables that are used from other modules.  These depencies should also be visible via the way they are being supplied in the terraform code themselves in the Example section below (ex. depends_on line in module – depends_on = [module.required_module_name]


## Example call to module (main.tf section that calls it, terraform init command with params, and terraform plan/apply command with params)
## -----------------------------------

Include an example of how to use your module (for instance, provide the main.tf lines from the root calling main.tf as well as the variables that need passing in.  Provide a terraform init example for it and a terraform plan/apply example for it with the required command line variables.  This should be easy to understand and use for someone to run the code


## License / Use information
## -----------------------------------

Fisher Investments internal, BSD, MIT License, Apache 2.0, etc.(see https://opensource.org/licenses)


## Author Information
## -----------------------------------

An optional section for the Terraform module author(s) / authoring team to include contact information for them, or a similar web url.
