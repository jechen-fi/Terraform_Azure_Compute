#Install Active Directory Powershell module
[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$appworkloadgroup
)

#$password = ConvertTo-SecureString -AsPlainText $AdmincredsPassword -Force

Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
New-Item -Path "c:\" -Name $appworkloadgroup -ItemType "directory"

#domain_token variable pulled from keyvault by terraform
#$domain_secret = ConvertTo-SecureString $keyvault_domain_token -AsPlainText -Force
#$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "USERACCOUNT", $domain_secret
#$server_group_name = "$env:COMPUTERNAME Administrators"

#Add-Computer -DomainName fidev.com -OUPath "OUPATH" -Credential $credential
#New-ADGroup -Name $server_group_name -SamAccountName $server_group_name -GroupCategory Security -GroupScope Global -DisplayName $server_group_name -Path "OUPATH" -Description "This group contains the administrators for server $env:COMPUTERNAME" -Credential $credential
#Add-ADGroupMember -Identity $server_group_name -Members "Cloud-Domain-Admin-Members-group" -Credential $credential
#Restart-Computer -Force