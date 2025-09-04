# 🌟 Java Web Application on WildFly 🌟

This project contains a simple **Java Web Application** built with **Maven** that generates a **WAR file**.  
We will deploy the WAR on **WildFly** and run it in a browser.

---

## 🛠️ Prerequisites

Make sure you have the following installed:

- ☕ Java 17 (Adoptium / Corretto / OpenJDK)  
- 🐘 Apache Maven 3.8+  
- 🦊 WildFly Application Server - 28.0.0
#(Steps - https://www.atlantic.net/vps-hosting/how-to-install-wildfly-server-on-fedora/#step-2-install-wildfly-and-configure)
- 🌀 Git  

---

## 🚀 Setup and Run

```bash
# 1️⃣ Clone the repository
git clone git@github.com:ganeshprasad-n/ng-java-app.git
cd ng-java-app

# 2️⃣ Build the project with Maven
mvn clean package

# 3️⃣ Copy the WAR file into WildFly deployments folder
# 👉 Replace $WILDFLY_HOME with your WildFly installation path
cp target/<war_name> $WILDFLY_HOME/standalone/deployments/

# ✅ Example (if WildFly is installed in /opt/wildfly):
cp target/Java-Web-Apps.war /opt/wildfly/standalone/deployments/

# ✅ Example (if WildFly is inside your home dir ~/wildfly):
cp target/Java-Web-Apps.war ~/wildfly/standalone/deployments/

# 4️⃣ Start WildFly server

# 👉 If installed as a service (systemd)
sudo systemctl restart wildfly
sudo systemctl status wildfly     # (optional: check if running)

# 5️⃣ Open the application in your browser 🎉
# 👉 Replace <server-ip> with your machine IP (or use localhost if local)
# 👉 Replace <app-name> with the WAR filename (without .war), e.g., Java-Web-Apps
http://<server-ip>:8080/<app-name>/

# ✅ Example
http://10.53.85.217:8080/webapp/


#Optional steps

# =========================================================
# Step 0: Prerequisites
# =========================================================
# Ensure WildFly is installed and running on 10.41.88.217:8080
# Ensure SELinux is enabled (enforcing)
# You have sudo privileges

# =========================================================
# Step 1: Stop Apache (if running)
# =========================================================
sudo systemctl stop httpd
sudo systemctl disable httpd
sudo systemctl status httpd

# =========================================================
# Step 2: Install Nginx
# =========================================================
sudo dnf install nginx -y      # Fedora/RHEL
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx

# Check in browser: http://10.41.88.217 should show Nginx welcome page

# =========================================================
# Step 3: Backup Default Nginx Configuration
# =========================================================
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# =========================================================
# Step 4: Configure Nginx to Proxy WildFly
# =========================================================
sudo nano /etc/nginx/nginx.conf
# Replace contents with:

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;               # NGINX will serve on standard HTTP port
        server_name _;           # default server

        location / {
            proxy_pass http://10.41.88.217:8080/webapp/;   # forward to WildFly
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}

# Save & exit (Ctrl+O, Enter, Ctrl+X)

# =========================================================
# Step 5: Test Nginx Configuration
# =========================================================
sudo nginx -t      # Check syntax
sudo systemctl restart nginx
sudo systemctl status nginx

# Test in browser: http://10.41.88.217 should show your WildFly app

# =========================================================
# Step 6: Re-enable SELinux
# =========================================================
sudo setenforce 1
sestatus

# If Nginx cannot connect to WildFly due to SELinux:
sudo setsebool -P httpd_can_network_connect 1

# =========================================================
# ✅ Done!
# =========================================================
# WildFly running on 8080
# Nginx proxying requests to WildFly
# SELinux enforcing, Nginx allowed to connect
# All set for production!








