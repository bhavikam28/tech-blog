---
title: 'Launching MVP with Automated Infrastructure: Packer AMIs, Terraform & AWS SSM'
date: 2025-03-31
author: "Bhavika Mantri"
draft: false
tags: ["AWS", "AWS Security", "DevOps", "Packer", "AWS SSM"]
categories: ["DevOps"]

---

### Introduction

Bringing a new product to life starts with launching a **Minimum Viable Product (MVP)** — an initial version that delivers core functionalities for early users while minimizing development time and cost.

I took on the challenge in this project: transforming the developers’ raw application code into a build system and publishing the service for initial testing in a reliable, scalable production environment. The goal was to automate infrastructure provisioning, create a custom AMI with Hashicorp Packer, deploy EC2 instances using Terraform, and manage them securely via AWS Systems Manager (SSM).

---

### Application Overview

The application is built using a modern tech stack:

- **Django (Python framework)**: Handles web application logic and API endpoints.
- **NGINX**: Acts as a reverse proxy, directing traffic efficiently.
- **Gunicorn**: Serves as the Web Server Gateway Interface (WSGI) to process HTTP requests for Django.
- **PostgreSQL**: A reliable, scalable database for storing authenticated user data


---

<div style="text-align: center;">
  <img src="/images/mvp/applicationoverview.png" alt="Application Architecture Overview" />
</div>

---

This comprehensive guide documents my journey through four crucial phases of infrastructure automation:

- Custom AMI Creation with HashiCorp Packer
- Bash Scripting for Automated Configuration
- Terraform Provisioning for Consistent Deployments
- Secure Management with AWS Systems Manager

---

### Implementation: Automated AMI Creation and Deployment

The infrastructure automation follows two streamlined CI/CD workflows:

---

<div style="text-align: center;">
  <img src="/images/mvp/implementation.png" alt="Implementation Architecture" />
</div>

---

- **AMI Creation with Packer:**
This workflow builds an immutable Amazon Machine Image from a base Ubuntu image using a BASH provisioning script. The script automates the installation of all dependencies (including Python, Nginx, and PostgreSQL) and configures the runtime environment for our Django application. Triggered by GitHub releases, each AMI is versioned to match the release tag (e.g., v1.0.0), ensuring traceability and consistency.

- **EC2 Deployment with Terraform:**
Once the AMI is available, a separate workflow deploys EC2 instances using Terraform. The process is designed for reliability: instances launch with the pre-configured AMI, eliminating post-deployment setup steps. Manual triggers via workflow_dispatch allow controlled rollouts of specific AMI versions.

---

   **Why Packer?**
    Immutable infrastructure is key to reducing configuration drift. By baking everything into the AMI — dependencies, application code, and even secrets — we ensure instances are production-ready upon launch. This approach also speeds up scaling; new instances inherit the same battle-tested environment without manual intervention.

---

### Step 1: Building Custom AMIs with HashiCorp Packer

I created a custom Amazon Machine Image (AMI) using HashiCorp Packer to ensure consistent and reusable infrastructure. The process followed the “Image as Code” principle, enabling automated and repeatable AMI builds.

**Steps Taken:**

**1. Configured the Packer Template:**

- Used ubuntu-jammy-22.04-amd64-server as the base image.
- Configured the vpc_id, subnet_id, and associate_public_ip_address in the source block.
- Defined ssh_username as ubuntu for SSH access.

**2. Added Versioning:**

- Introduced a versioning variable (version), allowing AMI updates to be tracked using the naming convention fictitious-app-ami-vX.X.X.

**3. Provisioned Application Code:**

- Uploaded the repository contents to /tmp and moved the necessary files to /opt/app.
- Ensured the application setup script (setup.sh) is executable.

**4. Optimized AMI Storage:**

- Used the amazon-ami-management post-processor to retain only the last two AMI releases, reducing storage costs.

---

