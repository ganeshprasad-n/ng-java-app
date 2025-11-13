#!/bin/bash
################################################################################
# VProfile App Server - Post-Build Quick Test
#
# Purpose: Quick diagnosis AFTER Jenkins deployment
# When to run: After every Jenkins build/deployment
# Focus: Deployment status, application errors, quick fixes
# Author: Ganeshprasad N
# Date: 2025-11-13
################################################################################

echo "=============================================="
echo "VProfile Post-Build Quick Test"
echo "Run this after Jenkins deployment"
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
    echo "         Jenkins deployment may have failed"
    APP_WORKING=false
fi

if [ -d "/opt/tomcat9/webapps/ROOT" ]; then
    echo "  [OK] Application extracted and deployed"
else
    echo "  [WARN] Application not yet extracted"
    echo "         Tomcat may still be extracting WAR file"
fi
echo ""

################################################################################
# 2. Application Startup Check
################################################################################
echo "[TEST 2/4] Checking application startup..."
echo ""

if [ -f "/opt/tomcat9/logs/catalina.out" ]; then
    # Check if app started successfully
    if sudo tail -100 /opt/tomcat9/logs/catalina.out | grep -q "Server startup in"; then
        STARTUP_TIME=$(sudo tail -100 /opt/tomcat9/logs/catalina.out | grep "Server startup in" | tail -1 | grep -oP '\[\K[0-9]+' || echo "unknown")
        echo "  [OK] Application started successfully"
        echo "       Startup time: ${STARTUP_TIME}ms"
    else
        echo "  [FAIL] Application startup message not found"
        echo "         Application may have failed to start"
        APP_WORKING=false
    fi
    
    # Check for fatal errors
    FATAL_ERRORS=$(sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -i "SEVERE\|FATAL" | grep -v "HHH000243\|StatusLogger" | wc -l)
    if [ $FATAL_ERRORS -gt 0 ]; then
        echo "  [WARN] Found $FATAL_ERRORS fatal error(s) in recent logs"
        echo "         Last fatal error:"
        sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -i "SEVERE\|FATAL" | grep -v "HHH000243\|StatusLogger" | tail -1
        APP_WORKING=false
    else
        echo "  [OK] No fatal errors in recent logs"
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

# Only check for known problematic errors
if [ -f "/opt/tomcat9/logs/catalina.out" ]; then
    # Check RabbitMQ connection
    if sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -q "ACCESS_REFUSED.*rabbitmq"; then
        echo "  [FAIL] RabbitMQ authentication failed"
        echo "         Fix: sudo rabbitmqctl add_user vprofile_mq vprofile@rabbit123"
        echo "              sudo rabbitmqctl set_permissions -p / vprofile_mq '.*' '.*' '.*'"
        APP_WORKING=false
    else
        echo "  [OK] RabbitMQ connection OK"
    fi
    
    # Check MySQL connection
    if sudo tail -50 /opt/tomcat9/logs/catalina.out | grep -q "Access denied.*vprofile_app"; then
        echo "  [FAIL] MySQL authentication failed"
        echo "         Fix: Check MySQL user credentials"
        APP_WORKING=false
    else
        echo "  [OK] MySQL connection OK"
    fi
else
    echo "  [SKIP] Cannot check service connectivity"
fi
echo ""

################################################################################
# 4. HTTP Endpoint Test
################################################################################
echo "[TEST 4/4] Testing HTTP endpoint..."
echo ""

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$CURRENT_IP:8080 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "  [OK] Application responding (HTTP 200)"
    echo "       URL: http://$CURRENT_IP:8080"
elif [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "301" ]; then
    echo "  [OK] Application responding (HTTP $HTTP_STATUS - redirect)"
    echo "       URL: http://$CURRENT_IP:8080"
elif [ "$HTTP_STATUS" = "404" ]; then
    echo "  [FAIL] Application not found (HTTP 404)"
    echo "         Application failed to deploy properly"
    APP_WORKING=false
elif [ "$HTTP_STATUS" = "500" ]; then
    echo "  [FAIL] Application error (HTTP 500)"
    echo "         Check logs for backend service issues"
    APP_WORKING=false
else
    echo "  [WARN] Unexpected HTTP status: $HTTP_STATUS"
    echo "         Application may not be ready yet"
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
    echo "Access your application at:"
    echo "  http://$CURRENT_IP:8080"
    echo ""
else
    echo "RESULT: Issues detected"
    echo "=============================================="
    echo ""
    echo "Quick troubleshooting steps:"
    echo ""
    echo "1. View last 30 lines of logs:"
    echo "   sudo tail -30 /opt/tomcat9/logs/catalina.out"
    echo ""
    echo "2. Follow logs in real-time:"
    echo "   sudo tail -f /opt/tomcat9/logs/catalina.out"
    echo ""
    echo "3. Restart Tomcat if needed:"
    echo "   sudo systemctl restart tomcat9"
    echo "   (wait 30 seconds, then re-run this script)"
    echo ""
    echo "4. Check if services are running:"
    echo "   sudo systemctl status mysqld"
    echo "   sudo systemctl status rabbitmq-server"
    echo ""
fi
echo "=============================================="
