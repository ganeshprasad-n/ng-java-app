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
cp target/*.war $WILDFLY_HOME/standalone/deployments/

# ✅ Example (if WildFly is installed in /opt/wildfly):
cp target/Java-Web-Apps.war /opt/wildfly/standalone/deployments/

# ✅ Example (if WildFly is inside your home dir ~/wildfly):
cp target/Java-Web-Apps.war ~/wildfly/standalone/deployments/

# 4️⃣ Start WildFly server

# 👉 If installed as a service (systemd)
sudo systemctl start wildfly
sudo systemctl status wildfly   # (optional: check if running)

# 5️⃣ Open the application in your browser 🎉
# 👉 Replace <server-ip> with your machine IP (or use localhost if local)
# 👉 Replace <app-name> with the WAR filename (without .war), e.g., Java-Web-Apps
http://<server-ip>:8080/<app-name>/

# ✅ Example
http://10.53.85.217:8080/Java-Web-Apps/





