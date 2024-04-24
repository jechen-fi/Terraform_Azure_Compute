
resource "azurerm_virtual_machine_extension" "monitoring" {
  for_each = var.extension_name == "microsoft_enterprise_cloud_monitoring" ? toset(["enabled"]) : toset([])

  name = "MicrosoftMonitoringAgent"

  virtual_machine_id   = var.virtual_machine_id
  publisher            = var.extension.publisher
  type                 = var.extension.type
  type_handler_version = var.extension.type_handler_version
  tags                 = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(
    {
      "workspaceId" : var.settings.workspace_id
      #var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].workspace_id
    }
  )
  protected_settings = jsonencode(
    {
      "workspaceKey" : var.settings.primary_shared_key
      #"workspaceKey" : data.external.monitoring_workspace_key["enabled"].result.primarySharedKey
    }
  )

}

# data "azurerm_log_analytics_workspace" "monitoring" {
#   for_each = var.extension_name == "microsoft_enterprise_cloud_monitoring" ? toset(["enabled"]) : toset([])

#   name                = var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].name
#   resource_group_name = var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].resource_group_name
# }

#
# Use data external to retrieve value from azure monitor
#
# With for_each it is not possible to change the provider's subscription at runtime so using the following pattern.
#

# TODO - BStalte - makes this work if LA workspace is in different subscription

# data "external" "monitoring_workspace_key" {
#   for_each = var.extension_name == "microsoft_enterprise_cloud_monitoring" ? toset(["enabled"]) : toset([])
#   program = [
#     "bash", "-c",
#     format(
#       "az monitor log-analytics workspace get-shared-keys --workspace-name '%s' --resource-group '%s' --subscription '%s' --query '{primarySharedKey: primarySharedKey }' -o json",
#       var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].name,
#       var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].resource_group_name,
#       substr(var.settings.diagnostics.log_analytics[var.extension.diagnostic_log_analytics_key].id, 15, 36)
#     )
#   ]
# }
