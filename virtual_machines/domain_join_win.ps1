#Install Active Directory Powershell module
Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature

#domain_token variable pulled from keyvault by terraform
$domain_secret = ConvertTo-SecureString $keyvault_domain_token -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "SVC_INF_AZURE_AD", $domain_secret
$server_group_name = "CLG_$env:COMPUTERNAME Administrators"

Add-Computer -DomainName fidev.com -OUPath "OU=Servers,OU=Common,OU=Azure,OU=Cloud,DC=fidev,DC=com" -Credential $credential
New-ADGroup -Name $server_group_name -SamAccountName $server_group_name -GroupCategory Security -GroupScope Global -DisplayName $server_group_name -Path "OU=Admin Permissions Groups,OU=Common,OU=Azure,OU=Cloud,DC=fidev,DC=com" -Description "This group contains the administrators for server $env:COMPUTERNAME" -Credential $credential
Add-ADGroupMember -Identity $server_group_name -Members "Cloud-Domain-Admin-Members-group", $app_workload_group -Credential $credential
Restart-Computer -Force