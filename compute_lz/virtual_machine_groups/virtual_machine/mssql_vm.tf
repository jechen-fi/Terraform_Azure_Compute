resource "azurerm_mssql_virtual_machine" "mssqlvm" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings, null) != null
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.disk,
    random_password.sql_admin_password,
    random_password.encryption_password

  ]

  virtual_machine_id               = local.os_type == "windows" ? try(azurerm_windows_virtual_machine.vm[each.key].id, null) : try(azurerm_linux_virtual_machine.vm[each.key].id, null)
  sql_license_type                 = try(each.value.mssql_settings.sql_license_type, null)
  r_services_enabled               = try(each.value.mssql_settings.r_services_enabled, null)
  sql_connectivity_port            = try(each.value.mssql_settings.sql_connectivity_port, null)
  sql_connectivity_type            = try(each.value.mssql_settings.sql_connectivity_type, null)
  tags                             = merge(local.tags, try(each.value.tags, null))
  sql_connectivity_update_username = try(each.value.mssql_settings.sql_authentication.sql_credential.sql_username, data.external.sql_username[each.key].result.value, null)

  sql_connectivity_update_password = try(coalesce(
    try(data.external.sql_password[each.key].result.value, null),
    try(random_password.sql_admin_password[each.key].result, null),
  ), null)

  dynamic "sql_instance" {
    for_each = try(each.value.mssql_settings.sql_instance, null) != null ? [each.value.mssql_settings.sql_instance] : []

    content {
      adhoc_workloads_optimization_enabled = try(sql_instance.value.adhoc_workloads_optimization_enabled, false)
      collation                            = try(sql_instance.value.collation, "SQL_Latin1_General_CP1_CI_AS")
      instant_file_initialization_enabled  = try(sql_instance.value.instant_file_initialization_enabled, false)
      lock_pages_in_memory_enabled         = try(sql_instance.value.lock_pages_in_memory_enabled, false)
      max_dop                              = try(sql_instance.value.max_dop, 0)
      max_server_memory_mb                 = try(sql_instance.value.max_server_memory_mb, 2147483647)
      min_server_memory_mb                 = try(sql_instance.value.min_server_memory_mb, 0)
    }
  }

  dynamic "auto_backup" {
    for_each = try(each.value.mssql_settings.auto_backup, null) != null ? [1] : []

    content {
      encryption_enabled = try(each.value.mssql_settings.auto_backup.encryption_password, null) != null ? true : false
      encryption_password = try(each.value.mssql_settings.auto_backup.encryption_password, null) != null ? try(coalesce(
        try(random_password.encryption_password[each.key].result, null),
        try(data.external.backup_encryption_password[each.key].result.value, null)
      ), null) : null
      retention_period_in_days        = each.value.mssql_settings.auto_backup.retention_period_in_days
      system_databases_backup_enabled = try(each.value.mssql_settings.auto_backup.system_databases_backup_enabled, null)
      storage_account_access_key      = data.azurerm_storage_account.mssqlvm_backup_sa[each.key].primary_access_key
      storage_blob_endpoint           = try(var.storage_accounts[each.value.mssql_settings.auto_backup.storage_account.key].primary_blob_endpoint, null)

      dynamic "manual_schedule" {
        for_each = try(each.value.mssql_settings.auto_backup.manual_schedule, null) != null ? [1] : []

        content {
          full_backup_frequency           = try(each.value.mssql_settings.auto_backup.manual_schedule.full_backup_frequency, null)
          full_backup_start_hour          = try(each.value.mssql_settings.auto_backup.manual_schedule.full_backup_start_hour, null)
          full_backup_window_in_hours     = try(each.value.mssql_settings.auto_backup.manual_schedule.full_backup_window_in_hours, null)
          log_backup_frequency_in_minutes = try(each.value.mssql_settings.auto_backup.manual_schedule.log_backup_frequency_in_minutes, null)
        }
      }

    }
  }

  dynamic "auto_patching" {
    for_each = try(each.value.mssql_settings.auto_patching, null) != null ? [1] : []

    content {
      day_of_week                            = each.value.mssql_settings.auto_patching.day_of_week
      maintenance_window_duration_in_minutes = each.value.mssql_settings.auto_patching.maintenance_window_duration_in_minutes
      maintenance_window_starting_hour       = each.value.mssql_settings.auto_patching.maintenance_window_starting_hour
    }
  }

  dynamic "key_vault_credential" {
    for_each = try(each.value.mssql_settings.sql_authentication.keyvault_credential, null) != null ? [1] : []

    content {
      name                     = each.value.mssql_settings.sql_authentication.keyvault_credential.name
      key_vault_url            = try(var.keyvaults[each.value.mssql_settings.sql_authentication.keyvault_credential.keyvault_key].vault_uri, null)
      service_principal_name   = try(data.external.sp_client_id[each.key].result.value, null)
      service_principal_secret = try(data.external.sp_client_secret[each.key].result.value, null)
    }
  }

  dynamic "storage_configuration" {
    for_each = try(each.value.mssql_settings.storage_configuration, null) != null ? [1] : []

    content {
      disk_type                      = each.value.mssql_settings.storage_configuration.disk_type
      storage_workload_type          = each.value.mssql_settings.storage_configuration.storage_workload_type
      system_db_on_data_disk_enabled = try(each.value.mssql_settings.storage_configuration.system_db_on_data_disk_enabled, false)

      dynamic "data_settings" {
        for_each = try(each.value.mssql_settings.storage_configuration.data_settings, null) != null ? [1] : []

        content {
          default_file_path = each.value.mssql_settings.storage_configuration.data_settings.default_file_path
          luns              = each.value.mssql_settings.storage_configuration.data_settings.luns
        }
      }
      dynamic "log_settings" {
        for_each = try(each.value.mssql_settings.storage_configuration.log_settings, null) != null ? [1] : []

        content {
          default_file_path = each.value.mssql_settings.storage_configuration.log_settings.default_file_path
          luns              = each.value.mssql_settings.storage_configuration.log_settings.luns
        }
      }
      dynamic "temp_db_settings" {
        for_each = try(each.value.mssql_settings.storage_configuration.temp_db_settings, null) != null ? [1] : []

        content {
          default_file_path = each.value.mssql_settings.storage_configuration.temp_db_settings.default_file_path
          luns              = each.value.mssql_settings.storage_configuration.temp_db_settings.luns
        }
      }

    }
  }

}


