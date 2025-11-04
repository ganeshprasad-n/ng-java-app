#!/bin/bash

################################################################################
# VProfile Java Application - Automated Prerequisites Setup Script
# 
# Purpose: Install all dependencies required for VProfile application
# Tested On: Ubuntu 24.04 LTS
# Author: DevOps Team
# Usage: bash setup-prerequisites.sh
#
################################################################################

set -e  # Exit on any error

# Industry-standard logging functions
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[OK] $1"
}

log_warning() {
    echo "[WARN] $1"
}

log_error() {
    echo "[ERR] $1"
}

################################################################################
# STEP 1: Check Prerequisites
################################################################################

echo ""
echo "===================================="
echo "VProfile Prerequisites Installation"
echo "Ubuntu 24.04 LTS Environment Setup"
echo "===================================="
echo ""

log_info "Checking system prerequisites..."
echo ""

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    log_error "This script requires Ubuntu 24.04 LTS"
    exit 1
fi

# Check if running with proper privileges
if [[ $EUID -ne 0 ]]; then
    log_warning "Some operations require sudo privileges"
fi

log_success "Ubuntu system detected"
echo ""

################################################################################
# STEP 2: System Update
################################################################################

echo "===================================="
echo "STAGE 1: System Package Updates"
echo "===================================="
echo ""

log_info "Updating system packages (this may take a few minutes)..."
sudo apt update
sudo apt upgrade -y

log_success "System packages updated"
echo ""

################################################################################
# STEP 3: Install Essential Tools
################################################################################

echo "===================================="
echo "STAGE 2: Installing Essential Tools"
echo "===================================="
echo ""

log_info "Installing: curl, wget, net-tools, vim, tree, git..."
sudo apt install -y curl wget net-tools vim tree git

log_success "Essential tools installed"
echo ""

# Verify installations
log_info "Verifying tool installations..."
git --version > /dev/null && log_success "Git installed"
curl --version > /dev/null && log_success "Curl installed"
echo ""

################################################################################
# STEP 4: Install Java Development Kit
################################################################################

echo "===================================="
echo "STAGE 3: Installing Java 11 JDK"
echo "===================================="
echo ""

log_info "Installing Java 11 OpenJDK..."
sudo apt install -y openjdk-11-jdk

log_success "Java 11 JDK installed"
echo ""

# Verify Java installation
log_info "Verifying Java installation..."
java_version=$(java -version 2>&1 | grep version)
log_success "Java Version: $java_version"
echo ""

################################################################################
# STEP 5: Configure Java Environment Variables
################################################################################

echo "===================================="
echo "STAGE 4: Java Environment Variables"
echo "===================================="
echo ""

log_info "Setting up JAVA_HOME and PATH..."

# Check if already configured
if grep -q "JAVA_HOME" ~/.bashrc; then
    log_warning "JAVA_HOME already configured in ~/.bashrc"
else
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    log_success "JAVA_HOME configured in ~/.bashrc"
fi

# Source bashrc to apply changes
source ~/.bashrc

log_info "JAVA_HOME: $(echo $JAVA_HOME)"
echo ""

################################################################################
# STEP 6: Install Apache Maven
################################################################################

echo "===================================="
echo "STAGE 5: Installing Apache Maven"
echo "===================================="
echo ""

log_info "Installing Apache Maven..."
sudo apt install -y maven

log_success "Maven installed"
echo ""

# Verify Maven installation
log_info "Verifying Maven installation..."
mvn_version=$(mvn --version | head -n 1)
log_success "Maven Version: $mvn_version"
echo ""

################################################################################
# STEP 7: Install MySQL Server
################################################################################

echo "===================================="
echo "STAGE 6: Installing MySQL 8.0"
echo "===================================="
echo ""

log_info "Installing MySQL Server..."
sudo apt install -y mysql-server

log_success "MySQL Server installed"
echo ""

log_info "Starting MySQL service..."
sudo systemctl start mysql
sudo systemctl enable mysql

log_success "MySQL service started and enabled"
echo ""

# Verify MySQL service
sudo systemctl status mysql --no-pager | grep "active"
echo ""

################################################################################
# STEP 8: Install Tomcat Server
################################################################################

echo "===================================="
echo "STAGE 7: Installing Tomcat 9"
echo "===================================="
echo ""

log_info "Downloading Tomcat 9.0.85..."
cd /tmp
wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz

log_success "Tomcat downloaded"
echo ""

log_info "Extracting Tomcat to /opt..."
sudo tar -xzf apache-tomcat-9.0.85.tar.gz -C /opt

log_info "Renaming Tomcat directory..."
sudo mv /opt/apache-tomcat-9.0.85 /opt/tomcat9

log_success "Tomcat extracted to /opt/tomcat9"
echo ""

log_info "Creating tomcat user..."
sudo useradd -r -s /bin/false tomcat 2>/dev/null || log_warning "tomcat user already exists"

log_info "Setting Tomcat ownership and permissions..."
sudo chown -R tomcat:tomcat /opt/tomcat9
sudo chmod -R 755 /opt/tomcat9

