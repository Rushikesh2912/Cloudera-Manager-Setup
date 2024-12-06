 
#!/bin/bash

# Script to install and configure NSCD and SSSD on RHEL 8


        #        Ensures that each command runs successfully and exits if any command fails.
	#	Installing Packages:
	#	NSCD: Name Service Caching Daemon, used to cache lookups for NIS, DNS, and LDAP.
	#	SSSD: System Security Services Daemon, provides access to different identity and authentication providers.
	#	Service Configuration:
	#	NSCD: Enabled and started.
	#	SSSD: Enabled and started. Also, an example configuration file /etc/sssd/sssd.conf is created for a simple LDAP setup. You should replace example.com and ldap.example.com with your actual domain and LDAP server information.
	#	Permissions: Proper permissions are set for /etc/sssd/sssd.conf to ensure only root can read or modify it.

#Example of SSSD Configuration:

#The SSSD configuration provided in the script is for an LDAP-based setup. Adjust the following fields to match your environment:

#	domains = example.com: Replace with your domain.
#	ldap_uri = ldap://ldap.example.com: Replace with your LDAP server URI.
#	ldap_search_base = dc=example,dc=com: Replace with the correct LDAP search base for your domain.





# Function to check for command success and exit if failed
check_command() {
  if [[ $? -ne 0 ]]; then
    echo "ERROR: $1 failed."
    exit 1
  fi
}

# Update the system package index
echo "Updating system package index..."
sudo yum update -y
check_command "System update"

# Install NSCD (Name Service Caching Daemon)
echo "Installing NSCD..."
sudo yum install -y nscd
check_command "NSCD installation"

# Install SSSD (System Security Services Daemon)
echo "Installing SSSD..."
sudo yum install -y sssd
check_command "SSSD installation"

# Enable and start NSCD service
echo "Enabling and starting NSCD service..."
sudo systemctl enable nscd
sudo systemctl start nscd
check_command "NSCD service start"

# Enable and start SSSD service
echo "Enabling and starting SSSD service..."
sudo systemctl enable sssd
sudo systemctl start sssd
check_command "SSSD service start"

# Create and configure the SSSD configuration file
SSSD_CONFIG_FILE="/etc/sssd/sssd.conf"
if [[ ! -f "$SSSD_CONFIG_FILE" ]]; then
  echo "Creating SSSD configuration file..."
  sudo bash -c 'cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = example.com
config_file_version = 2
services = nss, pam

[domain/example.com]
id_provider = ldap
auth_provider = ldap
ldap_uri = ldap://ldap.example.com
ldap_search_base = dc=example,dc=com
ldap_id_use_start_tls = true
ldap_tls_reqcert = allow
cache_credentials = true
EOF'
  check_command "SSSD configuration"
fi

# Set permissions for SSSD configuration file
echo "Setting permissions on SSSD configuration file..."
sudo chmod 600 /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
check_command "SSSD configuration permissions"

# Restart SSSD service to apply changes
echo "Restarting SSSD service..."
sudo systemctl restart sssd
check_command "SSSD service restart"

# Restart NSCD service to ensure cache works properly with SSSD
echo "Restarting NSCD service..."
sudo systemctl restart nscd
check_command "NSCD service restart"

echo "NSCD and SSSD installation and configuration completed successfully."
