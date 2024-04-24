terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  os_type = lower(var.settings.os_type)
  # Generate SSH Keys only if a public one is not provided
  # Added override to disable creation of SSH Keys if planning to only use admin creds
  create_sshkeys = (local.os_type == "linux" || local.os_type == "legacy") && try(var.settings.public_key_pem_file == "", true) && try(var.settings.create_sshkeys, true)
  tags           = merge(var.tags, var.global_settings.tags, try(var.settings.tags, null))

  #
  # Get the admin username and password from keyvault
  #
  admin_username = try(data.external.windows_admin_username.0.result.value, null)
  admin_password = try(data.external.windows_admin_password.0.result.value, null)
}