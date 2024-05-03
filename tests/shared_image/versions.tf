terraform {
  backend "azurerm" {}
  required_version = "= 1.1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }    
  }
}

provider "azurerm" {
  features {
    }
}