#!/bin/bash

# Check the current value of /proc/sys/vm/overcommit_memory
current_value=$(cat /proc/sys/vm/overcommit_memory)

echo "Current /proc/sys/vm/overcommit_memory value: $current_value"

# If the value is 0, update it to 1
if [ "$current_value" -eq 0 ]; then
  echo "Setting /proc/sys/vm/overcommit_memory to 1"
  echo 1 > /proc/sys/vm/overcommit_memory

  # Make the change persistent across reboots by modifying sysctl.conf
  if grep -q "vm.overcommit_memory" /etc/sysctl.conf; then
    sed -i 's/vm.overcommit_memory=.*/vm.overcommit_memory=1/' /etc/sysctl.conf
  else
    echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
  fi

  # Reload sysctl settings to apply the change
  sysctl -p
  echo "Change applied and made persistent."

else
  echo "/proc/sys/vm/overcommit_memory is already set to $current_value"
fi

