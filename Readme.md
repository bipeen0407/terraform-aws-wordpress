
# Terraform Multi-Region AWS WordPress Deployment

## Overview

This Terraform repository provisions a **multi-region WordPress deployment on AWS** with high availability, low latency, and scalable infrastructure. The architecture spans two regions (Ireland and Singapore) with active-active deployments, global CDN, and cross-region replication for disaster recovery.

## Repository Structure

- `modules/` — Reusable Terraform modules to provision individual services:
  - VPC, NAT Gateway, Security Groups
  - ALB, EC2 Auto Scaling Group
  - EFS, ElastiCache, Aurora Database
  - S3 bucket with cross-region replication
  - CloudFront CDN with Lambda@Edge
  - (Optional) WAF for web protection

- `envs/irl-dev/` — Terraform configuration for Ireland region environment
- `envs/sgp-dev/` — Terraform configuration for Singapore region environment
- `envs/global/` — Terraform configuration for global CloudFront distribution, Lambda@Edge, and (optional) WAF

## Key Features

- Active-active multi-region deployment across Ireland and Singapore
- Geo-routing traffic with CloudFront and Lambda@Edge (30% Ireland, 60% Singapore, 10% global)
- Scalable compute via EC2 Auto Scaling Groups
- High availability with Multi-AZ Aurora and cross-region replication
- Centralized security management with reusable Security Groups module
- Automated S3 Cross-Region Replication (CRR) for static assets
- Infrastructure managed with modular and reusable Terraform code

## Prerequisites

- Terraform
- AWS CLI configured with appropriate permissions
- IAM roles for Lambda@Edge in `us-east-1`
- An S3 bucket for Terraform remote state (recommended) with DynamoDB locking (recommended)
- ACM certificates for ALB HTTPS (optional but recommended)

## Deployment Steps

1. **Configure Variables**:
   Each environment folder has variables files; update `terraform.tfvars` in `envs/irl-dev` and `envs/sgp-dev` with region-specific values (VPC CIDR, AMI IDs, subnet CIDRs, passwords, etc.).

2. **Deploy Regional Environments**:
   Navigate into each environment folder and run:
   ```bash
   terraform init
   terraform apply
   ```
   This deploys the region-specific infrastructure and outputs ALB DNS, S3 bucket info, etc.

3. **Prepare Global Environment Variables**:
   Use outputs from regional deployments to fill `envs/global/terraform.tfvars` (for ALB DNS names, S3 domains, Lambda role, etc.).

4. **Deploy Global Stack**:
   Run in the global folder:
   ```bash
   terraform init
   terraform apply -var-file="terraform.tfvars"
   ```
   This provisions CloudFront, Lambda@Edge geo-routing, and WAF if enabled.

## Helpful Commands

- Validate Terraform configuration:
  ```bash
  terraform validate
  ```
- Format Terraform files:
  ```bash
  terraform fmt
  ```
- Generate and review a plan:
  ```bash
  terraform plan
  ```