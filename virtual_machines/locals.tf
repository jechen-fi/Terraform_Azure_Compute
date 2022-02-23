locals {

  virtual_machine_name = try(lower(var.virtual_machine_name), lower(format("%s%s%s", var.virtual_machine_name_prepend, "-", var.application_env)))

  os_type = var.os_distribution_list[var.os_distribution]["os_type"]

  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }
}

locals {

  subscription_id = var.subscription_id == "" ? data.azurerm_client_config.current.subscription_id : var.subscription_id

}