terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 0.3.0"
    }
  }
  required_version = ">= 0.15.5"
  experiments      = [module_variable_optional_attrs]
}

provider "azapi" {
}