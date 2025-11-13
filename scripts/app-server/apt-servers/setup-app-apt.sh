#!/bin/bash
################################################################################
# VProfile App Server Setup - Ubuntu 24.04 LTS
# 
# Purpose: Install all services for VProfile application
# Safe to run multiple times (idempotent)
# Author: Ganeshprasad N
# Date: 2025-11-13
################################################################################

echo "=============================================="
echo "VProfile App Server Setup - Ubuntu 24.04"
echo "This script is safe to run multiple times"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
echo "[INFO] Current Server IP: $CURRENT_IP"
echo ""

################################################################################
# Step 1: System Update
################################################################################
echo "[Step 1/10] Updating system packages..."
sudo apt update
sudo apt upgrade -y
echo "[SUCCESS] System updated"
echo ""

################################################################################
# Step 2: Basic Tools
################################################################################
echo "[Step 2/10] Installing basic tools..."
sudo apt install -y curl wget vim git tree net-tools unzip
echo "[SUCCESS] Basic tools installed"
echo ""

################################################################################
# Step 3: AWS CLI
################################################################################
echo "[Step 3/10] Installing AWS CLI..."
if command -v aws &> /dev/null; then
    echo "[SKIP] AWS CLI already installed"
    aws --version
else
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo "[SUCCESS] AWS CLI installed"
fi
echo ""

################################################################################
# Step 4: Java 11 and Maven
################################################################################
echo "[Step 4/10] Installing OpenJDK 11 and Maven..."

if java -version 2>&1 | grep -q "11.0"; then
    echo "[SKIP] Java 11 already installed"
    java -version 2>&1 | head -n1
else
    sudo apt install -y openjdk-11-jdk
    echo "[SUCCESS] Java 11 installed"
fi

if command -v mvn &> /dev/null; then
    echo "[SKIP] Maven already installed"
    mvn --version | head -n1
else
    sudo apt install -y maven
    echo "[SUCCESS] Maven installed"
fi

# Setup Java home
JAVA_HOME_PATH="/usr/lib/jvm/java-11-openjdk-amd64"
export JAVA_HOME=$JAVA_HOME_PATH
export PATH=$JAVA_HOME/bin:$PATH

if ! grep -q "JAVA_HOME" ~/.bashrc; then
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    echo "[SUCCESS] JAVA_HOME added to bashrc"
else
    echo "[SKIP] JAVA_HOME already in bashrc"
fi
echo ""

################################################################################
# Step 5: MySQL Server
################################################################################
echo "[Step 5/10] Installing MySQL Server..."
if sudo systemctl is-active --quiet mysql; then
    echo "[SKIP] MySQL already installed and running"
else
    sudo apt install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
    echo "[SUCCESS] MySQL installed and started"
fi
echo ""

################################################################################
# Step 6: RabbitMQ
################################################################################
echo "[Step 6/10] Installing RabbitMQ..."
if sudo systemctl is-active --quiet rabbitmq-server; then
    echo "[SKIP] RabbitMQ already installed and running"
else
    sudo apt install -y rabbitmq-server
    sudo systemctl start rabbitmq-server
    sudo systemctl enable rabbitmq-server
    echo "[SUCCESS] RabbitMQ installed and started"
fi
echo ""

################################################################################
# Step 7: Memcached
################################################################################
echo "[Step 7/10] Installing Memcached..."
if sudo systemctl is-active --quiet memcached; then
    echo "[SKIP] Memcached already installed and running"
else
    sudo apt install -y memcached
    sudo systemctl start memcached
    sudo systemctl enable memcached
    echo "[SUCCESS] Memcached installed and started"
fi
echo ""

################################################################################
# Step 8: ElasticSearch
################################################################################
echo "[Step 8/10] Installing ElasticSearch..."
if sudo systemctl is-active --quiet elasticsearch; then
    echo "[SKIP] ElasticSearch already installed and running"
else
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    
    sudo apt update
    sudo apt install -y elasticsearch
    sudo systemctl start elasticsearch
    sudo systemctl enable elasticsearch
    echo "[SUCCESS] ElasticSearch installed and started"
