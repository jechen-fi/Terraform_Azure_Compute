data "azurerm_disk_encryption_set" "encryption_set" {
  name                = var.settings.name
  resource_group_name = var.settings.rg_name
}