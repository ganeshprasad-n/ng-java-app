#!/bin/bash
################################################################################
# Jenkins CI/CD Server Setup - Ubuntu 24.04 LTS
#
# Purpose: Install Jenkins, Java, Maven, Git
# Safe to run multiple times (idempotent)
# Author: Ganeshprasad N
# Date: 2025-11-13
################################################################################

set -e

# Check root
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Run as root: sudo ./jenkins-setup-ubuntu.sh"
   exit 1
fi

echo "=============================================="
echo "Jenkins CI/CD Server Setup - Ubuntu 24.04"
echo "This script is safe to run multiple times"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
echo "[INFO] Current Server IP: $CURRENT_IP"
echo ""

################################################################################
# Step 1: System Update
################################################################################
echo "[Step 1/9] Updating system packages..."
apt-get update -y
apt-get upgrade -y
echo "[SUCCESS] System updated"
echo ""

################################################################################
# Step 2: Install Java 11 and 17
################################################################################
echo "[Step 2/9] Installing Java 11 and Java 17..."

if java -version 2>&1 | grep -q "11.0"; then
    echo "[SKIP] Java 11 already installed"
else
    apt-get install -y openjdk-11-jdk openjdk-11-jre
    echo "[SUCCESS] Java 11 installed"
fi

if java -version 2>&1 | grep -q "17.0"; then
    echo "[SKIP] Java 17 already installed"
else
    apt-get install -y openjdk-17-jdk openjdk-17-jre
    echo "[SUCCESS] Java 17 installed"
fi

# Set Java 17 as default for Jenkins
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java

echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' > /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh

java -version
echo ""

################################################################################
# Step 3: Install Maven
################################################################################
echo "[Step 3/9] Installing Maven 3.8.9..."

if [ -d "/opt/maven" ]; then
    echo "[SKIP] Maven already installed"
else
    cd /opt
    wget -q https://archive.apache.org/dist/maven/maven-3/3.8.9/binaries/apache-maven-3.8.9-bin.tar.gz
    tar -xzf apache-maven-3.8.9-bin.tar.gz
    mv apache-maven-3.8.9 maven
    rm -f apache-maven-3.8.9-bin.tar.gz
    
    echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh
    echo 'export PATH=$M2_HOME/bin:$PATH' >> /etc/profile.d/maven.sh
    echo "[SUCCESS] Maven installed"
fi

source /etc/profile.d/maven.sh
/opt/maven/bin/mvn -version
echo ""

################################################################################
# Step 4: Install Git
################################################################################
echo "[Step 4/9] Installing Git..."

if command -v git &> /dev/null; then
    echo "[SKIP] Git already installed"
else
    apt-get install -y git
    echo "[SUCCESS] Git installed"
fi

git --version
echo ""

################################################################################
# Step 5: Install Essential Tools
################################################################################
echo "[Step 5/9] Installing essential tools..."
apt-get install -y curl wget unzip vim net-tools
echo "[SUCCESS] Tools installed"
echo ""

################################################################################
# Step 6: Install Jenkins
################################################################################
echo "[Step 6/9] Installing Jenkins..."

if systemctl is-active --quiet jenkins; then
    echo "[SKIP] Jenkins already installed and running"
else
    wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
        https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
        > /etc/apt/sources.list.d/jenkins.list
    
    apt-get update -y
    apt-get install -y jenkins
    
    systemctl daemon-reload
    systemctl start jenkins
    systemctl enable jenkins
    echo "[SUCCESS] Jenkins installed and started"
fi
echo ""

################################################################################
# Step 7: Configure Firewall
################################################################################
echo "[Step 7/9] Configuring firewall..."

if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 8080/tcp
    echo "y" | ufw enable
    echo "[SUCCESS] Firewall configured"
else
    echo "[INFO] UFW not found"
fi
echo ""

################################################################################
# Step 8: Setup Jenkins User SSH
################################################################################
echo "[Step 8/9] Setting up Jenkins user..."

if [ -d "/var/lib/jenkins/.ssh" ]; then
    echo "[SKIP] Jenkins SSH directory exists"
else
    sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
    sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh
    echo "[SUCCESS] Jenkins SSH directory created"
fi
echo ""

################################################################################
# Step 9: Display Summary
################################################################################
echo "[Step 9/9] Waiting for Jenkins to start (30 seconds)..."
sleep 30

echo ""
echo "=============================================="
echo "SETUP COMPLETED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "SERVER INFORMATION:"
echo "  Server IP: $CURRENT_IP"
echo "  Hostname:  $(hostname)"
echo ""
echo "JENKINS ACCESS:"
echo "  URL: http://$CURRENT_IP:8080"
echo ""

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "  Initial Admin Password:"
    echo "  $INITIAL_PASSWORD"
    echo ""
fi

echo "INSTALLED VERSIONS:"
echo "  Java 11:  $(update-alternatives --list java | grep java-11)"
echo "  Java 17:  $(update-alternatives --list java | grep java-17)"
echo "  Maven:    $(/opt/maven/bin/mvn -version | head -n 1 | awk '{print $3}')"
echo "  Git:      $(git --version | awk '{print $3}')"
echo "  Jenkins:  $(systemctl is-active jenkins)"
echo ""
echo "NEXT STEPS:"
echo "  1. Run verification: ./post-setup-verify-jenkins.sh"
echo "  2. Access Jenkins UI and complete setup"
echo "  3. Install required plugins"
echo "  4. Configure tools and credentials"
echo ""
echo "=============================================="
