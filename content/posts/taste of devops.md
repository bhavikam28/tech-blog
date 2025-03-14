---
title: 'A Taste of DevOps: Automating My Tech Blog with Terraform, GitHub Actions, and AWS'
date: 2025-03-14
author: "Bhavika Mantri"
draft: false
tags: ["AWS", "AWS Security", "DevOps", "GitHub Actions", "Terraform"]
categories: ["DevOps"]
description: "Learn how I built a fully automated, secure, and scalable tech blog using Terraform, GitHub Actions, and AWS."
---


---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/techblog.png" alt="Automated Workflow" />
  <p><em>A visual representation of the automated workflow using Terraform, GitHub Actions, and AWS.</em></p>
</div>

---

Building a tech blog is more than just writing content — it’s about creating a platform that’s secure, scalable, and easy to maintain. When I started this project, I wanted to build something that could grow with me without requiring constant manual updates. In this post, I’ll walk you through my journey of building a fully automated tech blog using DevOps tools like GitHub Actions, Terraform, and AWS, complete with all the hiccups, “aha!” moments, and lessons learned along the way. Whether you’re a beginner or an experienced developer, this guide will help you create a robust blogging platform that’s both efficient and secure.

---

### Step 1: Serving a Static Website on AWS with CloudFront and S3

**Why AWS S3 and CloudFront?**

To host my blog, I used AWS S3 for storage and Amazon CloudFront as a Content Delivery Network (CDN). This combination ensures that my blog is:

- **Scalable**: Easily handle traffic spikes.
- **Cost-Effective**: Pay only for the storage and bandwidth you use.
- **Fast Content Delivery**: Serve content quickly to users worldwide.

---

To enhance security, I implemented **Origin Access Control (OAC)** for the S3 bucket. OAC ensures that the S3 bucket can only be accessed via the CloudFront distribution, preventing direct access to the S3 bucket. This setup:

- **Secures Content**: Protects your data from unauthorized access.
- **Improves Performance**: Leverages CloudFront’s global edge network for faster delivery.

---

### Step 2: Automating the Workflow with GitHub Actions

The GitHub Actions workflow is triggered whenever I push code to GitHub. It consists of three key jobs:

1. **Provision AWS Infrastructure (Infra_job)**:
   - This job uses **Terraform** to provision the AWS infrastructure, including the S3 bucket and CloudFront distribution. It leverages **HashiCorp Cloud Platform (HCP)** as the remote backend for Terraform, ensuring secure state management and collaboration.
   - **OIDC Integration Between Terraform Cloud and AWS**: To securely authenticate with AWS, I set up OIDC integration between Terraform Cloud and AWS. This allows Terraform to assume an IAM role without hardcoding credentials, enhancing security. I created a dedicated IAM role for Terraform with the necessary permissions to provision and manage AWS resources.

   ---

2. **Build the Blog with Hugo (build_job)**:
   - This job installs Hugo, builds the static site, and uploads the generated files as build artifacts.
   > **Why Hugo?**: I chose Hugo, a fast and flexible static site generator, because it made it easy to build a high-performance blog that integrates seamlessly with my automated deployment pipeline.

   ---

3. **Deploy the Blog to S3 and Invalidate CloudFront Cache (deploy_job)**:
   - This job syncs the built artifacts to the S3 bucket and invalidates the CloudFront cache to ensure visitors see the latest content.
   - **OIDC Integration Between GitHub and AWS**: For GitHub Actions, I configured OIDC integration with AWS to allow GitHub workflows to securely assume an IAM role. This role has permissions limited to syncing files to S3 and invalidating the CloudFront cache. By using OIDC, I eliminated the need for hardcoded credentials, making the setup more secure and scalable.

---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/oidc.png" alt="OIDC Integrations" />
  <p><em>OIDC Integrations</em></p>
</div>

---

   > Think of OIDC as a secure handshake between GitHub and AWS, allowing GitHub Actions to temporarily access your AWS resources without storing permanent credentials.

---

### Step 3: Managing Infrastructure with Terraform

**Organizing Terraform Code**

To manage my infrastructure code effectively, I organized it into multiple `.tf` files, each serving a specific purpose. Here’s how I structured the files:

---
<div style="text-align: center;">
  <img src="/images/tasteofdevops/terraformfilestructure.png" alt="Terraform File Structure" />
  <p><em>Terraform File Structure</em></p>
</div>

---

> **Why Terraform?** Terraform enables **Infrastructure as Code (IaC)**, automating the provisioning of AWS resources like S3, CloudFront, and ACM. It ensures consistency, scalability, and collaboration while reducing manual effort and errors.

---

### Step 4: Enhancing Security and Performance

1. **Securing the Blog with AWS ACM**:
   - I used AWS Certificate Manager (ACM) to provision an SSL/TLS certificate for my custom domain. This enabled HTTPS, encrypting all traffic between users and the blog.

   ---

2. **Restricting Access with IAM Policies**:
   - I implemented fine-grained IAM policies for both GitHub Actions and Terraform. These policies ensure that:
     - GitHub Actions can only sync files to S3 and invalidate the CloudFront cache.
     - Terraform has the minimum permissions required to provision and manage AWS resources.
   - By using Role-Based Access Control (RBAC) and OIDC integration, I eliminated the need for hardcoded credentials, reducing the risk of accidental exposure or misuse.

