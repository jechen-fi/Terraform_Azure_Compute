[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$appworkloadgroup,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$keyvaultdomaintoken,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$domainsvcaccount
)

#Install Active Directory Powershell module
Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
New-Item -Path "c:\" -Name $appworkloadgroup -ItemType "directory"

#domain_token variable pulled from keyvault by terraform
$domain_secret = ConvertTo-SecureString $keyvaultdomaintoken -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainsvcaccount, $domain_secret
$server_group_name = "CLG_$env:COMPUTERNAME Administrators"


$computername = $env:COMPUTERNAME

if ($computername -like "*dev*" -or $computername -like "*sit*"){
    Add-Computer -DomainName fidev.com -OUPath "OU=Servers,OU=Common,OU=Azure,OU=Cloud,DC=fidev,DC=com" -Credential $credential
    New-ADGroup -Name $server_group_name -SamAccountName $server_group_name -GroupCategory Security -GroupScope Global -DisplayName $server_group_name -Path "OU=Admin Permissions Groups,OU=Common,OU=Azure,OU=Cloud,DC=fidev,DC=com" -Description "This group contains the administrators for server $env:COMPUTERNAME" -Credential $credential
    Add-ADGroupMember -Identity $server_group_name -Members $appworkloadgroup, "Cloud-Domain-Admin-Members-group" -Credential $credential
}
elseif ($computername -like "*qa*" -or $computername -like "*prd*"){
    Add-Computer -DomainName fi.com -OUPath "OU=Servers,OU=Common,OU=Azure,OU=Cloud,DC=fi,DC=com" -Credential $credential
    New-ADGroup -Name $server_group_name -SamAccountName $server_group_name -GroupCategory Security -GroupScope Global -DisplayName $server_group_name -Path "OU=Admin Permissions Groups,OU=Common,OU=Azure,OU=Cloud,DC=fi,DC=com" -Description "This group contains the administrators for server $env:COMPUTERNAME" -Credential $credential
    Add-ADGroupMember -Identity $server_group_name -Members $appworkloadgroup, "CRG-Cloud_Infra_Admins" -Credential $credential
}
else{
    throw "COMPUTER OBJECT HAS NO ENVIRONMENT"
}

Restart-Computer -Force