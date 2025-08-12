# VPC ID where EFS will be created
variable "vpc_id" {
  description = "VPC ID where the EFS file system and mount targets will be created"
  type        = string
}

# List of subnet IDs (one per AZ) for EFS mount targets
variable "private_subnet_ids" {
  description = "Private subnet IDs across AZs for EFS mount targets"
  type        = list(string)
}

# Security group IDs for EFS (usually NFS traffic allowed from EC2 SGs)
variable "efs_security_groups" {
  description = "List of Security Group IDs to attach to EFS mount targets"
  type        = list(string)
}

# Environment label
variable "environment" {
  description = "Environment/region tag for identification"
  type        = string
}