```hcl

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    amazon-ami-management = {
      version = ">= 1.0.0"
      source  = "github.com/wata727/amazon-ami-management"
    }
  }
}

variable "subnet_id" {
  type        = string
  description = "Development Account OU Public Subnet ID shared by RAM"
  default     = ""  
}

variable "version" {
  type        = string
  default     = ""  
  description = "AMI Release version"
}

variable "vpc_id" {
  type        = string
  description = "Main VPC created in the Network Infrastructure OU"
  default     = ""  
}

variable "secret_key" {
  type        = string
  sensitive   = true  
  description = "Secret key for the application"
}

variable "db_user" {
  type        = string
  sensitive   = true  
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true 
  description = "Database password"
}

locals {
  ami_name          = "fictitious-app-ami"
  source_image_name = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
  source_ami_owners = ["099720109477"]
  ssh_username      = "ubuntu"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${local.ami_name}-${var.version}"
  instance_type = "t2.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = local.source_image_name  
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = local.source_ami_owners
  }

  ssh_username                = local.ssh_username
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
}

build {
  name = "custom_ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "./"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = [
      "echo Moving files...",
      "sudo mkdir -p /opt/app",
      "sudo mv /tmp/* /opt/app",
      "sudo chmod +x /opt/app/setup.sh"
    ]
  }

  provisioner "shell" {
    script = "setup.sh"
  }

  post-processor "amazon-ami-management" {
    regions       = ["us-east-1"]  
    identifier    = local.ami_name
    keep_releases = 2
  }
}

```

**5. Automated AMI Builds with GitHub Actions:**

- Configured GitHub OIDC for authentication, eliminating static credentials.
- Created a workflow to trigger Packer builds on new GitHub releases.
-  Injected sensitive credentials (SECRET_KEY, DB_USER, DB_PASSWORD) dynamically using a secrets.sh file.

---

```yaml
name: Packer Build on Release

on:
  release:
    types: [published]  

env:
  PACKER_VERSION: "1.11.2"

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read

    steps:
      # Step 1: Checkout the repository
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Install Packer
      - name: Setup Packer
        uses: hashicorp/setup-packer@main
        with:
          version: ${{ env.PACKER_VERSION }}

      # Step 3: Initialize Packer plugins
      - name: Run `packer init`
        run: packer init ./image.pkr.hcl

      # Step 4: Configure AWS credentials using OIDC
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE }}
          aws-region: us-east-1

      # Step 5: Build the AMI
      - name: Build AMI with Packer
        run: |
          packer build \
            -color=false \
            -on-error=abort \
            -var "vpc_id=${{ secrets.VPC_ID }}" \
            -var "subnet_id=${{ secrets.SUBNET_ID }}" \
            -var "version=${{ github.event.release.tag_name }}" \
            -var "secret_key=${{ secrets.SECRET_KEY }}" \
            -var "db_user=${{ secrets.DB_USER }}" \
            -var "db_password=${{ secrets.DB_PASSWORD }}" \
            ./image.pkr.hcl

```

---

🚀**Outcome:**
- Successfully generated a custom AMI with application files and configurations.
- Established an automated, versioned, and cost-efficient AMI creation process.
---

<
<div style="text-align: center;">
  <img src="/images/mvp/ami.png" alt="AMI Created" />
</div>

---

### Step 2: Launching EC2 Instances with Custom AMIs using Terraform

Once the AMI was ready, the next step was to launch an EC2 instance based on it. Using Terraform, I automated the deployment process.

**Steps Taken:**

**1. Configured Terraform Variables & Outputs:**

- Used remote state sharing to fetch VPC & subnet details.
- Defined ami_id as a required input variable to specify which AMI version to deploy.

**2. Created EC2 Instance:**

- Set t2.micro as the instance type (to stay within AWS Free Tier).
- Deployed in a public subnet with a public IP.
- Assigned a security group allowing inbound traffic on port 80 (HTTP).

**3. Implemented a CI/CD Pipeline for Terraform:**

- Created a GitHub Actions workflow to deploy Terraform infrastructure in us-east-1.
- Used OIDC integration to authenticate Terraform with AWS.
- Configured manual triggers using workflow_dispatch to deploy specific AMI versions.

---

