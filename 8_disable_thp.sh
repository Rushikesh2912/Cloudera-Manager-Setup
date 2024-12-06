i#!/bin/bash

# Function to discover basic OS details.
discover_os () {
  if command -v lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -is)
    OSVER=$(lsb_release -rs)
    OSREL=$(echo $OSVER | awk -F. '{print $1}')
  else
    if [ -f /etc/redhat-release ]; then
      if [ -f /etc/centos-release ]; then
        OS=CentOS
      else
        OS=RedHatEnterpriseServer
      fi
      OSVER=$(rpm -qf /etc/redhat-release --qf="%{VERSION}.%{RELEASE}\n")
      OSREL=$(rpm -qf /etc/redhat-release --qf="%{VERSION}\n" | awk -F. '{print $1}')
    fi
  fi
}

# Print script banner
echo "********************************************************************************"
echo "*** $(basename $0)"
echo "********************************************************************************"

# Check OS and version
discover_os
if [[ "$OS" != "RedHatEnterpriseServer" && "$OS" != "CentOS" ]]; then
  echo "ERROR: Unsupported OS. This script is designed for RHEL/CentOS."
  exit 1
fi

echo "Detected OS: $OS $OSVER (Release $OSREL)"

# Disable Transparent Huge Pages (THP) via GRUB
echo "Disabling Transparent Huge Pages via GRUB for RHEL/CentOS $OSREL..."

# Modify GRUB configuration to disable THP
if [[ $OSREL -ge 8 ]]; then
  # Update GRUB configuration for RHEL 8 and above
  echo "Updating GRUB for RHEL 8 or higher..."

  if [[ $OSREL -eq 8 ]]; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  elif [[ $OSREL -ge 9 ]]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
  fi

  # Add the transparent_hugepage=never argument to all kernels
  grubby --update-kernel=ALL --args="transparent_hugepage=never"

  if [[ $? -eq 0 ]]; then
    echo "GRUB successfully updated to disable Transparent Huge Pages (THP)."
    echo "Please reboot the system for the changes to take effect."
  else
    echo "ERROR: Failed to update GRUB. Check the logs for more details."
    exit 1
  fi
else
  echo "ERROR: Script is designed for RHEL 8 and above."
  exit 1
fi

# Disable THP for the current session
echo "Disabling Transparent Huge Pages for the current session..."
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

if [[ $? -eq 0 ]]; then
  echo "Transparent Huge Pages disabled for the current session."
else
  echo "ERROR: Failed to disable Transparent Huge Pages for the current session."
  exit 1
fi

echo "THP and defragmentation disabled successfully."
exit 0