fi
echo ""

################################################################################
# Step 9: Tomcat 9
################################################################################
echo "[Step 9/10] Installing Tomcat 9..."
if [ -d "/opt/tomcat9" ]; then
    echo "[SKIP] Tomcat already installed at /opt/tomcat9"
else
    wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
    sudo tar -xzf apache-tomcat-9.0.85.tar.gz -C /opt
    sudo mv /opt/apache-tomcat-9.0.85 /opt/tomcat9
    rm -f apache-tomcat-9.0.85.tar.gz
    
    # Create tomcat user if not exists
    if ! id -u tomcat &>/dev/null; then
        sudo useradd -r -s /bin/false tomcat
        echo "[SUCCESS] Tomcat user created"
    fi
    
    sudo chown -R tomcat:tomcat /opt/tomcat9
    sudo chmod -R 755 /opt/tomcat9
    
    # Create systemd service
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
    echo "[SUCCESS] Tomcat installed and started"
fi
echo ""

################################################################################
# Step 10: Create deploy user for CI/CD
################################################################################
echo "[Step 10/10] Creating deploy user for CI/CD..."
if id -u deploy &>/dev/null; then
    echo "[SKIP] Deploy user already exists"
else
    sudo useradd -m -s /bin/bash deploy
    echo "[SUCCESS] Deploy user created"
fi

# Setup sudoers for deploy user
SUDOERS_FILE="/etc/sudoers.d/deploy"
if [ -f "$SUDOERS_FILE" ]; then
    echo "[SKIP] Deploy sudo permissions already configured"
else
    echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl start tomcat9, /usr/bin/systemctl stop tomcat9, /usr/bin/systemctl restart tomcat9, /usr/bin/systemctl status tomcat9, /bin/rm, /bin/mv, /bin/chown, /bin/ls" | sudo tee $SUDOERS_FILE > /dev/null
    sudo chmod 440 $SUDOERS_FILE
    echo "[SUCCESS] Deploy sudo permissions configured"
fi
echo ""

# Wait for services
echo "[INFO] Waiting for services to fully initialize (10 seconds)..."
sleep 10

################################################################################
# FINAL SUMMARY
################################################################################
echo ""
echo "=============================================="
echo "SETUP COMPLETED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "SERVER INFORMATION:"
echo "  Server IP: $CURRENT_IP"
echo "  Hostname:  $(hostname)"
echo ""
echo "SERVICE STATUS:"
echo "  MySQL         : $(sudo systemctl is-active mysql)"
echo "  RabbitMQ      : $(sudo systemctl is-active rabbitmq-server)"
echo "  Memcached     : $(sudo systemctl is-active memcached)"
echo "  ElasticSearch : $(sudo systemctl is-active elasticsearch)"
echo "  Tomcat        : $(sudo systemctl is-active tomcat9)"
echo ""
echo "TOOL VERSIONS:"
echo "  Java:  $(java -version 2>&1 | head -n1)"
echo "  Maven: $(mvn --version 2>&1 | head -n1)"
echo ""
echo "NETWORK SERVICES:"
echo "  MySQL         -> $CURRENT_IP:3306"
echo "  Tomcat        -> $CURRENT_IP:8080"
echo "  RabbitMQ      -> $CURRENT_IP:5672"
echo "  Memcached     -> $CURRENT_IP:11211"
echo "  ElasticSearch -> $CURRENT_IP:9200"
echo ""
echo "IMPORTANT NOTES:"
echo "  MySQL on Ubuntu uses auth_socket authentication"
echo "  You need to set root password manually"
echo ""
echo "NEXT STEPS:"
echo "  1. Run verification: ./post-setup-verify.sh"
echo "  2. Set MySQL root password"
echo "  3. Configure application with IP: $CURRENT_IP"
echo "  4. Update Jenkins SSH config with this IP"
echo "  5. Update GitHub config repo with this IP"
echo ""
echo "=============================================="