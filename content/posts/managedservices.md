---
title: 'From EC2 to AWS Managed Services: Migrating to AWS RDS with DMS'
date: 2025-04-05
author: "Bhavika Mantri"
draft: false
tags: ["AWS", "DevOps", "AWS RDS", "AWS DMS", "AWS Parameter Store"]
categories: ["DevOps"]

---

<div style="text-align: center;">
  <img src="/images/managedservices/intro.png" alt="" />
</div>

---


### Introduction

Last week, I successfully deployed an MVP using a simple but effective setup — a custom AMI with everything bundled into a single EC2 instance. Building an MVP is just the beginning of a startup’s journey. As the user base grows, the initial infrastructure needs to scale effectively to meet the increased demands.

This week, I undertook a major infrastructure upgrade to ensure the platform remains fast, reliable, and cost-efficient as I scale by:

✅ Migrated the database from EC2 to Amazon RDS using AWS DMS

✅ Moved image storage to S3 with CloudFront for global delivery

✅ Secured configurations using SSM Parameter Store

✅ Updated the app to leverage these AWS services seamlessly


Let’s dive into the details!

<div style="text-align: center;">
  <img src="/images/managedservices/architecture.png" alt="Architecture Overview" />
</div>


---

### Why Change the Architecture? Preparing for Growth

The initial MVP was built for speed, but scaling requires a more robust foundation. Here’s why the old setup wouldn’t work long-term:

**1. More Users, More Problems**

**Then:** A single EC2 instance handled everything (app, database, storage).

**Now:** Traffic spikes? Database queries slowing down? RDS decouples the database, allowing independent scaling.

**2. Data Everywhere, Consistency Nowhere**

**Then:** User uploads lived on one server — impossible to share across multiple instances.

**Now:** S3 acts as a single source of truth for images, accessible globally via CloudFront.

**3. Security & Maintenance Headaches**

**Then:** Secrets baked into AMIs. Changing a password? Redeploy everything.

**Now:** SSM Parameter Store securely manages configurations, enabling zero-downtime updates.

**4. Cost Efficiency at Scale**

**Then:** Over-provisioned EBS volumes “just in case”.

**Now:** Pay only for what you use with S3, and optimize database costs separately.

**The Bottom Line:**
The new architecture isn’t just about fixing today’s issues — it’s about enabling tomorrow’s success without reengineering everything later.

---

### Part 1: Database Migration to Amazon RDS

**Why Move from EC2 to RDS?**
The initial PostgreSQL-on-EC2 setup had critical flaws:

- Data loss risk (every AMI update wiped the DB)
- No horizontal scaling (only vertical, which gets expensive)
- Performance bottlenecks (DB and app competing for resources)


**Why DMS Was the Right Choice?**
I used AWS Database Migration Service (DMS) because it enables:

- Continuous replication — Keeps RDS in sync with live EC2 database
- Near-zero downtime — Only seconds of downtime during cutover
- Automatic validation — Verifies data consistency automatically


**Step-by-Step Migration with AWS DMS:**

1. Set up RDS PostgreSQL with Terraform
- Free-tier-friendly (db.t3.micro)
- Private subnet placement for security
- Custom parameter group to disable forced SSL (for DMS compatibility)

<div style="text-align: center;">
  <img src="/images/managedservices/mvp.png" alt="RDS Database" />
</div>

---

```terraform

# Configured RDS instance in Terraform
resource "aws_db_instance" "mvp" {
  identifier           = "mvp-database"
  engine               = "postgresql"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro" # Free-tier eligible
  allocated_storage    = 20
  db_name              = "mvp"
  username             = var.db_username # Sensitive variables from TF Cloud
  password             = var.db_password
  parameter_group_name = aws_db_parameter_group.mvp.name
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.mvp.name
}

# Custom parameter group to disable SSL enforcement
resource "aws_db_parameter_group" "mvp" {
  name   = "mvp-pg-ssl-disabled"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Critical for DMS compatibility
  }
}

```

