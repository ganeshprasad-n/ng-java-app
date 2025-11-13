#!/bin/bash
################################################################################
# VProfile App Server - Post-Setup Verification (Ubuntu)
#
# Purpose: Verify configuration after initial server setup
# When to run: After running setup-ubuntu.sh
################################################################################

echo "=============================================="
echo "VProfile Post-Setup Verification - Ubuntu"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
ISSUES_FOUND=0

echo "[INFO] Server IP: $CURRENT_IP"
echo ""

################################################################################
# 1. Check Service Status
################################################################################
echo "[CHECK 1/8] Verifying service status..."
echo ""

SERVICES=("mysql" "rabbitmq-server" "memcached" "elasticsearch" "tomcat9")
for SERVICE in "${SERVICES[@]}"; do
    if sudo systemctl is-active --quiet $SERVICE; then
        echo "  [OK] $SERVICE is running"
    else
        echo "  [FAIL] $SERVICE is NOT running"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
echo ""

################################################################################
# 2. Check Network Ports
################################################################################
echo "[CHECK 2/8] Verifying network ports..."
echo ""

PORTS=("3306" "5672" "11211" "9300" "8080")
PORT_NAMES=("MySQL" "RabbitMQ" "Memcached" "ElasticSearch" "Tomcat")

for i in "${!PORTS[@]}"; do
    PORT="${PORTS[$i]}"
    NAME="${PORT_NAMES[$i]}"
    if sudo netstat -tulpn | grep -q ":$PORT "; then
        echo "  [OK] $NAME listening on port $PORT"
    else
        echo "  [FAIL] $NAME NOT listening on port $PORT"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
echo ""

################################################################################
# 3. MySQL Configuration (Ubuntu-specific)
################################################################################
echo "[CHECK 3/8] Verifying MySQL configuration..."
echo ""

# Ubuntu MySQL uses auth_socket by default
echo "  [INFO] Ubuntu MySQL uses auth_socket authentication"
echo "         You need to set password manually"
echo ""
echo "  [ACTION NEEDED] Set MySQL root password:"
echo "         Run: sudo mysql"
echo "              ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Admin@54321';"
echo "              FLUSH PRIVILEGES;"
echo "              EXIT;"
echo ""

# Try to check if password is set
if sudo mysql -u root -e "SELECT 1" &>/dev/null; then
    echo "  [INFO] MySQL root accessible without password"
    
    # Check database exists
    if sudo mysql -u root -e "SHOW DATABASES LIKE 'accounts'" | grep -q accounts; then
        echo "  [OK] Database 'accounts' exists"
    else
        echo "  [ACTION NEEDED] Create database 'accounts'"
        echo "         Run: sudo mysql -u root"
        echo "              CREATE DATABASE accounts;"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check user exists
    if sudo mysql -u root -e "SELECT User FROM mysql.user WHERE User='vprofile_app'" | grep -q vprofile_app; then
        echo "  [OK] MySQL user 'vprofile_app' exists"
    else
        echo "  [ACTION NEEDED] Create MySQL user 'vprofile_app'"
        echo "         Run: sudo mysql -u root"
        echo "              CREATE USER 'vprofile_app'@'%' IDENTIFIED BY 'vprofile@54321';"
        echo "              GRANT ALL PRIVILEGES ON accounts.* TO 'vprofile_app'@'%';"
        echo "              FLUSH PRIVILEGES;"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo "  [INFO] MySQL requires password (good!)"
    echo "         Verify configuration manually if already set up"
fi
echo ""

################################################################################
# 4. RabbitMQ Configuration
################################################################################
echo "[CHECK 4/8] Verifying RabbitMQ configuration..."
echo ""

if sudo rabbitmqctl list_users 2>/dev/null | grep -q vprofile_mq; then
    echo "  [OK] RabbitMQ user 'vprofile_mq' exists"
else
    echo "  [ACTION NEEDED] Create RabbitMQ user"
    echo "         Run: sudo rabbitmqctl add_user vprofile_mq vprofile@rabbit123"
    echo "              sudo rabbitmqctl set_permissions -p / vprofile_mq '.*' '.*' '.*'"
    echo "              sudo rabbitmqctl set_user_tags vprofile_mq administrator"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# 5. Deploy User Configuration
################################################################################
echo "[CHECK 5/8] Verifying deploy user configuration..."
echo ""

if id -u deploy &>/dev/null; then
    echo "  [OK] Deploy user exists"
    
    if [ -f "/etc/sudoers.d/deploy" ]; then
        echo "  [OK] Deploy sudo permissions configured"
    else
        echo "  [ACTION NEEDED] Configure deploy sudo permissions"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    if [ -d "/home/deploy/.ssh" ]; then
        echo "  [OK] Deploy SSH directory exists"
        
        if [ -f "/home/deploy/.ssh/authorized_keys" ]; then
            KEY_COUNT=$(wc -l < /home/deploy/.ssh/authorized_keys 2>/dev/null || echo 0)
            if [ $KEY_COUNT -gt 0 ]; then
                echo "  [OK] Deploy has $KEY_COUNT SSH key(s)"
            else
                echo "  [ACTION NEEDED] Add Jenkins SSH public key"
            fi
        else
            echo "  [ACTION NEEDED] Create authorized_keys file"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        echo "  [ACTION NEEDED] Create SSH directory for deploy user"
        echo "         Run: sudo mkdir -p /home/deploy/.ssh"
        echo "              sudo chown deploy:deploy /home/deploy/.ssh"
        echo "              sudo chmod 700 /home/deploy/.ssh"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo "  [FAIL] Deploy user not found"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# 6. Tomcat Deployment Check
################################################################################
echo "[CHECK 6/8] Verifying Tomcat configuration..."
echo ""

if [ -f "/opt/tomcat9/webapps/ROOT.war" ]; then
    echo "  [OK] ROOT.war file exists"
elif [ -d "/opt/tomcat9/webapps/ROOT" ]; then
    echo "  [OK] ROOT application directory exists"
else
    echo "  [INFO] No application deployed yet"
fi
echo ""

################################################################################
# 7. Firewall Check (UFW on Ubuntu)
################################################################################
echo "[CHECK 7/8] Verifying firewall configuration..."
echo ""

if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
        echo "  [INFO] UFW firewall is active"
        
        if sudo ufw status | grep -q "8080"; then
            echo "  [OK] Port 8080 is open"
        else
            echo "  [ACTION NEEDED] Open firewall port"
            echo "         Run: sudo ufw allow 8080/tcp"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        echo "  [INFO] UFW firewall is inactive"
    fi
else
    echo "  [INFO] UFW not installed"
fi
echo ""

################################################################################
# 8. Configuration IP Check
################################################################################
echo "[CHECK 8/8] IP configuration checklist..."
echo ""

echo "  Current Server IP: $CURRENT_IP"
echo ""
echo "  [ACTION NEEDED] Update these configurations:"
echo ""
echo "  1. Jenkins Server SSH Config"
echo "     Update: HostName $CURRENT_IP"
echo ""
echo "  2. GitHub Config Repository"
echo "     Update all service IPs to: $CURRENT_IP"
echo "     - jdbc.url, memcached, rabbitmq, elasticsearch"
echo ""

################################################################################
# SUMMARY
################################################################################
echo "=============================================="
echo "VERIFICATION SUMMARY"
echo "=============================================="
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "[SUCCESS] All checks passed"
    echo ""
    echo "Server is ready for first deployment"
else
    echo "[INFO] Found $ISSUES_FOUND configuration item(s) to complete"
    echo ""
    echo "Complete the actions listed above"
fi

echo ""
echo "Next: Build and deploy application via Jenkins"
echo "=============================================="