---

### Step 5: Environment Variables and Secrets

To ensure a secure and seamless integration between Terraform, GitHub Actions, and AWS, I configured several environment variables and secrets.

---

**Why These Variables and Secrets Matter**

- **Security**: Sensitive information like IAM role ARNs and API tokens are stored as secrets, ensuring they are never exposed in plaintext.
- **Flexibility**: Environment variables like `AWS_REGION` allow for easy configuration changes without modifying code.
- **Automation**: By using OIDC and role assumptions, I eliminated the need for hardcoded credentials, making the setup more secure and scalable.

---

1. **Terraform Workspace Variables**
In the Terraform Cloud workspace, I set the following environment variables to manage authentication, region, and role assumptions:

---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/terraformvariables.png" alt="Terraform Workspace Variables: Description" />
  <p><em>Terraform Workspace Variables: Description</em></p>
</div>

---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/terraformvalues.png" alt="Terraform Workspace Variables" />
  <p><em>Terraform Workspace Variables</em></p>
</div>

---

2. **GitHub Repository Secrets**
In the GitHub repository, I stored the following secrets to securely authenticate and interact with AWS and Terraform Cloud:

---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/githubsecrets.png" alt="GitHub Repository Secrets: Description" />
  <p><em>GitHub Repository Secrets: Description</em></p>
</div>

---

<div style="text-align: center;">
  <img src="/images/tasteofdevops/githubvalues.png" alt="GitHub Repository Secrets" />
  <p><em>GitHub Repository Secrets</em></p>
</div>

---

---

> **Successful completion of the GitHub workflow will create the following resources on the HCP Terraform**

---

![alt text](/images/tasteofdevops/terraformrun.png)

---

> **The workflow summary below shows the successful completion of all jobs under ‘Actions’ in GitHub:**

---

![alt text](/images/tasteofdevops/githubrun.png)

---

### Challenges and Lessons Learned

While the combination of Terraform, GitHub Actions, and AWS made the process more manageable, I encountered several challenges along the way. Here are the key lessons I learned:

1. **Terraform File Size Exceeding GitHub Limits**:
   - When pushing the Terraform code to GitHub, I encountered an error due to the size of the `.terraform` directory, specifically the provider binaries. The error message looked like this:

     ```
     remote: error: File .terraform/providers/registry.terraform.io/hashicorp/aws/4.52.0/windows_amd64/terraform-provider-aws_v4.52.0_x5.exe is 326.16 MB; this exceeds GitHub's file size limit of 100.00 MB
     ```
   ---
    *Terraform file size limits? Yeah, GitHub wasn’t too happy about that one — and neither was I!*
    ---
   
   - **Solution**:

     ```bash
     git filter-branch -f --index-filter 'git rm --cached -r --ignore-unmatch .terraform/'
     git push --force
     ```
   
   > **Pro Tip**: Add `.terraform/` to your `.gitignore` file to avoid this issue in the future. This ensures that the .terraform directory (which contains provider binaries and other local state files) is never tracked by Git.

---

2. **Incorrect OIDC Setup**:
   - When setting up OIDC integration between GitHub and AWS, I initially configured the wrong thumbprint for the GitHub OIDC provider. This caused authentication failures, and GitHub Actions couldn’t assume the IAM role. The issue was resolved after double-checking the thumbprint and reconfiguring the OIDC provider.

---

3. **Terraform AWS Role ARN Issue**:
   - While setting up OIDC integration between AWS and Terraform Cloud, I encountered an error when running `terraform plan`. After some troubleshooting, I realized that the correct environment variable for the IAM Role ARN is `TFC_AWS_RUN_ROLE_ARN`, not `AWS_ROLE_ARN`. This small but critical detail resolved the issue.

---

4. **Incorrect IAM Policy Permissions**:
   - I initially created an IAM policy that was too restrictive, which caused the GitHub Actions workflow to fail when trying to sync files to S3. After reviewing the AWS error logs, I updated the policy to include the necessary permissions and the workflow ran successfully.

---

### Conclusion

Building a secure, automated tech blog using Hugo, GitHub Actions, Terraform, and AWS has been an incredibly rewarding journey. From streamlining deployments with Terraform to ensuring robust security with OIDC and IAM policies, this project taught me the power of combining the right tools to create a scalable and efficient platform.

If you’re looking to build a similar setup, I hope this guide has provided you with valuable insights and practical solutions to common challenges. Whether you’re a beginner or an experienced developer, the combination of these tools can help you create a blog that’s not only secure and performant but also easy to maintain.

---

### Relevant Links

Here are some useful links to help you better understand the tools and concepts discussed in this blog:

- **GitHub Actions**:
  - [Understanding GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)
  - [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
  - [Setup-Terraform Action](https://github.com/hashicorp/setup-terraform)

- **AWS and IAM**:
  - [IAM Identity Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html)
  - [OpenID Connect (OIDC) with AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

- **Terraform**:
  - [Terraform Documentation](https://www.terraform.io/docs)
  - [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)