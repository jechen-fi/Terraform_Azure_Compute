terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.64.0"
    }
  }
  required_version = ">= 0.14.1, < 1.0.0"
}

provider "azurerm" {
  features {}
}
