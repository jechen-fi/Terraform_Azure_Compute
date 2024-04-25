locals {
  dynamic_custom_data = {
    palo_alto_connection_string = {
      for item in var.settings.virtual_machine_settings :
      item.name => base64encode("storage-account=${var.storage_accounts[item.palo_alto_connection_string.storage_account].name}, access-key=${var.storage_accounts[item.palo_alto_connection_string.storage_account].primary_access_key}, file-share=${var.storage_accounts[item.palo_alto_connection_string.storage_account].file_share[item.palo_alto_connection_string.file_share].name}, share-directory=${var.storage_accounts[item.palo_alto_connection_string.storage_account].file_share[item.palo_alto_connection_string.file_share].file_share_directories[item.palo_alto_connection_string.file_share_directory].name}")
      if try(item.palo_alto_connection_string, null) != null
    }

    citrix_adc_vpx_ha = {
      for item in var.settings.virtual_machine_settings :
      item.name => base64encode(<<-EOT
          <NS-PRE-BOOT-CONFIG>
            <NS-CONFIG>
              %{if item.citrix_adc_vpx_ha.enable_ha_for_internal_lb && item.citrix_adc_vpx_ha.add_vip}
                add ns ip ${item.citrix_adc_vpx_ha.ha_internal_lb.private_ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha.vnet_key].subnets[item.citrix_adc_vpx_ha.citrix_adc_client_subnet_key].cidr.0)} -type VIP
              %{endif}
              %{if !item.citrix_adc_vpx_ha.enable_ha_for_internal_lb && item.citrix_adc_vpx_ha.add_vip}
                add ns ip ${var.public_ip_addresses[item.citrix_adc_vpx_ha.public_ip_address_key].ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha.vnet_key].subnets[item.citrix_adc_vpx_ha.citrix_adc_client_subnet_key].cidr.0)} -type VIP
              %{endif}
              add ns ip ${azurerm_network_interface.nic["client-nic"].private_ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha.vnet_key].subnets[item.citrix_adc_vpx_ha.citrix_adc_client_subnet_key].cidr.0)} -type SNIP
              add ns ip ${azurerm_network_interface.nic["server-nic"].private_ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha.vnet_key].subnets[item.citrix_adc_vpx_ha.citrix_adc_server_subnet_key].cidr.0)} -type SNIP
              set systemparameter -promptString "%u@%s"
              add ha node 1 ${item.citrix_adc_vpx_ha.ha_node.adc-mgmt-nic.private_ip_address} -inc ENABLED
              set ns rpcNode ${item.citrix_adc_vpx_ha.rpc_node1.adc-mgmt-nic.private_ip_address} -password ${coalesce(try(var.additional_settings.citrix_adc_vpx_ha.rpc_node1.rpc_node_password, null), item.citrix_adc_vpx_ha.rpc_node1.rpc_node_password)} -secure YES
              set ns rpcNode ${item.citrix_adc_vpx_ha.rpc_node2.adc-mgmt-nic.private_ip_address} -password ${coalesce(try(var.additional_settings.citrix_adc_vpx_ha.rpc_node2.rpc_node_password, null), item.citrix_adc_vpx_ha.rpc_node2.rpc_node_password)} -secure YES
            </NS-CONFIG>
          </NS-PRE-BOOT-CONFIG>
        EOT
      )
      if try(item.citrix_adc_vpx_ha, null) != null
    }

    citrix_adc_vpx_ha_custom = {
      for item in var.settings.virtual_machine_settings :
      item.name => base64encode(<<-EOT
          <NS-PRE-BOOT-CONFIG>
            <NS-CONFIG>
              add ns ip ${azurerm_network_interface.nic["infra-nic"].private_ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha_custom.vnet_key].subnets[item.citrix_adc_vpx_ha_custom.citrix_adc_infra_subnet_key].cidr.0)} -type VIP
              add ns ip ${azurerm_network_interface.nic["dmz-nic"].private_ip_address} ${cidrnetmask(var.virtual_networks[item.citrix_adc_vpx_ha_custom.vnet_key].subnets[item.citrix_adc_vpx_ha_custom.citrix_adc_dmz_subnet_key].cidr.0)} -type SNIP
              set systemparameter -promptString "%u@%s"
              add ha node 1 ${item.citrix_adc_vpx_ha_custom.ha_node.adc-infra-nic.private_ip_address} -inc ENABLED
              set ns rpcNode ${item.citrix_adc_vpx_ha_custom.rpc_node1.adc-infra-nic.private_ip_address} -password ${coalesce(try(var.additional_settings.citrix_adc_vpx_ha_custom.rpc_node1.rpc_node_password, null), item.citrix_adc_vpx_ha_custom.rpc_node1.rpc_node_password)} -secure YES
              set ns rpcNode ${item.citrix_adc_vpx_ha_custom.rpc_node2.adc-infra-nic.private_ip_address} -password ${coalesce(try(var.additional_settings.citrix_adc_vpx_ha_custom.rpc_node2.rpc_node_password, null), item.citrix_adc_vpx_ha_custom.rpc_node2.rpc_node_password)} -secure YES
            </NS-CONFIG>
          </NS-PRE-BOOT-CONFIG>
        EOT
      )
      if try(item.citrix_adc_vpx_ha_custom, null) != null
    }

  }
}