```yaml

name: EC2 Deployment

on:
  workflow_dispatch:
    inputs:
      ami_id:
        required: true
        description: 'The exact AMI ID'

permissions:
  contents: read
  id-token: write  

jobs:
  deploy-ec2:
    name: EC2 Deployment
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform
    steps:
      - name: Repository Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }} 
          aws-region: us-east-1

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.8"
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }} 

      - name: Terraform Init
        id: init
        run: terraform init

      - name: Terraform Plan
        id: plan
        run: terraform plan

      - name: Terraform Apply
        if: github.event_name == 'workflow_dispatch'
        id: apply
        run: terraform apply -auto-approve

      - name: Public IP Output
        run: |
          echo "Public IP: $(terraform output instance_public_ip | tr -d '""')"
```
---

🚀 **Outcome:**
EC2 instance was launched successfully with version-controlled AMIs.

<div style="text-align: center;">
  <img src="/images/mvp/ec2.png" alt="EC2 Deployed" />
</div>

---

### Step 3: Securely Connecting to EC2 with AWS Systems Manager (SSM)

Since we aimed for a secure infrastructure, I configured AWS SSM for remote access, eliminating the need for SSH access.

**Steps Taken:**

**1. Created an IAM Instance Profile:**

- Attached AmazonSSMManagedInstanceCore policy to grant SSM access.
- Updated Terraform code to associate the IAM profile with the EC2 instance.

**2. Connected to the Instance Using SSM:**

- Used AWS Console Session Manager to establish a shell session.
- Ensured no additional inbound SSH ports were required.

---

🚀 **Outcome:**
Secure, agent-based access to the instance without SSH, enhancing security.

<div style="text-align: center;">
  <img src="/images/mvp/ami.png" alt="AMI Created" />
</div>

---

<div style="text-align: center;">
  <img src="/images/mvp/githubami.png" alt="GitHub AMI Build Workflow Results" />
</div>

---

### Step 4: Configuring the AMI using Bash Scripting

To ensure a fully automated deployment process, I developed a Bash script (setup.sh) that pre-installs critical web application components directly into the AMI. This eliminates the need for post-launch manual configurations, streamlining the deployment of EC2 instances.

**Key Components of the Setup:**

- **Django Framework:** Serves as the backbone of the application.
- **Gunicorn:** Handles WSGI requests efficiently for the Django application.
- **Nginx:** Acts as a reverse proxy to route requests to Gunicorn.
- **PostgreSQL:** Provides a robust relational database backend.
- **Python Virtual Environment:** Isolates dependencies and maintains a clean environment for the application.

**The script automates:**

- Installing essential dependencies (Nginx, Gunicorn, PostgreSQL, and Python packages).
- Setting up a Python virtual environment and installing application dependencies from requirements.txt.
- Configuring Gunicorn as a systemd service to ensure application persistence.
- Deploying an Nginx configuration that proxies traffic to the Gunicorn service.
- Enabling firewall rules to allow HTTP traffic and secure database access.

---

🚀 **Outcome:** 
The new AMI was now fully configured out-of-the-box, reducing setup time for future deployments.

---

### Final Test: Accessing the Application

With everything set up, I deployed the final AMI version and verified the application.

✅ Application is successfully running at **http://INSTANCE_PUBLIC_IP** 🎉

<div style="text-align: center;">
  <img src="/images/mvp/finaltest.png" alt="Final Application Test Results" />
</div>

---

### Key Takeaways:

- **IAM Permissions:** Setting up correct IAM policies is crucial for Packer, Terraform, and SSM.
- **GitHub Actions for CI/CD:** Automating builds and deployments speeds up iteration.
- **Immutable Infrastructure:** Packer AMIs ensure consistent environments from development to production.
- **Version Pin Everything:** Explicit versioning of AMIs and dependencies prevents “works on my machine” issues.
- **Security First:** Using SSM instead of SSH eliminates attack vectors and enhances access management.
- **Automate Early:** Manual processes tend to become bottlenecks; automating early ensures long-term scalability.

---

### Conclusion

This pipeline transformed my deployment process from manual, error-prone steps to a fully automated workflow. By combining Packer’s immutable AMIs, Terraform’s infrastructure as code, and SSM’s secure access, I now deploy production-ready environments in minutes — not hours.

---

### Relevant links

- [Installing Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/install-packer)
- [Packer Template Documentation](https://developer.hashicorp.com/packer/docs/templates)
- [Mutable vs Immutable Infrastructure](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure)