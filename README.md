# TechNest by Bhavika — Automated DevOps Blog on AWS

This repository powers [technestbybhavika.com](https://technestbybhavika.com), a fully automated, secure, and scalable tech blog built using Hugo, GitHub Actions, Terraform, and AWS services.

The goal was to build a production-grade, low-maintenance blog platform that incorporates Infrastructure-as-Code (IaC), CI/CD pipelines, and best practices for cloud security and performance.

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Build & Deploy](#build--deploy)
- [Blog Posts](#blog-posts)
- [About This Project](#about-this-project)
- [Contributing](#contributing)
- [License](#license)

---

## Architecture Overview

![Tech Blog DevOps Pipeline](./956d0f15-3513-4c6b-92bc-8c516a7fd798.png)

This architecture implements the following:

- Static blog content is built using Hugo.
- GitHub Actions triggers three CI/CD jobs: `infra_job`, `build_job`, and `deploy_job`.
- Terraform provisions AWS infrastructure using remote backend (HCP).
- GitHub and Terraform authenticate with AWS using OpenID Connect (OIDC) without long-lived credentials.
- Content is hosted on S3 and served securely via CloudFront with Origin Access Control (OAC).

---

## Features

- Static site generation using Hugo
- CI/CD pipeline with GitHub Actions
- Infrastructure provisioning via Terraform
- Secure, credential-less OIDC-based authentication
- Global content delivery using AWS CloudFront
- HTTPS with ACM SSL certificate
- Cache invalidation after every deployment
- Modular and scalable file structure

---

## Tech Stack

**Static Site Generator**  
- Hugo

**Infrastructure as Code (IaC)**  
- Terraform (with HCP as backend)

**CI/CD Automation**  
- GitHub Actions

**AWS Services**  
- S3 (static hosting)  
- CloudFront (CDN)  
- IAM (with OIDC role assumption)  
- ACM (SSL/TLS)  
- Route 53 (custom domain)

---

## Getting Started

### Prerequisites
- Git
- Hugo (extended version)
- Terraform

### Local Development
```bash
git clone https://github.com/bhavikam28/tech-blog.git
cd tech-blog
hugo server -D

Visit: http://localhost:1313

Configuration

Edit hugo.toml:

Set baseURL to your domain

Update author name, social links, and profile image

Build & Deploy

Deployment is fully automated via GitHub Actions.

GitHub Workflow Overview

infra_job: Provisions infrastructure (S3, CloudFront, IAM roles, ACM)

build_job: Builds the static blog site with Hugo

deploy_job: Uploads files to S3 and invalidates CloudFront cache

OIDC is used for secure role assumption without hardcoded secrets.

More details in the full write-up
.

Blog Posts

Published directly via this platform:

AWS Managed Services: Real-World DevOps Use Cases

Auto-Scaling MVP Architecture on AWS

Secure VPC and Networking Setup on AWS

About This Project

This project was created as part of my portfolio during the Cloud Talents AWS DevOps Bootcamp. It reflects practical cloud and DevOps experience including secure IAM practices, GitOps workflows, and scalable infrastructure design.

Live site: technestbybhavika.com

Related article: Medium Blog Post

Contributing

Open to feedback and collaboration. Please create an issue or pull request if you'd like to contribute.

License

This repository is licensed under the MIT License. See the LICENSE file for details.
