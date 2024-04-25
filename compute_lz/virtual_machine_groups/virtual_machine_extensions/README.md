# Virtual Machine Extensions

## TODO - NOT CONFIRMED WORKING

## Example Settings
```yaml

storageaccounts:
  st1:
    enabled: true
    reuse: true
    name: "avdcuscorppsa01"
    rg_name: "AVA-DEMO-CUS-CORP-PROD-ADMIN-RG"

virtual_machines:
  vm1:
    virtual_machine_extensions:
      microsoft_enterprise_cloud_monitoring:
        enabled: true
        log_analytics_key: "central_logs_ncus1"
        publisher: "Microsoft.EnterpriseCloud.Monitoring"
        type: "MicrosoftMonitoringAgent"     
        type_handler_version: "1.0"
      IaaSAntimalware:
        enabled: true
        log_analytics_key: "central_logs_ncus1"
        publisher: "Microsoft.Azure.Security"
        type: "IaaSAntimalware"        
        type_handler_version: "1.3"
        auto_upgrade_minor_version: true
        AntimalwareEnabled: true
        RealtimeProtectionEnabled: true
        ScheduledScanSettings:
          isEnabled: true
          day: 1
          time: 120
          scanType: Quick
      custom_script1:
        enabled: true
        commandtoexecute: "powershell -ExecutionPolicy Unrestricted -File Rapid7Install.ps1 exit 0"
        fileuri_sa_key: "st1"
        sa_set_storage_creds: true
        fileuris: ["https://avdcuscorppsa01.blob.core.windows.net/agent-installers/Rapid7Install.ps1", "https://avdcuscorppsa01.blob.core.windows.net/agent-installers/rapid7agentInstaller-x86_64.msi"]
        # identity_type: "SystemAssigned"
      AVD_DSC_Extension:
        enabled: true
        name: "AVD_DSC_Extension"
        modulesURL: "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_02-23-2022.zip"
        host_pool:
          host_pool_key: "hostpool1"
          # hostPoolToken: "only use during testing"
          getTokenFromKeyvault: false
          # key_vault_id: "used if getTokenFromKeyvault=true"
          # keyvault_key: "used if getTokenFromKeyvault=true"
      AADLoginForWindows:
        enabled: true
        name: "AADLoginForWindows"
```

## Example Module Reference

