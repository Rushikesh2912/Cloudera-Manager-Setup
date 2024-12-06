#!/bin/bash

# Bash script to disable IPv6 on RHEL 7/8/9

# Enable strict mode
set -euo pipefail

# Function to disable IPv6 in sysctl
disable_ipv6_sysctl() {
    echo "Disabling IPv6 in sysctl..."
    
    # Backup the current sysctl configuration
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    
    # Disable IPv6 in sysctl
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    
    # Apply the changes
    sysctl -p
}

# Function to disable IPv6 in GRUB
disable_ipv6_grub() {
    echo "Disabling IPv6 in GRUB..."

    # Backup the current GRUB configuration
    cp /etc/default/grub /etc/default/grub.bak

    # Modify GRUB to disable IPv6
    sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 ipv6.disable=1"/' /etc/default/grub

    # Update GRUB settings
    if grep -q "release 7" /etc/redhat-release; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    elif grep -q "release 8" /etc/redhat-release || grep -q "release 9" /etc/redhat-release; then
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
    fi
}

# Disable IPv6
disable_ipv6_sysctl
disable_ipv6_grub

# Reboot system to apply changes
echo "Reboot the system to apply IPv6 changes..."
#reboot
