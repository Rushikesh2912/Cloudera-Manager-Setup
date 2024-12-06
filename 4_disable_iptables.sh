#!/bin/bash

# Bash script to disable all kinds of internal firewalls on RHEL 7/8/9

# Enable strict mode
set -euo pipefail

# Discover the OS version
os_version=$(cat /etc/redhat-release)

echo "Detected OS version: $os_version"

# Disable firewalld
disable_firewalld() {
    if systemctl is-active firewalld >/dev/null 2>&1; then
        echo "Disabling firewalld..."
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl mask firewalld
        echo "firewalld has been disabled."
    else
        echo "firewalld is not running."
    fi
}

# Disable iptables
disable_iptables() {
    if systemctl is-active iptables >/dev/null 2>&1; then
        echo "Disabling iptables..."
        sudo systemctl stop iptables
        sudo systemctl disable iptables
        echo "iptables has been disabled."
    else
        echo "iptables is not running."
    fi
}

# Check RHEL version and proceed with disabling firewalls
if grep -q "release 7" /etc/redhat-release; then
    echo "Disabling firewalls for RHEL 7..."
    disable_firewalld
    disable_iptables

elif grep -q "release 8" /etc/redhat-release; then
    echo "Disabling firewalls for RHEL 8..."
    disable_firewalld
    disable_iptables

elif grep -q "release 9" /etc/redhat-release; then
    echo "Disabling firewalls for RHEL 9..."
    disable_firewalld
    disable_iptables

else
    echo "Unsupported RHEL version."
    exit 1
fi

echo "All firewall services have been disabled."
