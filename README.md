text
# 🚀 VProfile Application - Fedora Local Deployment Guide

> **Complete step-by-step guide for deploying vProfile Java web application on Fedora 42**    
> **Status:** ✅ Single server Ready - ideal for development environment | 📝 Tested & Verified

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🙏 Acknowledgments](#-acknowledgments)
- [🏗️ Architecture](#️-architecture)
- [📋 Prerequisites](#-prerequisites)
- [🎯 Phase 1: Fedora Environment Setup](#-phase-1-fedora-environment-setup)
  - [Step 1: Run Setup Script](#step-1-run-setup-script)
  - [What Gets Installed](#what-gets-installed)
  - [Verification](#verification)
- [🎯 Phase 2: Application Setup & Deployment](#-phase-2-application-setup--deployment)
  - [📥 Stage 1: Clone Repository](#-stage-1-clone-repository)
  - [🗄️ Stage 2: Database Setup](#️-stage-2-database-setup)
  - [⚙️ Stage 3: Application Configuration](#️-stage-3-application-configuration)
  - [🔨 Stage 4: Build Application](#-stage-4-build-application)
  - [🚀 Stage 5: Deploy to Tomcat](#-stage-5-deploy-to-tomcat)
  - [🌐 Stage 6: Testing & Verification](#-stage-6-testing--verification)
  - [🔧 Stage 7: Troubleshooting](#-stage-7-troubleshooting)
- [📋 Final Verification Script](#-final-verification-script)
- [🎓 What You've Learned](#-what-youve-learned)
- [🏢 Real-World Deployment Strategies](#-real-world-deployment-strategies)
- [📝 Final Notes & Next Steps](#-final-notes--next-steps)

---

## 🎯 Overview

**[⬆️ Back to Top](#-table-of-contents)**

This document describes a **step-by-step, copy-paste-ready guide** to prepare a Fedora environment, build the Java web application (vProfile), configure required services, and deploy to Tomcat.

## 🙏 Acknowledgments

**[⬆️ Back to Top](#-table-of-contents)**

**Original Repository:**  
[https://github.com/seunayolu/JavaProject.git](https://github.com/seunayolu/JavaProject.git)  
*Thanks to Seunayolu for the source code!*

**Modified Repository (Use This):**  
[https://github.com/ganeshprasad-n/ng-java-app.git](https://github.com/ganeshprasad-n/ng-java-app.git)  
**Branch:** `fedora-local`

---

## 🏗️ Architecture

**[⬆️ Back to Top](#-table-of-contents)**

┌─────────────────────────────────────────────────────┐
│ USER BROWSER (Windows/Mac Host) │
│ Accesses: http://VM-IP:8080/ │
└────────────────────┬────────────────────────────────┘
│
↓
┌─────────────────────────────────────────────────────┐
│ TOMCAT 9 (Port 8080) │
│ ├─ vprofile-v2.war (ROOT context) │
│ └─ Spring Boot Application │
└────────┬───────────────────┬────────────────────────┘
│ │
↓ ↓
┌─────────────┐ ┌─────────────────┐
│ MySQL │ │ ElasticSearch │
│ (Port 3306)│ │ (Port 9300) │
└─────────────┘ └─────────────────┘
│
├─ RabbitMQ (Port 5672)
├─ Memcached (Port 11211)
└─ Backend Services

text

### Tech Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Backend** | Spring Boot | 4.2.0 | Application framework |
| **Frontend** | JSP/HTML/CSS/JS | - | User interface |
| **Database** | MySQL | 8.x | Data persistence |
| **Cache** | Memcached | Latest | Session caching |
| **Message Queue** | RabbitMQ | Latest | Async operations |
| **Search** | ElasticSearch | 7.x | Search functionality |
| **Server** | Apache Tomcat | 9.0.85 | Servlet container |
| **Build Tool** | Maven | 3.x | Dependency management |
| **Java** | Adoptium Temurin JDK | 11 | Runtime environment |

---

## 📋 Prerequisites

**[⬆️ Back to Top](#-table-of-contents)**

### System Requirements

- **OS:** Fedora 42 (tested) or compatible Linux
- **RAM:** Minimum 4GB (8GB recommended)
- **Disk Space:** 10GB free space
- **Network:** Internet connection for downloads

### Required Knowledge

- Basic Linux command line
- Understanding of terminal/bash
- Familiarity with text editors (nano/vim)

---

## 🎯 Phase 1: Fedora Environment Setup

**[⬆️ Back to Top](#-table-of-contents)**

### Step 1: Run Setup Script

Create a folder for scripts and run the automated setup script.

**📁 Script Files Available in repo**  

**Script:** `setup-fedora.sh`

Create scripts directory
mkdir -p ~/scripts
cd ~/scripts

Create the script file
nano setup-fedora.sh

Copy the content from setup-fedora.sh file in the repo
Make executable
chmod +x setup-fedora.sh

Run the script
./setup-fedora.sh

text

### What Gets Installed

**[⬆️ Back to Top](#-table-of-contents)**

| Component | Description | Service Port |
|-----------|-------------|--------------|
| **Adoptium Temurin JDK 11** | Java runtime (required for Spring 4.2.0) | - |
| **Apache Maven** | Build automation tool | - |
| **MySQL Server** | Relational database | 3306 |
| **RabbitMQ** | Message broker | 5672 |
| **Memcached** | Caching service | 11211 |
| **ElasticSearch** | Search engine | 9200, 9300 |
| **Apache Tomcat 9** | Servlet container | 8080 |
| **AWS CLI v2** | AWS command line (optional) | - |
| **Development Tools** | git, vim, curl, wget, etc. | - |

### Verification

After script completes, verify all services are running:

Check service status
sudo systemctl status mysqld rabbitmq-server memcached elasticsearch tomcat9

Check Java version
java -version

Should show: openjdk version "11.0.x" ... Temurin
Check Maven
mvn -version

text

**Expected Output:**
All services should show: Active: active (running)
Java 11 from Adoptium Temurin
Maven 3.x

text

---

## 🎯 Phase 2: Application Setup & Deployment

**[⬆️ Back to Top](#-table-of-contents)**

---

## 📥 Stage 1: Clone Repository

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Grabbing the application source code and reviewing the project structure.

### Commands

Create workspace
mkdir -p ~/vprofile-project
cd ~/vprofile-project

Clone the repository (fedora-local branch only)
git clone --branch fedora-local --single-branch https://github.com/ganeshprasad-n/ng-java-app.git

Navigate to project
cd ng-java-app

Explore project structure
ls -la
tree . # If tree is installed

text

### ✅ Checkpoint 1: Verify Repository Structure

Ensure these directories and files exist:

- ✅ `src/main/java/` - Java source code
- ✅ `src/main/resources/` - Configuration files
- ✅ `src/main/webapp/` - JSP, CSS, JS files
- ✅ `pom.xml` - Maven build configuration
- ✅ `src/main/resources/db_backup.sql` - Database schema

### 📖 Why This Structure?

| Aspect | Explanation |
|--------|-------------|
| **Maven Standard Directory Layout** | Industry standard for Java projects |
| **Separation of Concerns** | Code, configs, and web resources in separate folders |
| **pom.xml** | Defines dependencies and build process |
| **db_backup.sql** | Contains database schema and initial data |

### ⚠️ Possible Issues & Solutions

If Git not found
sudo dnf install git -y

If Repository not found
→ Check URL and internet connection
If Permission denied
→ Ensure correct git URL (public repo)
text

---

## 🗄️ Stage 2: Database Setup

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Creating the MySQL database and importing the schema that the application needs.

### ⚠️ Important: MySQL Authentication on Fedora

MySQL on Fedora/RHEL uses different default authentication than Ubuntu. We'll configure password-based authentication.

### Step-by-Step Setup

#### 1. Run MySQL Secure Installation

sudo mysql_secure_installation

text

**When prompted, answer:**
Set root password: y
New password: Admin@54321
Re-enter password: Admin@54321
Remove anonymous users: y
Disallow root login remotely: y
Remove test database: y
Reload privilege tables: y

text

#### 2. Login to MySQL

sudo mysql -u root -p

Enter password: Admin@54321
text

#### 3. Create Application Database

CREATE DATABASE accounts;
SHOW DATABASES;
USE accounts;
EXIT;

text

**Expected Output:**
+--------------------+
| Database |
+--------------------+
| accounts |
| information_schema |
| mysql |
| performance_schema |
+--------------------+

text

### 👤 MySQL User Management

**[⬆️ Back to Top](#-table-of-contents)**

#### Create Dedicated Application User

Login as root
sudo mysql -u root -p

Enter password: Admin@54321
text
undefined
-- Create dedicated user for vprofile app
CREATE USER 'vprofile_app'@'localhost' IDENTIFIED BY 'vprofile@54321';

-- Grant privileges only to accounts database
GRANT ALL PRIVILEGES ON accounts.* TO 'vprofile_app'@'localhost';

-- For remote access (if needed)
CREATE USER 'vprofile'@'%' IDENTIFIED BY 'vprofile@54321';
GRANT ALL PRIVILEGES ON accounts.* TO 'vprofile'@'%';

-- Apply privilege changes
FLUSH PRIVILEGES;

-- Verify user creation
SELECT user, host FROM mysql.user;

EXIT;

text

#### Test the New User

mysql -u vprofile_app -p -e "SHOW DATABASES;"

Enter password: vprofile@54321
Should see: information_schema, accounts, performance_schema
text

### Import Database Schema

Navigate to project
cd ~/vprofile-project/ng-java-app

Import schema using root
mysql -u root -p accounts < src/main/resources/db_backup.sql

Enter password: Admin@54321
OR using application user
mysql -u vprofile_app -p accounts < src/main/resources/db_backup.sql

Enter password: vprofile@54321
Verify tables
mysql -u root -p -e "USE accounts; SHOW TABLES;"

text

**Expected Output:**
+--------------------+
| Tables_in_accounts |
+--------------------+
| role |
| user |
| user_role |
+--------------------+

text

### ✅ Checkpoint 2: Verify Database Setup

Test database connection
mysql -u vprofile_app -pvprofile@54321 -e "USE accounts; SELECT COUNT(*) FROM user;"

text

- ✅ Database `accounts` created
- ✅ Tables imported: user, role, user_role
- ✅ Can connect with application user

### 📖 Why This Step?

| Aspect | Explanation |
|--------|-------------|
| **Data Persistence** | MySQL stores user accounts and application data |
| **User Management** | user_role table manages permissions |
| **Dedicated Database** | Industry standard - one database per application |
| **Dedicated User** | Principle of least privilege - app user has only necessary permissions |

### ⚠️ Common Issues

If MySQL password issues
sudo mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'newpassword';

If file not found
ls -la src/main/resources/db_backup.sql

If permission denied
sudo chmod +r src/main/resources/db_backup.sql

If tables not importing (verbose mode)
mysql -u root -p accounts < src/main/resources/db_backup.sql --verbose

text

---

## ⚙️ Stage 3: Application Configuration

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Configuring `application.properties` to connect to MySQL, RabbitMQ, Memcached, and Elasticsearch.

### Navigate to Project

cd ~/vprofile-project/ng-java-app

text

### Create/Update application.properties

nano src/main/resources/application.properties

text

**Paste this configuration:**

#JDBC Configuration for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=vprofile_app
jdbc.password=vprofile@54321

#Memcached Configuration For Active and StandBy Host
memcached.active.host=localhost
memcached.active.port=11211
memcached.standBy.host=127.0.0.2
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=localhost
rabbitmq.port=5672
rabbitmq.username=guest
rabbitmq.password=guest

#Elasticesearch Configuration
elasticsearch.host=localhost
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode

text

**Alternative: Create using here-doc:**

cat > src/main/resources/application.properties << 'EOF'
#JDBC Configuration for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=vprofile_app
jdbc.password=vprofile@54321

#Memcached Configuration For Active and StandBy Host
memcached.active.host=localhost
memcached.active.port=11211
memcached.standBy.host=127.0.0.2
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=localhost
rabbitmq.port=5672
rabbitmq.username=guest
rabbitmq.password=guest

#Elasticesearch Configuration
elasticsearch.host=localhost
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

Verify
cat src/main/resources/application.properties

text

### ✅ Checkpoint 3: Verify Configuration

- ✅ application.properties file created
- ✅ All service connections point to localhost
- ✅ MySQL credentials match your setup
- ✅ All ports match running services

### 📖 Why Each Configuration Matters

| Configuration | Purpose | Example |
|--------------|---------|---------|
| **JDBC** | Java ↔ MySQL connection | `jdbc.url=jdbc:mysql://localhost:3306/accounts` |
| **Memcached** | Session caching for performance | `memcached.active.port=11211` |
| **RabbitMQ** | Async message processing | `rabbitmq.port=5672` |
| **ElasticSearch** | Search functionality | `elasticsearch.port=9300` |

### 🏢 Industry Best Practices

- ⚠️ Never commit passwords in VCS (only for learning here)
- ✅ Use environment variables in production
- ✅ Externalize configs for different environments (dev, staging, prod)
- ✅ Use secrets management (AWS Secrets Manager, HashiCorp Vault)

### ⚠️ Common Issues

If file creation fails
vim src/main/resources/application.properties

If permission issue
sudo chown $USER:$USER src/main/resources/application.properties

If services not running
sudo systemctl status mysql rabbitmq-server memcached elasticsearch

text

---

## 🔨 Stage 4: Build Application

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Building with Maven to compile Java code, resolve dependencies, and create a WAR file for Tomcat deployment.

### Maven Lifecycle Recap

Maven executes phases sequentially:

validate → compile → test → package → verify → install → deploy

text

### Common Maven Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `mvn clean compile` | Compile only (no package, no tests) | Quick syntax check during development |
| `mvn clean test` | Compile + run unit tests | Before committing code |
| `mvn clean package` | Compile + test + create WAR/JAR | Standard build |
| `mvn clean install` | Full build + install to local repo | **Industry standard** ⭐ |

### Build the Application

Navigate to project root
cd ~/vprofile-project/ng-java-app

Check we're in the right directory
pwd
ls pom.xml # Should exist

Full build (recommended)
mvn clean install -DskipTests

Alternative: with tests
mvn clean install

text

### Verify Build Success

Check WAR file was created
ls -lh target/vprofile-v2.war

Verify file size (should be 30-60MB typically)
file target/vprofile-v2.war

Should show: Java archive data (JAR)
List WAR contents
jar -tf target/vprofile-v2.war | head -20

Should show: META-INF/, WEB-INF/, etc.
text

**Expected Output:**
-rw-rw-r-- 1 ngp ngp 50M Nov 9 06:00 target/vprofile-v2.war
target/vprofile-v2.war: Java archive data (JAR)

text

### ✅ Checkpoint 4: Verify Build Success

- ✅ `mvn clean compile` - no errors
- ✅ `mvn package` - BUILD SUCCESS
- ✅ WAR file created: `target/vprofile-v2.war`
- ✅ File size reasonable (30-60MB typical)

### 📖 What's Happening During Build

| Phase | What Happens |
|-------|--------------|
| **Clean** | Deletes `target/` directory |
| **Validate** | Checks project structure and `pom.xml` |
| **Compile** | Java files → bytecode (.class files) |
| **Test** | Runs unit tests (JUnit/TestNG) |
| **Package** | Creates WAR (Web Application Archive) |
| **Install** | Copies to local Maven repository (~/.m2/) |

### ⚠️ Common Build Issues

If Java version mismatch
mvn -version # Check Maven's Java version
java -version # Check system Java version

Both should show Java 11
If network issues (dependency download fails)
mvn clean package -o # Use offline mode if dependencies cached

If memory issues
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=512m"
mvn clean install

If dependency errors
mvn dependency:resolve
mvn dependency:tree # View dependency tree

If tests fail (but want to continue)
mvn clean install -DskipTests

text

---

## 🚀 Stage 5: Deploy to Tomcat

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Taking the WAR file and deploying it to the Tomcat servlet container.

### Prerequisites: One-Time Setup

#### Add Your User to Tomcat Group

Add user to tomcat group
sudo usermod -aG tomcat $USER

Verify
groups $USER

Should show: ngp tomcat
Log out and back in for changes to take effect
exit

SSH back in
Verify again
groups

Should show tomcat in the list
text

#### Set Directory Permissions

sudo chmod 775 /opt/tomcat9/webapps

Verify
ls -ld /opt/tomcat9/webapps

Should show: drwxrwxr-x ... tomcat tomcat ... /opt/tomcat9/webapps
text

### Manual Deployment Steps

Step 1: Stop Tomcat
sudo systemctl stop tomcat9
sleep 2

Step 2: Clean old deployment
sudo rm -rf /opt/tomcat9/webapps/ROOT
sudo rm -f /opt/tomcat9/webapps/ROOT.war

Step 3: Deploy WAR
sudo cp ~/vprofile-project/ng-java-app/target/vprofile-v2.war /opt/tomcat9/webapps/ROOT.war
sudo chown tomcat:tomcat /opt/tomcat9/webapps/ROOT.war

Step 4: Start Tomcat
sudo systemctl start tomcat9

Step 5: Wait for deployment (30 seconds)
sleep 30

Step 6: Verify deployment
ls -la /opt/tomcat9/webapps/ | grep ROOT

Should show both ROOT.war and ROOT/ directory
text

### Automated Deployment Script

**[⬆️ Back to Top](#-table-of-contents)**

**Script:** `deployment-fedora.sh`

Navigate to scripts directory
cd ~/scripts

Create deployment script
nano deployment-fedora.sh

Copy the content from deployment-fedora.sh file in the repo
Make executable
chmod +x deployment-fedora.sh

Run deployment
./deployment-fedora.sh

text

### Monitoring & Logs

Monitor deployment in real-time
sudo tail -f /opt/tomcat9/logs/catalina.out

View last 200 lines
sudo tail -200 /opt/tomcat9/logs/catalina.out

Search for errors
sudo grep -i "error|exception|failed" /opt/tomcat9/logs/catalina.out | tail -30

If required, restart Tomcat
sudo systemctl restart tomcat9

text

### ✅ Checkpoint 5: Verify Deployment

Check Tomcat service
sudo systemctl status tomcat9

Should show: Active: active (running)
Check WAR file
ls -lh /opt/tomcat9/webapps/ROOT.war

Should show: -rw-r--r-- 1 tomcat tomcat 50M ...
Check deployment extraction
ls -la /opt/tomcat9/webapps/ROOT/

Should show WEB-INF/, META-INF/, etc.
Check logs for success message
sudo grep "Server startup" /opt/tomcat9/logs/catalina.out | tail -1

Should show: Server startup in [XXXX] milliseconds
text

- ✅ Tomcat service running
- ✅ WAR file in webapps directory
- ✅ Catalina logs show no severe errors
- ✅ Deployment completion message in logs

### 📖 Why Deploy as ROOT.war?

| Aspect | Explanation |
|--------|-------------|
| **Root Context** | App accessible at `http://localhost:8080/` (no context path) |
| **No App Name in URL** | Users don't need to remember `/vprofile-v2/` |
| **Main Application** | Standard for primary application on a server |
| **Industry Practice** | Microservices: one app per container as ROOT |

### 🏢 Industry Deployment Strategies

| Strategy | Use Case | URL Pattern |
|----------|----------|-------------|
| **ROOT deployment** | Modern microservices, one app per Tomcat | `http://host:8080/` |
| **Context path deployment** | Multiple apps on one Tomcat (legacy) | `http://host:8080/app1/`, `http://host:8080/app2/` |
| **Manager deployment** | Web-based upload via Tomcat Manager | `http://host:8080/manager/` |

### ⚠️ Deployment Issues & Fixes

If Tomcat won't start
sudo journalctl -u tomcat9 -f

If permission errors
sudo chown -R tomcat:tomcat /opt/tomcat9/webapps/

If port 8080 in use
sudo netstat -tulpn | grep 8080

Change port in /opt/tomcat9/conf/server.xml if needed
If WAR not deploying
sudo tail -f /opt/tomcat9/logs/catalina.out

Look for deployment messages
text

### Alternative: Deploy with Context Path

If you prefer accessing the app at `http://localhost:8080/vprofile-v2/`:

sudo systemctl stop tomcat9
sudo rm -rf /opt/tomcat9/webapps/ROOT* /opt/tomcat9/webapps/vprofile*
sudo cp ~/vprofile-project/ng-java-app/target/vprofile-v2.war /opt/tomcat9/webapps/
sudo chown tomcat:tomcat /opt/tomcat9/webapps/vprofile-v2.war
sudo systemctl start tomcat9

Access at:
http://localhost:8080/vprofile-v2/
text

---

## 🌐 Stage 6: Testing & Verification

**[⬆️ Back to Top](#-table-of-contents)**

### What We're Doing

Verifying the application is working end-to-end with all services connected.

### Quick Tests from Terminal

Test Tomcat response
curl -I http://localhost:8080/

Should return: HTTP/1.1 200 or HTTP/1.1 302 (redirect to /login)
Test application homepage
curl http://localhost:8080/ | head -20

Should return HTML content, not 404 error
Monitor logs for errors
sudo tail -f /opt/tomcat9/logs/catalina.out | grep -i "error|warn|exception"

text

### Manual Browser Testing

**From your host machine browser:**

http://VM-IP:8080/

text

**Example:**
http://10.115.108.134:8080/

text

**Test these features:**

- ✅ Homepage loads
- ✅ Can navigate to `/login`
- ✅ Can navigate to `/registration`
- ✅ Form inputs work
- ✅ No JavaScript errors in browser console (F12)

### Comprehensive Service Check

Create service check script
cat > ~/scripts/check-services.sh << 'EOF'
#!/bin/bash
echo "=== VProfile Service Check ==="
echo ""

echo "MySQL: $(nc -z localhost 3306 && echo 'OK ✅' || echo 'FAIL ❌')"
echo "RabbitMQ: $(nc -z localhost 5672 && echo 'OK ✅' || echo 'FAIL ❌')"
echo "Memcached: $(nc -z localhost 11211 && echo 'OK ✅' || echo 'FAIL ❌')"
echo "ElasticSearch: $(curl -s http://localhost:9200 > /dev/null && echo 'OK ✅' || echo 'FAIL ❌')"
echo "Tomcat: $(curl -s http://localhost:8080 > /dev/null && echo 'OK ✅' || echo 'FAIL ❌')"
EOF

chmod +x ~/scripts/check-services.sh
~/scripts/check-services.sh

text

**Expected Output:**
=== VProfile Service Check ===

MySQL: OK ✅
RabbitMQ: OK ✅
Memcached: OK ✅
ElasticSearch: OK ✅
Tomcat: OK ✅

text

### ✅ Checkpoint 6: Full Application Verification

- ✅ Tomcat responds on port 8080
- ✅ Application homepage loads
- ✅ No errors in browser console
- ✅ Database operations work (register/login)
- ✅ All services connected
- ✅ **Application is LIVE!** 🎉

### 📖 What to Test

| Feature | How to Test | Expected Result |
|---------|-------------|-----------------|
| **Homepage** | Visit `http://VM-IP:8080/` | Shows login/registration page |
| **User Registration** | Fill registration form | New user created in database |
| **User Login** | Login with credentials | Session created, redirect to dashboard |
| **Database Query** | Login (triggers SELECT query) | User data loaded from MySQL |
| **Session Caching** | Login, refresh page | Session persists (Memcached working) |
| **Search** | Use search feature | ElasticSearch returns results |

---

## 🔧 Stage 7: Troubleshooting

**[⬆️ Back to Top](#-table-of-contents)**

### Database Connection Issues

Test MySQL connection
mysql -u root -pAdmin@54321 -e "SELECT 1;"

Check application properties
cat ~/vprofile-project/ng-java-app/src/main/resources/application.properties | grep jdbc

Verify MySQL is listening
sudo netstat -tulpn | grep 3306

Check MySQL service status
sudo systemctl status mysql

text

### Service Connection Problems

Check all services status
sudo systemctl status mysql rabbitmq-server memcached elasticsearch tomcat9

Test individual service connectivity
echo "stats" | nc localhost 11211 # Memcached
nc -z localhost 5672 && echo "RabbitMQ OK" # RabbitMQ
mysql -u root -p'Admin@54321' -e "SELECT 1;" # MySQL
curl http://localhost:9200 # ElasticSearch

text

### Application Debugging & Logs

Live log monitoring
sudo tail -f /opt/tomcat9/logs/catalina.out

Check for specific errors
sudo grep -i "error|exception|failed" /opt/tomcat9/logs/catalina.out | tail -10

Verify WAR extraction
ls -la /opt/tomcat9/webapps/ROOT/

Check disk space
df -h

Check memory usage
free -h

Check Java process
ps aux | grep tomcat

text

### Common Error Patterns

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `Connection refused (localhost:3306)` | MySQL not running | `sudo systemctl start mysqld` |
| `Access denied for user 'vprofile_app'` | Wrong credentials | Check application.properties |
| `java.lang.OutOfMemoryError` | Insufficient heap memory | Increase `-Xmx` in Tomcat config |
| `Address already in use (port 8080)` | Port conflict | Change port or kill process using it |
| `ClassNotFoundException` | Missing dependency | Rebuild with `mvn clean install` |

### Debugging: 404 Error (Default Tomcat Page)

**[⬆️ Back to Top](#-table-of-contents)**

**Symptom:** Tomcat default page shown instead of your app.

**Root cause:** Default ROOT app still serving; your app either not deployed to ROOT or not extracted correctly.

**Systematic debugging steps:**

Step 1: Check webapps directory
sudo ls -la /opt/tomcat9/webapps/

Should show: ROOT.war and ROOT/ directory
Step 2: Monitor deployment logs
sudo tail -f /opt/tomcat9/logs/catalina.out

Look for: "Deployment of web application archive [.../ROOT.war] has finished"
Step 3: Check if ROOT directory has content
ls -la /opt/tomcat9/webapps/ROOT/

Should show: WEB-INF/, META-INF/, index.jsp, etc.
Step 4: Check application-specific logs
sudo tail -f /opt/tomcat9/logs/localhost.*.log

Step 5: Verify WAR integrity
jar -tf ~/vprofile-project/ng-java-app/target/vprofile-v2.war | head

text

**Fixes:**

Option 1: Force redeploy
sudo systemctl stop tomcat9
sudo rm -rf /opt/tomcat9/webapps/ROOT*
sudo cp ~/vprofile-project/ng-java-app/target/vprofile-v2.war /opt/tomcat9/webapps/ROOT.war
sudo chown tomcat:tomcat /opt/tomcat9/webapps/ROOT.war
sudo systemctl start tomcat9

Option 2: Deploy with context path (alternative)
sudo systemctl stop tomcat9
sudo rm -rf /opt/tomcat9/webapps/ROOT* /opt/tomcat9/webapps/vprofile*
sudo cp ~/vprofile-project/ng-java-app/target/vprofile-v2.war /opt/tomcat9/webapps/vprofile-v2.war
sudo chown tomcat:tomcat /opt/tomcat9/webapps/vprofile-v2.war
sudo systemctl start tomcat9

Access at: http://VM-IP:8080/vprofile-v2/
text

**Pro tip:** Always check logs first — 90% of issues are visible there.

---

## 📋 Final Verification Script

**[⬆️ Back to Top](#-table-of-contents)**

Save as `verify-vprofile.sh` and run:

#!/bin/bash
echo "=== VProfile Complete Verification ==="
echo ""

1. Service Status
echo "1. Service Status:"
echo " MySQL: $(sudo systemctl is-active mysqld)"
echo " RabbitMQ: $(sudo systemctl is-active rabbitmq-server)"
echo " Memcached: $(sudo systemctl is-active memcached)"
echo " ElasticSearch: $(sudo systemctl is-active elasticsearch)"
echo " Tomcat: $(sudo systemctl is-active tomcat9)"
echo ""

2. Port Listening
echo "2. Port Accessibility:"
for port in 3306 5672 11211 9200 8080; do
nc -z localhost $port 2>/dev/null && echo " Port $port: OPEN ✅" || echo " Port $port: CLOSED ❌"
done
echo ""

3. Application Health
echo "3. Application Health:"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
echo " HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
echo " Application: HEALTHY ✅"
else
echo " Application: UNHEALTHY ❌"
fi
echo ""

4. Database Connectivity
echo "4. Database Test:"
DB_TEST=$(mysql -u root -p'Admin@54321' -e "SELECT COUNT(*) FROM accounts.user;" 2>/dev/null | tail -1)
if [ -n "$DB_TEST" ]; then
echo " Users in DB: $DB_TEST ✅"
else
echo " Database connection: FAILED ❌"
fi
echo ""

echo "=== Verification Complete ==="

text

**Usage:**

chmod +x ~/scripts/verify-vprofile.sh
~/scripts/verify-vprofile.sh

text

---

## 🎓 What You've Learned

**[⬆️ Back to Top](#-table-of-contents)**

### Core Concepts Mastered

| Concept | What You Learned |
|---------|-----------------|
| **Git & Version Control** | Clone and explore Java projects |
| **MySQL Database** | Setup, user management, schema import |
| **Application Configuration** | Connect Java to backend services |
| **Maven Build Tool** | Compile, test, package Java applications |
| **Java Web Applications** | WAR file structure and deployment |
| **Tomcat Server** | Deploy and manage web applications |
| **Multi-tier Architecture** | Frontend, backend, database, cache, queue integration |
| **DevOps Workflow** | Build, test, deploy automation |
| **Linux System Admin** | User management, permissions, service management |
| **Troubleshooting** | Systematic debugging approach |

### 📚 Industry Skills

You now understand:

- ✅ How to setup a complete development environment
- ✅ How Java applications are structured (Maven standard layout)
- ✅ How to build and package applications
- ✅ How to deploy to production servers
- ✅ How to manage databases and services
- ✅ How to troubleshoot deployment issues
- ✅ Real-world DevOps practices

### 🚀 Real-World Applications

This workflow is used by:

- ✅ DevOps Engineers
- ✅ Backend Developers
- ✅ Site Reliability Engineers (SRE)
- ✅ System Administrators
- ✅ Platform Engineers

### 📝 Next Steps

1. **Automate Everything**: Create scripts for repeated tasks
2. **Add CI/CD**: Use Jenkins/GitLab for automatic builds
3. **Container Deployment**: Move to Docker/Kubernetes
4. **Cloud Deployment**: Deploy to AWS/Azure/GCP
5. **Advanced Monitoring**: Add Prometheus/Grafana

---

## 🏢 Real-World Deployment Strategies

**[⬆️ Back to Top](#-table-of-contents)**

### Single vs Multiple WAR Deployments

#### Single WAR (ROOT.war)

**URL:** `http://localhost:8080/`

**Use case:** One application per Tomcat server (modern cloud approach)

**Pros:**
- ✅ Isolation - failures don't affect other apps
- ✅ Easier scaling per service
- ✅ Simpler troubleshooting
- ✅ Recommended modern approach

**Cons:**
- ❌ Higher resource usage per app
- ❌ More servers to manage

#### Multiple WARs (context paths)

**URLs:**
- `http://localhost:8080/vprofile/` → vprofile.war
- `http://localhost:8080/api/` → api.war
- `http://localhost:8080/admin/` → admin.war

**Use case:** Legacy/monolithic deployments or when multiple apps need to share a JVM

**Pros:**
- ✅ Cost-saving - one server for multiple apps
- ✅ Shared resources (connection pools, etc.)
- ✅ Lower infrastructure cost

**Cons:**
- ❌ Single point of failure
- ❌ Resource contention
- ❌ Complex troubleshooting

### Modern vs Legacy Comparison

| Aspect | Single WAR (Modern) | Multiple WARs (Legacy) |
|--------|---------------------|------------------------|
| **Architecture** | Microservices | Monolithic |
| **Scaling** | Per service | All or nothing |
| **Deployment** | Independent | Coordinated |
| **Resource Isolation** | ✅ High | ❌ Low |
| **Cost** | Higher (more instances) | Lower (shared instance) |
| **Complexity** | Simple per service | Complex overall |
| **Failure Impact** | Isolated | Cascading |
| **Recommended For** | Cloud, Containers | On-premise, Legacy |

### Real-World Strategies

#### Modern Approach (Recommended)

┌─────────────────────────────────────────┐
│ Load Balancer (Nginx / ALB / CloudFlare)│
└────────────┬────────────────────────────┘
│
┌──────┴──────┐
│ │
┌─────▼────┐ ┌─────▼────┐
│ Container│ │ Container│
│ (Tomcat) │ │ (Tomcat) │
│ ROOT.war │ │ ROOT.war │
└──────────┘ └──────────┘

text

**Characteristics:**
- One WAR per container/VM
- Deployed as ROOT
- Reverse proxy handles routing
- Horizontal scaling

#### Legacy Approach

┌──────────────────────────────┐
│ Single Tomcat Server │
├──────────────────────────────┤
│ vprofile.war → /vprofile/ │
│ api.war → /api/ │
│ admin.war → /admin/ │
└──────────────────────────────┘

text

**Characteristics:**
- Multiple WARs on single Tomcat
- Context path routing
- Shared resources
- Vertical scaling

### Recommendation for vProfile

**Use single ROOT.war deployment** - aligns with modern standards and cloud-native practices.

---

## 📝 Final Notes & Next Steps

**[⬆️ Back to Top](#-table-of-contents)**

### 📁 Provided Scripts

Use these scripts for repeatable operations:

| Script | Purpose | Location |
|--------|---------|----------|
| `setup-fedora.sh` | Environment setup | [Google Drive](https://drive.google.com/drive/folders/1pI2YbeFA3GhPIRtTORFiMvzwx9XtgdNj?usp=drive_link) |
| `deployment-fedora.sh` | Application deployment | [Google Drive](https://drive.google.com/drive/folders/1pI2YbeFA3GhPIRtTORFiMvzwx9XtgdNj?usp=drive_link) |
| `verify-vprofile.sh` | Health check | [Above](#-final-verification-script) |
| `check-services.sh` | Service status | [Above](#comprehensive-service-check) |

### 🔒 Production Security Checklist

**⚠️ Before production deployment:**

- ❌ Do NOT store passwords in `application.properties`
- ✅ Use environment variables or secrets manager
- ✅ Enable HTTPS/TLS
- ✅ Change default passwords (MySQL root, RabbitMQ guest)
- ✅ Enable firewall rules
- ✅ Regular backups
- ✅ Monitoring and alerting
- ✅ Log aggregation

### Example: Externalize Credentials

Production approach - use environment variables
export DB_USERNAME=vprofile_app
export DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id prod/vprofile/db --query SecretString --output text)

Or use Spring Boot profiles
java -jar app.jar --spring.profiles.active=prod

text

### 📚 Additional Resources

- **Maven Documentation**: https://maven.apache.org/
- **Tomcat Documentation**: https://tomcat.apache.org/
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **Spring Boot**: https://spring.io/projects/spring-boot
- **Java Documentation**: https://docs.oracle.com/en/java/

### 🙋 Getting Help

If you encounter issues:

1. Check logs first: `sudo tail -f /opt/tomcat9/logs/catalina.out`
2. Verify all services are running: `sudo systemctl status mysql rabbitmq-server memcached elasticsearch tomcat9`
3. Run verification script: `~/scripts/verify-vprofile.sh`
4. Search error messages online
5. Check GitHub Issues in the repository

---

## 📝 Document Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2025-11-09 | 1.0 | Initial release with comprehensive guide |

---

**Happy Deploying! 🚀**

**[⬆️ Back to Top](#-table-of-contents)**

---