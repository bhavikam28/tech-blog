# TechNest by Bhavika — DevOps-Powered Blog on AWS

Welcome to the repository powering [TechNest by Bhavika](https://technestbybhavika.com) — a fully automated, secure, and scalable tech blog built using **Hugo**, **GitHub Actions**, **Terraform**, and **AWS**.

> **Goal**: Deploy a production-grade, low-maintenance personal blog with CI/CD, Infrastructure as Code, and security best practices.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Build & Deploy](#build--deploy)
- [Published Blog Posts](#published-blog-posts)
- [About](#about)
- [License](#license)

---

## Architecture Overview

<img width="1536" height="596" alt="image" src="https://github.com/user-attachments/assets/de616713-fb57-48b0-968e-bfdcca170084" />


- **GitHub Actions Workflow** triggers on code push.
- Three jobs: `infra_job`, `build_job`, `deploy_job`.
- Uses **OIDC** for secure IAM role assumptions (GitHub & Terraform Cloud).
- AWS infra includes **S3 (static site)**, **CloudFront (CDN)**, and **ACM (SSL)**.
- **OAC** restricts S3 access to CloudFront only.

---

## Features

- Static site generation with [Hugo](https://gohugo.io/)
- Full CI/CD with GitHub Actions
- Infra-as-Code using Terraform + HCP backend
- AWS S3 + CloudFront + ACM with OIDC-secured role assumptions
- SSL-enabled custom domain: [technestbybhavika.com](https://technestbybhavika.com)
- Clean and secure IAM roles, no long-lived credentials
- Reusable and modular Terraform code structure

---

## Tech Stack

| Category       | Tools & Services                                      |
|----------------|-------------------------------------------------------|
| Static Site    | [Hugo](https://gohugo.io/)                            |
| CI/CD          | GitHub Actions                                        |
| IaC            | Terraform + Terraform Cloud                           |
| Cloud          | AWS (S3, CloudFront, ACM, IAM, OIDC)                  |
| AuthN/AuthZ    | OpenID Connect (OIDC) with GitHub + Terraform         |
| Domain & SSL   | Route 53 + ACM                                        |

---

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/)
- [Hugo Extended](https://gohugo.io/getting-started/installing/)
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)

### Local Development

```bash
git clone https://github.com/bhavikam28/tech-blog.git
cd tech-blog
hugo server -D
```

Visit: http://localhost:1313

## 🔧 Configuration

Visit your site locally at: [http://localhost:1313](http://localhost:1313)

Open the `hugo.toml` file and update the following:

- `baseURL = "https://technestbybhavika.com"`
- Author name
- Social links (LinkedIn, GitHub, Medium, etc.)
- Profile image URL

---

## Build & Deploy

Deployment is fully automated using **GitHub Actions**.

### GitHub Workflow Overview

- **`infra_job`** – Provisions infrastructure (S3, CloudFront, IAM roles, ACM)
- **`build_job`** – Builds the static blog using Hugo
- **`deploy_job`** – Uploads files to S3 and invalidates CloudFront cache

> 🔐 OIDC is used for secure role assumption without hardcoded secrets.

📖 [Read the full write-up on Medium](https://medium.com/@bhavi.28.mantri/a-taste-of-devops-automating-my-tech-blog-with-terraform-github-actions-and-aws-93f46a33662f)

---

## Published Blog Posts

Published directly via this platform:

- [**AWS Managed Services: Real-World DevOps Use Cases**](https://technestbybhavika.com/managedservices/)
- [**Auto-Scaling MVP Architecture on AWS**](https://technestbybhavika.com/mvp/)
- [**VPC Networking Deep Dive**](https://technestbybhavika.com/networking/)

---

## About

This project is part of my portfolio from the **Cloud Talents AWS DevOps Bootcamp**, designed to showcase real-world **IaC**, **CI/CD**, and **AWS security** integrations using **Terraform** and **GitHub Actions**.

- 🔗 **Website**: [technestbybhavika.com](https://technestbybhavika.com)
- ✍️ **Articles**: [medium.com/@bhavi.28.mantri](https://medium.com/@bhavi.28.mantri)

---

## License

**MIT © Bhavika Mantri** — Free to use, fork, and build on.

