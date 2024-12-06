# Cloudera-Manager-Setup
---

## **Step 1: Host Repository on Ubuntu**

1. **Launch an Ubuntu EC2 Instance:**
   - Use an Ubuntu AMI (e.g., Ubuntu 20.04).
   - Ensure the instance has internet connectivity.

2. **Update and Install Apache:**
   ```bash
   sudo apt update
   sudo apt install apache2 -y
   ```

3. **Upload or Download the Repository:**
   - If uploading:
     - Use `scp` to copy `cdp.tar.gz` to the Ubuntu machine.
   - If downloading:
     ```bash
     wget <REPO_DOWNLOAD_URL>
     ```

4. **Extract Repository:**
   ```bash
   tar -zxvf cdp.tar.gz
   ```

5. **Move Repository to Apache Directory:**
   ```bash
   sudo mv cloudera /var/www/html/
   ```

6. **Access the Hosted Repository:**
   - Open a browser and navigate to:
     ```
     http://<UBUNTU_INSTANCE_IP>/cloudera
     ```

---

## **Step 2: Setup CentOS 7 Machine**

### **Launch CentOS 7 Instance:**
1. Use a CentOS 7 AMI with an **m4** or **c3** instance type.
2. Allocate **60 GB storage**.
3. Ensure security groups allow necessary ports (22 for SSH, 7180 for Cloudera Manager, etc.).

### **Install Necessary Packages:**
```bash
sudo yum update -y
sudo yum install wget nano httpd python3.6 zip unzip -y
```

---

## **Step 3: Install Java and MySQL Connector**

### **Install Java:**
```bash
sudo yum install java-1.8.0-openjdk-devel -y
wget https://s3.amazonaws.com/cloud-age/jdk-8u162-linux-x64.rpm
sudo rpm -Uvh jdk-8u162-linux-x64.rpm
```

### **Install MySQL Connector:**
```bash
wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-8.0.26-1.el7.noarch.rpm
sudo rpm -ivh mysql-connector-java-8.0.26-1.el7.noarch.rpm
```

---

## **Step 4: Upload and Run Kernel Tuning Script**

1. **Upload `kernel_tuning.py` via SCP:**
   ```bash
   scp kernel_tuning.py centos@<INSTANCE_IP>:/home/centos/
   ```

2. **Run the Script:**
   ```bash
   python3 kernel_tuning.py
   ```

---

## **Step 5: Install JDBC Connectors**

1. **Download and Extract Connector:**
   ```bash
   wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz
   tar -zxvf mysql-connector-java-5.1.46.tar.gz
   ```

2. **Move the Connector:**
   ```bash
   sudo mkdir -p /usr/share/java/
   sudo cp mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar
   ```

---

## **Step 6: Create Machine Image**

1. **Make an AMI of the Prepared CentOS 7 Instance.**
2. **Launch Six Instances from the AMI:**
   - CM (Cloudera Manager)
   - DB (Database)
   - Gateway
   - Master Node
   - 1DN (Data Node 1)
   - 2DN (Data Node 2)
   - 3DN (Data Node 3)

---

## **Step 7: Install MySQL Server**

1. **Install MySQL:**
   ```bash
   wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
   sudo rpm -ivh mysql57-community-release-el7-9.noarch.rpm
   sudo yum install --nogpgcheck mysql-server -y
   sudo systemctl start mysqld
   sudo systemctl status mysqld
   ```

2. **Secure MySQL Installation:**
   ```bash
   sudo mysql_secure_installation
   ```

---

## **Step 8: Create Databases**

1. **Log Into MySQL:**
   ```bash
   sudo mysql -u root -p
   ```

2. **Run the Following SQL Commands:**
   ```sql
   CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
   GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'P@ssw0rd';

   CREATE DATABASE hive DEFAULT CHARACTER SET utf8;
   GRANT ALL ON hive.* TO 'hive'@'%' IDENTIFIED BY 'P@ssw0rd';

   CREATE DATABASE hue DEFAULT CHARACTER SET utf8;
   GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'P@ssw0rd';

   -- Repeat for other databases: rman, navs, navms, oozie, actmo, sentry, ranger
   ```

---

## **Step 9: Configure Cloudera Manager**

1. **Add Cloudera Manager Repository:**
   ```bash
   sudo nano /etc/yum.repos.d/cloudera-manager.repo
   ```

   **Content:**
   ```
   [cloudera-manager]
   name=Cloudera Manager
   baseurl=http://15.207.54.29/cloudera/cm7/
   gpgkey=http://15.207.54.29/cloudera/cm7/RPM-GPG-KEY-cloudera
   gpgcheck=0
   ```

2. **Install Cloudera Manager:**
   ```bash
   sudo yum clean all
   sudo yum makecache
   sudo yum install cloudera-manager-server cloudera-manager-daemons -y
   ```

3. **Prepare the Database Schema:**
   ```bash
   sudo /opt/cloudera/cm/schema/scm_prepare_database.sh mysql -h <DB_HOST_IP> scm scm P@ssw0rd
   ```

4. **Start Cloudera Manager Server:**
   ```bash
   sudo service cloudera-scm-server start
   ```

---

## **Step 10: Access Cloudera Manager**

1. **Check if Cloudera Manager is Running:**
   ```bash
   sudo netstat -tulnp | grep 7180
   ```

2. **Open Cloudera Manager in a Browser:**
   Navigate to:
   ```
   http://<PUBLIC_IP>:7180
   ```

   Use the default credentials:
   - **Username:** admin
   - **Password:** admin

---

### Author : Rushikesh Shinde
### Contact : +91 9623548002 
This process completes the hosting of the repository on Ubuntu and the setup of Cloudera Manager on CentOS.
