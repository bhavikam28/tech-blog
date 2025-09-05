# 🚀 TechNest by Bhavika — Automated DevOps Blog on AWS

Welcome to the repository powering [**TechNest by Bhavika**](https://technestbybhavika.com) — a fully automated, scalable, and secure personal tech blog built with **Hugo**, **GitHub Actions**, **Terraform**, and **AWS**.

> 🎯 **Goal**: Build a production-grade, secure, cost-effective, and CI/CD-enabled tech blog powered by Infrastructure-as-Code and GitOps workflows.

---

## 🗂️ Table of Contents
- [📸 Architecture Overview](#-architecture-overview)
- [⚙️ Features](#️-features)
- [🚀 Tech Stack](#-tech-stack)
- [🛠️ Getting Started](#️-getting-started)
- [📦 Build & Deploy](#-build--deploy)
- [✍️ Blog Posts](#-blog-posts)
- [📚 About This Project](#-about-this-project)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)

---

## 📸 Architecture Overview

<img width="1536" height="596" alt="image" src="https://github.com/user-attachments/assets/98bbfcef-ae9f-4ee7-b6c8-02e2729272de" />


This architecture supports a secure and automated blog deployment pipeline:

- **S3**: Hosts the static Hugo site
- **CloudFront**: Distributes content globally with low latency
- **OIDC Integration**: Ensures secure credential-less access between GitHub, Terraform Cloud, and AWS
- **GitHub Actions**: Runs CI/CD jobs for provisioning, building, and deploying

---

## ⚙️ Features

✅ Hugo-based static site generation  
✅ AWS S3 + CloudFront setup with secure OAC  
✅ Infrastructure-as-Code with Terraform  
✅ CI/CD with GitHub Actions workflows  
✅ CloudFront cache invalidation on deploy  
✅ OIDC-based secretless authentication  
✅ SSL via AWS ACM  
✅ GitOps-enabled automation  
✅ Easy to manage and extend

---

## 🚀 Tech Stack

- **Frontend**: [Hugo](https://gohugo.io/) — Fast static site generator
- **CI/CD**: [GitHub Actions](https://docs.github.com/en/actions)
- **IaC**: [Terraform](https://www.terraform.io/) + HCP (Terraform Cloud)
- **Cloud Services**: AWS S3, CloudFront, ACM, IAM, OIDC
- **Auth**: OIDC between GitHub & AWS, Terraform & AWS

---

## 🛠️ Getting Started

### 📥 Prerequisites
- [Git](https://git-scm.com/)
- [Hugo (extended)](https://gohugo.io/getting-started/installing/)
- [Terraform](https://www.terraform.io/downloads)

### 🧪 Local Development
```bash
git clone https://github.com/bhavikam28/tech-blog.git
cd tech-blog
hugo server -D
Visit: http://localhost:1313

⚙️ Configuration
Update hugo.toml:

baseURL = "https://technestbybhavika.com"

Add your LinkedIn, GitHub, name, and profile photo links

📦 Build & Deploy
Deployment is automated using GitHub Actions + OIDC roles.

🛠️ GitHub Actions Workflow
infra_job: Provisions AWS (S3, CloudFront, IAM, ACM)

build_job: Builds Hugo site and stores artifacts

deploy_job: Deploys to S3, invalidates CloudFront cache

OIDC ensures secure, short-lived credentials — no secrets or access keys required!

📖 Read the full blog post on how this pipeline works

✍️ Blog Posts
These posts were written and published from this site:

📘 AWS Managed Services: Real-World DevOps Use Cases

🚀 Auto-Scaling MVP Architecture on AWS

🌐 Building Secure VPC and Networking Setup on AWS

📚 About This Project
This project was built as part of my AWS DevOps portfolio in the Cloud Talents Bootcamp.

🔗 Visit the live blog
✍️ Also published on Medium

🤝 Contributing
Feel free to fork this repo, raise an issue, or submit a pull request. Suggestions are always welcome!

📜 License
MIT © Bhavika Mantri — Open-source, feel free to reuse with credit.
