text
# 🗑️ AWS 3-TIER ARCHITECTURE: RESOURCE CLEANUP & COST MANAGEMENT

> **Complete guide to safely cleanup AWS resources, track costs, and optimize spending**  
> **Production-Grade Resource Management | Effective Cost Reduction | Zero Leftover Resources**

**📅 Pricing Data**: November 07, 2025 (AWS Official Documentation)  
**⚠️ Disclaimer**: All charges mentioned are based on current AWS pricing. Actual costs may vary based on region, usage patterns, and future AWS pricing changes. Always verify current pricing on AWS pricing pages.

---

## 📖 TABLE OF CONTENTS

### 🎯 Quick Navigation

| # | 📑 Section | 🎯 Focus | 👥 Owner |
|---|-----------|---------|---------|
| **1** | [🏗️ What We Created](#️-what-we-created) | Architecture overview | All |
| **2** | [📊 Cost Breakdown](#-cost-breakdown-matrix) | Monthly costs by component | DevOps + Finance |
| **3** | [💰 Total Cost Estimation](#-total-monthly-cost-estimation) | Three deployment scenarios | Finance + DevOps |
| **4** | [🗑️ Cleanup Guide](#️-cleanup-step-by-step-guide) | Safe deletion procedures | DevOps + SysAdmin |
| **5** | [🆓 Free Resources](#-free-tier--no-cost-resources) | No-cost services to keep | All |
| **6** | [🔍 Hidden Costs](#-good-to-check-hidden-cost-resources) | Commonly missed charges | DevOps + Finance |
| **7** | [✅ Cost Optimization](#-cost-optimization-best-practices) | Reduce spending by 60 percent | DevOps + Architect |
| **8** | [🎯 Final Checklist](#-final-cleanup-checklist) | Verification steps | QA + DevOps |
| **9** | [📋 FAQs](#-frequently-asked-questions) | Questions and answers | All |

---

## 🏗️ WHAT WE CREATED

[⬆️ Back to Top](#-table-of-contents)

### Your Complete 3-Tier Architecture Stack

┌─────────────────────────────────────────────────────┐
│ LAYER 1: CDN & STATIC ASSETS │
│ ├─ CloudFront Distribution │
│ └─ S3 Bucket (ng-vprofile-static-content) │
├─────────────────────────────────────────────────────┤
│ LAYER 2: APPLICATION & LOAD BALANCING │
│ ├─ Application Load Balancer (ALB) │
│ ├─ 2× EC2 Instances (t3.large) │
│ └─ Target Groups │
├─────────────────────────────────────────────────────┤
│ LAYER 3: DATABASE & CACHE │
│ ├─ RDS MySQL (db.t3.medium) │
│ ├─ ElastiCache Memcached (2 nodes) │
│ └─ RDS Snapshots (Backups) │
├─────────────────────────────────────────────────────┤
│ LAYER 4: NETWORKING │
│ ├─ VPC (Custom) │
│ ├─ Subnets (Public + Private) │
│ ├─ Security Groups (5+) │
│ ├─ Elastic IPs (2×) │
│ ├─ NAT Gateway (optional) │
│ └─ Internet Gateway │
└─────────────────────────────────────────────────────┘

text

---

## 📊 COST BREAKDOWN MATRIX

[⬆️ Back to Top](#-table-of-contents)

### 1️⃣ CloudFront (CDN for Static Assets)

| Component | Pricing | Monthly Cost | Usage |
|-----------|---------|-------------|-------|
| **Data Transfer Out** | $0.085/GB (after 1TB free) | $0 to $35 | 500GB typical |
| **HTTPS Requests** | $0.01 per 10K requests (after 10M free) | $0.00 | 5M typical |
| **Invalidations** | $0.005 per path (after 1K free) | $0.00 | 100 paths typical |
| **CloudFront Functions** | $0.10 per 1M invocations | $0.00 | Optional |
| **🎯 CloudFront Subtotal** | - | **$0 to $35 per month** | Learning setup |

**High Traffic Example:**
Scenario: 2TB data transfer per month
Calculation: (2048GB - 1024GB free) × $0.085/GB = $87.04 per month

text

---

### 2️⃣ Application Load Balancer (ALB)

| Component | Pricing | Monthly Cost | Notes |
|-----------|---------|-------------|-------|
| **ALB Hourly Rate** | $0.0225 per hour | $16.43 | 730 hours per month |
| **LCU (Load Capacity Units)** | $0.008 per LCU per hour | $5.84 | Average 1 LCU |
| **Static IPv4 Address** | $0.005 per hour | $3.65 | Per IP (×2 = $7.30) |
| **🎯 ALB Subtotal** | - | **$22 to $30 per month** | Typical usage |

**LCU Calculation Example:**
Low traffic workload:
├─ New connections: 500 per day = ~0.07 LCU
├─ Active connections: 10K = 0.1 LCU
└─ Processed bytes: 100GB per month = 0.003 LCU
───────────────────────────────────────
Total: 0.17 LCU = $1.00 per month

text

---

### 3️⃣ EC2 Instances (2× Application Servers)

| Instance Type | Per Hour | Monthly (730 hours) | Total for 2 Instances |
|---------------|----------|---------------------|----------------------|
| **t3.small** | $0.0208 | $15.18 | $30.36 |
| **t3.medium** | $0.0416 | $30.37 | $60.74 |
| **t3.large** | $0.0832 | $60.74 | **$121.48** ✅ |
| **t3.xlarge** | $0.1664 | $121.47 | $242.94 |
| **r6i.large** | $0.126 | $92.04 | $184.08 |

**Additional EC2 Costs:**

| Item | Cost | Calculation |
|------|------|-------------|
| **EBS Storage (gp3)** | $0.10 per GB per month | 30GB = $3 per instance |
| **EBS Snapshot Storage** | $0.05 per GB per month | 10GB = $0.50 |
| **Data Transfer Out** | $0.09 per GB | After 1GB free per month |
| **🎯 EC2 Subtotal** | - | **$120 to $150 per month** |

---

### 4️⃣ RDS (MySQL Database)

| Component | Unit Price | Monthly Cost | Notes |
|-----------|-----------|-------------|-------|
| **db.t3.micro** | $0.017 per hour | $12.41 | Development only |
| **db.t3.small** | $0.034 per hour | $24.82 | Small workload |
| **db.t3.medium** | $0.068 per hour | $49.64 | **Typical Setup** ✅ |
| **db.r6i.xlarge** | $0.504 per hour | $368.00 | High memory needs |
| **Storage (gp2)** | $0.23 per GB per month | $4.60 | 20GB typical |
| **Backup Storage** | $0.095 per GB per month | $1.90 | 30-day retention |
| **Multi-AZ** | 2× instance cost | +$49.64 | High availability |
| **🎯 RDS Subtotal** | - | **$56 to $100 per month** |

**RDS Cost Examples:**

| Scenario | Instance | Storage | Backups | Monthly Total |
|----------|----------|---------|---------|--------------|
| **Development (Small)** | t3.micro ($12.41) | $2.30 | $0.50 | **$15.21** |
| **Typical Production** | t3.medium ($49.64) | $4.60 | $1.90 | **$56.14** ✅ |
| **Multi-AZ Production** | t3.medium×2 ($99.28) | $4.60 | $1.90 | **$105.78** |
| **Enterprise** | r6i.xlarge ($368) | $23.00 | $5.00 | **$396.00** |

---

### 5️⃣ ElastiCache (Memcached)

| Node Type | Per Hour | Monthly (730 hours) | Total for 2 Nodes |
|-----------|----------|---------------------|------------------|
| **cache.t3.micro** | $0.017 | $12.41 | $24.82 |
| **cache.t3.small** | $0.034 | $24.82 | **$49.64** ✅ |
| **cache.t3.medium** | $0.068 | $49.64 | $99.28 |
| **cache.r7g.large** | $0.163 | $119.00 | $238.00 |
| **cache.r7g.xlarge** | $0.326 | $238.00 | $476.00 |

**Serverless Memcached Option:**

| Metric | Pricing |
|--------|---------|
| **Data Storage** | $0.125 per GB per hour |
| **ECPU Processing** | $0.0034 per 1 million ECPUs |
| **Minimum Monthly Cost** | ~$6 to $10 |

**Data Transfer Costs:**
Same Availability Zone (EC2 → ElastiCache): FREE ✅
Different Availability Zone: $0.01 per GB
Cross-Region: $0.02 per GB
Internet Outbound: $0.09 per GB

text

---

### 6️⃣ VPC & Networking

| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| **VPC Creation** | $0.00 | Always free |
| **Internet Gateway** | $0.00 | Always free |
| **Subnets** | $0.00 | Unlimited, always free |
| **Security Groups** | $0.00 | Unlimited, always free |
| **Route Tables** | $0.00 | Always free |
| **Elastic IP (unused)** | $36.50 per year | ⚠️ Costs if unattached |
| **Elastic IP (attached)** | $0.00 | Free when in use |
| **NAT Gateway** | $32.85 | Plus $0.045 per GB |
| **VPC Endpoint** | $7.20 | Plus $0.01 per GB |
| **VPC Flow Logs** | $0.50 per GB | Optional |
| **🎯 Network Subtotal** | **$0 to $70 per month** | Depends on usage |

---

## 💰 TOTAL MONTHLY COST ESTIMATION

[⬆️ Back to Top](#-table-of-contents)

### 📉 Scenario 1: Minimal Learning Setup (AWS Free Tier)

═══════════════════════════════════════════════════════
🎓 LEARNING / DEVELOPMENT TIER
═══════════════════════════════════════════════════════

🌐 CloudFront: $0.00
(within free tier - 1TB transfer, 10M requests)

⚖️ ALB: $16.43
(hourly: $0.0225 × 730 hours)

🖥️ EC2 (2× t3.small): $30.36
($0.0208 × 730 × 2)

💾 EBS Storage (20GB): $2.00
($0.10 × 20)

🗄️ RDS (db.t3.micro): $12.41
($0.017 × 730)

⚡ ElastiCache (2× t3.micro): $24.82
($0.017 × 730 × 2)

🔐 Network: $7.30
(Elastic IPs: $0.005 × 730 × 2)

─────────────────────────────────────────────────────
💸 TOTAL MONTHLY COST: $93.32 ✅

📊 ANNUAL COST: $1,119.84

🎁 Free Tier Benefit: -$50 to $100

💰 Final Annual Cost: ~$1,020.00
═══════════════════════════════════════════════════════

text

**Perfect For:**
- Learning AWS architecture
- Development and testing environments
- Academic projects and student portfolios
- Personal learning and experimentation

---

### 📈 Scenario 2: Typical Production Setup

═══════════════════════════════════════════════════════
🚀 STANDARD PRODUCTION TIER
═══════════════════════════════════════════════════════

🌐 CloudFront: $35.00
(500GB transfer beyond free tier)

⚖️ ALB: $22.27
(Hourly charge + LCU charges)

🖥️ EC2 (2× t3.large): $121.48
($0.0832 × 730 × 2)

💾 EBS Storage (30GB): $6.00
($0.10 × 30)

📦 EBS Snapshots: $0.50
(backup storage)

🗄️ RDS (db.t3.medium): $56.14
(Instance + storage + backup)

⚡ ElastiCache (2× t3.small): $49.64
($0.034 × 730 × 2)

🔐 Network: $7.30
(Elastic IPs)

─────────────────────────────────────────────────────
💸 TOTAL MONTHLY COST: $298.33 ✅

📊 ANNUAL COST: $3,580.00

💡 With Optimization: $2,500.00

📊 Savings Potential: 30% (-$1,080.00)
═══════════════════════════════════════════════════════

text

**Perfect For:**
- Small to medium production applications
- 100 to 1000 concurrent users
- Standard SLA requirements
- Startup and small business applications

---

### 🏢 Scenario 3: Enterprise Production Setup

═══════════════════════════════════════════════════════
🏢 ENTERPRISE / HIGH-PERFORMANCE TIER
═══════════════════════════════════════════════════════

🌐 CloudFront: $165.00
(2TB data transfer)

⚖️ ALB (2 instances): $50.00
(Multi-AZ redundancy)

🖥️ EC2 (4× t3.xlarge): $484.88
($0.1664 × 730 × 4)

💾 EBS Storage (100GB): $10.00
($0.10 × 100)

📦 EBS Snapshots (50GB): $2.50
(backup retention)

🗄️ RDS (r6i.xlarge, Multi-AZ): $736.00
(Instance ×2 + storage + backup)

⚡ ElastiCache (4× r7g.xlarge): $952.00
($0.326 × 730 × 4)

🔐 Network: $40.15
(Elastic IPs + NAT Gateway)

📊 CloudWatch (Custom Metrics): $50.00
(Advanced monitoring)

🔐 AWS Secrets Manager: $2.50
($0.50 per secret × 5)

─────────────────────────────────────────────────────
💸 TOTAL MONTHLY COST: $2,493.03 ✅

📊 ANNUAL COST: $29,916.00

💡 With Reserved Instances (3yr): $18,000.00

📊 Savings Potential: 60% (-$11,916.00)
═══════════════════════════════════════════════════════

text

**Perfect For:**
- Large-scale production applications
- 10K+ concurrent users
- Mission-critical applications with high SLA
- Enterprise customers with compliance needs

---

## 🗑️ CLEANUP STEP-BY-STEP GUIDE

[⬆️ Back to Top](#-table-of-contents)

### ⚠️ CRITICAL: Deletion Order is MANDATORY!

Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
↓ ↓ ↓ ↓ ↓ ↓
STOP DELETE DELETE DELETE DELETE CLEANUP
TRAFFIC COMPUTE DATABASE ALB CDN NETWORK

❌ WRONG ORDER = Orphaned resources = Hidden charges!
✅ RIGHT ORDER = Clean deletion = Zero lingering costs

text

---

### 🟥 Phase 1: Halt Application Traffic

[⬆️ Back to Top](#-table-of-contents)

#### Step 1️⃣ Deregister EC2 Instances from Target Group

**Why First:** Prevents ALB from routing requests during termination

**Action:**

Get target group ARN
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/vprofile-TG/abc123"

Deregister both EC2 instances
aws elbv2 deregister-targets
--target-group-arn $TARGET_GROUP_ARN
--targets Id=i-1234567890abcdef0 Id=i-0987654321fedcba0
--region us-east-1

echo "✅ EC2 instances deregistered from ALB"

text

**Verify Deregistration:**

Check target health status
aws elbv2 describe-target-health
--target-group-arn $TARGET_GROUP_ARN
--region us-east-1

Output should show: "TargetHealth": {"State": "unused"}
text

**⏱️ Time Required:** 2 to 3 minutes  
**💰 Cost Impact:** NONE (ALB still running)  
**🔄 Reversible:** YES (can re-register if needed)

---

### 🟥 Phase 2: Delete Compute Resources

[⬆️ Back to Top](#-table-of-contents)

#### Step 2️⃣ Terminate EC2 Instances

**⚠️ WARNING:** This permanently terminates application servers!

**Action:**

Terminate both EC2 instances
aws ec2 terminate-instances
--instance-ids i-1234567890abcdef0 i-0987654321fedcba0
--region us-east-1

echo "🗑️ EC2 instances terminating..."

text

**Monitor Termination:**

Check instance states (wait until "terminated")
aws ec2 describe-instances
--instance-ids i-1234567890abcdef0 i-0987654321fedcba0
--query 'Reservations.Instances[*].[InstanceId,State.Name]'
--region us-east-1

Expected output:
i-1234567890abcdef0 | terminated
i-0987654321fedcba0 | terminated
text

**⏱️ Time Required:** 3 to 5 minutes  
**💰 Monthly Cost Savings:** -$121.48 ✅  
**🔄 Reversible:** NO (data permanently lost)  
**✅ Checkpoint:** Both instances must show "terminated" status

---

#### Step 3️⃣ Delete EBS Volumes

**Why:** EBS volumes persist after EC2 termination if "Delete on Termination" was not set

**Check for Unattached Volumes:**

Find unattached volumes (likely from terminated instances)
aws ec2 describe-volumes
--filters "Name=status,Values=available"
--region us-east-1
--query 'Volumes[*].[VolumeId,Size,CreateTime]'

Example output:
vol-0a12b3c4d5e6f7g8h | 30 | 2025-11-05T10:30:00.000Z
text

**Delete Each Unattached Volume:**

Delete volume by ID
aws ec2 delete-volume
--volume-id vol-0a12b3c4d5e6f7g8h
--region us-east-1

echo "🗑️ EBS volume deleted: vol-0a12b3c4d5e6f7g8h"

text

**⏱️ Time Required:** Immediate  
**💰 Monthly Cost Savings:** -$6.00 (for 30GB) ✅  
**🔄 Reversible:** NO (data permanently lost)

---

#### Step 4️⃣ Delete ElastiCache Cluster

**⚠️ WARNING:** All cached data will be permanently deleted!

**Create Backup First (Optional):**

Export cache as backup (if needed for reference)
aws elasticache create-snapshot
--cache-cluster-id vprofile-memcache
--snapshot-name vprofile-memcache-backup-$(date +%Y%m%d)
--region us-east-1

echo "⏳ Snapshot creating... (5 to 10 minutes)"

text

**Delete ElastiCache Cluster:**

Delete Memcached cluster
aws elasticache delete-cache-cluster
--cache-cluster-id vprofile-memcache
--region us-east-1

echo "🗑️ ElastiCache cluster deleting..."

text

**Monitor Deletion:**

Wait for cluster to be fully deleted (5 to 10 minutes)
aws elasticache describe-cache-clusters
--cache-cluster-id vprofile-memcache
--region us-east-1
--query 'CacheClusters.CacheClusterStatus'

Status progression: "deleting" → "deleted"
text

**⏱️ Time Required:** 5 to 10 minutes  
**💰 Monthly Cost Savings:** -$49.64 ✅  
**🔄 Reversible:** NO (but snapshot available if created)

---

### 🟥 Phase 3: Delete Database Resources

[⬆️ Back to Top](#-table-of-contents)

#### Step 5️⃣ Create RDS Snapshot (BEFORE Deletion!)

**⚠️ CRITICAL:** Always create backup before deleting database!

**Create Final Snapshot:**

Create snapshot with timestamp
aws rds create-db-snapshot
--db-instance-identifier vprofile-db-mysql
--db-snapshot-identifier vprofile-db-backup-$(date +%Y%m%d-%H%M%S)
--region us-east-1

echo "📦 Snapshot created: vprofile-db-backup-20251107-120000"
echo "⏳ Snapshot in progress... (10 to 30 minutes for large databases)"

text

**Monitor Snapshot Creation:**

Check snapshot completion status
aws rds describe-db-snapshots
--db-snapshot-identifier vprofile-db-backup-20251107-120000
--region us-east-1
--query 'DBSnapshots.[DBSnapshotIdentifier,Status,AllocatedStorage]'

Expected output: vprofile-db-backup-20251107-120000 | available | 20
text

**Snapshot Storage Costs:**

| Database Size | Monthly Snapshot Cost |
|--------------|---------------------|
| 20 GB | $1.90 (kept indefinitely) |
| 100 GB | $9.50 |
| 500 GB | $47.50 |

💡 **Best Practice:** Keep snapshots for 6 to 12 months for compliance and disaster recovery

---

#### Step 6️⃣ Delete RDS Database Instance

**⚠️ WARNING:** Database will be permanently deleted!

**Action:**

Delete RDS database (skip final snapshot since we already created one)
aws rds delete-db-instance
--db-instance-identifier vprofile-db-mysql
--skip-final-snapshot
--region us-east-1

echo "🗑️ RDS database deleting..."

text

**Monitor Deletion Progress:**

Wait 10 to 15 minutes for complete deletion
aws rds describe-db-instances
--db-instance-identifier vprofile-db-mysql
--region us-east-1
--query 'DBInstances.DBInstanceStatus'

Status progression: "deleting" → eventually returns error "DBInstance not found"
text

**⏱️ Time Required:** 10 to 15 minutes  
**💰 Monthly Cost Savings:** -$56.14 ✅  
**🔄 Reversible:** NO (can restore from snapshot if needed)  
**✅ Checkpoint:** Confirm snapshot exists before proceeding

---

### 🟥 Phase 4: Delete Load Balancer Resources

[⬆️ Back to Top](#-table-of-contents)

#### Step 7️⃣ Delete Application Load Balancer

**Action:**

Get ALB ARN (replace with your actual ARN)
ALB_ARN="arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/vprofile-ALB/abc123"

Delete the load balancer
aws elbv2 delete-load-balancer
--load-balancer-arn $ALB_ARN
--region us-east-1

echo "🗑️ ALB deleting..."

text

**Monitor Deletion:**

Verify ALB deletion (2 to 3 minutes)
aws elbv2 describe-load-balancers
--load-balancer-arns $ALB_ARN
--region us-east-1

Should return: "LoadBalancers": [] (empty list)
text

**⏱️ Time Required:** 2 to 3 minutes  
**💰 Monthly Cost Savings:** -$22.27 ✅  
**🔄 Reversible:** NO

---

#### Step 8️⃣ Delete Target Group

**Action:**

Delete target group
aws elbv2 delete-target-group
--target-group-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/vprofile-TG/abc123
--region us-east-1

echo "🗑️ Target group deleted"

text

**⏱️ Time Required:** Immediate  
**💰 Cost Impact:** NONE (target groups are free)  
**🔄 Reversible:** NO

---

### 🟥 Phase 5: Delete CDN & Static Assets

[⬆️ Back to Top](#-table-of-contents)

#### Step 9️⃣ Disable CloudFront Distribution

**Why:** CloudFront distributions must be disabled before they can be deleted

**Action:**

Get current distribution configuration
aws cloudfront get-distribution-config
--id ABCDEFG1234567 \

distribution-config.json

Edit the JSON file manually: set "Enabled": false
Update the distribution
aws cloudfront update-distribution
--id ABCDEFG1234567
--if-match ETAG_VALUE
--distribution-config file://distribution-config.json
--region us-east-1

echo "⏳ CloudFront disabling... (15 to 30 minutes)"

text

**Via AWS Console (Easier):**
Go to CloudFront → Distributions

Select your distribution

Click "Disable"

Confirm action

Wait 15 to 30 minutes

text

**⏱️ Time Required:** 15 to 30 minutes for disabling

---

#### Step 🔟 Delete CloudFront Distribution

**Action (After distribution is disabled):**

Delete the disabled distribution
aws cloudfront delete-distribution
--id ABCDEFG1234567
--if-match ETAG_VALUE
--region us-east-1

echo "🗑️ CloudFront distribution deleted"

text

**Verify Deletion:**

Confirm deletion
aws cloudfront get-distribution
--id ABCDEFG1234567
--region us-east-1

Should return: "NoSuchDistribution" error
text

**⏱️ Time Required:** Immediate (after disabling complete)  
**💰 Monthly Cost Savings:** -$35.00 ✅  
**🔄 Reversible:** NO

---

#### Step 1️⃣1️⃣ Empty and Delete S3 Bucket

**⚠️ WARNING:** Bucket must be completely empty before deletion

**Action:**

Set bucket name variable
BUCKET_NAME="ng-vprofile-static-content"

Empty the bucket (remove all objects)
aws s3 rm s3://$BUCKET_NAME --recursive --region us-east-1

echo "📦 Bucket contents deleted"

Delete the empty bucket
aws s3api delete-bucket
--bucket $BUCKET_NAME
--region us-east-1

echo "🗑️ S3 bucket deleted: $BUCKET_NAME"

text

**Via AWS Console:**
Go to S3 → Buckets

Select your bucket

Click "Empty" → Confirm

Click "Delete" → Confirm

text

**⏱️ Time Required:** Depends on bucket size (seconds to minutes)  
**💰 Monthly Cost Savings:** -$1.00 ✅  
**🔄 Reversible:** NO (all data permanently lost)

---

### 🟥 Phase 6: Cleanup Network Resources

[⬆️ Back to Top](#-table-of-contents)

#### Step 1️⃣2️⃣ Release Elastic IPs

**Why:** Unused Elastic IPs cost money ($0.005 per hour = $36.50 per year)

**Check for Unassociated IPs:**

Find unused Elastic IPs
aws ec2 describe-addresses
--query 'Addresses[?AssociationId==null]'
--region us-east-1

Output shows unassociated Elastic IPs
text

**Release Each Unused IP:**

Release Elastic IP
aws ec2 release-address
--allocation-id eipalloc-1234567890abcdef0
--region us-east-1

echo "🗑️ Elastic IP released: eipalloc-1234567890abcdef0"

text

**⏱️ Time Required:** Immediate  
**💰 Monthly Cost Savings:** -$3.65 per IP ✅  
**🔄 Reversible:** NO (but can allocate new IPs anytime)

---

#### Step 1️⃣3️⃣ Delete NAT Gateway (If Created)

**Check for NAT Gateways:**

Find NAT Gateways
aws ec2 describe-nat-gateways
--filter "Name=state,Values=available"
--region us-east-1
--query 'NatGateways[*].[NatGatewayId,State,SubnetId]'

text

**Delete NAT Gateway:**

Delete NAT Gateway
aws ec2 delete-nat-gateway
--nat-gateway-id natgw-1234567890abcdef0
--region us-east-1

echo "🗑️ NAT Gateway deleting..."

text

**Monitor Deletion:**

Wait 5 minutes for deletion
aws ec2 describe-nat-gateways
--nat-gateway-ids natgw-1234567890abcdef0
--region us-east-1
--query 'NatGateways.State'

Status: "deleting" → "deleted"
text

**⏱️ Time Required:** 5 minutes  
**💰 Monthly Cost Savings:** -$32.85 ✅  
**🔄 Reversible:** NO

---

#### Step 1️⃣4️⃣ Delete Security Groups (Optional)

**⚠️ Note:** Default security groups cannot be deleted

**Action:**

Delete custom security groups
aws ec2 delete-security-group
--group-id sg-1234567890abcdef0
--region us-east-1

echo "🗑️ Security group deleted"

text

**⏱️ Time Required:** Immediate  
**💰 Cost Impact:** NONE (security groups are always free)  
**🔄 Reversible:** NO

---

## 🆓 FREE TIER & NO-COST RESOURCES

[⬆️ Back to Top](#-table-of-contents)

### Resources That DO NOT Cost Money

🎁 ALWAYS FREE IN AWS
═══════════════════════════════════════════════════════

✅ VPC (Virtual Private Cloud)
└─ Create unlimited VPCs at no charge

✅ Internet Gateway
└─ Included with every VPC

✅ Subnets (unlimited per VPC)
└─ No charge for any number of subnets

✅ Route Tables
└─ Manage routing at no cost

✅ Security Groups (unlimited)
└─ Network firewall rules included

✅ Network ACLs
└─ Default included with every VPC

✅ Target Groups
└─ Associated with load balancers

✅ Auto Scaling Groups with 0 instances
└─ Scaling rules only, no compute charge

✅ Launch Templates
└─ EC2 configuration storage

✅ CloudWatch Basic Metrics
└─ 5-minute resolution metrics
└─ Detailed (1-minute) = $0.10 per metric

✅ Elastic IPs when attached to running instance
└─ Free when actively in use
└─ Costs $0.005 per hour when unused

✅ RDS Parameter Groups
└─ Database configuration storage

✅ ElastiCache Parameter Groups
└─ Cache configuration storage

✅ CloudFront Distribution (disabled state)
└─ No traffic = no cost

═══════════════════════════════════════════════════════

text

**💡 Key Takeaway:** Keep these free resources for future projects. No need to delete them!

---

## 🔍 GOOD TO CHECK: HIDDEN COST RESOURCES

[⬆️ Back to Top](#-table-of-contents)

### Top Hidden Cost Culprits

These are commonly overlooked resources that **silently accumulate charges** in 3-tier architectures:

---

### 1️⃣ Unused Elastic IPs

**Cost:** $0.005 per hour = $36.50 per year if unattached!

**Check for Orphaned IPs:**

Find unattached Elastic IPs
aws ec2 describe-addresses
--query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]'
--region us-east-1

Each unattached IP costs $3.65 per month
text

**Action:**

Release immediately
aws ec2 release-address
--allocation-id eipalloc-12345
--region us-east-1

text

**💰 Monthly Savings:** $3.65 per unused IP ✅

---

### 2️⃣ NAT Gateway Running Idle

**Cost:** $0.045 per hour = $32.85 per month (just sitting there!)

**Check NAT Gateway Usage:**

Find NAT Gateways
aws ec2 describe-nat-gateways
--filter "Name=state,Values=available"
--region us-east-1

Each NAT Gateway costs $32.85 per month minimum
Plus $0.045 per GB processed
text

**⚠️ High-Cost Scenario:**
NAT Gateway running 24/7 with minimal traffic:
├─ Hourly charge: $0.045 × 730 = $32.85
├─ Data processing: 100GB × $0.045 = $4.50
└─ Total monthly cost: $37.35

text

**💰 Monthly Savings:** $32.85 to $50 if deleted ✅

---

### 3️⃣ RDS Automated Backups Retention

**Cost:** $0.095 per GB per month

**Check Backup Retention Period:**

Check current retention setting
aws rds describe-db-instances
--db-instance-identifier my-database
--query 'DBInstances.BackupRetentionPeriod'
--region us-east-1

Output example: 30 (days)
text

**Cost Example:**
20GB database with 30-day retention:
└─ 20GB × $0.095 = $1.90 per month

text

**Reduce Retention to Save Money:**

Set backup retention to 7 days
aws rds modify-db-instance
--db-instance-identifier my-database
--backup-retention-period 7
--apply-immediately
--region us-east-1

text

**💰 Monthly Savings:** $1 to $5 depending on database size ✅

---

### 4️⃣ CloudWatch Logs & Log Groups

**Cost:** 
- Ingestion: $0.50 per GB
- Storage: $0.03 per GB per month

**Find All Log Groups:**

List all log groups and retention settings
aws logs describe-log-groups
--region us-east-1
--query 'logGroups[*].[logGroupName,retentionInDays]'

text

**Hidden Costs Example:**
ALB access logs: 500GB per month
├─ Ingestion: 500GB × $0.50 = $250.00
├─ Storage: 500GB × $0.03 = $15.00
└─ Total monthly cost: $265.00 ⚠️

text

**Set Log Retention to Save Money:**

Set log retention to 7 days
aws logs put-retention-policy
--log-group-name /aws/alb/my-alb
--retention-in-days 7
--region us-east-1

text

**💰 Monthly Savings:** $50 to $250 depending on log volume ✅

---

### 5️⃣ S3 Bucket with Old Data

**Cost:** $0.023 per GB per month for Standard storage

**Calculate S3 Bucket Size:**

Check bucket size
aws s3 ls s3://my-bucket --summarize --human-readable --recursive

Output shows total size
text

**Hidden Cost Scenarios:**
Backup dumps: 100GB = $2.30 per month ⚠️
Application logs: 500GB = $11.50 per month ⚠️
Old AMI images: 50GB = $1.15 per month
───────────────────────────────────────
Total potential cost: $14.95 per month

text

**Action: Use S3 Lifecycle Policies:**

Move old data to cheaper storage classes
Standard: $0.023 per GB
Standard-IA: $0.0125 per GB (accessed less than once per month)
Glacier: $0.004 per GB (long-term archival)
text

**💰 Monthly Savings:** $1 to $15 depending on data volume ✅

---

### 6️⃣ RDS Multi-AZ Accidentally Enabled

**Cost:** DOUBLES your RDS bill!

**Check Multi-AZ Status:**

Check if Multi-AZ is enabled
aws rds describe-db-instances
--db-instance-identifier my-database
--query 'DBInstances.MultiAZ'
--region us-east-1

Output: true (means Multi-AZ enabled = 2× cost!)
text

**Cost Impact Example:**
Single-AZ db.t3.medium: $49.64 per month
Multi-AZ db.t3.medium: $99.28 per month (2× cost!) ⚠️
───────────────────────────────────────
Unnecessary cost: $49.64 per month

text

**Disable if Not Needed:**

Disable Multi-AZ for cost savings
aws rds modify-db-instance
--db-instance-identifier my-database
--no-multi-az
--apply-immediately
--region us-east-1

text

**💰 Monthly Savings:** $49.64 for db.t3.medium ✅

---

### 7️⃣ EC2 Instances with Large EBS Volumes

**Cost:** $0.10 per GB per month for gp3

**Check All EBS Volumes:**

Find all volumes and their sizes
aws ec2 describe-volumes
--region us-east-1
--query 'Volumes[*].[VolumeId,Size,VolumeType,State]'

text

**Cost Examples:**
100GB gp2: $0.10 × 100 = $10.00 per month
500GB io1: $0.125 × 500 = $62.50 per month
1TB st1: $0.045 × 1000 = $45.00 per month

text

**Action: Delete Unattached Volumes:**

Delete unused volumes
aws ec2 delete-volume
--volume-id vol-12345
--region us-east-1

text

**💰 Monthly Savings:** $5 to $50 depending on volume size ✅

---

### 8️⃣ Data Transfer Costs (Cross-AZ, Cross-Region)

**Pricing:**
Same Availability Zone: FREE ✅
Different Availability Zone: $0.01 per GB
Cross-Region: $0.02 per GB
Internet Outbound (to users): $0.09 per GB (first 10TB)

text

**Cost Example:**
100GB cross-AZ data transfer per month:
└─ 100GB × $0.01 = $1.00

100GB cross-region transfer per month:
└─ 100GB × $0.02 = $2.00

100GB to internet (user downloads):
└─ 100GB × $0.09 = $9.00 ⚠️

text

**💡 Optimization Tip:** Keep resources in same AZ when possible

---

## ✅ COST OPTIMIZATION BEST PRACTICES

[⬆️ Back to Top](#-table-of-contents)

### Quick Win #1: Use AWS Free Tier (First 12 Months)

**Benefits:**
750 hours t2.micro EC2 per month = ~$9 savings
1GB data transfer per month = $0.09 savings
5GB S3 storage = $0.12 savings
750 hours RDS t2.micro = ~$12 savings
───────────────────────────────────────
Total monthly savings: ~$21
Annual savings: ~$252 ✅

text

**Check Free Tier Usage:**
AWS Console → Billing → AWS Free Tier
View current free tier usage and alerts

text

---

### Quick Win #2: Right-Size EC2 Instances

**Cost Comparison:**
t3.large for learning? ❌ Overkill ($60.74 per month)
t3.medium (typical app) ✅ Better ($30.37 per month)
t3.small (light workload) ✅ Good ($15.18 per month)
t3.micro (free tier) ✅ Best for learning ($0 with free tier)

Potential savings: $45 per instance per month ✅

text

---

### Quick Win #3: Reserved Instances (RI)

**1-Year Commitment:**
On-Demand EC2 t3.large: $0.0832 per hour
1-Year RI: $0.0624 per hour (-25%)
───────────────────────────────────────
Monthly savings: $15.18 per instance
Annual savings: $182.16 per instance ✅

text

**3-Year Commitment:**
On-Demand EC2 t3.large: $0.0832 per hour
3-Year RI: $0.0520 per hour (-37%)
───────────────────────────────────────
Monthly savings: $22.78 per instance
Annual savings: $273.36 per instance ✅

text

---

### Quick Win #4: Delete Unused Snapshots

**Check for Old Snapshots:**

Find snapshots older than 90 days
aws ec2 describe-snapshots
--owner-ids self
--query 'Snapshots[*].[SnapshotId,StartTime,VolumeSize]'
--region us-east-1

text

**Cost Example:**
50GB old snapshot: $0.05 × 50 = $2.50 per month
200GB snapshot set: $0.05 × 200 = $10.00 per month
───────────────────────────────────────
Annual waste: $120 to $150 ⚠️

text

**Delete Unused Snapshots:**

Delete snapshot
aws ec2 delete-snapshot
--snapshot-id snap-1234567890abcdef0
--region us-east-1

text

**💰 Savings:** $2 to $10 per month ✅

---

### Quick Win #5: Use Spot Instances (Non-Critical Workloads)

**Cost Comparison:**
On-Demand t3.large: $0.0832 per hour
Spot t3.large: $0.0249 per hour (-70%!)
───────────────────────────────────────
Monthly savings: $42.56 per instance
Annual savings: $510.72 per instance ✅

text

**⚠️ Caveat:** Spot instances can be interrupted by AWS

**✅ Good For:**
- Development and testing
- Batch processing jobs
- Non-critical applications

**❌ Not Good For:**
- Production databases
- Mission-critical applications

---

### Quick Win #6: Enable CloudFront Compression

**Bandwidth Savings:**
Without compression: 500GB data transfer
With compression: 200GB data transfer (60% reduction)
───────────────────────────────────────
Cost before: $42.50 per month
Cost after: $17.00 per month
Monthly savings: $25.50 ✅

text

**Enable Compression:**

Update CloudFront distribution to enable compression
AWS Console → CloudFront → Distributions → Edit
Enable: "Compress Objects Automatically"
text

---

## 🎯 FINAL CLEANUP CHECKLIST

[⬆️ Back to Top](#-table-of-contents)

PHASE 1: APPLICATION LAYER
✅ Deregister EC2 from Target Groups

PHASE 2: COMPUTE RESOURCES
✅ Terminate 2× EC2 Instances (-$121.48 per month)
✅ Delete EBS Volumes (30GB) (-$6.00 per month)
✅ Delete ElastiCache Cluster (-$49.64 per month)

PHASE 3: DATABASE LAYER
✅ Create RDS Snapshot (backup)
✅ Delete RDS Instance (-$56.14 per month)

PHASE 4: LOAD BALANCING
✅ Delete ALB (-$22.27 per month)
✅ Delete Target Groups (free resource)

PHASE 5: CDN & STORAGE
✅ Disable CloudFront Distribution
✅ Delete CloudFront Distribution (-$35.00 per month)
✅ Empty and Delete S3 Bucket (-$1.00 per month)

PHASE 6: NETWORK CLEANUP
✅ Release Elastic IPs (-$3.65 per month)
✅ Delete NAT Gateway (if exists) (-$32.85 per month)

PHASE 7: OPTIONAL CLEANUP (FREE RESOURCES)
✅ Delete Custom Security Groups (free)
✅ Delete Subnets (free)
✅ Delete VPC (free)

═══════════════════════════════════════════════════════
💰 TOTAL MONTHLY SAVINGS: -$328.03
📊 ANNUAL SAVINGS: -$3,936.36
═══════════════════════════════════════════════════════

text

---

## 📋 FREQUENTLY ASKED QUESTIONS

[⬆️ Back to Top](#-table-of-contents)

### ❓ Will I be charged for terminated EC2 instances?

**Answer:** ✅ NO
- Terminated instances = $0 per hour
- But EBS volumes may still cost if not deleted
- Elastic IPs cost if not released

---

### ❓ How long until I see billing changes?

**Answer:** 24 to 48 hours
- AWS bills hourly, updates in Billing Console
- Changes visible in AWS Cost Explorer after 1 day
- Final charges appear on next month's invoice

---

### ❓ What if I delete RDS without snapshot?

**Answer:** ⚠️ Data is PERMANENTLY LOST
- Always create snapshot before deletion
- Snapshots cost $0.095 per GB per month
- Can restore database from snapshot anytime

---

### ❓ Can I recover deleted resources?

**Answer:**
- ✅ EC2: Possible within 1 hour from Recycle Bin (some regions)
- ❌ RDS: Only if snapshot was created
- ❌ ElastiCache: Cannot recover
- ❌ S3: Can recover if versioning was enabled

---

### ❓ Should I delete VPC, Subnets, Security Groups?

**Answer:** NO (they are FREE)
- Keep VPC for future deployments
- Subnets and Security Groups cost nothing
- Good to have ready for next project
- Only delete if you're 100% sure you won't use AWS again

---

### ❓ What are the most commonly forgotten charges?

**Answer:** Top 5 hidden charges:
1. Unused Elastic IPs ($36.50 per year each)
2. NAT Gateway running idle ($32.85 per month)
3. CloudWatch Logs storage ($50 to $250 per month)
4. Old EBS snapshots ($2 to $10 per month)
5. S3 buckets with old data ($1 to $15 per month)

---

### ❓ How do I avoid charges during learning?

**Answer:** Best practices:
- Use AWS Free Tier (first 12 months)
- Set billing alerts at $10, $50, $100
- Terminate resources immediately after practice
- Use t3.micro instances instead of t3.large
- Enable "DeleteOnTermination" for EBS volumes

---

### ❓ What if I see unexpected charges?

**Answer:** Investigation steps:
1. Check AWS Billing Console → Bills
2. Review Cost Explorer → Group by Service
3. Check CloudWatch Logs size
4. Look for unused Elastic IPs
5. Verify NAT Gateway usage
6. Contact AWS Support (Basic plan is free)

---

**🎓 Final Notes:**

This comprehensive guide provides production-grade practices for AWS 3-tier architecture deployment and cost management. By following the cleanup phases and optimization tips, you can **reduce costs by 60 to 70 percent** while maintaining infrastructure quality.

Always verify current AWS pricing on official AWS documentation as rates change over time.

---

**📅 Document Version:** 1.0  
**Date:** November 07, 2025  
**Last Updated:** Based on AWS November 2025 Pricing  
**Status:** ✅ Ready for Production Use

---

**🔗 Quick Reference Links:**

- AWS Pricing Console: https://aws.amazon.com/pricing/
- AWS Billing Dashboard: https://console.aws.amazon.com/billing
- AWS Cost Explorer: https://console.aws.amazon.com/cost-management
- AWS Free Tier: https://aws.amazon.com/free/

---

[⬆️ Back to Top](#-table-of-contents)