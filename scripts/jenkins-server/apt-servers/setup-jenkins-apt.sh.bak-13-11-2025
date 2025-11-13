#!/bin/bash
##############################################################################
# Jenkins Setup Script - Ubuntu 24.04 LTS
# Simple and straightforward installation
##############################################################################

set -e  # Stop if any command fails

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root"
   echo "Usage: sudo ./jenkins-setup.sh"
   exit 1
fi

echo "==============================================="
echo "    Jenkins CI/CD Server Setup"
echo "    Ubuntu 24.04 LTS"
echo "==============================================="
echo ""

##############################################################################
# Step 1: Update System
##############################################################################
echo "[Step 1/8] Updating system packages..."
apt-get update -y
apt-get upgrade -y
echo "[SUCCESS] System updated"
echo ""

##############################################################################
# Step 2: Install Java 17
##############################################################################
echo "[Step 2/8] Installing Java 17..."
apt-get install -y openjdk-17-jdk openjdk-17-jre

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' > /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh

java -version
echo "[SUCCESS] Java 17 installed"
echo ""

##############################################################################
# Step 3: Install Maven 3.8.9
##############################################################################
echo "[Step 3/8] Installing Maven 3.8.9..."
cd /opt
wget -q https://archive.apache.org/dist/maven/maven-3/3.8.9/binaries/apache-maven-3.8.9-bin.tar.gz
tar -xzf apache-maven-3.8.9-bin.tar.gz
mv apache-maven-3.8.9 maven
rm -f apache-maven-3.8.9-bin.tar.gz

# Set Maven environment
echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh
echo 'export PATH=$M2_HOME/bin:$PATH' >> /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

/opt/maven/bin/mvn -version
echo "[SUCCESS] Maven installed"
echo ""

##############################################################################
# Step 4: Install Git
##############################################################################
echo "[Step 4/8] Installing Git..."
apt-get install -y git
git --version
echo "[SUCCESS] Git installed"
echo ""

##############################################################################
# Step 5: Install Essential Tools
##############################################################################
echo "[Step 5/8] Installing essential tools..."
apt-get install -y curl wget unzip vim net-tools
echo "[SUCCESS] Tools installed"
echo ""

##############################################################################
# Step 6: Install Jenkins
##############################################################################
echo "[Step 6/8] Installing Jenkins..."

# Add Jenkins repository key
wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

# Install Jenkins
apt-get update -y
apt-get install -y jenkins

# Start Jenkins
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins

echo "[SUCCESS] Jenkins installed and started"
echo ""

##############################################################################
# Step 7: Configure Firewall
##############################################################################
echo "[Step 7/8] Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp    # SSH
    ufw allow 8080/tcp  # Jenkins
    echo "y" | ufw enable
    ufw status
    echo "[SUCCESS] Firewall configured"
else
    echo "[INFO] UFW not found, skipping firewall setup"
fi
echo ""

##############################################################################
# Step 8: Display Summary
##############################################################################
echo "[Step 8/8] Waiting for Jenkins to start (30 seconds)..."
sleep 30

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "==============================================="
echo "    Installation Complete!"
echo "==============================================="
echo ""
echo "Jenkins URL: http://${SERVER_IP}:8080"
echo ""

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "Initial Admin Password:"
    echo "${INITIAL_PASSWORD}"
    echo ""
fi

echo "Installed Versions:"
echo "  - Java:    $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')"
echo "  - Maven:   $(/opt/maven/bin/mvn -version | head -n 1 | awk '{print $3}')"
echo "  - Git:     $(git --version | awk '{print $3}')"
echo "  - Jenkins: $(systemctl is-active jenkins)"
echo ""
echo "Next Steps:"
echo "  1. Open Jenkins URL in browser"
echo "  2. Enter the admin password shown above"
echo "  3. Install suggested plugins"
echo "  4. Create admin user"
echo ""
echo "==============================================="