2. Configured AWS Database Migration Service (DMS) with Terraform

- Created a replication instance (dms.t3.micro)

<div style="text-align: center;">
  <img src="/images/managedservices/replicationinstance.png" alt="DMS Replication Instance" />
</div>

---

- Defined source (EC2) and target (RDS) endpoints
<div style="text-align: center;">
  <img src="/images/managedservices/endpoints.png" alt="DMS Endpoints" />
</div>

---

- Ran a full-load replication task to migrate data

<div style="text-align: center;">
  <img src="/images/managedservices/dmstask.png" alt="DMS Replication Task" />
</div>

---

```terraform

# DMS Replication Instance
resource "aws_dms_replication_instance" "mvp" {
  replication_instance_class = "dms.t3.micro"
  replication_instance_id    = "mvp-migration-instance"
  allocated_storage          = 20 # Minimum storage for Free Tier
  vpc_security_group_ids     = [aws_security_group.dms.id]

  # Required tags for cost tracking
  tags = {
    Environment = "Migration"
  }
}

# Source Endpoint (EC2 PostgreSQL)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "ec2-postgres-source"
  endpoint_type = "source"
  engine_name   = "postgres"
  server_name   = aws_instance.app.private_ip
  port          = 5432
  username      = var.db_username
  password      = var.db_password
  database_name = "mvp"
}

# Target Endpoint (RDS)
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "rds-postgres-target"
  endpoint_type = "target"
  engine_name   = "postgres"
  server_name   = aws_db_instance.mvp.address
  port          = 5432
  username      = var.db_username
  password      = var.db_password
  database_name = "mvp"
}

# Replication Task
resource "aws_dms_replication_task" "migration" {
  migration_type           = "full-load"
  replication_task_id      = "mvp-full-migration"
  replication_instance_arn = aws_dms_replication_instance.mvp.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  table_mappings           = file("${path.module}/table-mappings.json")
}
```

3. Switched the Application to RDS

- Updated Django’s settings.py to point to RDS
- Tested thoroughly before decommissioning the local DB

```python
# settings.py 
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': '${aws_db_instance.mvp.address}', # Terraform reference
        'NAME': 'mvp',
        'USER': '${var.db_username}',
        'PASSWORD': '${var.db_password}'
    }
}
```

**Result:** A managed, scalable database that survives instance replacements!

---

### Part 2: Image Storage on S3 + CloudFront

**Why S3 Over EBS?**
- Unlimited storage (no more “disk full” errors)
- Reduced costs (pay-per-use vs. provisioned EBS)
- Global availability via CloudFront CDN

**Implementation Steps:**
1. Created an S3 Bucket and a CloudFront Distribution using Terraform.

<div style="text-align: center;">
  <img src="/images/managedservices/s3 bucket.png" alt="S3 Bucket" />
</div>

---

<div style="text-align: center;">
  <img src="/images/managedservices/cfd.png" alt="CloudFront Distribution" />
</div>

---
2. Enabled Origin Access Control to ensure only CloudFront can access S3.

<div style="text-align: center;">
  <img src="/images/managedservices/oac.png" alt="Origin Access Control" />
</div>

---

3. Updated EC2 IAM Role to grant permission for S3 operations (put, get, delete, list).

4. Copied existing images from EC2 to S3 using the AWS CLI as shown below.

5. Verified image accessibility via CloudFront.

```bash
aws s3 cp /opt/app/media/user_image/ s3://my-bucket/media/user_image/ - recursive
```

**Result:** Now, all user-uploaded images are stored securely in S3 and served efficiently through CloudFront, improving performance and reducing costs.

---

### Part 3: Secure Configuration with SSM Parameter Store

**Why Ditch secrets.sh?**
- Hardcoded secrets in AMIs = security risk
- No audit trail for changes
- Manual updates required for credential rotation