```terraform
module "vm_extension_antimalware" {
  source     = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine_extensions"
  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.virtual_machine_extensions.IaaSAntimalware, null) != null
    && try(value.virtual_machine_extensions.IaaSAntimalware.enabled, false) == true
  }

  virtual_machine_id = module.virtual_machines[each.key].id
  extension          = each.value.virtual_machine_extensions.IaaSAntimalware
  extension_name     = "IaaSAntimalware"
  settings = {
    workspace_id              = module.log_analytics_reused[each.value.virtual_machine_extensions.IaaSAntimalware.log_analytics_key].workspace_id
    AntimalwareEnabled        = try(each.value.virtual_machine_extensions.IaaSAntimalware.AntimalwareEnabled, false)
    RealtimeProtectionEnabled = try(each.value.virtual_machine_extensions.IaaSAntimalware.RealtimeProtectionEnabled, false)

    ScheduledScanSettings = {
      isEnabled = try(each.value.virtual_machine_extensions.IaaSAntimalware.ScheduledScanSettings.isEnabled, false)
      day       = try(each.value.virtual_machine_extensions.IaaSAntimalware.ScheduledScanSettings.day, 1)
      time      = try(each.value.virtual_machine_extensions.IaaSAntimalware.ScheduledScanSettings.time, 120)
      scanType  = try(each.value.virtual_machine_extensions.IaaSAntimalware.ScheduledScanSettings.scanType, "Quick")
    }

  }
}

module "vm_extension_monitoring_agent" {
  source     = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine_extensions"
  depends_on = [module.virtual_machines, module.log_analytics_reused]

  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.virtual_machine_extensions.microsoft_enterprise_cloud_monitoring, null) != null
    && try(value.virtual_machine_extensions.microsoft_enterprise_cloud_monitoring.enabled, false) == true
  }

  virtual_machine_id = module.virtual_machines[each.key].id
  extension          = each.value.virtual_machine_extensions.microsoft_enterprise_cloud_monitoring
  extension_name     = "microsoft_enterprise_cloud_monitoring"
  settings = {
    #diagnostics = module.diagnostics
    workspace_id       = module.log_analytics_reused[each.value.virtual_machine_extensions.microsoft_enterprise_cloud_monitoring.log_analytics_key].workspace_id
    primary_shared_key = module.log_analytics_reused[each.value.virtual_machine_extensions.microsoft_enterprise_cloud_monitoring.log_analytics_key].primary_shared_key
  }
}

module "vm_extension_custom_script1" {
  source     = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine_extensions"
  depends_on = [module.virtual_machines]

  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.virtual_machine_extensions.custom_script1, null) != null
    && try(value.virtual_machine_extensions.custom_script1.enabled, false) == true
  }

  virtual_machine_id      = module.virtual_machines[each.key].id
  virtual_machine_os_type = each.value.os_type
  extension               = each.value.virtual_machine_extensions.custom_script1
  extension_name          = "custom_script"
  storage_accounts        = module.storage_account_reused
}

module "vm_extension_avd_dsc" {
  depends_on = [
    module.virtual_machines,
    module.avd_host_pools
  ]
  source = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine_extensions?ref=feature/avd-vm-updates"

  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.virtual_machine_extensions.AVD_DSC_Extension, null) != null
    && try(value.virtual_machine_extensions.AVD_DSC_Extension.enabled, false) == true
  }

  virtual_machine_id = module.virtual_machines[each.key].id
  extension          = each.value.virtual_machine_extensions.AVD_DSC_Extension
  extension_name     = "AVD_DSC_Extension"
  avd_host_pools     = module.avd_host_pools
}

module "vm_extension_AADLoginForWindows" {
  depends_on = [
    module.vm_extension_avd_dsc
  ]
  source = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/compute/virtual_machine_extensions?ref=feature/avd-vm-updates"

  for_each = {
    for key, value in try(local.settings.virtual_machines, {}) : key => value
    if try(value.virtual_machine_extensions.AADLoginForWindows, null) != null
    && try(value.virtual_machine_extensions.AADLoginForWindows.enabled, false) == true
  }

  virtual_machine_id = module.virtual_machines[each.key].id
  extension          = each.value.virtual_machine_extensions.AADLoginForWindows
  extension_name     = "AADLoginForWindows"
}

module "storage_account_reused" {
  source = "[[git_ssh_url]]/[[devOps_org_name]]/[[devOps_project_name]]/[[devOps_repo_name]]//modules/storage_account_reused"
  for_each = {
    for key, value in try(local.settings.storageaccounts, {}) : key => value
    if try(value.enabled, false) == true && try(value.reuse, false) == true
  }

  global_settings = local.settings
  storage_account = each.value
  tags            = try(each.value.tags, null)
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.AADJPrivate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.AADLoginForWindows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.AVD_DSC_Extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.AzureDiskEncryptionLinux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.AzureDiskEncryptionWindows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.GitHubEnterprise](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.GitHubRunner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.InitializeDataDisks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.domainjoin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.iaasantimalware](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.nvidia_gpu_driver_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.promote_vm_domain_controller](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [null_resource.remove_github_runner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_key_vault_secret.LegacyADLoginForWindows_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.LegacyADLoginForWindows_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.hostPoolToken](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.promote_vm_domain_controller_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.promote_vm_domain_controller_domain_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [external_external.storage_account_key](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_domain_mode"></a> [ad\_domain\_mode](#input\_ad\_domain\_mode) | Specifies the domain functional level of the first domain in the creation of a new forest. Supported values for this parameter can be either a valid integer or a corresponding enumerated string value. For instance, to set the domain mode level to Windows Server 2008 R2, you can specify either a value of 4 or Win2008R2. | `string` | `null` | no |
| <a name="input_ad_domain_name"></a> [ad\_domain\_name](#input\_ad\_domain\_name) | Specifies the fully qualified domain name (FQDN) for the domain where the domain controller is installed or added | `string` | `null` | no |
| <a name="input_ad_install_forest"></a> [ad\_install\_forest](#input\_ad\_install\_forest) | Flag to determine if new Domain Controller will be primary server = new forest. Assume YES | `bool` | `true` | no |
| <a name="input_ad_netbios_name"></a> [ad\_netbios\_name](#input\_ad\_netbios\_name) | Specifies the NetBIOS name for the root domain in the new forest. For NetBIOS names to be valid for use with this parameter they must be single label names of 15 characters or less | `string` | `null` | no |
| <a name="input_avd_host_pools"></a> [avd\_host\_pools](#input\_avd\_host\_pools) | Azure Virtual Desktop Pools module object | `map` | `{}` | no |
| <a name="input_extension"></a> [extension](#input\_extension) | Configuration settings object for the Virtual Machine Extension resource | `any` | n/a | yes |
| <a name="input_extension_name"></a> [extension\_name](#input\_extension\_name) | The name of the extension which is used to determine extension script in this module | `string` | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object | `any` | n/a | yes |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | Keyvault ID | `string` | `null` | no |
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | Keyvault module object to store the SSH public and private keys when not provided by the var.public\_key\_pem\_file or retrieve admin username and password | `map` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the VM is provisioned | `string` | `null` | no |
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | Managed Identities module object | `map` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the VM is provisioned | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration sub-settings object for the Virtual Machine Extension resource | `map` | `{}` | no |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Storage Accounts module object | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource | `map` | `{}` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | The ID of the Virtual Machine | `string` | n/a | yes |
| <a name="input_virtual_machine_name"></a> [virtual\_machine\_name](#input\_virtual\_machine\_name) | The Name of the Virtual Machine | `string` | `null` | no |
| <a name="input_virtual_machine_os_type"></a> [virtual\_machine\_os\_type](#input\_virtual\_machine\_os\_type) | VM OS Type | `map` | `{}` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The VM Local Admin Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended). This value is used to domain join a VM. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | The VM Local Admin Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable. | `string` | `null` | no |
| <a name="input_vm_domain_password"></a> [vm\_domain\_password](#input\_vm\_domain\_password) | The VM Domain User Password Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable (not recommended). This value is used to domain join a VM. | `string` | `null` | no |
| <a name="input_vm_domain_username"></a> [vm\_domain\_username](#input\_vm\_domain\_username) | The VM Domain Username Provided by a DevOps Variable Group, KeyVault Secret or Clear Text Variable. This value is used to domain join a VM. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->