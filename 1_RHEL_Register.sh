#!/bin/bash

# Bash Script to Register RHEL Subscription

# Enable strict mode
set -euo pipefail

# Define username and password variables for RHEL cloud console
USERNAME="username"
PASSWORD="Password"

# Register the system to Red Hat Subscription Manager
echo "Registering to Red Hat Subscription Manager..."

subscription-manager register \
    --username="$USERNAME" \
    --password="$PASSWORD" \
    --auto-attach
subscription-manager list --available
# Verify if the registration was successful
if [ $? -eq 0 ]; then
    echo "Successfully registered to Red Hat Subscription Manager."
else
    echo "Registration failed."
    exit 1
fi


# Step 1: List available subscriptions
echo "Listing available subscriptions..."
available_pools=$(subscription-manager list --available --pool-only)

# Check if any available pools are found
if [ -z "$available_pools" ]; then
    echo "No available subscriptions found."
    exit 1
fi

# Step 2: Attach the first available pool automatically
# Assuming that the output returns pool IDs, and we take the first one
first_pool=$(echo "$available_pools" | head -n 1)

echo "Attaching the first available pool: $first_pool"
subscription-manager attach --pool="$first_pool"

# Step 3: List enabled repositories
echo "Listing enabled repositories..."
subscription-manager repos --list-enabled
insights-client --register
echo "Operation completed."
# Step 2: Attach the first available pool automatically
# Assuming that the output returns pool IDs, and we take the first one
#first_pool=$(echo "$available_pools" | head -n 1)

#echo "Attaching the first available pool: $first_pool"
#subscription-manager attach --pool="$first_pool"

# Step 3: List enabled repositories
#echo "Listing enabled repositories..."
#subscription-manager repos --list-enabled

insights-client --register
#rhc connect -a <activation-key> -o <organization-id>
#rhc connect -u <username> -p <password>

#dnf repolist all

if [ "$OS" == RedHatEnterpriseServer -o "$OS" == CentOS ]; then
  dnf -y -e1 -d1 install epel-release
  if ! rpm -q epel-release; then
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OSREL}.noarch.rpm
  fi
  if [ "$OS" == RedHatEnterpriseServer ]; then
    subscription-manager repos --enable=rhel-${OSREL}-server-optional-rpms
  fi
  dnf -y -e1 -d1 install bind-utils perl expect wget nano unzip openldap openldap-clients
dnf module enable perl

fi

if [ "$OS" == RedHatEnterpriseServer -o "$OS" == CentOS ]; then
  dnf -y install epel-release

  if ! rpm -q epel-release; then
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OSREL}.noarch.rpm
  fi

  # Enable BaseOS, AppStream, and Optional repositories if needed
  subscription-manager repos --enable=rhel-${OSREL}-for-x86_64-baseos-rpms \
                             --enable=rhel-${OSREL}-for-x86_64-appstream-rpms \
                             --enable=rhel-${OSREL}-for-x86_64-supplementary-rpms \
                             --enable=codeready-builder-for-rhel-${OSREL}-x86_64-rpms || true

  dnf -y install bind-utils perl expect wget nano unzip openldap openldap-clients
fi

echo "Operation completed."
