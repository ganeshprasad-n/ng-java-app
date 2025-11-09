#!/bin/bash
################################################################################
# VProfile Java Application - Automated Prerequisites Setup Script
# 
# Purpose: Install all dependencies required for VProfile application
# Tested On: Ubuntu 24.04 LTS
# Author: Ganeshprasad N
# Created: $(date +%Y-%m-%d)
# Usage: ./setup-ubuntu.sh
# 
# Features:
# - Simple and straightforward commands
# - Safe to run multiple times
# - Uses OpenJDK 11 for Spring 4.2.0 compatibility
################################################################################

echo "=============================================="
echo "VProfile Prerequisites Setup - Ubuntu 24.04"
echo "=============================================="

# System Update
echo "[1/9] Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Basic Tools
echo "[2/9] Installing basic tools..."
sudo apt install -y curl wget vim git tree net-tools unzip

# AWS CLI
echo "[3/9] Installing AWS CLI..."
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI already installed: $(aws --version 2>&1)"
else
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo "✅ AWS CLI installed"
fi

# Java & Maven
echo "[4/9] Installing OpenJDK 11 and Maven..."
sudo apt install -y openjdk-11-jdk maven

# Setup Java home
JAVA_HOME_PATH="/usr/lib/jvm/java-11-openjdk-amd64"
export JAVA_HOME=$JAVA_HOME_PATH
export PATH=$JAVA_HOME/bin:$PATH

# Save to bashrc
echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

echo "✅ Java 11 installed: $(java -version 2>&1 | head -n1)"
echo "✅ Maven installed: $(mvn --version 2>&1 | head -n1)"
echo "JAVA_HOME: $JAVA_HOME_PATH"

# MySQL
echo "[5/9] Installing MySQL Server..."
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
echo "✅ MySQL installed and started"

# RabbitMQ
echo "[6/9] Installing RabbitMQ..."
sudo apt install -y rabbitmq-server
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
echo "✅ RabbitMQ installed and started"

# Memcached
echo "[7/9] Installing Memcached..."
sudo apt install -y memcached
sudo systemctl start memcached
sudo systemctl enable memcached
echo "✅ Memcached installed and started"

# ElasticSearch
echo "[8/9] Installing ElasticSearch..."
# Import ElasticSearch GPG key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Add ElasticSearch repository
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update
sudo apt install -y elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
echo "✅ ElasticSearch installed and started"

# Tomcat
echo "[9/9] Installing Tomcat..."
wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
sudo tar -xzf apache-tomcat-9.0.85.tar.gz -C /opt
sudo mv /opt/apache-tomcat-9.0.85 /opt/tomcat9
rm -f apache-tomcat-9.0.85.tar.gz

sudo useradd -r -s /bin/false tomcat 2>/dev/null || true
sudo chown -R tomcat:tomcat /opt/tomcat9
sudo chmod -R 755 /opt/tomcat9

sudo tee /etc/systemd/system/tomcat9.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=$JAVA_HOME_PATH
Environment=CATALINA_PID=/opt/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat9
Environment=CATALINA_BASE=/opt/tomcat9
ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tomcat9
sudo systemctl start tomcat9
echo "✅ Tomcat installed and started"

# Wait for services
sleep 5

################################################################################
# FINAL SUMMARY
################################################################################

echo ""
echo "=============================================="
echo "✅ INSTALLATION COMPLETED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "INSTALLED COMPONENTS:"
echo "  ✅ OpenJDK 11"
echo "  ✅ Apache Maven" 
echo "  ✅ MySQL Server"
echo "  ✅ RabbitMQ Message Broker"
echo "  ✅ Memcached Caching Service"
echo "  ✅ ElasticSearch Search Engine"
echo "  ✅ Apache Tomcat 9"
echo "  ✅ AWS CLI v2"
echo "  ✅ Development Tools"
echo ""
echo "SERVICE STATUS:"
echo "  MySQL         : $(sudo systemctl is-active mysql)"
echo "  RabbitMQ      : $(sudo systemctl is-active rabbitmq-server)"
echo "  Memcached     : $(sudo systemctl is-active memcached)"
echo "  ElasticSearch : $(sudo systemctl is-active elasticsearch)"
echo "  Tomcat        : $(sudo systemctl is-active tomcat9)"
echo ""
echo "TOOL VERSIONS:"
echo "  Java       : $(java -version 2>&1 | head -n1)"
echo "  Maven      : $(mvn --version 2>&1 | head -n1)"
echo "  AWS CLI    : $(aws --version 2>&1)"
echo ""
echo "JAVA HOME:"
echo "  JAVA_HOME  : $JAVA_HOME_PATH"
echo ""
echo "ACCESS INFORMATION:"
echo "  MySQL         -> localhost:3306"
echo "  Tomcat        -> localhost:8080" 
echo "  RabbitMQ      -> localhost:5672"
echo "  Memcached     -> localhost:11211"
echo "  ElasticSearch -> localhost:9200"
echo ""
echo "IMPORTANT NOTES:"
echo "  ⚠️  This script is safe to run multiple times"
echo "  ⚠️  Java 11 is required for vProfile Spring 4.2.0"
echo "  ⚠️  MySQL on Ubuntu uses auth_socket by default - run mysql_secure_installation"
echo ""
echo "NEXT STEPS:"
echo "  1. Clone repo: git clone --branch main --single-branch https://github.com/ganeshprasad-n/ng-java-app.git"
echo "  2. MySQL setup: sudo mysql_secure_installation"
echo "  3. Create database: CREATE DATABASE accounts;"
echo "  4. Create user: CREATE USER 'vprofile_app'@'localhost' IDENTIFIED BY 'vprofile@54321';"
echo "  5. Grant privileges: GRANT ALL PRIVILEGES ON accounts.* TO 'vprofile_app'@'localhost';"
echo "  6. Import schema: mysql -u root -p accounts < db_backup.sql"
echo "  7. Configure application.properties (localhost for all services)"
echo "  8. Build: mvn clean install -DskipTests"
echo "  9. Deploy: sudo cp target/*.war /opt/tomcat9/webapps/ROOT.war"
echo ""
echo "=============================================="
