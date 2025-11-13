#!/bin/bash
################################################################################
# VProfile App Server - Post-Setup Verification
#
# Purpose: Verify CONFIGURATION after initial server setup
# When to run: After running setup-fedora.sh for the first time
# Focus: Database setup, users, permissions, SSH keys
# Author: Ganeshprasad N
# Date: 2025-11-13
################################################################################

echo "=============================================="
echo "VProfile Post-Setup Verification"
echo "Run this ONCE after initial server setup"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
ISSUES_FOUND=0

echo "[INFO] Server IP: $CURRENT_IP"
echo ""

################################################################################
# 1. MySQL Database & User Setup
################################################################################
echo "[CHECK 1/5] MySQL Database Configuration"
echo ""

if mysql -u root -e "SELECT 1" &>/dev/null; then
    echo "  [OK] MySQL is accessible"
    
    # Check database
    if mysql -u root -e "SHOW DATABASES LIKE 'accounts'" 2>/dev/null | grep -q accounts; then
        echo "  [OK] Database 'accounts' exists"
    else
        echo "  [ACTION NEEDED] Create database 'accounts'"
        echo "          Run: sudo mysql -u root"
        echo "               CREATE DATABASE accounts;"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check user
    if mysql -u root -e "SELECT User FROM mysql.user WHERE User='vprofile_app'" 2>/dev/null | grep -q vprofile_app; then
        echo "  [OK] MySQL user 'vprofile_app' exists"
    else
        echo "  [ACTION NEEDED] Create MySQL user 'vprofile_app'"
        echo "          Run: sudo mysql -u root"
        echo "               CREATE USER 'vprofile_app'@'%' IDENTIFIED BY 'vprofile@54321';"
        echo "               GRANT ALL PRIVILEGES ON accounts.* TO 'vprofile_app'@'%';"
        echo "               FLUSH PRIVILEGES;"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check if data exists
    TABLE_COUNT=$(mysql -u root accounts -e "SHOW TABLES" 2>/dev/null | wc -l)
    if [ $TABLE_COUNT -gt 1 ]; then
        echo "  [OK] Database has $((TABLE_COUNT - 1)) tables (data imported)"
    else
        echo "  [ACTION NEEDED] Import database schema"
        echo "          Run: mysql -u root accounts < /path/to/db_backup.sql"
    fi
else
    echo "  [SKIP] Cannot access MySQL (password required)"
    echo "         Verify manually if already configured"
fi
echo ""

################################################################################
# 2. RabbitMQ User
################################################################################
echo "[CHECK 2/5] RabbitMQ User Configuration"
echo ""

if sudo rabbitmqctl list_users 2>/dev/null | grep -q vprofile_mq; then
    echo "  [OK] RabbitMQ user 'vprofile_mq' exists"
else
    echo "  [ACTION NEEDED] Create RabbitMQ user"
    echo "          Run: sudo rabbitmqctl add_user vprofile_mq vprofile@rabbit123"
    echo "               sudo rabbitmqctl set_permissions -p / vprofile_mq '.*' '.*' '.*'"
    echo "               sudo rabbitmqctl set_user_tags vprofile_mq administrator"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# 3. Deploy User & Permissions
################################################################################
echo "[CHECK 3/5] Deploy User Configuration"
echo ""

if id -u deploy &>/dev/null; then
    echo "  [OK] Deploy user exists"
    
    # Check sudoers
    if [ -f "/etc/sudoers.d/deploy" ]; then
        echo "  [OK] Deploy sudo permissions configured"
    else
        echo "  [ACTION NEEDED] Configure deploy sudo permissions"
        echo "          This should have been done by setup script"
        echo "          Re-run setup-fedora.sh if needed"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check SSH directory
    if [ -d "/home/deploy/.ssh" ]; then
        echo "  [OK] Deploy SSH directory exists"
        
        if [ -f "/home/deploy/.ssh/authorized_keys" ]; then
            KEY_COUNT=$(wc -l < /home/deploy/.ssh/authorized_keys 2>/dev/null || echo 0)
            if [ $KEY_COUNT -gt 0 ]; then
                echo "  [OK] Deploy has $KEY_COUNT SSH key(s)"
            else
                echo "  [ACTION NEEDED] Add Jenkins SSH public key"
                echo "          Copy Jenkins public key to: /home/deploy/.ssh/authorized_keys"
            fi
        else
            echo "  [ACTION NEEDED] Create authorized_keys file"
            echo "          Run: sudo touch /home/deploy/.ssh/authorized_keys"
            echo "               sudo chown deploy:deploy /home/deploy/.ssh/authorized_keys"
            echo "               sudo chmod 600 /home/deploy/.ssh/authorized_keys"
            echo "          Then add Jenkins public key to this file"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        echo "  [ACTION NEEDED] Create SSH directory for deploy user"
        echo "          Run: sudo mkdir -p /home/deploy/.ssh"
        echo "               sudo chown deploy:deploy /home/deploy/.ssh"
        echo "               sudo chmod 700 /home/deploy/.ssh"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo "  [FAIL] Deploy user not found"
    echo "         Re-run setup-fedora.sh"
fi
echo ""

################################################################################
# 4. Configuration IP Addresses
################################################################################
echo "[CHECK 4/5] IP Configuration Checklist"
echo ""

echo "  Current Server IP: $CURRENT_IP"
echo ""
echo "  [ACTION NEEDED] Update these configurations:"
echo ""
echo "  1. Jenkins Server SSH Config"
echo "     File: /home/jenkins/.ssh/config (on Jenkins server)"
echo "     Update: HostName $CURRENT_IP"
echo ""
echo "  2. GitHub Config Repository"
echo "     Repo: ng-java-app-config"
echo "     Branch: jenkins-local"
echo "     File: environments/dev/application.properties"
echo "     Update ALL IPs to: $CURRENT_IP"
echo "     - jdbc.url=jdbc:mysql://$CURRENT_IP:3306/..."
echo "     - memcached.active.host=$CURRENT_IP"
echo "     - rabbitmq.address=$CURRENT_IP"
echo "     - elasticsearch.host=$CURRENT_IP"
echo ""

################################################################################
# 5. Firewall Configuration
################################################################################
echo "[CHECK 5/5] Firewall Configuration"
echo ""

if sudo firewall-cmd --list-ports 2>/dev/null | grep -q 8080; then
    echo "  [OK] Firewall port 8080 is open"
else
    echo "  [ACTION NEEDED] Open firewall port for Tomcat"
    echo "          Run: sudo firewall-cmd --permanent --add-port=8080/tcp"
    echo "               sudo firewall-cmd --reload"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# SUMMARY
################################################################################
echo "=============================================="
echo "VERIFICATION SUMMARY"
echo "=============================================="
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "[SUCCESS] All configurations verified!"
    echo ""
    echo "Server is ready for first deployment"
else
    echo "[INFO] Found $ISSUES_FOUND configuration item(s) to complete"
    echo ""
    echo "Complete the actions listed above"
    echo "Then run first Jenkins build"
fi

echo ""
echo "Next: Build and deploy application via Jenkins"
echo "=============================================="
