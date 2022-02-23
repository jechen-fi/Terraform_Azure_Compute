terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.93.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  required_version = ">= 0.15.5"
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
  alias           = "image-sub"
}
