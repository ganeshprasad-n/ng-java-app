#!/bin/bash
################################################################################
# VProfile Java Application - Automated Deployment Script
# 
# Purpose: Automating build and deployment for VProfile application
# Tested On: Fedora 42
# Author: Ganeshprasad N
# Created: $(date +%Y-%m-%d)
# Usage: ./deployment-fedora.sh
# 
# Features:
# - Simple and straightforward commands
# - Safe to run multiple times
################################################################################

echo "═══════════════════════════════════════════"
echo "🚀 VPROFILE DEPLOYMENT"
echo "═══════════════════════════════════════════"


# Step 1: Build
echo ""
echo "📦 Step 1: Building application..."
cd ~/vprofile-app/ng-java-app/
mvn clean install -DskipTests
echo "✅ Build complete"


# Step 2: Fix permissions
echo ""
echo "🔧 Step 2: Fixing permissions..."
sudo chmod 755 /opt/tomcat9/webapps
echo "✅ Permissions fixed"


# Step 3: Stop Tomcat
echo ""
echo "⏸️  Step 3: Stopping Tomcat..."
sudo systemctl stop tomcat9
sleep 2
echo "✅ Tomcat stopped"


# Step 4: Clean old deployment
echo ""
echo "🗑️  Step 4: Cleaning old deployment..."
sudo rm -rf /opt/tomcat9/webapps/ROOT
sudo rm -f /opt/tomcat9/webapps/ROOT.war
echo "✅ Old deployment removed"


# Step 5: Deploy WAR
echo ""
echo "📤 Step 5: Deploying WAR file..."
sudo cp ~/vprofile-app/ng-java-app/target/vprofile-v2.war /opt/tomcat9/webapps/ROOT.war
sudo chown tomcat:tomcat /opt/tomcat9/webapps/ROOT.war
echo "✅ WAR file deployed"


# Step 6: Start Tomcat
echo ""
echo "▶️  Step 6: Starting Tomcat..."
sudo systemctl start tomcat9
sleep 5
echo "✅ Tomcat started"


# Step 7: Wait for deployment
echo ""
echo "⏳ Step 7: Waiting 30 seconds for deployment..."
sleep 30
echo "✅ Wait complete"


# Step 8: Verify
echo ""
echo "🔍 Step 8: Checking deployment..."
if [ -d "/opt/tomcat9/webapps/ROOT" ]; then
    echo "✅ Application deployed successfully!"
    echo ""
    echo "═══════════════════════════════════════════"
    echo "🎉 DEPLOYMENT SUCCESSFUL"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "📍 Access your application:"
    echo "🌐 URL: http://<server_IP>:8080/"
    echo ""
    ls -lh /opt/tomcat9/webapps/ | grep ROOT
else
    echo "❌ Deployment failed!"
    echo ""
    echo "📋 Checking Tomcat logs..."
    sudo tail -30 /opt/tomcat9/logs/catalina.out
fi