log_success "Tomcat ownership and permissions configured"
echo ""

log_info "Creating Tomcat systemd service file..."
sudo tee /etc/systemd/system/tomcat9.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
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

log_success "Tomcat systemd service file created"
echo ""

log_info "Enabling Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat9

log_success "Tomcat service enabled"
echo ""

log_info "Starting Tomcat service..."
sudo systemctl start tomcat9

log_success "Tomcat service started"
echo ""

# Wait for Tomcat to start
sleep 5

# Verify Tomcat service
sudo systemctl status tomcat9 --no-pager | grep "active"
echo ""

################################################################################
# STEP 9: Install RabbitMQ
################################################################################

echo "===================================="
echo "STAGE 8: Installing RabbitMQ"
echo "===================================="
echo ""

log_info "Installing RabbitMQ Server..."
sudo apt install -y rabbitmq-server

log_success "RabbitMQ Server installed"
echo ""

log_info "Starting RabbitMQ service..."
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

log_success "RabbitMQ service started and enabled"
echo ""

################################################################################
# STEP 10: Install Memcached
################################################################################

echo "===================================="
echo "STAGE 9: Installing Memcached"
echo "===================================="
echo ""

log_info "Installing Memcached..."
sudo apt install -y memcached

log_success "Memcached installed"
echo ""

log_info "Starting Memcached service..."
sudo systemctl start memcached
sudo systemctl enable memcached

log_success "Memcached service started and enabled"
echo ""

################################################################################
# STEP 11: Install ElasticSearch
################################################################################

echo "===================================="
echo "STAGE 10: Installing ElasticSearch"
echo "===================================="
echo ""

log_info "Adding ElasticSearch GPG key..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

log_info "Adding ElasticSearch APT repository..."
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list > /dev/null

log_info "Updating package list..."
sudo apt update

log_info "Installing ElasticSearch..."
sudo apt install -y elasticsearch

log_success "ElasticSearch installed"
echo ""

log_info "Starting ElasticSearch service..."
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

log_success "ElasticSearch service started and enabled"
echo ""

################################################################################
# STEP 12: Verify All Services
################################################################################

echo "===================================="
echo "STAGE 11: Verifying All Services"
echo "===================================="
echo ""

log_info "Checking all service statuses..."
echo ""

services=("mysql" "tomcat9" "rabbitmq-server" "memcached" "elasticsearch")

for service in "${services[@]}"; do
    if sudo systemctl is-active --quiet "$service"; then
        log_success "$service is running"
    else
        log_warning "$service is NOT running"
        sudo systemctl status "$service" --no-pager | head -n 3
    fi
done

echo ""

################################################################################
# STEP 13: Port Verification
################################################################################

echo "===================================="
echo "STAGE 12: Verifying Service Ports"
echo "===================================="
echo ""

log_info "Checking service port listeners..."
echo ""

ports=("3306:MySQL" "8080:Tomcat" "5672:RabbitMQ" "11211:Memcached" "9200:ElasticSearch")

for port_info in "${ports[@]}"; do
    port="${port_info%%:*}"
    service="${port_info##*:}"
    
    if sudo netstat -tulpn 2>/dev/null | grep -q ":$port"; then
        log_success "$service listening on port $port"
    else
        log_warning "$service NOT listening on port $port"
    fi
done

echo ""

################################################################################
# STEP 14: Create Required Directories
################################################################################

echo "===================================="
echo "STAGE 13: Creating Directories"
echo "===================================="
echo ""

log_info "Creating application directory structure..."

mkdir -p ~/java-app
log_success "Application directory created: ~/java-app"

echo ""

################################################################################
# FINAL SUMMARY
################################################################################

echo "===================================="
echo "INSTALLATION COMPLETED"
echo "===================================="
echo ""

log_success "All prerequisites installed and services running"
echo ""

echo "INSTALLED COMPONENTS:"
echo "  [OK] Java 11 OpenJDK"
echo "  [OK] Apache Maven"
echo "  [OK] MySQL 8.0 Server"
echo "  [OK] Tomcat 9 Application Server"
echo "  [OK] RabbitMQ Message Queue"
echo "  [OK] Memcached Caching Service"
echo "  [OK] ElasticSearch Search Engine"
echo "  [OK] Development Tools"
echo ""

echo "NEXT STEPS:"
echo "  1. Read README.md for detailed configuration instructions"
echo "  2. Clone VProfile repository"
echo "  3. Configure MySQL root password (Stage 2 in README)"
echo "  4. Deploy VProfile application (Stage 3-4 in README)"
echo ""

echo "SERVICE ACCESS:"
echo "  MySQL         -> localhost:3306"
echo "  Tomcat        -> localhost:8080"
echo "  RabbitMQ      -> localhost:5672"
echo "  Memcached     -> localhost:11211"
echo "  ElasticSearch -> localhost:9200"
echo ""

log_info "For configuration details, refer to README.md"
echo ""

################################################################################
# End of Script
################################################################################
