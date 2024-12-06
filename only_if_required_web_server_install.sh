#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Update the system and install httpd
echo "Updating system and installing httpd..."
yum update -y
yum install httpd -y

# Enable httpd to start on boot
echo "Enabling httpd to start on boot..."
systemctl enable httpd

# Check httpd status
echo "Checking httpd service status..."
systemctl status httpd

# Start the httpd service
echo "Starting httpd service..."
systemctl start httpd

# Confirm httpd is running
echo "Checking if httpd is running..."
systemctl status httpd

# Final message
echo "httpd has been installed and started successfully."

exit 0

