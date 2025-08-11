# VPC ID where security groups will be created
variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

# List of public subnet CIDRs (for ALB inbound rules from Internet)
variable "cloudfront_ipv4_cidrs" {
  description = "List of cloudfront_ipv4_cidrs CIDR blocks"
  type        = list(string)
  default     = []
}

# List of private subnet CIDRs (for intra-VPC rules if needed)
variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

# Environment label for tagging purposes
variable "environment" {
  description = "Environment or region label"
  type        = string
}
