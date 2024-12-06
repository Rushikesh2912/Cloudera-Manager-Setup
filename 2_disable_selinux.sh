#!/bin/bash

# Function to discover basic OS details.
discover_os () {
  if command -v lsb_release >/dev/null; then
    OS=`lsb_release -is`
    OSVER=`lsb_release -rs`
    OSREL=`echo $OSVER | awk -F. '{print $1}'`
  else
    if [ -f /etc/redhat-release ]; then
      if [ -f /etc/centos-release ]; then
        OS=CentOS
      else
        OS=RedHatEnterpriseServer
      fi
      OSVER=`rpm -qf /etc/redhat-release --qf="%{VERSION}.%{RELEASE}\n"`
      OSREL=`rpm -qf /etc/redhat-release --qf="%{VERSION}\n" | awk -F. '{print $1}'`
    fi
  fi
}

echo "********************************************************************************"
echo "*** Disabling SELinux on RHEL $OSREL ***"
echo "********************************************************************************"

# Discover OS details
discover_os

# Check if the OS is supported (RHEL/CentOS 7/8/9)
if [ "$OS" != "RedHatEnterpriseServer" ] && [ "$OS" != "CentOS" ]; then
  echo "ERROR: Unsupported OS. This script only supports RHEL/CentOS."
  exit 1
fi

# Disable SELinux
echo "Disabling SELinux..."
setenforce 0

# Modify /etc/selinux/config to permanently disable SELinux
if [[ -f /etc/selinux/config ]]; then
  sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
  echo "SELinux has been disabled permanently in /etc/selinux/config."
else
  echo "ERROR: SELinux configuration file not found."
  exit 1
fi

echo "SELinux is now disabled. A reboot is required for the changes to take full effect."

