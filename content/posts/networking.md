---
title: 'From Isolation to Connectivity: AWS VPC & RAM Resource Sharing'
date: 2025-03-28
author: "Bhavika Mantri"
draft: false
tags: ["AWS", "AWS Security", "DevOps", "AWS VPC", "AWS RAM"]
categories: ["DevOps"]
description: "How to build secure, interconnected AWS accounts with VPC segmentation and RAM resource sharing."

---

<div style="text-align: center;">
  <img src="/images/networking/ram.png" alt="RAM" />
</div>

---

In the ever-evolving world of cloud computing, networking isn’t just a technical detail — it’s the foundation that ensures security, scalability, and efficiency. As organizations increasingly adopt multi-account strategies on AWS to manage their workloads, they face a trio of critical challenges:

- **Secure Isolation**: Protecting sensitive workloads from external threats while maintaining operational integrity.
- **Controlled Sharing**: Enabling seamless collaboration across teams and accounts without compromising security.
- **Operational Efficiency**: Streamlining resource management across multiple accounts to reduce complexity and costs.

These challenges aren’t just theoretical — they’re real hurdles that can make or break a cloud deployment. A well-designed network architecture can mean the difference between a secure, scalable environment and one plagued by vulnerabilities or inefficiencies. This guide dives into how I tackled these issues by implementing AWS Virtual Private Cloud (VPC) and Resource Access Manager (RAM), following the **AWS Security Reference Architecture (SRA)** best practices.

Drawing from the AWS SRA, the approach centers on creating a **dedicated Network account** to centralize networking resources, which can then be securely shared with other accounts using RAM. This not only enhances security but also promotes collaboration and cost efficiency. To add more perspective, I’ve incorporated insights from related discussions on networking in AWS, such as the importance of isolating resources in private subnets and the role of automation in deployment workflows. Whether you’re managing a small setup or preparing for a large-scale deployment, this guide provides a blueprint for building a robust AWS network foundation. Let’s get started!

---

### Core Architectural Components:

## 1. Virtual Private Cloud (VPC): Your Cloud Fortress
A VPC acts as a private, isolated network within AWS’s public cloud, offering a secure environment for your resources. Think of it as a private hotel within a bustling city: it has public areas (subnets) for external access and private rooms (subnets) for sensitive operations. A VPC provides:

- Logical isolation of network segments.
- Granular security controls through security groups and network ACLs.
- Flexible IP addressing with CIDR blocks.
- Connectivity options for hybrid cloud setups.

**Implementation**:

---

<div style="text-align: center;">
  <img src="/images/networking/vpc.png" alt="VPC" />
</div>

---

**Key Features**:

- **Multi-AZ Deployment**: Spread across availability zones for high availability.
- **Public and Private Subnets**: Public subnets handle internet-facing resources, while private subnets keep critical workloads isolated.
- **NAT Gateway**: Allows private subnets to access the internet securely without being exposed.

This setup ensures that business-critical applications, like databases or internal APIs, remain inaccessible from the public internet, a key principle for enhancing security in a cloud environment.

---

## 2. Resource Access Manager (RAM): The Secure Sharing Mechanism
RAM is a powerful tool for sharing resources across AWS accounts without duplicating them. It’s like a secure channel between departments in an organization, allowing controlled access to shared resources. RAM offers:

- Elimination of resource duplication.
- Centralized control over shared resources.
- Seamless cross-account collaboration.
- No additional cost — sharing is free!

---

<div style="text-align: center;">
  <img src="/images/networking/awsram.png" alt="AWS RAM" />
</div>

---

The configuration shares the VPC subnets with the “Sandbox” OU, ensuring that accounts within this OU (like a Development account) can access the network resources securely.

---

### Step-by-Step Implementation:

## Phase 1: Establishing the Network Foundation
The AWS SRA emphasizes the importance of a dedicated Network account to centralize networking resources across an organization. This approach simplifies management, whether you’re handling a handful of accounts or hundreds. Here’s how I set it up:

1. **Created an “Infrastructure” OU**: 
Using AWS Control Tower, I placed this Organizational Unit (OU) under the Root OU to house network-related accounts.

2. **Provisioned Network account**: 
Create an AWS account named Network from the account factory.

---

<div style="text-align: center;">
  <img src="/images/networking/organizations.png" alt="AWS Organizations" />
</div>

---

3. **Disabled Auto-VPC Creation**: 
Modified Account Factory settings to prevent default VPCs from being created in all regions, keeping the environment clean.

---

<div style="text-align: center;">
  <img src="/images/networking/accountfactory.png" alt="Account Factory" />
</div>

---

4. **Verified Access**: 
Ensured I could access the Network account through the AWS Access Portal.