# storage account sas

data "azurerm_storage_account" "mssqlvm_backup_sa" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.auto_backup, null) != null
  }

  name                = try(var.storage_accounts[each.value.mssql_settings.auto_backup.storage_account.key].name, null)
  resource_group_name = try(var.storage_accounts[each.value.mssql_settings.auto_backup.storage_account.key].resource_group_name, null)
}


# Use data external to retrieve value from azure keyvault

data "external" "sql_username" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.sql_credential, null) != null && try(value.mssql_settings.sql_authentication.sql_credential.sql_username_key, null) != null
  }

  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      each.value.mssql_settings.sql_authentication.sql_credential.sql_username_key,
      try(var.keyvaults[each.value.mssql_settings.sql_authentication.sql_credential.keyvault_key].name, null)
    )
  ]
}

data "external" "sql_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.sql_credential.sql_password_key, null) != null
  }

  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      each.value.mssql_settings.sql_authentication.sql_credential.sql_password_key,
      try(var.keyvaults[each.value.mssql_settings.sql_authentication.sql_credential.keyvault_key].name, null)
    )
  ]
}


data "external" "backup_encryption_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.auto_backup.encryption_password.encryption_password_key, null) != null
  }

  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      each.value.mssql_settings.auto_backup.encryption_password.encryption_password_key,
      try(var.keyvaults[each.value.mssql_settings.auto_backup.encryption_password.keyvault_key].name, null)
    )
  ]
}


data "external" "sp_client_id" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets, null) != null
  }

  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      each.value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets.sp_client_id_key,
      try(var.keyvaults[each.value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets.keyvault_key].name, null)
    )
  ]
}

data "external" "sp_client_secret" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets, null) != null
  }

  program = [
    "bash", "-c",
    format(
      "az keyvault secret show --name '%s' --vault-name '%s' --query '{value: value }' -o json",
      each.value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets.sp_client_secret_key,
      try(var.keyvaults[each.value.mssql_settings.sql_authentication.keyvault_credential.service_principal_secrets.keyvault_key].name, null)
    )
  ]
}

# Generate password for sql admin
resource "random_password" "sql_admin_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.sql_credential.sql_password_key, null) == null && try(value.mssql_settings, null) != null
  }

  length           = 100
  special          = true
  upper            = true
  numeric          = true
  override_special = "$#%"
}

# Store the generated password into keyvault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.sql_authentication.sql_credential.sql_password_key, null) == null && try(value.mssql_settings, null) != null
  }

  name         = can(each.value.mssql_settings.sql_authentication.sql_credential.keyvault_secret_name) ? each.value.mssql_settings.sql_authentication.sql_credential.keyvault_secret_name : format("%s-mssql-login-pw", azurerm_windows_virtual_machine.vm[each.key].name)
  value        = random_password.sql_admin_password[each.key].result
  key_vault_id = try(var.keyvaults[each.value.mssql_settings.sql_authentication.sql_credential.keyvault_key].id, null)

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "random_password" "encryption_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings, null) != null
  }
  # Encryption password must be generated on first apply thus condition is removed to ensure creation first.

  # for_each = {
  #   for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
  #   if try(value.mssql_settings.auto_backup.encryption_password, null) != null && try(value.mssql_settings.auto_backup.encryption_password.encryption_password_key, null) == null
  # }

  length           = 100
  special          = true
  upper            = true
  numeric          = true
  override_special = "$#%"
}

# Store the generated password into keyvault
resource "azurerm_key_vault_secret" "backup_encryption_password" {
  for_each = {
    for key, value in try(var.settings.virtual_machine_settings, {}) : key => value
    if try(value.mssql_settings.auto_backup.encryption_password, null) != null && try(value.mssql_settings.auto_backup.encryption_password.encryption_password_key, null) == null && try(value.mssql_settings, null) != null
  }

  name         = can(each.value.mssql_settings.auto_backup.encryption_password.encryption_password_secret_name) ? each.value.mssql_settings.auto_backup.encryption_password.encryption_password_secret_name : format("%s-mssql-bkup-encryption-pw", azurerm_windows_virtual_machine.vm[each.key].name)
  value        = random_password.encryption_password[each.key].result
  key_vault_id = try(var.keyvaults[each.value.mssql_settings.auto_backup.encryption_password.keyvault_key].id, null)

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
