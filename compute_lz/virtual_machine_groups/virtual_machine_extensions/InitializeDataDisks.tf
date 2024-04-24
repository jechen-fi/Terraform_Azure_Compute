resource "azurerm_virtual_machine_extension" "InitializeDataDisks" {
  for_each                   = var.extension_name == "InitializeDataDisks" ? toset(["enabled"]) : toset([])
  name                       = try(var.extension.name, "InitializeDataDisks")
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = try(var.extension.publisher, "Microsoft.Compute")
  type                       = try(var.extension.type, "CustomScriptExtension")
  type_handler_version       = try(var.extension.type_handler_version, "1.10")
  auto_upgrade_minor_version = try(var.extension.auto_upgrade_minor_version, null)
  automatic_upgrade_enabled  = try(var.extension.automatic_upgrade_enabled, null)
  tags                       = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  settings = jsonencode(
    {
      "commandToExecute" : "powershell.exe -Command \"${local.ps_init_disk_ps_cmd}\""
    }
  )

}

locals {

  # Examples

  # Get-Disk | Where-Object PartitionStyle -Eq "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "data" -Confirm:$false"

  # Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "data" -Confirm:$false"

  ps_init_disk_PartitionStyle     = try(var.extension.PartitionStyle, "GPT")
  ps_init_disk_DriveLetter        = try(var.extension.DriveLetter, "")
  ps_init_disk_DriveLetter_cmd    = local.ps_init_disk_DriveLetter != "" ? "-DriveLetter ${local.ps_init_disk_DriveLetter}" : "-AssignDriveLetter"
  ps_init_disk_FileSystem         = try(var.extension.FileSystem, "NTFS")
  ps_init_disk_NewFileSystemLabel = try(var.extension.NewFileSystemLabel, null) != null ? "-NewFileSystemLabel ${var.extension.NewFileSystemLabel}" : ""

  ps_init_disk_ps_cmd = "Get-Disk | Where-Object PartitionStyle -Eq \"RAW\" | Initialize-Disk -PartitionStyle ${local.ps_init_disk_PartitionStyle} -PassThru | New-Partition ${local.ps_init_disk_DriveLetter_cmd} -UseMaximumSize | Format-Volume -FileSystem ${local.ps_init_disk_FileSystem} ${local.ps_init_disk_NewFileSystemLabel} -Confirm:$false"

}