5. **Optimized Costs**: 
I ran a CloudShell script in the Management account to reduce AWS Config expenses, which was a small but impactful step for cost efficiency.

---

## Phase 2: Building the VPC with Terraform
A VPC is essential for running services like EC2 or RDS, so I built one from scratch with the following components:

- **2 Public Subnets**: For resources that need internet access, like load balancers.
- **2 Private Subnets**: For internal workloads, such as databases, that should remain isolated.
- **1 Internet Gateway**: The entry point for internet traffic.
- **4 Route Tables**: To direct traffic between subnets and the internet gateway.

The Terraform code deployed this VPC in us-east-1. I stored the code in a GitHub repository to track changes — version control is a lifesaver for managing infrastructure as code!

---

## Phase 3: Automating with GitHub Actions
Automation is key to maintaining consistency and reducing human error in deployments. I set up a CI/CD pipeline using GitHub Actions to deploy the VPC:

- **Trigger**: Pushes to the main branch or pull requests.
- **Steps**: Initialize Terraform, validate the configuration, generate a plan, perform a security scan, automated apply for the changes, and apply those changes.

---

<div style="text-align: center;">
  <img src="/images/networking/githubworkflow.png" alt="GitHub Workflow" />
</div>

---

Here’s the workflow:

**CI/CD Pipeline**:  
```yaml

name: Terraform VPC Deployment

on:
 workflow_dispatch:
permissions:
 contents: read
 id-token: write

jobs:
 terraform:
 name: Deploy VPC to AWS
 runs-on: ubuntu-latest

 steps:
 - name: Checkout Repository
 uses: actions/checkout@v4

- name: Setup Terraform
 uses: hashicorp/setup-terraform@v2

 with:
 terraform_version: "1.10.3"
 cli_config_credentials_token: ${{ secrets.TFC_API_TOKEN }} # API_TOKEN for HCP Terraform

- name: Terraform Init
 run: terraform init

- name: Terraform Plan
 run: terraform plan -input=false

- name: Terraform Apply
 run: terraform apply -auto-approve -input=false

```

To enable secure access, I integrated GitHub Actions with AWS using OpenID Connect (OIDC). This involved setting up an OIDC provider in AWS and creating an IAM role for GitHub Actions to assume, ensuring that deployments are both secure and automated.

---

## Phase 4: Cross-Account Sharing with RAM
The Network account hosts the VPC, but other accounts — like a Development account — need to use it. AWS RAM makes this possible by securely sharing resources across accounts. Here’s how I implemented it:

1. **Enabled Sharing**: In the Management account, activated RAM sharing with AWS Organizations.

---

<div style="text-align: center;">
  <img src="/images/networking/ramsettings.png" alt="RAM Settings" />
</div>

---

2. **Created a Resource Share**: Added a resource share in Terraform to share all VPC subnets with the “Sandbox” OU.

3. **Verified Access**: Logged into the Development account and confirmed the shared VPC subnets were visible under “Shared with Me” in RAM.

---

<div style="text-align: center;">
  <img src="/images/networking/sharedresources.png" alt="Shared Resources" />
</div>

---

4. **Cleaned Up**: Deleted the default aws-controltower-VPC in the Development account to avoid confusion.

---

### Security and Operational Benefits
This implementation delivers several advantages:

- **Enhanced Security**: Private subnets isolate critical resources, while security groups act as virtual firewalls to control traffic. The NAT Gateway ensures outbound-only internet access for private subnets.
- **Cost Efficiency**: Using a single NAT Gateway and sharing resources via RAM eliminates duplication, reducing data transfer costs.
- **Operational Efficiency**: Centralized network management, automated deployments via GitHub Actions, and consistent configurations streamline operations.
- **Scalability and Flexibility**: The VPC’s CIDR block design allows for flexible subnet sizing, and RAM enables easy resource sharing as the organization grows.

---

### Additional Insights
While working on this project, I came across some valuable insights that added depth to my approach. One key takeaway was the analogy of a VPC as a private hotel: public subnets act like a lobby with controlled access to the outside world, while private subnets are like secure rooms for sensitive operations. This perspective helped me better understand the importance of isolating resources and using gateways like the NAT Gateway as controlled access points.

---

### Conclusion
This implementation provides a secure, scalable foundation for AWS networking. By combining a dedicated Network account, Infrastructure as Code with Terraform, automated CI/CD pipelines via GitHub Actions, and secure resource sharing with RAM, I’ve created a setup that balances security, efficiency, and flexibility.

I hope this documentation was helpful, and thank you for reading!

---

### Resources
- [AWS Security Reference Architecture](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/network.html)
- [Amazon Virtual Private Cloud (VPC) Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS RAM User Guide](https://aws.amazon.com/ram/)
- [Terraform AWS Modules](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)