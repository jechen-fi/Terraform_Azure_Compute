terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.64.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.0"
    }
  }
  required_version = "= 0.15.5"
}

provider "azurerm" {
  features {}
}