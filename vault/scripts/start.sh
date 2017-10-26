!/bin/bash -e 


function main() {

        VAULT_URL="$(ctx node properties "vault_url")"

        # Update system and install dependencies
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get install python python-pip zip rsyslog -y
        sudo pip install serv repex

        # Download Vault, Extract and move to bin folder
        ctx logger info "Downloading vault "
        mkdir ~/downloads/
	echo "${VAULT_URL}" > ~/list.txt
        wget -O ~/downloads/vault.zip ${VAULT_URL}
        ctx logger info "Succesfully downloaded Vault"
	sudo unzip ~/downloads/vault.zip -d /usr/bin
        ctx logger info "Unpacked Vault and moved to bin folder"

        # Configure Vault and setup Serv
        ctx logger info "Configuring Vault server"
        TEMP_VAULT_CONF="$(ctx download-resource-and-render resources/vault.hcl)"
        #TEMP_VAULT_CONF="$(ctx download-resource resources/vault.hcl)"
        sudo mv "${TEMP_VAULT_CONF}" /opt/vault.hcl
        cat "${TEMP_VAULT_CONF}" /opt/vault.hcl > ~/list2.txt
        echo "sudo  mv "${TEMP_VAULT_CONF}" /opt/vault.hcl" >> ~/list.txt
        sudo serv generate vault --name vault --args 'server -config=/opt/vault.hcl' --deploy --start
	ctx logger info "Vault is installed and is running with serv"

        # Setup audit logging to Logentries
        TEMP_RSYSLOG_CONF="$(ctx download-resource-and-render resources/25-le_vault.conf)"
        #TEMP_RSYSLOG_CONF="$(ctx download-resource resources/25-le_vault.conf)"
        sudo mv "${TEMP_RSYSLOG_CONF}" /etc/rsyslog.d/25-le_vault.conf
	sudo touch /var/log/vault.audit
	sudo rpx repl -p /etc/rsyslog.conf -r '\$ModLoad imklog   # provides kernel logging support' -w '$ModLoad imklog   # provides kernel logging support\n$ModLoad imfile # needs to be done just once'
        cat "${TEMP_RSYSLOG_CONF}" > ~/list3.txt
        sudo service rsyslog restart

}

main