**How I Fixed It?**
1. Created SSM Parameters in Terraform for: Database credentials, Django secret key, RDS endpoint, S3 bucket name, CloudFront URL.
- /cloudtalents/startup/secret_key
- /cloudtalents/startup/db_user
- /cloudtalents/startup/db_password
- /cloudtalents/startup/database_endpoint
- /cloudtalents/startup/image_storage_bucket_name
- /cloudtalents/startup/image_storage_cloudfront_domain

<div style="text-align: center;">
  <img src="/images/managedservices/parameterstore.png" alt="Parameter Store" />
</div>

---

2. Updated EC2 Instance Profile to allow reading these parameters.

3. Updated GitHub Actions to remove secret file generation.

**Result:** No more secrets in code, and changes happen instantly across all instances.

---

### Part 4: Deploying the New Application Version

With the new infrastructure in place, I deployed an updated version of the application:

1. Replaced the application code with the new version from the provided zip file.
2. Created a new GitHub release to build and deploy a fresh AMI.
3. Verified the application functionality:
4. Checked for previously uploaded images.
5. Tested new image uploads.

**Result:** Everything worked smoothly, confirming a successful migration! 🎉

---

### Challenges & Solutions

**1. Server Error (500) During User Signup**

*Problem:* The application returned 500 errors when new users attempted to sign up.

*Root Cause:*

- Missing auth_user table in the database
- Incorrect database credentials in settings.py

*Solution:*

- Updated the DATABASES configuration in settings.py to use the correct credentials.
- Ran Django migrations to create the auth_user table and restarted Gunicorn and Nginx.

```bash
# Updated database configuration
python manage.py makemigrations
python manage.py migrate
sudo systemctl restart gunicorn
sudo systemctl restart nginx
```

**2. Critical File Location Issues**

*Problem:* Django management commands failed due to missing manage.py.

*Root Cause:* Incorrect project structure deployment.

*Solution:* Reorganized files to proper locations:

```bash
/opt/app/
├── cloudtalents/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── manage.py
├── requirements.txt
└── venv/
```

**3. Database Migration Hurdles**

*Problem:* DMS replication tasks failed to connect.

*Root Cause:* PostgreSQL security restrictions in pg_hba.conf.

*Solution:* Edited the pg_hba.conf file to allow connections from the DMS replication instance IP (10.10.10.215):

```conf
# Added DMS instance IP to allowlist
host    all             all             10.10.10.215/32           md5
sudo systemctl restart postgresql
```

**4. Data Migration Failures**

*Problem:* DMS tasks showed 100% completion but ended in error state.

*Root Cause:* Schema incompatibilities and unsupported data types.

*Solution:*

- Created premigration assessment report
- Modified problematic tables and data types
- Restarted migration task after fixes

---

### Key Lessons Learned
1. Always Verify Project Structure
Missing or misplaced files like manage.py can cause cascading failures.

2. Test Database Connections Early
Connection issues between services should be identified before migration.

3. Leverage AWS Assessment Tools
Premigration assessments revealed critical schema issues that would have caused data loss.

4. Maintain Operational Checks through regular verification of:

- Virtual environment activation
- Service status (PostgreSQL, Gunicorn, Nginx)
- File permissions

---

### Final Thoughts

By making these improvements, the MVP is now more scalable, cost-effective, and secure:

✅ Database on Amazon RDS — No more data loss or performance bottlenecks.

✅ Images stored in Amazon S3 and served via CloudFront — Faster and cheaper image delivery.

✅ Configurations managed in SSM Parameter Store — Enhanced security and scalability.

✅ Updated application deployment pipeline — More streamlined and automated.

This upgrade ensures that the MVP is well-prepared for growth while keeping costs under control. Exciting times ahead! 🚀

---

### Relevant Links
- [Amazon RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS DMS Documentation](https://docs.aws.amazon.com/dms/)
- [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
