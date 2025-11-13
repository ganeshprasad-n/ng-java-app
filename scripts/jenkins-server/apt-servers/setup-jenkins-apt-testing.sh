#!/bin/bash
################################################################################
# Jenkins Server - Post-Setup Verification (Ubuntu)
#
# Purpose: Verify Jenkins configuration after initial setup
# When to run: After jenkins-setup-ubuntu.sh
################################################################################

echo "=============================================="
echo "Jenkins Post-Setup Verification - Ubuntu"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
ISSUES_FOUND=0

echo "[INFO] Server IP: $CURRENT_IP"
echo ""

################################################################################
# 1. Check Jenkins Service
################################################################################
echo "[CHECK 1/6] Jenkins Service Status"
echo ""

if systemctl is-active --quiet jenkins; then
    echo "  [OK] Jenkins is running"
    
    if systemctl is-enabled --quiet jenkins; then
        echo "  [OK] Jenkins enabled at boot"
    else
        echo "  [WARN] Jenkins not enabled at boot"
        echo "         Run: sudo systemctl enable jenkins"
    fi
else
    echo "  [FAIL] Jenkins is NOT running"
    echo "         Run: sudo systemctl start jenkins"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# 2. Check Java Installation
################################################################################
echo "[CHECK 2/6] Java Installation"
echo ""

if update-alternatives --list java | grep -q "java-11"; then
    echo "  [OK] Java 11 installed"
else
    echo "  [WARN] Java 11 not found"
    echo "         Install: sudo apt-get install openjdk-11-jdk"
fi

if update-alternatives --list java | grep -q "java-17"; then
    echo "  [OK] Java 17 installed"
else
    echo "  [WARN] Java 17 not found"
fi

CURRENT_JAVA=$(java -version 2>&1 | head -n 1)
echo "  Current default: $CURRENT_JAVA"
echo ""

################################################################################
# 3. Check Maven and Git
################################################################################
echo "[CHECK 3/6] Build Tools"
echo ""

if [ -d "/opt/maven" ]; then
    echo "  [OK] Maven installed at /opt/maven"
else
    echo "  [FAIL] Maven not found"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if command -v git &> /dev/null; then
    echo "  [OK] Git installed"
else
    echo "  [FAIL] Git not found"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

################################################################################
# 4. Check Jenkins SSH Keys
################################################################################
echo "[CHECK 4/6] Jenkins SSH Configuration"
echo ""

if [ -d "/var/lib/jenkins/.ssh" ]; then
    echo "  [OK] Jenkins SSH directory exists"
    
    KEY_FILES=$(sudo ls /var/lib/jenkins/.ssh/ 2>/dev/null | grep -E "^id_|^jenkins-" | wc -l)
    if [ $KEY_FILES -gt 0 ]; then
        echo "  [OK] Found $KEY_FILES SSH key(s)"
    else
        echo "  [ACTION NEEDED] Generate SSH keys"
        echo "         Run as jenkins user:"
        echo "         sudo su - jenkins"
        echo "         ssh-keygen -t ed25519 -C 'jenkins@github' -f ~/.ssh/jenkins-github-key"
        echo "         ssh-keygen -t ed25519 -C 'jenkins@app-server' -f ~/.ssh/jenkins-app-server-key"
    fi
else
    echo "  [WARN] Jenkins SSH directory not found"
fi
echo ""

################################################################################
# 5. Check Jenkins Web Access
################################################################################
echo "[CHECK 5/6] Jenkins Web Access"
echo ""

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "403" ]; then
    echo "  [OK] Jenkins web interface responding"
    echo "       Access: http://$CURRENT_IP:8080"
else
    echo "  [WARN] Jenkins web interface not responding (HTTP $HTTP_STATUS)"
    echo "         Jenkins may still be starting up"
    echo "         Wait 60 seconds and try: curl -I http://localhost:8080"
fi
echo ""

################################################################################
# 6. Check Initial Setup Status
################################################################################
echo "[CHECK 6/6] Initial Setup Status"
echo ""

if [ -f "/var/lib/jenkins/secrets/initialAdminPassword" ]; then
    echo "  [INFO] Initial setup NOT completed"
    echo "         Admin password available"
    echo "         Complete setup at: http://$CURRENT_IP:8080"
elif [ -d "/var/lib/jenkins/users" ]; then
    USER_COUNT=$(sudo ls -la /var/lib/jenkins/users/ 2>/dev/null | grep "^d" | grep -v "^\.$\|^\.\.$$" | wc -l)
    if [ $USER_COUNT -gt 0 ]; then
        echo "  [OK] Initial setup completed"
        echo "       Users configured: $USER_COUNT"
    fi
else
    echo "  [INFO] Cannot determine setup status"
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
    echo "[SUCCESS] All checks passed"
    echo ""
    echo "Jenkins is ready for configuration"
else
    echo "[WARNING] Found $ISSUES_FOUND issue(s)"
    echo ""
    echo "Fix issues listed above"
fi

echo ""
echo "Next: Configure Jenkins tools and credentials"
echo "=============================================="
