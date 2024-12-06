#!/bin/bash

# Ensure we are running as root or using sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo privileges." 
   exit 1
fi

# Define user and SSH config paths
USER_HOME="/home/ec2-user"
SSH_DIR="$USER_HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
ID_RSA_PUB="$SSH_DIR/id_rsa.pub"
ID_RSA="$SSH_DIR/id_rsa"

# Ensure the SSH directory exists
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Create SSH config file and add the necessary configurations
touch "$CONFIG_FILE"
echo -e 'Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null' > "$CONFIG_FILE"
chown ec2-user:ec2-user "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

# Generate SSH key pair if it doesn't exist
if [[ ! -f "$ID_RSA" ]]; then
  sudo -u ec2-user ssh-keygen -t rsa -P "" -f "$ID_RSA" <<< y
fi

# Append the public key to authorized_keys
cat "$ID_RSA_PUB" >> "$AUTHORIZED_KEYS"
chown ec2-user:ec2-user "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"

# Restart SSH service
systemctl restart sshd.service

# Test SSH connection to localhost
echo "Testing SSH connection to localhost..."
sudo -u ec2-user ssh -o "StrictHostKeyChecking=no" localhost
