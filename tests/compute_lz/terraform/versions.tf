terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.32.0"
    }
  }
  required_version = "= 1.1.7"
}

provider "azurerm" {
  features {}
}