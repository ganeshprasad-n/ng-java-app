
text
# 🚀 AWS 3-Tier Architecture: Complete Deployment & Cleanup Guide
## 💼 Production-Grade Resource Management | Cost Optimization | Effective Cleanup

**📅 Pricing Data**: November 07, 2025 | AWS Official Documentation
**⚠️ Disclaimer**: All charges mentioned are based on current AWS pricing. Actual costs may vary based on region, usage patterns, and future AWS pricing updates. Always verify on AWS pricing pages.

---

## 📑 Quick Navigation

- [🏗️ What We Created](#-what-we-created)
- [💰 Cost Breakdown](#-cost-breakdown-by-component)
- [🗑️ Complete Cleanup Guide](#-complete-cleanup-guide)
- [🆓 Free Resources](#-free-tier--no-cost-resources)
- [🔍 Hidden Costs](#-good-to-check-hidden-cost-resources)
- [✅ Total Cost Estimation](#-total-monthly-cost-estimation)
- [🎯 Cost Optimization](#-cost-optimization-best-practices)

---

## 🏗️ What We Created

### ✅ 3-Tier Architecture Stack

┌─────────────────────────────────────────────┐
│ 🌐 CloudFront + S3 (CDN) │ → $0-35/month
├─────────────────────────────────────────────┤
│ 🔄 ALB (Load Balancer) + 2× EC2 Servers │ → $143.75/month
├─────────────────────────────────────────────┤
│ 🗄️ RDS (MySQL) + 💾 ElastiCache (Memcached)│ → $105.78/month
├─────────────────────────────────────────────┤
│ 🔐 VPC + Security Groups + Networking │ → $7-40/month
└─────────────────────────────────────────────┘

text

| Component | Service | Instance Type | Created | Status |
|-----------|---------|---------------|---------|--------|
| 🌐 CDN | CloudFront | Distribution | ✅ Yes | Active |
| 💾 Static Assets | S3 Bucket | Standard | ✅ Yes | Active |
| ⚖️ Load Balancer | ALB | Application LB | ✅ Yes | Active |
| 🖥️ App Servers | EC2 | 2× t3.large | ✅ Yes | Active |
| 🗄️ Database | RDS | MySQL (t3.medium) | ✅ Yes | Active |
| ⚡ Cache Layer | ElastiCache | 2× Memcached | ✅ Yes | Active |
| 🔐 Network | VPC + SG | Custom | ✅ Yes | Active |

---

## 💰 Cost Breakdown by Component

### 1️⃣ CloudFront (Global CDN for Static Assets)

┌──────────────────────────────────────────┐
│ 🌍 CloudFront Pricing │
├──────────────────────────────────────────┤
│ Data Transfer Out (1TB+): $0.085/GB │
│ HTTPS Requests: $0.01/10K │
│ Invalidations: $0.005/path │
│ Monthly Free: 1TB + 10M req│
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
- 500GB data transfer = **$0.00** (within free tier)
- 5M HTTPS requests = **$0.00** (within free tier)
- **🎯 Total: $0-35/month** (typical learning setup)

**Monitor:**
AWS Console → CloudFront → Distributions → Reports
text

---

### 2️⃣ Application Load Balancer (ALB)

┌──────────────────────────────────────────┐
│ ⚖️ ALB Pricing │
├──────────────────────────────────────────┤
│ Hourly Rate: $0.0225/hour │
│ LCU (Load Units): $0.008/LCU/hour │
│ Static IPv4: $0.005/hour │
│ Monthly (730 hours): $16.43 + LCU │
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
Hourly Rate: $0.0225 × 730 = $16.43
LCU (avg 1): 1 × $0.008 × 730 = $5.84
Static IP (x2): 0.005 × 730 × 2 = $7.30
────────────────────────────────────────
🎯 Total: ~$22-30/month

text

---

### 3️⃣ EC2 Instances (2× Application Servers)

┌──────────────────────────────────────────┐
│ 🖥️ EC2 Instance Pricing │
├──────────────────────────────────────────┤
│ t3.large: $0.0832/hour │
│ Monthly (2×): $121.48 for both │
│ EBS Storage: $0.10/GB ($6/month) │
│ Free Tier: 750 hrs t2.micro (12mo) │
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
2× t3.large: $0.0832 × 730 × 2 = $121.48
EBS Storage: 30GB × $0.10 = $6.00
Data Transfer Out: ~$5-10
────────────────────────────────────────
🎯 Total: ~$132-141/month

text

**⚠️ Instance Type Comparison:**
| Type | Per Hour | Monthly | Total (2×) |
|------|----------|---------|-----------|
| t3.small | $0.0208 | $15.18 | $30.36 |
| t3.medium | $0.0416 | $30.37 | $60.74 |
| t3.large | $0.0832 | $60.74 | **$121.48** ✅ |
| t3.xlarge | $0.1664 | $121.47 | $242.94 |

---

### 4️⃣ RDS (MySQL Database)

┌──────────────────────────────────────────┐
│ 🗄️ RDS Pricing │
├──────────────────────────────────────────┤
│ db.t3.medium: $0.068/hour │
│ Storage (20GB): $0.23/GB/month ($4.60) │
│ Backup Storage: $0.095/GB/month │
│ Multi-AZ: 2× instance cost (avoid!) │
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
RDS Instance: $0.068 × 730 = $49.64
Storage (20GB): 20 × $0.23 = $4.60
Backup Storage: ~$1.90
────────────────────────────────────────
🎯 Total: ~$56-60/month

text

**⚠️ Database Size Impact:**
| Size | Storage Cost | Monthly Total |
|------|-------------|---------------|
| 10GB | $2.30/mo | $52.94 |
| 20GB | $4.60/mo | $55.24 |
| 50GB | $11.50/mo | $62.14 |
| 100GB | $23.00/mo | $73.64 |

---

### 5️⃣ ElastiCache (Memcached)

┌──────────────────────────────────────────┐
│ ⚡ ElastiCache Pricing │
├──────────────────────────────────────────┤
│ cache.t3.small: $0.034/hour │
│ 2 Nodes Monthly: $24.82 × 2 = $49.64 │
│ Data Transfer: FREE (same AZ) │
│ Serverless: $0.125/GB-hour (pay-go)│
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
2× cache.t3.small: $0.034 × 730 × 2 = $49.64
Data Transfer: FREE (within VPC)
────────────────────────────────────────
🎯 Total: ~$49-50/month

text

**⚠️ Node Type Comparison:**
| Node | Per Hour | Monthly (1×) | Total (2×) |
|------|----------|-------------|-----------|
| t3.micro | $0.017 | $12.41 | $24.82 |
| t3.small | $0.034 | $24.82 | **$49.64** ✅ |
| r7g.large | $0.163 | $119.00 | $238.00 |
| r7g.xlarge | $0.326 | $238.00 | $476.00 |

---

### 6️⃣ VPC & Network

┌──────────────────────────────────────────┐
│ 🔐 Network Pricing │
├──────────────────────────────────────────┤
│ VPC Creation: FREE ✅ │
│ Security Groups: FREE ✅ │
│ Subnets: FREE ✅ │
│ NAT Gateway: $0.045/hour ($32.85) │
│ Static IP: $0.005/hour ($3.65) │
│ Elastic IPv4: $0.005/hour (unused) │
│ Cross-AZ Transfer: $0.01/GB │
│ Same-AZ Transfer: FREE ✅ │
└──────────────────────────────────────────┘

text

**💸 Your Monthly Cost:**
Elastic IPs (2): $0.005 × 730 × 2 = $7.30
NAT Gateway (opt): $0.045 × 730 = $32.85
────────────────────────────────────────
🎯 Total: $7-40/month

text

---

## 📊 Total Monthly Cost Estimation

### 🎯 Minimal Learning Setup (AWS Free Tier Eligible)

═══════════════════════════════════════════
💰 COST BREAKDOWN
═══════════════════════════════════════════

🌐 CloudFront: $0.00
⚖️ ALB: $16.43
🖥️ EC2 (2× t3.small): $30.36
💾 EBS Storage: $3.00
🗄️ RDS (t3.micro): $12.30
⚡ ElastiCache (2× t3.micro): $24.82
🔐 Network: $7.30
─────────────────────────────────────────
💸 TOTAL MONTHLY: ~$94.21 ✅

💡 Free Tier Savings: ~$50+/month (12 months)

text

### 📈 Typical Production Setup

═══════════════════════════════════════════
💰 STANDARD CONFIGURATION
═══════════════════════════════════════════

🌐 CloudFront (500GB): $35.00
⚖️ ALB: $22.27
🖥️ EC2 (2× t3.large): $121.48
💾 EBS Storage (30GB): $6.00
🗄️ RDS (t3.medium): $56.14
⚡ ElastiCache (2× t3.small): $49.64
🔐 Network: $7.30
─────────────────────────────────────────
💸 TOTAL MONTHLY: ~$297.83 ✅

text

### 🏢 High-Performance Production

═══════════════════════════════════════════
💰 ENTERPRISE CONFIGURATION
═══════════════════════════════════════════

🌐 CloudFront (2TB): $165.00
⚖️ ALB: $50.00
🖥️ EC2 (2× t3.xlarge): $242.94
💾 EBS Storage (100GB): $10.00
🗄️ RDS (r6i.xlarge): $368.00
⚡ ElastiCache (2× r7g.xlarge): $476.00
🔐 Network (with NAT): $40.15
─────────────────────────────────────────
💸 TOTAL MONTHLY: ~$1,351.09 ⚠️

text

---

## 🗑️ Complete Cleanup Guide

### ⚠️ CRITICAL: Follow Deletion Order EXACTLY!

Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7
↓ ↓ ↓ ↓ ↓ ↓ ↓
STOP DELETE DELETE DELETE DELETE CLEANUP FREE
APP COMPUTE DATABASE ALB CDN NETWORK TIER

text

---

### 🟦 Phase 1: Stop Application & Load Balancer

#### Step 1️⃣ Deregister EC2 from Target Group

Via AWS CLI
aws elbv2 deregister-targets
--target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/name/id
--targets Id=i-1234567890abcdef0 Id=i-0987654321fedcba0
--region us-east-1

Monitor: Check console → EC2 → Target Groups
Status should change to "Unused"
text

**💡 Why First:** Prevents ALB from routing traffic during termination

---

### 🟦 Phase 2: Delete Compute Resources

#### Step 2️⃣ Terminate 2× EC2 Instances

⚠️ WARNING: This permanently deletes application servers
Via AWS CLI
aws ec2 terminate-instances
--instance-ids i-1234567890abcdef0 i-0987654321fedcba0
--region us-east-1

Via AWS Console
EC2 → Instances → Select 2 instances → Instance State → Terminate
Monitor termination (wait 2-3 minutes)
aws ec2 describe-instances
--instance-ids i-1234567890abcdef0
--query 'Reservations.Instances.State.Name'
--region us-east-1

Output should be: "terminated"
text

**💰 Savings: -$121.48/month** ✅

**Delete EBS Volumes:**
If volumes don't auto-delete:
aws ec2 delete-volume
--volume-id vol-1234567890abcdef0
--region us-east-1

text

**💰 Savings: -$6.00/month** ✅

---

#### Step 3️⃣ Delete ElastiCache Memcached Cluster

⚠️ This deletes all cached data permanently
Via AWS CLI
aws elasticache delete-cache-cluster
--cache-cluster-id my-memcached-cluster
--region us-east-1

Via AWS Console
ElastiCache → Memcached Clusters → Select → Delete
Wait 5-10 minutes, verify deletion
aws elasticache describe-cache-clusters
--cache-cluster-id my-memcached-cluster
--region us-east-1

Output: "CacheCluster not found"
text

**💰 Savings: -$49.64/month** ✅

---

### 🟦 Phase 3: Delete Database

#### Step 4️⃣ Create RDS Snapshot (Optional but Recommended)

✅ Create backup before deletion
aws rds create-db-snapshot
--db-instance-identifier my-database
--db-snapshot-identifier my-database-backup-20251107
--region us-east-1

Wait for snapshot (5-30 minutes)
aws rds describe-db-snapshots
--db-snapshot-identifier my-database-backup-20251107
--query 'DBSnapshots.Status'
--region us-east-1

Output: "available"
text

**💡 Why:** Snapshots cost **$0.095/GB/month** but preserve data

---

#### Step 5️⃣ Delete RDS Instance

⚠️ WARNING: Database permanently deleted if no snapshot
Via AWS CLI
aws rds delete-db-instance
--db-instance-identifier my-database
--skip-final-snapshot
--region us-east-1

Via AWS Console
RDS → Databases → Select instance → Delete
❌ Uncheck "Create final snapshot" (if snapshot already made)
Wait 10-15 minutes, verify
aws rds describe-db-instances
--db-instance-identifier my-database
--region us-east-1

Output: "DBInstance not found"
text

**💰 Savings: -$56.14/month** ✅

---

### 🟦 Phase 4: Delete Load Balancer

#### Step 6️⃣ Delete Application Load Balancer

⚠️ This stops serving traffic
Via AWS CLI
aws elbv2 delete-load-balancer
--load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/name/id
--region us-east-1

Via AWS Console
EC2 → Load Balancers → Select ALB → Delete
Wait 2-3 minutes, verify
aws elbv2 describe-load-balancers
--load-balancer-arns arn:aws:elasticloadbalancing:...
--region us-east-1

Output: "There are no resources matching your request"
text

**💰 Savings: -$22.27/month** ✅

---

#### Step 7️⃣ Delete Target Group

Via AWS CLI
aws elbv2 delete-target-group
--target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/name/id
--region us-east-1

Via AWS Console
EC2 → Target Groups → Select → Delete
text

**💡 Note:** Target groups are FREE, no cost savings

---

### 🟦 Phase 5: Delete CDN & Static Assets

#### Step 8️⃣ Disable CloudFront Distribution

Distributions must be disabled before deletion
Via AWS CLI
aws cloudfront get-distribution-config
--id ABCDEFG1234567 \

distribution-config.json

Edit the JSON file: set "Enabled": false
aws cloudfront update-distribution
--id ABCDEFG1234567
--distribution-config file://distribution-config.json
--region us-east-1

Via AWS Console
CloudFront → Distributions → Select → Disable
Wait 15-30 minutes for disabling
text

---

#### Step 9️⃣ Delete CloudFront Distribution

Via AWS Console (after distribution is disabled)
CloudFront → Distributions → Select disabled distribution → Delete
Via AWS CLI
aws cloudfront delete-distribution
--id ABCDEFG1234567
--region us-east-1

Verify deletion
aws cloudfront get-distribution
--id ABCDEFG1234567
--region us-east-1

Output: "NoSuchDistribution"
text

**💰 Savings: -$35.00/month** ✅

---

#### Step 🔟 Empty & Delete S3 Bucket

⚠️ Bucket must be empty before deletion
Empty bucket (remove all objects)
aws s3 rm s3://my-bucket --recursive --region us-east-1

Delete bucket
aws s3api delete-bucket
--bucket my-bucket
--region us-east-1

Via AWS Console
S3 → Select bucket → Empty → Delete
text

**💰 Savings: -$1.00/month** ✅

---

### 🟦 Phase 6: Cleanup Network Resources

#### Step 1️⃣1️⃣ Release Elastic IPs

Check unassociated Elastic IPs
aws ec2 describe-addresses
--query 'Addresses[?AssociationId==null]'
--region us-east-1

Release each unused IP
aws ec2 release-address
--allocation-id eipalloc-1234567890abcdef0
--region us-east-1

Via AWS Console
EC2 → Elastic IPs → Select unused → Release
text

**⚠️ Cost of Unused IP:** $0.005/hour = $36.50/year

**💰 Savings: -$3.65/month** ✅

---

#### Step 1️⃣2️⃣ Delete NAT Gateway (if created)

Check NAT Gateways
aws ec2 describe-nat-gateways
--filter "Name=state,Values=available"
--region us-east-1

Delete NAT Gateway
aws ec2 delete-nat-gateway
--nat-gateway-id natgw-1234567890abcdef0
--region us-east-1

Wait 5 minutes, verify
aws ec2 describe-nat-gateways
--nat-gateway-ids natgw-1234567890abcdef0
--region us-east-1

State should be: "deleted"
text

**⚠️ NAT Gateway Cost:** $0.045/hour = $32.85/month

**💰 Savings: -$32.85/month** ✅

---

### 🟦 Phase 7: Optional - Cleanup VPC Resources

#### Step 1️⃣3️⃣ Delete Security Groups (Custom Only)

❌ Cannot delete default security groups
Delete custom security groups
aws ec2 delete-security-group
--group-id sg-1234567890abcdef0
--region us-east-1

Via AWS Console
VPC → Security Groups → Select custom → Delete
text

**💡 Note:** Security groups are FREE, no cost savings

---

#### Step 1️⃣4️⃣ Delete Subnets (Optional)

Delete custom subnets
aws ec2 delete-subnet
--subnet-id subnet-1234567890abcdef0
--region us-east-1

text

**💡 Note:** Subnets are FREE, no cost savings

---

#### Step 1️⃣5️⃣ Delete VPC (Optional)

⚠️ Only if no resources attached
aws ec2 delete-vpc
--vpc-id vpc-1234567890abcdef0
--region us-east-1

text

**💡 Note:** VPC is FREE, no cost savings

---

## 📋 Cleanup Checklist

PHASE 1: Application Layer
✅ Deregister EC2 from Target Groups

PHASE 2: Compute Resources
✅ Terminate 2× EC2 Instances (-$121.48/month)
✅ Delete EBS Volumes (30GB) (-$6.00/month)
✅ Delete ElastiCache Cluster (-$49.64/month)

PHASE 3: Database Layer
✅ Create RDS Snapshot (optional)
✅ Delete RDS Instance (-$56.14/month)

PHASE 4: Load Balancing
✅ Delete ALB (-$22.27/month)
✅ Delete Target Groups (free)

PHASE 5: CDN & Storage
✅ Disable CloudFront Distribution
✅ Delete CloudFront Distribution (-$35.00/month)
✅ Empty & Delete S3 Bucket (-$1.00/month)

PHASE 6: Network Cleanup
✅ Release Elastic IPs (-$3.65/month)
✅ Delete NAT Gateway (optional) (-$32.85/month)

PHASE 7: VPC Cleanup (Optional)
✅ Delete Custom Security Groups (free)
✅ Delete Subnets (free)
✅ Delete VPC (free)

═══════════════════════════════════════════════
💰 TOTAL MONTHLY SAVINGS: -$327.03
═══════════════════════════════════════════════

text

---

## 🆓 Free Tier & No-Cost Resources

These resources exist but **DO NOT cost money**:

🎁 ALWAYS FREE
═══════════════════════════════════════════════

✅ VPC (Virtual Private Cloud)
└─ Create unlimited VPCs, no charge

✅ Internet Gateway
└─ Included with VPC

✅ Subnets (unlimited per VPC)
└─ No charge

✅ Route Tables
└─ Manage routing for free

✅ Security Groups (unlimited)
└─ Network ACL management included

✅ Network ACLs
└─ Default included with VPC

✅ Target Groups
└─ Associated with ALB/NLB

✅ Auto Scaling Groups (ASG) with 0 instances
└─ Scaling rules only, no compute charge

✅ Launch Templates
└─ Configuration storage

✅ CloudWatch Basic Metrics
└─ 5-minute resolution (detailed = $0.10/metric)

✅ Elastic IPs (when attached to running instance)
└─ Free if actively used

✅ RDS Parameter Groups
└─ Configuration storage

✅ ElastiCache Parameter Groups
└─ Configuration storage

text

---

## 🔍 Good To Check: Hidden Cost Resources

### ⚠️ TOP COST CULPRITS (commonly forgotten)

#### 1️⃣ Unused Elastic IPs - $36.50/year each!

Check for orphaned IPs
aws ec2 describe-addresses
--query 'Addresses[?AssociationId==null]'
--region us-east-1

Cost: $0.005/hour = $36.50/year if unused
Action: Release immediately
aws ec2 release-address --allocation-id eipalloc-12345 --region us-east-1

text

**💰 Savings: $3.65/month per unused IP**

---

#### 2️⃣ NAT Gateway Running Idle - $32.85/month minimum

Check NAT Gateway status
aws ec2 describe-nat-gateways
--filter "Name=state,Values=available"
--region us-east-1

Cost: $0.045/hour = $32.85/month (just sitting there!)
Plus: $0.045/GB for data processed
Action: Delete if not needed
aws ec2 delete-nat-gateway --nat-gateway-id natgw-12345 --region us-east-1

text

**💰 Savings: $32.85+/month**

---

#### 3️⃣ RDS Automated Backups - $0.095/GB/month

Check backup retention
aws rds describe-db-instances
--db-instance-identifier my-database
--query 'DBInstances.BackupRetentionPeriod'
--region us-east-1

Output: 30 (days) = stores 30 daily backups
Example: 20GB DB = 30 backups = ~$1.90/month
Action: Reduce retention to 7 days
aws rds modify-db-instance
--db-instance-identifier my-database
--backup-retention-period 7
--apply-immediately
--region us-east-1

text

**💰 Savings: ~$1.36/month for 20GB DB**

---

#### 4️⃣ CloudWatch Logs - $0.50/GB ingestion + $0.03/GB storage

Find all log groups
aws logs describe-log-groups --region us-east-1

Check retention settings
aws logs describe-log-groups
--query 'logGroups[*].[logGroupName,retentionInDays]'
--region us-east-1

⚠️ ALB logs example:
500GB/month of logs = $250/month!!!
Action: Set retention to 7 days
aws logs put-retention-policy
--log-group-name /aws/alb/my-alb
--retention-in-days 7
--region us-east-1

text

**💰 Savings: $100-250/month for high-traffic apps**

---

#### 5️⃣ S3 Bucket with Old Data - $0.023/GB/month

Calculate bucket size
aws s3 ls s3://my-bucket --summarize --human-readable --recursive

⚠️ Examples:
100GB backup dumps = $2.30/month
500GB logs = $11.50/month
50GB old AMI snapshots = $1.15/month
Action: Use S3 Lifecycle policies
text

**💰 Savings: $1-15/month depending on data**

---

#### 6️⃣ RDS Multi-AZ Accidentally Enabled - DOUBLES BILL!

Check if Multi-AZ enabled
aws rds describe-db-instances
--db-instance-identifier my-database
--query 'DBInstances.MultiAZ'
--region us-east-1

Output: true = 2× cost!
Example: t3.medium: $49.64 → $99.28/month!
Action: Disable Multi-AZ
aws rds modify-db-instance
--db-instance-identifier my-database
--no-multi-az
--apply-immediately
--region us-east-1

text

**💰 Savings: $49.64/month for t3.medium**

---

#### 7️⃣ EC2 Instances with Large EBS Volumes

Check all volumes
aws ec2 describe-volumes
--region us-east-1
--query 'Volumes[*].[VolumeId,Size,VolumeType,State]'

⚠️ Examples:
100GB gp2 = $0.10 × 100 = $10/month
500GB io1 = $0.125 × 500 = $62.50/month
1TB st1 = $0.045 × 1000 = $45/month
Action: Right-size volumes, delete unattached ones
aws ec2 delete-volume --volume-id vol-12345 --region us-east-1

text

**💰 Savings: $5-50/month depending on volume size**

---

#### 8️⃣ Data Transfer Costs (Cross-AZ, Cross-Region)

Monitor data transfer
AWS Console → EC2 → Network Interfaces → Byte counts
Costs:
Same AZ = FREE ✅
Different AZ = $0.01/GB
Cross-Region = $0.02/GB
Internet outbound = $0.09/GB (first 10TB)
Example:
100GB cross-AZ transfer = $1.00
100GB cross-region = $2.00
100GB to internet = $9.00
text

**💰 Savings: $0.01-0.09/GB by optimizing transfers**

---

#### 9️⃣ VPC Endpoints & NAT Gateway Alternatives

VPC Endpoint (for private RDS access)
Cost: $7.20/month + $0.01/GB processed
NAT Gateway (for outbound internet)
Cost: $32.85/month + $0.045/GB
⚠️ If using both for light workloads = expensive!
Consider: NAT Instance (EC2) if traffic < 100GB/month
text

**💰 Potential Savings: $10-40/month**

---

#### 🔟 CloudFront Origin Shield - $0.01/GB extra!

Check if Origin Shield enabled
aws cloudfront get-distribution
--id ABCDEFG1234567
--query 'Distribution.DistributionConfig.OriginShield'

If enabled: adds $0.01/GB to CloudFront cost
500GB transfer + Origin Shield = $5/month extra
Action: Disable if not needed
text

**💰 Savings: $1-10/month**

---

### 🟢 AWS Cost Monitoring & Alerts

Set up cost alert (recommended)
AWS Console → AWS Billing → Billing Preferences
→ Enable "Receive Free Tier Usage Alerts"
→ Enable "Receive Billing Alerts"
Check Cost Anomaly Detection
AWS Console → Cost Management → Cost Anomaly Detection
→ Create detector for unusual spending
text

---

## ✅ Cost Optimization Best Practices

### 🎯 Quick Win #1: Use AWS Free Tier (First 12 Months)

750 hours t2.micro EC2 = ~$5-10/month savings
1GB data transfer = ~$0.09/GB savings
5GB CloudFront = ~$0.425/GB savings

text

**Action:**
Check free tier eligibility
AWS Console → AWS Free Tier → View current free tier
text

---

### 🎯 Quick Win #2: Right-Size Instances

t3.large for learning? ❌ Overkill
t3.medium (typical app) ✅ Perfect
t3.small (light workload) ✅ Also good
t3.micro (free tier) ✅ Learning

Savings: $60.74 → $30.37/month for each instance

text

---

### 🎯 Quick Win #3: Reserved Instances (RI)

On-Demand EC2: $0.0832/hour
1-Year RI: $0.0624/hour (-25%)
3-Year RI: $0.0520/hour (-37%)

Example: 2× t3.large
On-Demand: $121.48/month
1-Year RI: $91.10/month (-$30.38)
3-Year RI: $76.02/month (-$45.46)

⚠️ Caveat: Upfront payment required

text

---

### 🎯 Quick Win #4: Delete Unused Snapshots

Find old snapshots
aws ec2 describe-snapshots
--owner-ids self
--query 'Snapshots[*].[SnapshotId,StartTime,VolumeSize]'
--region us-east-1

Cost: $0.095/GB/month
50GB old snapshot = $4.75/month
Delete unused snapshots
aws ec2 delete-snapshot
--snapshot-id snap-1234567890abcdef0
--region us-east-1

text

---

### 🎯 Quick Win #5: Auto Scaling (for variable load)

Without ASG:
2× t3.large 24/7 = $121.48/month

With ASG (avg 1.5 instances):
1.5× t3.large average = $91.11/month
Savings: $30.37/month (25% reduction)

text

---

### 🎯 Quick Win #6: Spot Instances (for non-critical)

On-Demand t3.large: $0.0832/hour
Spot t3.large: $0.0249/hour (-70%!)

Example: 2× instances
On-Demand: $121.48/month
Spot: $36.45/month

⚠️ Can be interrupted (not suitable for prod DB)
✅ Great for app tier, batch jobs, testing

text

---

### 🎯 Quick Win #7: S3 Lifecycle Policies

Automatically move old data to cheaper storage
Standard: $0.023/GB/month
IA (30+ days): $0.0125/GB/month
Glacier: $0.004/GB/month
aws s3api put-bucket-lifecycle-configuration
--bucket my-bucket
--lifecycle-configuration '{
"Rules": [{
"Id": "Archive after 30 days",
"Status": "Enabled",
"Transitions": [{
"Days": 30,
"StorageClass": "STANDARD_IA"
}, {
"Days": 90,
"StorageClass": "GLACIER"
}]
}]
}'

Example: 1TB of data = $23 → $12.50 → $4 (savings: $19/month!)
text

---

### 🎯 Quick Win #8: CloudFront Distribution Settings

Enable Caching to reduce origin hits
Cache-Control: max-age=31536000 (1 year for static assets)
Enable Compression (saves ~60% bandwidth)
aws cloudfront create-distribution
--distribution-config '{
"CacheBehaviors": [{
"Compress": true
}]
}'

Monitor cache hit ratio
CloudFront → Distributions → Reports tab
Target: >80% cache hit ratio
Savings: $5-20/month on CloudFront

text

---

### 🎯 Quick Win #9: Enable Detailed Monitoring Selectively

Basic Monitoring (5-min): FREE
Detailed Monitoring (1-min): $0.10/metric

❌ Don't enable for all metrics
✅ Enable only for critical metrics:

CPU Utilization

Database Connections

Cache Hit Rate

Savings: $5-50/month

text

---

### 🎯 Quick Win #10: Monthly Cost Tracking

Setup AWS Billing Alerts
AWS Console → Billing → Preferences
→ "Receive Billing Alerts"
→ Set threshold (e.g., $300/month)
Use AWS Cost Explorer
AWS Console → Cost Management → Cost Explorer
→ Track spending by service
Export monthly CSV
aws ce get-cost-and-usage
--time-period Start=2025-11-01,End=2025-11-30
--granularity MONTHLY
--metrics BlendedCost
--group-by Type=DIMENSION,Key=SERVICE

text

---

## 🎯 Production Grade Cost Reduction Strategy

### Month 1-2: Setup Phase
Cost: ~$300-400/month
Focus: Baseline monitoring, learn AWS services

text

### Month 3: Optimization Phase
❌ Remove unused resources
✅ Right-size instances (large → medium)
✅ Enable compression in CloudFront
✅ Set log retention to 7 days
✅ Delete old snapshots & backups

Expected Savings: -$80-100/month (-25-30%)

text

### Month 4+: Production Grade
✅ Reserved Instances (1-year): -$30/month
✅ Auto Scaling configured: -$30/month
✅ S3 Lifecycle policies: -$10/month
✅ Spot instances for app tier: -$85/month

🎯 Final Monthly Cost: ~$150-200
💰 Total Savings from Month 1: 60-70%

text

---

## 🆘 Troubleshooting & FAQs

### ❓ Q: Will I be charged for terminated EC2 instances?

**A:** ✅ NO
- Terminated instances = $0/hour
- But EBS volumes attached still cost (delete them)
- Elastic IPs still cost if not released

---

### ❓ Q: How long until I see billing changes?

**A:** 24-48 hours
- AWS bills hourly, updates in AWS Billing Console
- Changes visible in AWS Cost Explorer after 1 day

---

### ❓ Q: What if I delete RDS without snapshot?

**A:** ⚠️ Data is PERMANENTLY LOST
- Always create snapshot first
- Snapshots cost $0.095/GB/month but preserve data
- Can restore from snapshot anytime

---

### ❓ Q: Can I recover deleted resources?

**A:**
- ✅ EC2: Deleted within 1 hour from Recycle Bin (some regions)
- ❌ RDS: Only if snapshot was created
- ❌ ElastiCache: Cannot recover
- ❌ S3: Can recover if versioning enabled

---

### ❓ Q: Are there hidden charges I missed?

**A:** Common ones:
✅ Check: CloudWatch Logs (high for ALB)
✅ Check: Unused Elastic IPs
✅ Check: RDS backup storage
✅ Check: NAT Gateway
✅ Check: Multi-AZ enabled by mistake
✅ Check: Old EBS snapshots
✅ Check: S3 data sitting in Standard storage

text

---

### ❓ Q: Should I delete VPC, Subnets, Security Groups?

**A:** NO (they're FREE)
- Keep VPC for future deployments
- Subnets & Security Groups cost nothing
- Good to have ready for next project

---

## 📞 Quick Reference: Important AWS Console Links

🔗 Cost Management
→ https://console.aws.amazon.com/cost-management

🔗 Billing & Invoices
→ https://console.aws.amazon.com/billing

🔗 EC2 Instances
→ https://console.aws.amazon.com/ec2

🔗 RDS Databases
→ https://console.aws.amazon.com/rds

🔗 ElastiCache
→ https://console.aws.amazon.com/elasticache

🔗 CloudFront
→ https://console.aws.amazon.com/cloudfront

🔗 S3 Buckets
→ https://console.aws.amazon.com/s3

🔗 CloudWatch (Monitoring)
→ https://console.aws.amazon.com/cloudwatch

text

---

## 🎓 Key Learnings Summary

┌─────────────────────────────────────────────────────┐
│ ✨ AWS 3-Tier Architecture Production Checklist │
├─────────────────────────────────────────────────────┤
│ │
│ ✅ Infrastructure │
│ ✓ CloudFront + S3 configured │
│ ✓ ALB with 2× EC2 instances │
│ ✓ RDS MySQL database ready │
│ ✓ ElastiCache Memcached active │
│ ✓ VPC + Security Groups locked down │
│ │
│ ✅ Configuration │
│ ✓ application.properties updated │
│ ✓ RDS credentials configured │
│ ✓ Memcached endpoints added │
│ ✓ CloudFront CDN for static assets │
│ │
│ ✅ Cost Monitoring │
│ ✓ Billing alerts enabled │
│ ✓ Cost Explorer tracking active │
│ ✓ Unused resources identified │
│ ✓ Cleanup procedures documented │
│ │
│ ✅ Production Ready │
│ ✓ Auto Scaling configured (if needed) │
│ ✓ Backups and snapshots scheduled │
│ ✓ Monitoring and logs in place │
│ ✓ Disaster recovery plan ready │
│ │
└─────────────────────────────────────────────────────┘

text

---

## 📞 Next Steps

1️⃣ Review your AWS Console
→ Check all resources created
→ Verify no unintended resources

2️⃣ Test Application
→ Verify database connectivity
→ Test Memcached caching
→ Monitor CloudFront cache hits

3️⃣ Setup Monitoring
→ CloudWatch dashboards
→ Billing alerts
→ Performance metrics

4️⃣ Plan Cleanup
→ Schedule termination date
→ Create backups first
→ Follow phases in this guide

5️⃣ Cost Optimization
→ Apply tips from Quick Wins
→ Consider Reserved Instances
→ Monitor monthly bills

text

---

**🎯 Final Notes:**

> This guide provides **production-grade practices** for AWS 3-tier architecture deployment and cost management. By following the cleanup phases and optimization tips, you can reduce costs by 60-70% while maintaining infrastructure quality.

> Always verify current AWS pricing on official AWS documentation as rates change frequently.

---

**📅 Document Version:** 1.0 | **Date:** November 07, 2025  
**Last Updated:** As per AWS November 2025 Pricing  
**Status:** ✅ Ready for Production Use

Perfect! This is a complete, single copy-paste README with:

✅ Fun navigable symbols throughout
✅ Cost breakdown for every component
✅ Detailed cleanup procedures (15 steps in phases)
✅ Hidden cost resources section
✅ Free tier & no-cost resources identified
✅ Cost optimization quick wins
✅ Clear disclaimers with November 07, 2025 timestamp
✅ Production-grade checklist
✅ FAQ troubleshooting section
✅ Easy to copy-paste into README.md file