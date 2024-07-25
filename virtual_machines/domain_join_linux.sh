#!/bin/bash

#
# TEST SCRIPT VARS FROM TF
#

exec >> /etc/adlogs/script.log

domain=""

echo "domain_acct is : ${domain_acct}"
echo "app_group is : ${app_group}"
echo "wf_env is : ${wf_env}"
echo "domain_secret passed in as : ${domain_secret}"

#filter for fi or fidev and set var
if [[ "$wf_env" == *"dev"* ]] || [[ "$wf_env" == *"sit"* ]]; then
domain="FIDEV"
elif [[ "$wf_env" == *"qa"* ]] || [[ "$wf_env" == *"prd"* ]] || [[ "$wf_env" == "d" ]] || [[ "$wf_env" == "s" ]] || [[ "$wf_env" == "u" ]] || [[ "$wf_env" == "p" ]]; then
domain="FI"
else
    echo "environment and domain not determined"
fi

echo "domain reported: $${domain}"


#
# END TEST
#

# #install required packages
# yum install -y sssd sssd-client sssd-tools oddjob-mkhomedir samba-common-tools oddjob krb5-workstation authselect-compat adcli realmd


# vmname=$(hostname)
# vmgroup="clg_$${vmname} administrators"


# #filter for fi or fidev and set var
# if [ "$wf_env" == "dev" ] || [ "$wf_env" == "sit" ]; then
# domain="FIDEV"
# elif [ "$wf_env" == "qa" ] || [ "$wf_env" == "prd" ] || [ "$wf_env" == "d" ] || [ "$wf_env" == "s" ] || [ "$wf_env" == "u" ] || [ "$wf_env" == "p" ]; then
# domain="FI"
# else
#     echo "environment and domain not determined" && exit
# fi

# DOMAIN="$${domain}.COM"
# MACHINENAME="$${vmname}.$${DOMAIN}"

# #Set hostname
# hostnamectl set-hostname $$MACHINENAME

# #Configure SSSD
# echo "Configuring SSSD..."
# cat <<EOF > /etc/sssd/sssd.conf
# [sssd]
# services = nss, pam
# config_file_version = 2
# domains = $$DOMAIN
# dyndns_update = true
# dyndns_refresh_interval = 43200
# dyndns_update_ptr = true
# dyndns_ttl = 3600
 
# [domain/$$DOMAIN]
# ad_domain = $$DOMAIN
# krb5_realm = $$DOMAIN
# realmd_tags = manages-system joined-with-adcli
# cache_credentials = True
# id_provider = ad
# access_provider = simple
# krb5_store_password_if_offline = True
# fallback_homedir = /home/%u%d
# default_shell = /bin/bash
# ldap_id_mapping = True
# use_fully_qualified_names = True
# EOF
 
# #Restart SSSD
# echo "Restarting and autostarting SSSD cause systemd is bad"
# systemctl restart sssd
# systemctl enable sssd

# #join domain
# realm join --user="${domain_acct}" "$${DOMAIN}" --computer-ou="OU=Linux Servers,OU=Common,OU=Azure,OU=Cloud,DC=$${domain},DC=COM" --verbose

# #create host group from passed in variable

# adcli create-group "$${vmgroup}" --domain="$${DOMAIN}" --domain-ou="OU=Admin Permissions Groups,OU=Common,OU=Azure,OU=Cloud,DC=$${domain},DC=com" \
# --login-user="${domain_acct}" --stdin-password="${domain_secret}"

# #populate group with clg account passed in from variable
# adcli add-member --domain="$${DOMAIN}" "$${vmgroup}" "${app_group}" --login-user="${domain_acct}" --stdin-password="${domain_secret}"

# #add group to permit login
 
# realm permit -g "$${vmgroup}@$${DOMAIN}"

# echo ""$${vmgroup}@$${DOMAIN}" ALL=(ALL) ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/sudo-access-ad-users
# chmod 440 /etc/sudoers.d/sudo-access-ad-users
 
# #restart
# reboot