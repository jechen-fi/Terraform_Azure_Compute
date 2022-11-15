terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.64.0"
    }
  }
  required_version = ">= 0.14.1"
}

# provider "azurerm" {
#   features {}
# }
