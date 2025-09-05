# TechNest by Bhavika — DevOps-Powered Blog on AWS

Welcome to the repository powering **TechNest by Bhavika** — a fully automated, secure, and scalable tech blog built using **Hugo**, **GitHub Actions**, **Terraform**, and **AWS**.

🎯 **Goal**: Deploy a production-grade, low-maintenance personal blog with CI/CD, Infrastructure as Code, and security best practices.

---

## Architecture Overview

<img width="1794" height="712" alt="image" src="https://github.com/user-attachments/assets/de5716d5-f18a-4db3-971a-d352b33291ab" />


- GitHub Actions Workflow triggers on code push.
- Three jobs: `infra_job`, `build_job`, `deploy_job`.
- Uses **OIDC** for secure IAM role assumptions (GitHub & Terraform Cloud).
- AWS Infra: S3 (static site), CloudFront (CDN), ACM (SSL).
- Origin Access Control (OAC) restricts S3 access to CloudFront only.

---

## Features

- Static site generation with Hugo  
- Full CI/CD using GitHub Actions  
- Infrastructure-as-Code using Terraform + HCP backend  
- AWS S3 + CloudFront + ACM with OIDC-secured IAM role assumptions  
- SSL-enabled custom domain: [technestbybhavika.com](https://technestbybhavika.com)  
- Secure IAM roles — no long-lived credentials  
- Modular, reusable Terraform code  

---

## Tech Stack

| Category        | Tools & Services                                 |
|----------------|--------------------------------------------------|
| Static Site     | Hugo                                             |
| CI/CD           | GitHub Actions                                   |
| Infrastructure  | Terraform + Terraform Cloud                      |
| Cloud Services  | AWS (S3, CloudFront, ACM, IAM, OIDC)             |
| Auth            | OpenID Connect (OIDC) with GitHub + Terraform    |
| Domain & SSL    | Route 53 + AWS ACM                               |

---

## Getting Started

### ✅ Prerequisites
- [Git](https://git-scm.com/)
- [Hugo (extended version)](https://gohugo.io/)
- [Terraform CLI](https://developer.hashicorp.com/terraform)

### Local Development

```bash
git clone https://github.com/bhavikam28/tech-blog.git
cd tech-blog
hugo server -D
```

Visit: http://localhost:1313

## Configuration

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

