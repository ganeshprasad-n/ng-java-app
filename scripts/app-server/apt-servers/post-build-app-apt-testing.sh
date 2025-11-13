#!/bin/bash
################################################################################
# VProfile App Server - Post-Build Quick Test (Ubuntu)
#
# Purpose: Quick diagnosis after Jenkins deployment
# When to run: After every Jenkins build/deployment
################################################################################

echo "=============================================="
echo "VProfile Post-Build Quick Test - Ubuntu"
echo "=============================================="
echo ""

CURRENT_IP=$(hostname -I | awk '{print $1}')
APP_WORKING=true

################################################################################
# 1. Deployment Files Check
################################################################################
echo "[TEST 1/4] Checking deployment files..."
echo ""

if [ -f "/opt/tomcat9/webapps/ROOT.war" ]; then
    WAR_SIZE=$(ls -lh /opt/tomcat9/webapps/ROOT.war | awk '{print $5}')
    WAR_DATE=$(ls -l /opt/tomcat9/webapps/ROOT.war | awk '{print $6, $7, $8}')
    echo "  [OK] ROOT.war deployed"
    echo "       Size: $WAR_SIZE"
    echo "       Date: $WAR_DATE"
else
    echo "  [FAIL] ROOT.war NOT found"
    APP_WORKING=false
fi

if [ -d "/opt/tomcat9/webapps/ROOT" ]; then
    echo "  [OK] Application extracted"
else
    echo "  [INFO] Application not yet extracted"
fi
echo ""

################################################################################
# 2. Application Startup Check
################################################################################
echo "[TEST 2/4] Checking application startup..."
echo ""

if [ -f "/opt/tomcat9/logs/catalina.out" ]; then
    if sudo tail -100 /opt/tomcat9/logs/catalina.out | grep -q "Server startup in"; then
        STARTUP_TIME=$(sudo tail -100 /opt/tomcat9/logs/catalina.out | grep "Server startup in" | tail -1 | grep -oP '\[\K[0-9]+' || echo "unknown")
        echo "  [OK] Application started successfully"
        echo "       Startup time: ${STARTUP_TIME}ms"
    else
        echo "  [FAIL] Application startup message not found"
        APP_WORKING=false
    fi
    
    FATAL_ERRORS=$(sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -i "SEVERE\|FATAL" | grep -v "HHH000243\|StatusLogger" | wc -l)
    if [ $FATAL_ERRORS -gt 0 ]; then
        echo "  [WARN] Found $FATAL_ERRORS fatal error(s)"
        APP_WORKING=false
    else
        echo "  [OK] No fatal errors"
    fi
else
    echo "  [FAIL] Tomcat log file not found"
    APP_WORKING=false
fi
echo ""

################################################################################
# 3. Service Connectivity Check
################################################################################
echo "[TEST 3/4] Checking backend services..."
echo ""

if [ -f "/opt/tomcat9/logs/catalina.out" ]; then
    if sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -q "ACCESS_REFUSED.*rabbitmq"; then
        echo "  [FAIL] RabbitMQ authentication failed"
        APP_WORKING=false
    else
        echo "  [OK] RabbitMQ connection OK"
    fi
    
    if sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -q "Access denied.*vprofile_app"; then
        echo "  [FAIL] MySQL authentication failed"
        APP_WORKING=false
    else
        echo "  [OK] MySQL connection OK"
    fi
else
    echo "  [SKIP] Cannot check connectivity"
fi
echo ""

################################################################################
# 4. HTTP Endpoint Test
################################################################################
echo "[TEST 4/4] Testing HTTP endpoint..."
echo ""

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$CURRENT_IP:8080 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "301" ]; then
    echo "  [OK] Application responding (HTTP $HTTP_STATUS)"
    echo "       URL: http://$CURRENT_IP:8080"
elif [ "$HTTP_STATUS" = "404" ]; then
    echo "  [FAIL] Application not found (HTTP 404)"
    APP_WORKING=false
elif [ "$HTTP_STATUS" = "500" ]; then
    echo "  [FAIL] Application error (HTTP 500)"
    APP_WORKING=false
else
    echo "  [WARN] HTTP status: $HTTP_STATUS"
fi
echo ""

################################################################################
# FINAL RESULT
################################################################################
echo "=============================================="
if [ "$APP_WORKING" = true ]; then
    echo "RESULT: Application is WORKING"
    echo "=============================================="
    echo ""
    echo "Access: http://$CURRENT_IP:8080"
else
    echo "RESULT: Issues detected"
    echo "=============================================="
    echo ""
    echo "Troubleshooting:"
    echo "  1. View logs: sudo tail -30 /opt/tomcat9/logs/catalina.out"
    echo "  2. Follow logs: sudo tail -f /opt/tomcat9/logs/catalina.out"
    echo "  3. Restart: sudo systemctl restart tomcat9"
    echo "  4. Check services: sudo systemctl status mysql rabbitmq-server"
fi
echo "=============================================="