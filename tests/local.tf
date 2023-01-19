locals {
  local_variables = {
    environment = var.environment
    location    = var.location
  }
  admin_password = "Test!@#123"
  admin_username = "adminUser"
}

locals {
  tags = {
    applicationName = "VM & Extension module testing"
    environment     = "CTD"
  }
  script_uri = ["https://a00004sbxst001.blob.core.windows.net/artifacts/wrapper2.ps1","https://a00004sbxst001.blob.core.windows.net/artifacts/test1.ps1","https://a00004sbxst001.blob.core.windows.net/artifacts/test2.ps1"]
}