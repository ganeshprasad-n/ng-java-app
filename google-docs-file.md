text
# 🚀 Production-Grade 3-Tier AWS Application Deployment Guide

> **Complete Step-by-Step Guide to Deploy a Scalable, Secure, and High-Performance Cloud Application with CloudFront, ALB, RDS, and ElastiCache**

---

## 📑 Table of Contents

- [🏗️ Architecture Overview](#-architecture-overview)
- [📋 Prerequisites](#-prerequisites)
- [📝 Step 1: Application Properties Configuration](#-step-1-application-properties-configuration)
- [💾 Step 2: S3 Static Assets Setup](#-step-2-s3-static-assets-setup)
- [🌐 Step 3: CloudFront CDN Configuration](#-step-3-cloudfront-cdn-configuration)
- [⚖️ Step 4: Application Load Balancer Setup](#-step-4-application-load-balancer-setup)
- [🎯 Step 5: Target Group Configuration](#-step-5-target-group-configuration)
- [🔐 Step 6: Security Groups Configuration](#-step-6-security-groups-configuration)
- [🔀 Step 7: CloudFront Origins & Behaviors](#-step-7-cloudfront-origins--behaviors)
- [✅ Step 8: Testing & Verification](#-step-8-testing--verification)
- [🐛 Common Issues & Troubleshooting](#-common-issues--troubleshooting)
- [📌 Checkpoints Summary](#-checkpoints-summary)
- [📚 Quick Reference](#-quick-reference)
- [🎉 Conclusion](#-conclusion)

---

## 🏗️ Architecture Overview

┌─────────────────────────────────────────────────────────────────┐
│ Internet Users │
│ (Global Access) │
└────────────────────┬────────────────────────────────────────────┘
│
▼
┌────────────────────────────┐
│ CloudFront CDN │
│ d129luge7edfzu │
│ (Global Edge Locations) │
└────┬──────────┬────────┬───┘
│ │ │
┌────▼───┐ ┌───▼────┐ ┌─▼──────┐
│ S3 │ │ S3 │ │ ALB │
│ /css │ │/images │ │:80 │
│ /js │ │ │ │ │
└────────┘ └────────┘ └────┬───┘
│
▼
┌──────────────────┐
│ Target Group │
│ Port: 8080 │
└────────┬─────────┘
│
┌────────────▼─────────────┐
│ │
┌─────▼──────┐ ┌────────▼────┐
│ EC2 - App │ │ RDS MySQL │
│ Tomcat:8080│◄───────►│ Memcached │
└────────────┘ └─────────────┘

text

### ✨ Why This Architecture?

| Component | Purpose | Benefit |
|-----------|---------|---------|
| **CloudFront** | Global CDN | Reduced latency, global coverage |
| **ALB** | Load balancing | Traffic distribution, health checks |
| **S3 + OAC** | Static assets | Secure, cost-effective storage |
| **EC2** | Application server | Flexible compute |
| **RDS** | Database | Managed, reliable data storage |
| **ElastiCache** | Session cache | Improved performance, scalability |

---

## 📋 Prerequisites

### ✅ Required AWS Resources

- [ ] EC2 instance running with Tomcat installed
- [ ] RDS MySQL database created and running
- [ ] ElastiCache Memcached cluster created
- [ ] S3 bucket created for static files
- [ ] VPC with public/private subnets configured
- [ ] Security groups created (ALB, EC2, RDS, ElastiCache)
- [ ] IAM permissions for AWS services
- [ ] AWS CLI configured (optional but recommended)

### 📦 Required Knowledge

- Intermediate AWS knowledge
- Basic Linux/Ubuntu CLI
- Understanding of networking (ports, security groups)
- Java/Spring Boot familiarity

### 🛠️ Required Tools

AWS CLI
aws --version

Maven (for building Java application)
mvn --version

Git (for cloning project)
git --version

text

---

## 📝 Step 1: Application Properties Configuration

### 🎯 Overview

Spring Boot applications require specific property keys for database, cache, and CDN configuration. Using wrong property names causes application startup failures.

**Key Point:** The application expects `jdbc.*` properties (NOT Spring Boot's default `spring.datasource.*`)

### 🔧 Configuration File Location

~/ng-java-app/src/main/resources/application.properties

text

### 📄 Complete Property Configuration

Create or update the file with these properties:

============================================
DATABASE CONFIGURATION
============================================
jdbc.driverClassName=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://vprofile-db-mysql.cy5icoeogbzs.us-east-1.rds.amazonaws.com:3306/accounts
jdbc.username=admin
jdbc.password=>Q1|x2QkH[ZH9g#Fbx(W_#fbgH~s

============================================
MEMCACHED CONFIGURATION
============================================
memcached.active.host=vprofile-memcache.hsm7kd.cfg.use1.cache.amazonaws.com
memcached.active.port=11211
memcached.standBy.host=vprofile-memcache.hsm7kd.cfg.use1.cache.amazonaws.com
memcached.standBy.port=11211

============================================
RABBITMQ CONFIGURATION (Placeholder - Not Used)
============================================
rabbitmq.address=localhost
rabbitmq.port=5672
rabbitmq.username=guest
rabbitmq.password=guest

============================================
ELASTICSEARCH CONFIGURATION (Placeholder - Not Used)
============================================
elasticsearch.host=localhost
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode

============================================
CDN CONFIGURATION
============================================
cdn.enabled=true
cdn.domain=https://d129luge7edfzu.cloudfront.net

text

### 💡 Property Explanation Table

| Property | Purpose | Example | Why It's Needed |
|----------|---------|---------|-----------------|
| `jdbc.driverClassName` | MySQL JDBC driver | `com.mysql.cj.jdbc.Driver` | Connect to MySQL |
| `jdbc.url` | Database connection string | `jdbc:mysql://rds-endpoint:3306/db` | Specify database |
| `jdbc.username` | DB username | `admin` | Authenticate to RDS |
| `jdbc.password` | DB password | `password123` | Authenticate to RDS |
| `memcached.active.host` | Primary cache endpoint | `cache.amazonaws.com` | Primary cache server |
| `memcached.active.port` | Cache port | `11211` | Memcached default port |
| `rabbitmq.address` | Message queue host | `localhost` | **Placeholder (required)** |
| `rabbitmq.port` | Queue port | `5672` | **Placeholder (required)** |
| `elasticsearch.host` | Search engine host | `localhost` | **Placeholder (required)** |
| `elasticsearch.port` | Search engine port | `9300` | **Placeholder (required)** |
| `cdn.enabled` | Enable CDN URLs | `true` | Tell app to use CloudFront |
| `cdn.domain` | CloudFront domain | `https://d129luge7edfzu.cloudfront.net` | Base URL for static assets |

### ⚠️ Common Issues & Solutions

#### ❌ Issue 1: Wrong Property Prefix

❌ WRONG - causes ClassNotFoundException
spring.datasource.url=jdbc:mysql://...
spring.datasource.username=admin

✅ CORRECT - works with application
jdbc.url=jdbc:mysql://...
jdbc.username=admin

text

**Why?** The application's Java code expects `jdbc.*` properties, not Spring Boot's default `spring.datasource.*`.

**Error Message:**
Error: Could not resolve placeholder 'jdbc.url' in value "..."

text

#### ❌ Issue 2: Missing Placeholder Properties

Error: Could not resolve placeholder 'rabbitmq.address' in value "..."
Application failed to start

text

**Cause:** Even unused services must have placeholder properties.

**Solution:** Add all required properties with any value:
rabbitmq.address=localhost
rabbitmq.port=5672
elasticsearch.host=localhost
elasticsearch.port=9300

text

### ✅ Verification Commands

1. Verify file exists and has content
cat ~/ng-java-app/src/main/resources/application.properties | wc -l

Expected output: 20+ lines
2. Check for critical properties
grep "jdbc.url" ~/ng-java-app/src/main/resources/application.properties

Expected: Shows the jdbc.url line
3. Rebuild application
cd ~/ng-java-app
mvn clean install -DskipTests

Expected: BUILD SUCCESS
4. Deploy WAR to Tomcat
sudo cp target/vprofile-v2.war /opt/tomcat/webapps/ROOT.war
sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war

5. Restart Tomcat
sudo systemctl restart tomcat

6. Wait 30 seconds and check logs
sleep 30
sudo tail -100 /opt/tomcat/logs/catalina.out

7. Verify no property errors
sudo tail -100 /opt/tomcat/logs/catalina.out | grep -i "placeholder|error" | head -5

text

### 🎯 Checkpoint 1: Application Configuration

**Before proceeding, verify:**

- [ ] `application.properties` file exists at `~/ng-java-app/src/main/resources/`
- [ ] All required properties present (jdbc, memcached, rabbitmq, elasticsearch, cdn)
- [ ] Application builds successfully (`mvn clean install -DskipTests`)
- [ ] No property placeholder errors in build output
- [ ] WAR file deployed to Tomcat
- [ ] Tomcat service restarted successfully
- [ ] Application accessible at `http://localhost:8080`
- [ ] Login page displays (confirms database connected)
- [ ] No "Could not resolve placeholder" errors in logs

---

## 💾 Step 2: S3 Static Assets Setup

### 📝 Overview

Static files (CSS, JavaScript, images) are stored in S3 for scalability. CloudFront serves them for performance. Using Origin Access Control (OAC) keeps the bucket private.

### 📁 Required Bucket Structure

s3://ng-vprofile-static-content/
├── css/
│ ├── bootstrap.min.css
│ ├── common.css
│ ├── profile.css
│ └── w3.css
├── images/
│ ├── background.png
│ ├── header.jpg
│ ├── hkh-infotech-logo.png
│ ├── login-background.png
│ └── technologies/
│ ├── Ansible_logo.png
│ ├── Vagrant.png
│ └── ... (other tech logos)
└── js/
├── app.js
└── bootstrap.min.js

text

### 🔧 Step-by-Step Configuration

#### Step 2.1: Upload Static Files

Navigate to webapp resources directory
cd ~/ng-java-app/src/main/webapp/

Verify files exist
ls -la resources/

Upload CSS files
aws s3 sync resources/css/ s3://ng-vprofile-static-content/css/
--delete
--region us-east-1

Upload image files
aws s3 sync resources/images/ s3://ng-vprofile-static-content/images/
--delete
--region us-east-1

Upload JavaScript files
aws s3 sync resources/js/ s3://ng-vprofile-static-content/js/
--delete
--region us-east-1

Verify upload
aws s3 ls s3://ng-vprofile-static-content/ --recursive --region us-east-1

text

**Expected Output:**
2025-11-05 20:16:03 153844 css/bootstrap.min.css
2025-11-05 20:16:04 1232 css/common.css
2025-11-05 20:16:05 4617 css/profile.css
2025-11-05 20:16:29 862537 images/background.png
... more files

text

#### Step 2.2: Enable Block Public Access

**Goal:** Keep S3 bucket private. Only CloudFront with OAC can access.

**Via AWS Console:**

1. Go to: **S3 → ng-vprofile-static-content → Permissions**
2. Click: **Block Public Access → Edit**
3. ✅ Check ALL 5 boxes:
   - ✅ Block all public access
   - ✅ Block public access to buckets and objects granted through new ACLs
   - ✅ Block public access to buckets and objects granted through any ACLs
   - ✅ Block public and cross-account access through new public bucket policies
   - ✅ Block public and cross-account access through any public bucket policies
4. Click: **Save Changes**

**Via AWS CLI:**

aws s3api put-public-access-block
--bucket ng-vprofile-static-content
--public-access-block-configuration
BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
--region us-east-1

text

**Verification:**

aws s3api get-public-access-block
--bucket ng-vprofile-static-content
--region us-east-1

Expected output:
{
"PublicAccessBlockConfiguration": {
"BlockPublicAcls": true,
"IgnorePublicAcls": true,
"BlockPublicPolicy": true,
"RestrictPublicBuckets": true
}
}
text

#### Step 2.3: Bucket Policy (Auto-Applied)

CloudFront's OAC will automatically create this policy. You should see it in:
**S3 → ng-vprofile-static-content → Permissions → Bucket Policy**

{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "AllowCloudFrontServicePrincipal",
"Effect": "Allow",
"Principal": {
"Service": "cloudfront.amazonaws.com"
},
"Action": "s3:GetObject",
"Resource": "arn:aws:s3:::ng-vprofile-static-content/*",
"Condition": {
"StringEquals": {
"AWS:SourceArn": "arn:aws:cloudfront::476114157050:distribution/E267BD6EUNMEIV"
}
}
}
]
}

text

**Why this matters:** Only the specified CloudFront distribution can read S3 objects.

### ⚠️ Common Issues & Solutions

#### ❌ Issue: "Bucket Policy Changes Can't Be Saved"

Error: Your bucket policy changes can't be saved.
You either don't have permissions to edit the bucket policy,
or your bucket policy grants a level of public access that
conflicts with your Block Public Access settings.

text

**Cause:** Block Public Access is ON, but policy grants public access.

**Solution:** 
1. Make sure Block Public Access blocks are ALL enabled
2. Use CloudFront OAC (not public bucket policy)
3. Let CloudFront auto-generate the policy

#### ❌ Issue: Direct S3 Access Not Blocked

curl https://ng-vprofile-static-content.s3.amazonaws.com/css/profile.css

Returns: HTML page or file ❌ WRONG
text

**Cause:** Block Public Access not enabled properly.

**Solution:** 
1. Re-enable Block Public Access settings
2. Verify all 5 checkboxes are checked
3. Wait 5 minutes for propagation

### ✅ Verification Commands

1. List bucket contents
aws s3 ls s3://ng-vprofile-static-content/ --recursive | head -20

2. Verify Block Public Access is ON
aws s3api get-public-access-block --bucket ng-vprofile-static-content

3. Test direct S3 access (should fail with 403)
curl -I https://ng-vprofile-static-content.s3.amazonaws.com/css/profile.css

Expected: HTTP/1.1 403 Forbidden ✅
4. Check bucket policy
aws s3api get-bucket-policy --bucket ng-vprofile-static-content

5. Verify specific file
aws s3 ls s3://ng-vprofile-static-content/css/profile.css

6. Count total files uploaded
aws s3 ls s3://ng-vprofile-static-content/ --recursive | wc -l

text

### 🎯 Checkpoint 2: S3 & Static Assets

**Before proceeding, verify:**

- [ ] Static files uploaded to S3 (css/, images/, js/ directories)
- [ ] All file counts match local source
- [ ] S3 Block Public Access enabled (all 5 settings ON)
- [ ] Direct S3 access returns 403 Forbidden (private bucket ✅)
- [ ] Bucket policy allows CloudFront OAC
- [ ] Files have correct MIME types (CSS as text/css, images as image/*)
- [ ] No public access grants in bucket policy

---

## 🌐 Step 3: CloudFront CDN Configuration

### 📝 Overview

CloudFront is your **single entry point** for all content. It:
- Serves static files from S3
- Serves dynamic content from ALB
- Caches aggressively
- Scales to billions of requests

### 🔧 Initial CloudFront Setup

#### Step 3.1: Create CloudFront Distribution

**AWS Console Navigation:**
CloudFront → Distributions → Create Distribution

text

**Configuration:**

Distribution Settings:
├─ Origin domain: ng-vprofile-static-content.s3.us-east-1.amazonaws.com
├─ Origin access: ✅ Origin access control settings (recommended)
├─ Create control setting: vprofile-oac
├─ Enable Origin Shield: No
├─ Default cache behavior: CachingOptimized
├─ Viewer protocol policy: Redirect HTTP to HTTPS
├─ Allowed HTTP methods: GET, HEAD
├─ Price class: Use all edge locations
└─ Enable IPv6: Yes

text

**Result:** CloudFront Distribution ID: `d129luge7edfzu` (example)

#### Step 3.2: Create Origin Access Control (OAC)

**AWS Console Navigation:**
CloudFront → Origin access → Create control setting

text

**Configuration:**

Name: vprofile-oac
Description: OAC for VProfile S3 access
Signing behavior: Sign requests (recommended)
Origin type: S3

text

**Why OAC instead of OAI?**
- ✅ OAC is newer, more secure
- ✅ Automatic bucket policy management
- ✅ Recommended by AWS
- ❌ OAI is deprecated

#### Step 3.3: Update S3 Bucket Policy

After creating OAC, CloudFront displays:
Copy S3 bucket policy and apply to your S3 bucket

text

**Steps:**
1. Copy the provided policy
2. Go to: **S3 → ng-vprofile-static-content → Permissions → Bucket Policy**
3. Paste the policy
4. Click **Save**

### ⚠️ Common Issues & Solutions

#### ❌ Issue: AccessDenied on CloudFront Root

curl https://d129luge7edfzu.cloudfront.net

<Error><Code>AccessDenied</Code></Error>
text

**Cause:** Default behavior points to S3, but S3 has no `index.html`.

**Root path resolution:**
GET / → CloudFront checks behaviors
→ Matches default (*) → routes to S3
→ S3 tries to serve /index.html
→ File doesn't exist → 403/AccessDenied

text

**Solution:** Add ALB as second origin, change default behavior to ALB.

(Handled in Step 7)

#### ❌ Issue: OAC Not Created Properly

**Symptoms:**
CloudFront distributions show "Pending"
S3 access returns 403 even for CloudFront

text

**Solution:**
1. Verify OAC exists: **CloudFront → Origin access → List**
2. Verify OAC linked to distribution
3. Verify S3 bucket policy has OAC principal
4. Wait 5-10 minutes for propagation

### ✅ Verification Commands

1. Get CloudFront distribution details
aws cloudfront list-distributions --region us-east-1 | grep -A 5 "d129luge7edfzu"

2. Check distribution status
aws cloudfront get-distribution --id d129luge7edfzu
--query 'Distribution.DistributionConfig.Enabled'
--region us-east-1

3. Test CloudFront static file (may fail until ALB added)
curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

For now, might return 403 - that's OK, fixed in Step 7
4. List OAC
aws cloudfront list-origin-access-controls --region us-east-1

5. Verify S3 bucket policy has CloudFront OAC
aws s3api get-bucket-policy --bucket ng-vprofile-static-content

text

### 🎯 Checkpoint 3: CloudFront Basic Setup

**Before proceeding, verify:**

- [ ] CloudFront distribution created and Status = Deployed
- [ ] OAC created and linked to distribution
- [ ] S3 bucket policy updated automatically
- [ ] CloudFront domain name assigned (d129luge7edfzu.cloudfront.net)
- [ ] Distribution points to S3 bucket as origin
- [ ] Default cache behavior set to CachingOptimized
- [ ] Viewer protocol policy set to redirect HTTP to HTTPS
- [ ] Origin access control properly linked

---

## ⚖️ Step 4: Application Load Balancer Setup

### 📝 Overview

ALB distributes HTTP traffic and performs health checks. It's the **connection layer** between CloudFront and EC2.

### 🎯 Port Flow Understanding

User → CloudFront:443 → ALB:80 → Target Group:8080 → EC2 Tomcat:8080

Why 80 on ALB (not 8080)?
├─ Port 80/443: Standard HTTP/HTTPS ports (internet standard)
├─ Port 8080: Non-standard application port
├─ ALB bridges both: listens on 80, forwards to 8080
└─ EC2 Tomcat still on 8080 (no change needed)

text

### 🔧 ALB Configuration

#### Step 4.1: Create ALB

**AWS Console Navigation:**
EC2 → Load Balancers → Create Load Balancer → Application Load Balancer

text

**Configuration:**

Basic Configuration:
├─ Name: vprofile-ALB
├─ Scheme: Internet-facing ✅ (must be public)
├─ IP address type: IPv4
└─ Load Balancer Protocol: HTTP

Network Mapping:
├─ VPC: vpc-0ee2a59278acdcf88 (your VPC)
├─ Availability Zones:
│ ├─ us-east-1a ✅
│ └─ us-east-1b ✅
└─ Subnets: Select PUBLIC subnets only

Security Groups:
├─ Create new: ALB-frontend
│ ├─ Inbound HTTP (80) from 0.0.0.0/0
│ ├─ Inbound HTTPS (443) from 0.0.0.0/0
│ └─ Outbound All traffic

text

**Result:** ALB DNS name assigned
vprofile-ALB-1184541630.us-east-1.elb.amazonaws.com

text

#### Step 4.2: ALB Listener Configuration

ALB is created with HTTP:80 listener by default.

**Listener:** HTTP:80 → **Forward to** → Target Group (created in Step 5)

#### Step 4.3: Security Group (ALB-frontend)

**Inbound Rules:**

| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| HTTP | TCP | 80 | 0.0.0.0/0 | Allow internet HTTP |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Allow internet HTTPS |

**Outbound Rules:**
- All traffic to 0.0.0.0/0 (allow ALB to reach targets)

### ⚠️ Common Issues & Solutions

#### ❌ Issue: ALB Returns 502 Bad Gateway

curl http://vprofile-ALB-xxx.elb.amazonaws.com

<h1>502 Bad Gateway</h1>
text

**Possible Causes:**
1. No healthy targets in target group
2. Target group not attached to listener
3. EC2 not responding

**Solution:** Skip to Step 5 (Target Group) to fix this.

#### ❌ Issue: ALB Takes Too Long to Provision

**Expected behavior:**
State: provisioning (2-5 minutes)
↓
State: active (ready to use)

text

**What NOT to do:**
- ❌ Delete and recreate ALB
- ❌ Wait indefinitely

**What TO do:**
- ✅ Wait 10 minutes
- ✅ If still pending, check AWS Service Health Dashboard
- ✅ Verify subnets are correct

### ✅ Verification Commands

1. Get ALB DNS name
aws elbv2 describe-load-balancers --names vprofile-ALB
--query 'LoadBalancers.DNSName' --output text

Expected: vprofile-ALB-xxx.us-east-1.elb.amazonaws.com
2. Check ALB state
aws elbv2 describe-load-balancers --names vprofile-ALB
--query 'LoadBalancers.State.Code' --output text

Expected: active
3. List ALB listeners
aws elbv2 describe-listeners --load-balancer-arn <ALB_ARN>

4. Verify security group
aws ec2 describe-security-groups --group-names ALB-frontend

text

### 🎯 Checkpoint 4: ALB Creation

**Before proceeding, verify:**

- [ ] ALB created and Status = "active"
- [ ] ALB is Internet-facing (not internal)
- [ ] ALB spans at least 2 Availability Zones
- [ ] ALB security group exists with HTTP/HTTPS inbound
- [ ] ALB listener configured for HTTP:80
- [ ] DNS name assigned and resolvable
- [ ] No pending configuration changes

---

## 🎯 Step 5: Target Group Configuration

### 📝 Overview

Target Groups define:
1. **Where traffic goes** (EC2 instance, port)
2. **How to check health** (path, frequency, success criteria)
3. **When to mark unhealthy** (consecutive failures)

### 🎯 Health Check Deep Dive

Problem: Your application redirects "/" to "/login"

GET / → Tomcat returns 302 redirect to /login
ALB health check:
├─ Receives: 302 status code
├─ Expects: 200 status code ✅
├─ Result: ❌ UNHEALTHY (mismatch!)

Solution: Change health check path to /login

GET /login → Tomcat returns 200 OK
ALB health check:
├─ Receives: 200 status code
├─ Expects: 200 status code ✅
├─ Result: ✅ HEALTHY (match!)

text

### 🔧 Target Group Configuration

#### Step 5.1: Create Target Group

**AWS Console Navigation:**
EC2 → Target Groups → Create target group

text

**Configuration:**

Basic Configuration:
├─ Target type: Instances ✅
├─ Target group name: vprofile-new-TG
├─ Protocol: HTTP
├─ Port: 8080 ✅ (Tomcat port, NOT 80!)
├─ VPC: vpc-0ee2a59278acdcf88
└─ Protocol version: HTTP1

Health Check Settings:
├─ Health check protocol: HTTP
├─ Health check path: /login ✅ (NOT /)
├─ Health check port: 8080 ✅ (Override)
├─ Healthy threshold: 2 consecutive successes
├─ Unhealthy threshold: 2 consecutive failures
├─ Timeout: 2 seconds
├─ Interval: 5 seconds
└─ Success codes: 200

text

#### Step 5.2: Register Targets

Register targets:
├─ Select EC2 instance: i-0e5cf9e5f00a9f2bc
├─ Port: 8080 ✅
└─ Click "Include as pending below"
└─ Create target group

text

#### Step 5.3: Attach to ALB Listener

Load Balancers → vprofile-ALB → Listeners
├─ HTTP:80 → Edit
├─ Forward to target group: vprofile-new-TG ✅
└─ Save

text

### 💡 Port Configuration Explanation

ALB Listener listens on: Port 80 ✅
Target Group routes to: Port 8080 ✅
EC2 Tomcat listens on: Port 8080 ✅

Why port mapping?
├─ Users access standard ports (80/443)
├─ Tomcat doesn't need ports 80/443
├─ ALB transparently maps 80 → 8080
└─ Keeps application on non-privileged port

text

### 💡 Health Check Path Explanation

Health check path "/login" returns 200
├─ Path "/": Returns 302 (redirect) ❌ FAILS health check
├─ Path "/login": Returns 200 (page) ✅ PASSES health check
├─ Path "/": Would need index.html in root

Why "/login" works:
├─ Spring Security redirects "/" → "/login"
├─ "/login" is accessible without authentication
├─ ALB can verify 200 response
└─ Target marked HEALTHY ✅

text

### ⚠️ Common Issues & Solutions

#### ❌ Issue: Target Remains Unhealthy

Target health: Unhealthy (red circle)
Health check status: Health checks failed with these codes:

text

**Possible Causes:**

| Cause | How to Detect | Solution |
|-------|---------------|----------|
| Health check path wrong | Codes: [302] | Change path to `/login` |
| Health check port wrong | Connection timeout | Set port override to 8080 |
| EC2 SG blocks ALB traffic | Connection refused | Add 8080 rule from ALB SG |
| Tomcat not running | Connection timeout | Restart Tomcat |
| Tomcat on wrong port | Connection refused | Verify on port 8080 |

**Debugging Steps:**

1. Test health check path locally
curl -I http://localhost:8080/login

Expected: HTTP/1.1 200 OK ✅
2. Test root path (shows why it fails)
curl -I http://localhost:8080/

Expected: HTTP/1.1 302 Found (redirect)
3. Check Tomcat listening
sudo ss -tlnp | grep 8080

Expected: LISTEN ... java (Tomcat process)
4. Check Tomcat is running
sudo systemctl status tomcat

Expected: active (running)
5. Test from EC2 local
curl http://127.0.0.1:8080/login

Expected: HTML login page
text

#### ❌ Issue: Timeout on Health Checks

Health status: Unhealthy
Health check details: Health checks timed out

text

**Cause:** 2 second timeout too short, Tomcat slow to respond.

**Solution:** Increase timeout to 5 seconds in health check settings.

#### ❌ Issue: Wrong Target Port

Target Group Port: 80 (should be 8080!)

text

**Impact:** ALB forwards to port 80, but Tomcat on 8080 → Connection refused.

**Fix:**
Target Group → Edit attributes → Port: 8080 ✅

text

### ✅ Verification Commands

1. Test Tomcat on port 8080
curl -I http://localhost:8080/login

Expected: HTTP/1.1 200 OK
2. Get target health status
aws elbv2 describe-target-health
--target-group-arn arn:aws:elasticloadbalancing:us-east-1:xxx:targetgroup/vprofile-new-TG/xxx
--query 'TargetHealthDescriptions.TargetHealth'

Expected output:
{
"State": "healthy",
"Reason": "N/A",
"Description": "N/A"
}
3. Verify port 8080 listening
sudo ss -tlnp | grep java

Expected: LISTEN 0.0.0.0:8080 java
4. Test ALB
curl http://vprofile-ALB-xxx.elb.amazonaws.com

Expected: HTML login page (not 502)
text

### 🎯 Checkpoint 5: Target Group & Health Checks

**Before proceeding, verify:**

- [ ] Target Group created with port 8080
- [ ] Health check path set to `/login` (NOT `/`)
- [ ] Health check port set to 8080
- [ ] EC2 instance registered to target group
- [ ] Target status shows "Healthy" (green ✅)
- [ ] ALB listener forwards to target group
- [ ] ALB returns 200 when accessed (not 502)
- [ ] Health check succeeds consistently

---

## 🔐 Step 6: Security Groups Configuration

### 📝 Overview

Security Groups are **network firewalls**. Misconfiguration causes:
- Health checks fail (connection refused)
- ALB can't reach EC2
- Database can't connect

### 🔧 Security Group Architecture

┌──────────────────────────┐
│ ALB-frontend (sg-030c...)│
│ Inbound: HTTP (80) │
│ Inbound: HTTPS (443) │
└──────────┬───────────────┘
│ (forwarding traffic)
▼
┌──────────────────────────────┐
│ EC2 Jump-server-SG │
│ Inbound: 80 from ALB SG ✅ │
│ Inbound: 8080 from ALB SG✅ │
│ Inbound: 22 from your IP │
│ Outbound: All traffic │
└──────────┬───────────────────┘
│ (connecting to)
┌────┴─────────────┐
▼ ▼
┌────────────┐ ┌──────────────┐
│ RDS MySQL │ │ ElastiCache │
│ Port 3306 │ │ Port 11211 │
└────────────┘ └──────────────┘

text

### 🔧 EC2 Security Group Configuration

**Security Group Name:** Jump-server-SG (sg-09b6dc00e7fa57bc9)

#### Inbound Rules

| # | Type | Protocol | Port | Source | Purpose |
|---|------|----------|------|--------|---------|
| 1 | HTTP | TCP | 80 | ALB SG (sg-030...) | Allow HTTP from ALB |
| 2 | Custom TCP | TCP | 8080 | ALB SG (sg-030...) | Allow Tomcat from ALB ✅ |
| 3 | SSH | TCP | 22 | Your IP | SSH access |

**Why port 8080 from ALB SG?**
ALB needs to:
├─ Send health checks to EC2:8080 ✅
├─ Forward user traffic to EC2:8080 ✅
└─ Without rule → connection refused ❌

This is the MOST COMMON mistake!

text

#### Outbound Rules

All traffic to 0.0.0.0/0 (default)
├─ EC2 can reach internet
├─ EC2 can reach RDS
└─ EC2 can reach ElastiCache

text

### 🔧 Step-by-Step Setup

#### Via AWS Console

1. **EC2 → Security Groups → Jump-server-SG**
2. **Inbound rules → Edit inbound rules**

Rule 1 (Port 80 from ALB):
├─ Type: HTTP
├─ Protocol: TCP
├─ Port: 80
├─ Source: Custom → sg-030c5b9c9cfd576a6 (ALB SG)
└─ Add rule

Rule 2 (Port 8080 from ALB) - CRITICAL:
├─ Type: Custom TCP
├─ Protocol: TCP
├─ Port: 8080
├─ Source: Custom → sg-030c5b9c9cfd576a6 (ALB SG)
└─ Add rule

Rule 3 (SSH for testing):
├─ Type: SSH
├─ Protocol: TCP
├─ Port: 22
├─ Source: Custom → Your IP (e.g., 203.0.113.0/32)
└─ Add rule

text

3. **Save rules**

#### Via AWS CLI

Get ALB security group ID
ALB_SG_ID=$(aws ec2 describe-security-groups
--filters "Name=group-name,Values=ALB-frontend"
--query 'SecurityGroups.GroupId' --output text)

Add port 8080 rule from ALB SG to EC2 SG
aws ec2 authorize-security-group-ingress
--group-id sg-09b6dc00e7fa57bc9
--protocol tcp
--port 8080
--source-group $ALB_SG_ID
--region us-east-1

Verify the rule was added
aws ec2 describe-security-groups
--group-ids sg-09b6dc00e7fa57bc9
--query 'SecurityGroups.IpPermissions'

text

### ⚠️ Common Issues & Solutions

#### ❌ Issue: Health Checks Fail (Connection Refused)

Target Health: Unhealthy
Error: Connection refused

text

**Root Cause:**
EC2 SG doesn't have rule for port 8080 from ALB SG
│
├─ ALB tries to health check on 8080
├─ EC2 SG blocks the traffic
└─ Connection refused

text

**Solution:**
Add rule: 8080 from ALB SG to EC2 SG
aws ec2 authorize-security-group-ingress
--group-id sg-09b6dc00e7fa57bc9
--protocol tcp
--port 8080
--source-group sg-030c5b9c9cfd576a6

text

#### ❌ Issue: Source Set to 0.0.0.0/0 Instead of ALB SG

Inbound Rule:
Type: Custom TCP
Port: 8080
Source: 0.0.0.0/0 ❌ WRONG (opens to entire internet!)

text

**Why it's wrong:**
- Exposes Tomcat to entire world
- Anyone can directly access EC2:8080
- Defeats purpose of ALB
- Security risk

**Correct:**
Inbound Rule:
Type: Custom TCP
Port: 8080
Source: sg-030c5b9c9cfd576a6 ✅ (ALB SG only)

text

#### ❌ Issue: Circular SG Dependencies

ALB SG → EC2 SG → RDS SG → ALB SG (loop!)

text

**Check for:**
1. ALB SG references EC2 SG (inbound from EC2) - ❌ WRONG
2. RDS SG references Application SG (inbound from EC2) - ✅ OK
3. ElastiCache SG references Application SG (inbound from EC2) - ✅ OK

### ✅ Verification Commands

1. Get EC2 security group details
aws ec2 describe-security-groups
--group-ids sg-09b6dc00e7fa57bc9
--query 'SecurityGroups.IpPermissions'

2. Verify port 8080 rule exists from ALB SG
aws ec2 describe-security-groups
--group-ids sg-09b6dc00e7fa57bc9
--query 'SecurityGroups.IpPermissions[?FromPort==8080]'

3. Check if Tomcat responding to ALB traffic
From ALB subnet (if possible):
curl -I http://EC2_PRIVATE_IP:8080/login

4. List all security group rules
aws ec2 describe-security-groups --group-ids
sg-09b6dc00e7fa57bc9
--query 'SecurityGroups.[GroupName,IpPermissions]'

text

### 🎯 Checkpoint 6: Security Groups

**Before proceeding, verify:**

- [ ] EC2 SG allows port 8080 from ALB SG (NOT 0.0.0.0/0)
- [ ] EC2 SG allows port 80 from ALB SG (optional)
- [ ] EC2 SG allows SSH from your IP
- [ ] ALB SG allows HTTP (80) from 0.0.0.0/0
- [ ] ALB SG allows HTTPS (443) from 0.0.0.0/0
- [ ] RDS SG allows 3306 from EC2 SG
- [ ] ElastiCache SG allows 11211 from EC2 SG
- [ ] No circular dependencies
- [ ] Target health check succeeds after rules applied

---

## 🔀 Step 7: CloudFront Origins & Behaviors

### 📝 Overview

CloudFront uses **Behaviors** (path patterns) to route requests to different origins:
- `/css/*` → S3 (static, cached)
- `/images/*` → S3 (static, cached)
- `/js/*` → S3 (static, cached)
- `/*` (default) → ALB (dynamic, not cached)

### 🔧 Add ALB as Second Origin

#### Step 7.1: Add ALB Origin

**AWS Console Navigation:**
CloudFront → Distributions → d129luge7edfzu → Origins → Create origin

text

**Configuration:**

Origin Settings:
├─ Origin domain: vprofile-ALB-1184541630.us-east-1.elb.amazonaws.com ✅
├─ Protocol: HTTP only
├─ HTTP port: 80 ✅
├─ HTTPS port: 443
├─ Minimum origin SSL protocol: TLSv1.2
├─ Origin path: (leave empty)
├─ Name: vprofile-alb ✅
├─ Add custom header: (none needed)
├─ Origin Shield: Disabled
└─ Create origin

text

#### Step 7.2: Create Behavior for CSS

**AWS Console Navigation:**
CloudFront → Distributions → d129luge7edfzu → Behaviors → Create behavior

text

**Configuration:**

Behavior 1 (CSS Files):
├─ Path Pattern: /css/*
├─ Origin: ng-vprofile-static-content (S3) ✅
├─ Viewer protocol policy: Redirect HTTP to HTTPS
├─ Allowed HTTP methods: GET, HEAD
├─ Cache policy: CachingOptimized
├─ Origin request policy: (none)
└─ Create behavior

text

#### Step 7.3: Create Behavior for Images

Behavior 2 (Image Files):
├─ Path Pattern: /images/*
├─ Origin: ng-vprofile-static-content (S3) ✅
├─ (Same settings as CSS)
└─ Create behavior

text

#### Step 7.4: Create Behavior for JavaScript

Behavior 3 (JavaScript Files):
├─ Path Pattern: /js/*
├─ Origin: ng-vprofile-static-content (S3) ✅
├─ (Same settings as CSS)
└─ Create behavior

text

#### Step 7.5: Update Default Behavior

**This is CRITICAL - changes default from S3 to ALB**

**AWS Console Navigation:**
CloudFront → Distributions → d129luge7edfzu → Behaviors → Default (*) → Edit

text

**Configuration:**

Default Behavior (Root Path):
├─ Path Pattern: * (default) ✅
├─ Origin: vprofile-alb ✅ (CHANGED from S3!)
├─ Viewer protocol policy: Redirect HTTP to HTTPS
├─ Allowed HTTP methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
├─ Cache policy: CachingDisabled ✅ (dynamic content)
├─ Origin request policy: AllViewer
├─ Response headers policy: (none)
└─ Update behavior

text

**Why CachingDisabled for ALB?**
Static content from S3:
├─ Same CSS every day
├─ Cache aggressively ✅
└─ Reduce origin load

Dynamic content from ALB:
├─ Different user data
├─ User-specific responses
├─ Can't cache ✅
└─ Every request hits ALB

text

### 📊 Behavior Precedence Order

CloudFront evaluates behaviors **top-to-bottom**:

| Precedence | Path Pattern | Origin | Type | Cache |
|-----------|--------------|--------|------|-------|
| 0 | `/css/*` | S3 | Static | Optimized |
| 1 | `/images/*` | S3 | Static | Optimized |
| 2 | `/js/*` | S3 | Static | Optimized |
| Default | `*` | ALB | Dynamic | Disabled |

**Order matters!**
If default () was precedence 0:
├─ / matches * first
├─ Routes to ALB ✓
├─ Then /css/ never evaluated
└─ All CSS goes to ALB ❌ WRONG

Correct order:
├─ /css/* checked first
├─ Matches /css/style.css ✓
├─ Routes to S3 ✓
└─ Dynamic content falls through to default

text

### ⚠️ Common Issues & Solutions

#### ❌ Issue: Root Path Returns AccessDenied

curl https://d129luge7edfzu.cloudfront.net

<Error><Code>AccessDenied</Code></Error>
text

**Root Cause:**
Default behavior still points to S3
├─ / matches default (*)
├─ Routes to S3
├─ S3 tries to serve /index.html
├─ File doesn't exist in S3
└─ CloudFront returns AccessDenied from S3

text

**Solution:** Change default behavior origin from S3 to ALB.

After fixing:
curl https://d129luge7edfzu.cloudfront.net

Returns: HTML login page ✅
text

#### ❌ Issue: All Traffic Goes to ALB (No Static Caching)

curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

Server: ALB ❌ (should be S3!)
text

**Cause:** Behaviors for `/css/*`, `/images/*`, `/js/*` not created.

**Solution:** Create specific behaviors before default.

#### ❌ Issue: Behaviors in Wrong Order

**Console shows:**
Default () - Precedence 0 ❌
/css/ - Precedence 1
/images/* - Precedence 2

text

**Why it's wrong:**
- Default matches first
- Specific patterns never evaluated
- All content served by ALB

**Fix:** Reorder in CloudFront console or CLI.

### ✅ Verification Commands

1. Test root path (should show Tomcat login)
curl https://d129luge7edfzu.cloudfront.net

Expected: HTML login page
2. Test CSS (should come from S3)
curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

Expected: x-cache: Hit from cloudfront, server: AmazonS3
3. Test images
curl -I https://d129luge7edfzu.cloudfront.net/images/logo.png

Expected: x-cache: Hit from cloudfront, server: AmazonS3
4. Test dynamic content
curl -I https://d129luge7edfzu.cloudfront.net/login

Expected: x-cache: Miss from cloudfront (dynamic)
5. Get behaviors list
aws cloudfront get-distribution --id d129luge7edfzu
--query 'Distribution.DistributionConfig.CacheBehaviors'
--region us-east-1

text

### 🎯 Checkpoint 7: CloudFront Origins & Behaviors

**Before proceeding, verify:**

- [ ] ALB added as second CloudFront origin
- [ ] Behavior created for `/css/*` → S3 origin
- [ ] Behavior created for `/images/*` → S3 origin
- [ ] Behavior created for `/js/*` → S3 origin
- [ ] Default behavior updated to ALB origin (NOT S3)
- [ ] Behaviors in correct precedence order (specific before default)
- [ ] CloudFront root path returns HTML (not AccessDenied)
- [ ] Static files served from S3 via CloudFront (x-cache header)
- [ ] Dynamic content served from ALB via CloudFront

---

## ✅ Step 8: Testing & Verification

### 📝 Complete Testing Checklist

#### 🧪 Test 1: Application Properties

Test application startup
curl http://localhost:8080/login

Expected: HTML login page (database connected ✅)
If error: Check application.properties format
text

#### 🧪 Test 2: S3 Static Assets

Test direct S3 access (should FAIL - private bucket)
curl -I https://ng-vprofile-static-content.s3.amazonaws.com/css/profile.css

Expected: HTTP 403 Forbidden ✅
Test CloudFront static access (should WORK)
curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

Expected: HTTP 200, x-cache: Hit from cloudfront ✅
text

#### 🧪 Test 3: ALB Health Checks

Check target health
aws elbv2 describe-target-health --target-group-arn <TG_ARN>

Expected: State: healthy
Test ALB directly
curl http://vprofile-ALB-xxx.us-east-1.elb.amazonaws.com

Expected: HTML login page
text

#### 🧪 Test 4: CloudFront Integration

Test root path (ALB origin)
curl https://d129luge7edfzu.cloudfront.net

Expected: HTML login page
Test CSS (S3 origin)
curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

Expected: HTTP 200, server: AmazonS3
Test caching
curl -I https://d129luge7edfzu.cloudfront.net/images/logo.png | grep x-cache

Expected: x-cache: Hit from cloudfront
text

#### 🧪 Test 5: End-to-End Browser Test

1. **Open browser:** `https://d129luge7edfzu.cloudfront.net`
2. **Open Developer Tools:** F12 → Network tab
3. **Refresh Page:** Ctrl+R
4. **Verify:**
   - ✅ HTML comes from CloudFront (via ALB)
   - ✅ CSS comes from CloudFront (via S3) - server: AmazonS3
   - ✅ Images come from CloudFront (via S3) - server: AmazonS3
   - ✅ All resources load successfully (200 status)
   - ✅ Cache headers indicate caching strategy

### ✅ Verification Output Examples

**Successful CloudFront response:**
$ curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css

HTTP/2 200
content-type: text/css
content-length: 4617
x-amz-server-side-encryption: AES256
x-cache: Hit from cloudfront ✅
via: 1.1 b18bcd54d0f77ca53d7c0ba4b9e54284.cloudfront.net (CloudFront)
x-amz-cf-pop: IAD89-P2
age: 601

text

**Successful ALB response:**
$ curl http://vprofile-ALB-1184541630.us-east-1.elb.amazonaws.com

<!DOCTYPE html> <html> <head> <title>VProfile - Login</title> </head> <body> <form id="loginForm"> <!-- Login form HTML --> </form> </body> </html> ```
Healthy target status:

text
$ aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...

{
    "TargetHealthDescriptions": [
        {
            "Target": {
                "Id": "i-0e5cf9e5f00a9f2bc",
                "Port": 8080
            },
            "TargetHealth": {
                "State": "healthy",
                "Reason": "N/A",
                "Description": "N/A"
            }
        }
    ]
}
🎯 Success Criteria
✅ All tests pass:

 Application accessible via CloudFront URL

 Static files cached by CloudFront

 Dynamic content served by ALB

 Database queries working (login functional)

 Memcached sessions working

 No errors in Tomcat logs

 ALB targets showing healthy

 CloudFront distributions active

 Security groups correctly configured

 S3 bucket private with OAC access

🐛 Common Issues & Troubleshooting
🔧 ISSUE 1: Application Won't Start
❌ Symptom
text
sudo systemctl status tomcat
# Status: failed (red)
🔍 Diagnosis
text
sudo tail -200 /opt/tomcat/logs/catalina.out
💡 Common Causes & Solutions
Error	Cause	Solution
Could not resolve placeholder 'jdbc.url'	Wrong property prefix	Use jdbc.url not spring.datasource.url
Could not resolve placeholder 'rabbitmq.address'	Missing placeholder	Add rabbitmq.address=localhost
Communications link failure	DB connection fail	Check RDS endpoint, credentials, SG
java.lang.OutOfMemoryError	Not enough heap memory	Increase Tomcat heap size in catalina.sh
✅ Debug Steps
text
# 1. Check properties file format
cat ~/ng-java-app/src/main/resources/application.properties

# 2. Verify database connection
mysql -h vprofile-db-mysql.cy5icoeogbzs.us-east-1.rds.amazonaws.com \
  -u admin -p \
  -e "SELECT 1;"

# 3. Test Memcached connection
echo "stats" | nc vprofile-memcache.hsm7kd.cfg.use1.cache.amazonaws.com 11211

# 4. Rebuild and redeploy
cd ~/ng-java-app
mvn clean install -DskipTests
sudo cp target/vprofile-v2.war /opt/tomcat/webapps/ROOT.war
sudo systemctl restart tomcat

# 5. Monitor startup
sudo tail -f /opt/tomcat/logs/catalina.out
🔧 ISSUE 2: Target Group Unhealthy
❌ Symptom
text
Target health: Unhealthy (red circle)
Health checks failed with these codes: 
🎯 Root Causes & Solutions
Root Cause 1: Health Check Path Returns 302

text
# Verify:
curl -I http://localhost:8080/
# Returns: 302 Found (redirect to /login)

# Fix:
# Target Groups → Health checks → Path: / → /login
Root Cause 2: Health Check Port Wrong

text
# Check current:
# Target Groups → Health checks → Port: default (80)

# Fix to:
# Target Groups → Health checks → Port: 8080 (override)
Root Cause 3: Security Group Blocks Traffic

text
# EC2 doesn't allow 8080 from ALB SG

# Fix:
aws ec2 authorize-security-group-ingress \
  --group-id sg-09b6dc00e7fa57bc9 \
  --protocol tcp --port 8080 \
  --source-group sg-030c5b9c9cfd576a6
Root Cause 4: Tomcat Not Running

text
# Check:
sudo systemctl status tomcat

# If not running:
sudo systemctl restart tomcat

# Verify:
curl -I http://localhost:8080/login
# Expected: 200 OK
✅ Debug Steps
text
# Complete health check diagnosis
sudo systemctl status tomcat && \
curl -I http://localhost:8080/login && \
sudo ss -tlnp | grep 8080 && \
aws elbv2 describe-target-health --target-group-arn <ARN>
🔧 ISSUE 3: CloudFront Returns AccessDenied
❌ Symptom
text
curl https://d129luge7edfzu.cloudfront.net
# <Error><Code>AccessDenied</Code></Error>
🔍 Root Cause
text
Default behavior points to S3
├─ CloudFront routes / to S3 bucket
├─ S3 tries to serve /index.html
├─ File doesn't exist
└─ S3 returns AccessDenied
✅ Solution
text
1. CloudFront → Behaviors → Default (*)
2. Change Origin from: ng-vprofile-static-content (S3)
3. Change Origin to: vprofile-alb (ALB)
4. Save and wait 2-5 minutes for propagation
🔧 ISSUE 4: ALB Returns 502 Bad Gateway
❌ Symptom
text
curl http://vprofile-ALB-xxx.elb.amazonaws.com
# <h1>502 Bad Gateway</h1>
🔍 Possible Causes
Cause	Check	Fix
No healthy targets	See Issue 2	Fix target health
Target group not attached	aws elbv2 describe-listeners	Attach TG to listener
Tomcat crashed	sudo systemctl status tomcat	Restart Tomcat
🔧 ISSUE 5: Static Files Don't Load
❌ Symptom
text
CSS/images 404 in browser
CloudFront returns AccessDenied for /css/*
🔍 Possible Causes
Cause	Check	Fix
Files not uploaded	aws s3 ls s3://bucket/css/	Upload with aws s3 sync
Behaviors not created	CloudFront → Behaviors	Create /css/, /images/, /js/*
Wrong S3 path	CloudFront origin	Verify origin is S3 bucket
✅ Solution
text
# 1. Verify files in S3
aws s3 ls s3://ng-vprofile-static-content/css/

# 2. Create behaviors if missing
# CloudFront → Behaviors → Create for /css/*, /images/*, /js/*

# 3. Test CloudFront
curl -I https://d129luge7edfzu.cloudfront.net/css/profile.css
# Expected: 200, x-cache: Hit from cloudfront
📌 Checkpoints Summary
✅ Pre-Deployment
 RDS MySQL database created

 ElastiCache Memcached cluster created

 S3 bucket created

 EC2 instance running with Tomcat

 Security groups created

 VPC with public/private subnets

 AWS credentials configured

✅ Application Configuration
 application.properties file created

 All properties present with correct format

 Application builds successfully

 WAR deploys without errors

 Tomcat starts successfully

 No property placeholder errors

✅ S3 & Static Assets
 Files uploaded (css/, images/, js/)

 Block Public Access enabled (all 5 settings)

 Direct S3 access returns 403

 Bucket policy allows CloudFront OAC

 All file counts match

✅ CloudFront & CDN
 Distribution created and deployed

 OAC created and linked

 S3 origin configured

 ALB origin added

 Behaviors created (/css/, /images/, /js/*, *)

 Default behavior points to ALB

 Static files accessible via CloudFront

✅ ALB & Load Balancing
 ALB created and active

 Listener configured HTTP:80

 ALB security group allows traffic

 Target group created with port 8080

 Health check path set to /login

 EC2 registered and healthy

 ALB DNS name resolvable

✅ Security Groups
 EC2 SG allows 8080 from ALB SG

 EC2 SG allows 80 from ALB SG

 EC2 SG allows SSH

 ALB SG allows HTTP/HTTPS

 RDS SG allows 3306 from EC2

 ElastiCache SG allows 11211 from EC2

✅ End-to-End Testing
 Application accessible via CloudFront

 Login page loads correctly

 Static files have correct MIME types

 CSS/images cached by CloudFront

 Database queries working

 Sessions cached in Memcached

 No errors in logs

📚 Quick Reference
🎯 Port Mapping
text
Internet User:           0.0.0.0:443/80 (internet standard)
                              │
CloudFront:            0.0.0.0:443 (HTTPS only)
                              │
ALB Listener:          0.0.0.0:80 (HTTP, public)
                              │
Target Group Port:     0.0.0.0:8080 (private, internal)
                              │
EC2 Tomcat:            0.0.0.0:8080 (application server)
                              │
RDS MySQL:             VPC:3306 (private database)
ElastiCache:           VPC:11211 (private cache)
📍 URL Access Patterns
URL	Source	Status	Purpose
https://d129luge7edfzu.cloudfront.net	ALB via CloudFront	✅ 200	Main app access
https://d129luge7edfzu.cloudfront.net/css/*	S3 via CloudFront	✅ 200	Static CSS
https://d129luge7edfzu.cloudfront.net/images/*	S3 via CloudFront	✅ 200	Static images
https://d129luge7edfzu.cloudfront.net/js/*	S3 via CloudFront	✅ 200	Static JS
http://vprofile-ALB-xxx.elb.amazonaws.com	ALB direct	✅ 200	Direct ALB
http://EC2_IP:8080	EC2 direct	✅ 200	Direct EC2
https://ng-vprofile-static-content.s3.amazonaws.com/*	S3 direct	❌ 403	Private bucket
📊 AWS Resource Summary
Resource	Name/ID	Purpose
CloudFront	d129luge7edfzu	CDN, single entry point
ALB	vprofile-ALB-xxx	Load balancing
Target Group	vprofile-new-TG	Health checks, routing
EC2	i-0e5cf9e5f00a9f2bc	Application server
S3	ng-vprofile-static-content	Static assets
RDS	vprofile-db-mysql	MySQL database
ElastiCache	vprofile-memcache	Memcached cache
ALB SG	sg-030c5b9c9cfd576a6	ALB firewall
EC2 SG	sg-09b6dc00e7fa57bc9	EC2 firewall
🎯 Health Check Configuration
text
Protocol: HTTP
Path: /login ← NOT /
Port: 8080 (override, match target port)
Timeout: 2 seconds
Interval: 5 seconds
Healthy threshold: 2 consecutive successes
Unhealthy threshold: 2 consecutive failures
Success codes: 200
🔐 Security Group Rules
EC2 Inbound:

text
8080/TCP from sg-030c5b9c9cfd576a6 (ALB SG)
80/TCP from sg-030c5b9c9cfd576a6 (ALB SG)
22/TCP from Your IP
ALB Inbound:

text
80/TCP from 0.0.0.0/0
443/TCP from 0.0.0.0/0
🎉 Conclusion
✨ You've Successfully Deployed:
✅ Production-Grade 3-Tier Architecture

Scalable with load balancing

Global CDN coverage

Private database access

Session caching

Security best practices

✅ Key Features:

CloudFront CDN for content delivery

ALB for traffic distribution

EC2 for application compute

RDS for persistent data

ElastiCache for performance

S3 for static assets

Security groups for network isolation

✅ Interview-Ready Skills:

AWS infrastructure design

Load balancing configuration

CDN optimization

Security best practices

DevOps fundamentals

📚 Documentation Used
Detailed step-by-step instructions for every component

Comprehensive troubleshooting for common issues

Checkpoint system to verify each step

Quick reference for future deployments

Real command examples with expected outputs

🚀 Next Steps (Optional)
If you want to enhance this further:

 Add Auto Scaling Group for EC2 instances

 Move EC2 to private subnet with NAT Gateway

 Create RDS read replicas for scaling

 Setup CloudWatch monitoring and alarms

 Add WAF to CloudFront for security

 Enable encryption for RDS and S3

 Configure backup and disaster recovery

💡 Key Takeaways
Concept	Learning
ALB	Port mapping, health checks, routing
CloudFront	Behaviors, origins, caching strategies
Security Groups	Firewall rules, principle of least privilege
S3 with OAC	Private buckets, secure CDN access
Health Checks	Path selection, status code matching
📖 Further Reading
AWS CloudFront Documentation

AWS ALB Documentation

AWS S3 Security Best Practices

Spring Boot Application Properties

📄 License
This guide is provided as-is for educational and deployment purposes.

🙏 Acknowledgments
This complete deployment guide covers production-ready AWS architecture with all best practices, security considerations, and real-world troubleshooting scenarios.

Happy Deploying! 🚀

Last Updated: November 7, 2025
Version: 1.0
Status: Production Ready ✅

text

***

## 📝 How to Use This README

1. **Save as `README.md`** in your GitHub repository
2. **Update with your actual values:**
   - Replace `d129luge7edfzu` with your CloudFront ID
   - Replace `vprofile-*` with your actual names
   - Replace IAM/AWS IDs with yours
   - Update RDS endpoint with your actual endpoint

3. **Push to GitHub:**
```bash
git add README.md
git commit -m "Add comprehensive deployment guide"
git push origin main
This README is complete, comprehensive, and production-ready! 🎉

It includes:

✅ Complete architecture diagrams

✅ All 8 steps with detailed explanations

✅ Code examples and commands

✅ Common issues & solutions

✅ Checkpoints for verification

✅ Quick reference tables

✅ Fun symbols & emojis for readability

✅ No content reduced - everything included!