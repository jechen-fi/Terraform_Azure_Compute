output "load_balancer_private_ip" {
  description = "The Private IP address allocated for load balancer"
  value       = var.load_balancer_type == "private" ? element(concat(azurerm_lb.vmsslb.*.private_ip_address, [""]), 0) : null
}

output "linux_virtual_machine_scale_set_name" {
  description = "The name of the Linux Virtual Machine Scale Set."
  value       = var.os_type == "linux" ? element(concat(azurerm_linux_virtual_machine_scale_set.linux_vmss.*.name, [""]), 0) : null
}

output "windows_virtual_machine_scale_set_name" {
  description = "The name of the windows Virtual Machine Scale Set."
  value       = var.os_type == "windows" ? element(concat(azurerm_windows_virtual_machine_scale_set.winsrv_vmss.*.name, [""]), 0) : null
}