#!/bin/bash

# Check the current value of /proc/sys/vm/swappiness
current_value=$(cat /proc/sys/vm/swappiness)

echo "Current /proc/sys/vm/swappiness value: $current_value"

# If the value is not 1, update it to 1
if [ "$current_value" -ne 1 ]; then
  echo "Setting /proc/sys/vm/swappiness to 1"
  echo 1 > /proc/sys/vm/swappiness

  # Make the change persistent across reboots by modifying sysctl.conf
  if grep -q "vm.swappiness" /etc/sysctl.conf; then
    sed -i 's/vm.swappiness=.*/vm.swappiness=1/' /etc/sysctl.conf
  else
    echo "vm.swappiness=1" >> /etc/sysctl.conf
  fi

  # Reload sysctl settings to apply the change
  echo "Swappiness value set to 1 and made persistent."

else
  echo "/proc/sys/vm/swappiness is already set to $current_value"
fi

