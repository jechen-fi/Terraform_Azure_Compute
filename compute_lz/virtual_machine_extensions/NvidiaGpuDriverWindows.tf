# https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-windows

resource "azurerm_virtual_machine_extension" "nvidia_gpu_driver_windows" {
  for_each                   = var.extension_name == "NvidiaGpuDriverWindows" ? toset(["enabled"]) : toset([])
  name                       = try(var.extension.name, "NvidiaGpuDriverWindows")
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = try(var.extension.publisher, "Microsoft.HpcCompute")
  type                       = try(var.extension.type, "NvidiaGpuDriverWindows")
  type_handler_version       = try(var.extension.type_handler_version, "1.4")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, null)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, null)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  # settings = jsonencode(
  #   {
  #     "" : ""
  #   }
  # )

}
