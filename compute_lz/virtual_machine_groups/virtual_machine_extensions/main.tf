terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  tags = merge(var.tags, var.global_settings.tags, try(var.extension.tags, {}))
}
