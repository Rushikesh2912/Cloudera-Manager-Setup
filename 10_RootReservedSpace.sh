#!/bin/bash

# Ensure necessary tools are installed
sudo yum install -y xfsprogs e2fsprogs parted || { echo "Failed to install necessary packages."; exit 1; }

# Check if xvda exists
if lsblk | grep -q "xvda"; then
    echo "xvda found"

    # Check if xvda4 exists
    if lsblk | grep -q "xvda4"; then
        echo "xvda4 found, proceeding with xvda4"
        # Get the file system type of xvda4
        FSTYPE=$(lsblk -f /dev/xvda4 | grep xvda4 | awk '{print $2}')
        
        # Check the file system type and take action accordingly
        if [ "$FSTYPE" == "xfs" ]; then
            echo "xvda4 is XFS, growing file system"
            sudo xfs_growfs /dev/xvda4 || { echo "Failed to grow XFS on xvda4."; exit 1; }
        else
            echo "xvda4 is not XFS, formatting as ext4"
            sudo mkfs.ext4 /dev/xvda4 || { echo "Failed to format xvda4 as ext4."; exit 1; }
            sudo tune2fs -m 1 /dev/xvda4 || { echo "Failed to reserve space on xvda4."; exit 1; }
        fi
    else
        echo "xvda found, but xvda4 not found. Creating and formatting xvda4"
        # Add logic here to create xvda4, if necessary
        sudo parted /dev/xvda mkpart primary ext4 1MiB 100% || { echo "Failed to create partition xvda4."; exit 1; }
        sudo mkfs.ext4 /dev/xvda4 || { echo "Failed to format xvda4."; exit 1; }
        sudo tune2fs -m 1 /dev/xvda4 || { echo "Failed to reserve space on xvda4."; exit 1; }
    fi

    # Additional logic for /dev/nvme0n1
    echo "Proceeding with /dev/nvme0n1"
    sudo lsblk /dev/nvme0n1

    FSTYPE=$(lsblk -f /dev/nvme0n1 | grep nvme0n1 | awk '{print $2}')

    if [ "$FSTYPE" == "xfs" ]; then
        sudo xfs_growfs /dev/nvme0n1 || { echo "Failed to grow XFS on nvme0n1."; exit 1; }
    else
        sudo mkfs.ext4 /dev/nvme0n1p1 || { echo "Failed to format nvme0n1p1 as ext4."; exit 1; }
        sudo tune2fs -m 1 /dev/nvme0n1p1 || { echo "Failed to reserve space on nvme0n1p1."; exit 1; }
    fi

else
    echo "xvda not found, no changes made."
fi



