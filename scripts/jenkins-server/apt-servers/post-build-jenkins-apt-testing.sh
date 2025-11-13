#!/bin/bash
################################################################################
# Jenkins Server - Post-Build Verification (Ubuntu)
#
# Purpose: Quick check after each Jenkins build
# When to run: After Jenkins pipeline execution
################################################################################

echo "=============================================="
echo "Jenkins Post-Build Verification - Ubuntu"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')

################################################################################
# 1. Check Jenkins Service
################################################################################
echo "[TEST 1/4] Jenkins Service Health"
echo ""

if systemctl is-active --quiet jenkins; then
    echo "  [OK] Jenkins is running"
    
    # Check memory usage
    JENKINS_PID=$(systemctl show -p MainPID jenkins | cut -d= -f2)
    if [ "$JENKINS_PID" != "0" ]; then
        MEM_USAGE=$(ps -p $JENKINS_PID -o %mem --no-headers | tr -d ' ')
        echo "  [INFO] Memory usage: ${MEM_USAGE}%"
    fi
else
    echo "  [FAIL] Jenkins is NOT running"
    echo "         Start: sudo systemctl start jenkins"
fi
echo ""

################################################################################
# 2. Check Build Executors
################################################################################
echo "[TEST 2/4] Build Status"
echo ""

if [ -d "/var/lib/jenkins/workspace" ]; then
    WORKSPACE_COUNT=$(sudo ls /var/lib/jenkins/workspace/ 2>/dev/null | wc -l)
    echo "  [INFO] Active workspaces: $WORKSPACE_COUNT"
    
    WORKSPACE_SIZE=$(sudo du -sh /var/lib/jenkins/workspace 2>/dev/null | awk '{print $1}')
    echo "  [INFO] Workspace size: $WORKSPACE_SIZE"
else
    echo "  [INFO] No builds executed yet"
fi
echo ""

################################################################################
# 3. Check Recent Build Logs
################################################################################
echo "[TEST 3/4] Recent Activity"
echo ""

if [ -f "/var/lib/jenkins/jenkins.log" ]; then
    ERROR_COUNT=$(sudo tail -100 /var/lib/jenkins/jenkins.log 2>/dev/null | grep -i "error\|exception" | wc -l)
    
    if [ $ERROR_COUNT -gt 0 ]; then
        echo "  [WARN] Found $ERROR_COUNT error(s) in recent logs"
        echo "         Check: sudo tail -50 /var/lib/jenkins/jenkins.log"
    else
        echo "  [OK] No recent errors in Jenkins logs"
    fi
else
    echo "  [INFO] Jenkins log file not found"
fi
echo ""

################################################################################
# 4. Check Disk Space
################################################################################
echo "[TEST 4/4] Disk Space"
echo ""

JENKINS_DISK=$(df -h /var/lib/jenkins | tail -1 | awk '{print $5}' | tr -d '%')

if [ $JENKINS_DISK -lt 80 ]; then
    echo "  [OK] Disk usage: ${JENKINS_DISK}%"
elif [ $JENKINS_DISK -lt 90 ]; then
    echo "  [WARN] Disk usage: ${JENKINS_DISK}%"
    echo "         Consider cleanup soon"
else
    echo "  [CRITICAL] Disk usage: ${JENKINS_DISK}%"
    echo "         Cleanup required: sudo rm -rf /var/lib/jenkins/workspace/*"
fi
echo ""

################################################################################
# QUICK ACTIONS
################################################################################
echo "=============================================="
echo "QUICK TROUBLESHOOTING"
echo "=============================================="
echo ""
echo "View Jenkins logs:"
echo "  sudo journalctl -u jenkins -n 50"
echo ""
echo "Restart Jenkins:"
echo "  sudo systemctl restart jenkins"
echo ""
echo "Check Jenkins status:"
echo "  sudo systemctl status jenkins"
echo ""
echo "Access Jenkins:"
echo "  http://$CURRENT_IP:8080"
echo ""
echo "=============================================="
