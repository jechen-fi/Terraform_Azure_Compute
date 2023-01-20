terraform {
  backend "azurerm" {}
  required_version = "= 1.1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.12.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "= 0.7.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.25.0"
    }
  }
}

provider "azurerm" {
  features {
      key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.mgmt_subscription_id
  alias           = "mgmt-sub"
}