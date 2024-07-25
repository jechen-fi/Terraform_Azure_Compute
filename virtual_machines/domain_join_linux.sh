#!/bin/bash

# Required vars to come from Terraform during script extension execution
# echo "wf_env is  ${wf_env}"
# echo "domain_secret passed in as  ${domain_secret}"

#filter for fi or fidev and set var
if [[ "${wf_env}" == "dev" ]] || [[ "${wf_env}" == "sit" ]]; then
domain="FIDEV"
elif [[ "${wf_env}" == "qa" ]] || [[ "${wf_env}" == "prd" ]]; then
domain="FI"
else
    echo "environment and domain not determined"
fi

echo "domain reported $${domain}"

#install required packages
yum install -y sssd sssd-client sssd-tools oddjob-mkhomedir samba-common-tools oddjob krb5-workstation authselect-compat adcli realmd

domain_acct="SVC_INF_AZURE_AD"
vmname=$(hostname)
vmgroup="clg_$${vmname} administrators"
DOMAIN="$${domain}.COM"
MACHINENAME="$${vmname}.$${DOMAIN}"
sudoers="%clg_$${vmname}\ administrators"

#Set hostname
hostnamectl set-hostname $${MACHINENAME}

#join domain
echo ${domain_secret} | realm join --user=$${domain_acct} $${DOMAIN} --computer-ou="OU=Linux Servers,OU=Common,OU=Azure,OU=Cloud,DC=$${domain},DC=COM"

#Configure SSSD
echo "Configuring SSSD..."
cat <<EOF > /etc/sssd/sssd.conf
[sssd]
domains = $${DOMAIN}
config_file_version = 2
services = nss, pam
default_domain_suffix = $${DOMAIN}
dyndns_update = true
dyndns_refresh_interval = 43200
dyndns_update_ptr = true
dyndns_ttl = 3600
 
[domain/$$DOMAIN]
ad_domain = $$DOMAIN
krb5_realm = $$DOMAIN
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
access_provider = simple
krb5_store_password_if_offline = True
fallback_homedir = /home/%u%d
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = True
EOF
 
#Restart SSSD
echo "Restarting and autostarting SSSD cause systemd is bad"
systemctl restart sssd
systemctl enable sssd


#create vm admin group
echo ${domain_secret} | adcli create-group "$${vmgroup}" --domain=$${DOMAIN} --domain-ou="OU=Admin Permissions Groups,OU=Common,OU=Azure,OU=Cloud,DC=$${domain},DC=com" --login-user=$${domain_acct} --stdin-password

##populate vm group with clg app group - not possible to nest groups with adcli
#echo ${domain_secret} | adcli add-member --domain=$${DOMAIN} "$${vmgroup}" "$${app_group}" --login-user=$${domain_acct} --stdin-password


#add group to permit login 
realm permit -g "$${vmgroup}@$${DOMAIN}"

#add group to sudoers
echo ""$${sudoers}@$${DOMAIN}" ALL=(ALL) ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/sudo-access-ad-users
chmod 440 /etc/sudoers.d/sudo-access-ad-users

echo "Please have users request access to $${vmgroup} in $${DOMAIN}"
 
#restart
reboot