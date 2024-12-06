#!/bin/bash


# Script to install MySQL 8 on RHEL 8

# Function to check for command success and exit if failed
check_command() {
  if [[ $? -ne 0 ]]; then
    echo "ERROR: $1 failed."
    exit 1
  fi
}

# Update the system package index
echo "Updating system package index..."
sudo yum update -y
check_command "System update"
sudo dnf install wget -y
sudo dnf install expect -y
# Download the MySQL repository package
echo "Downloading MySQL repository..."
wget https://dev.mysql.com/get/mysql80-community-release-el8-8.noarch.rpm
check_command "MySQL repo download"

# Install the MySQL repository package
echo "Installing MySQL repository..."
sudo rpm -ivh mysql80-community-release-el8-8.noarch.rpm
check_command "MySQL repo installation"

# Install MySQL development libraries
echo "Installing MySQL development libraries..."
sudo yum install mysql-devel -y
check_command "MySQL development libraries installation"

# Install MySQL server
echo "Installing MySQL server..."
sudo yum install --nogpgcheck mysql-server -y
check_command "MySQL server installation"

# Start MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysqld
check_command "MySQL service start"

# Check the status of MySQL service
echo "Checking MySQL service status..."
sudo systemctl status mysqld
check_command "MySQL service status check"

# Run MySQL secure installation to set root password and secure the setup
echo "Running MySQL secure installation..."
sudo mysql_secure_installation
check_command "MySQL secure installation"

echo "MySQL installation and configuration completed successfully."

# Get the default MySQL root password from the log
MYSQL_ROOT_PASSWORD=$(sudo grep 'temporary password' /var/log/mysql/mysqld.log | awk '{print $NF}')
echo "Temporary MySQL root password retrieved."

# Automate mysql_secure_installation
echo "Running MySQL secure installation..."

# Expect script to automate mysql_secure_installation
expect <<EOF
spawn sudo mysql_secure_installation

# Enter the temporary root password
expect "Enter password for user root:"
send "$MYSQL_ROOT_PASSWORD\r"

# Password strength: select 1 for medium
expect "New password:"
send "Kt088616**\r"

# Confirm new password
expect "Re-enter new password:"
send "Passw0rd\r"

# Remove anonymous users (choose Yes)
expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

# Disallow root login remotely (choose Yes)
expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

# Remove test database (choose Yes)
expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

# Reload privilege tables (choose Yes)
expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

# End expect
expect eof
EOF

check_command "MySQL secure installation"

echo "MySQL installation and configuration completed successfully."

