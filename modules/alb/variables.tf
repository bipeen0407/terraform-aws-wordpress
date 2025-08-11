# VPC ID for ALB
variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created"
  type        = string
}

# Public subnet IDs for ALB placement
variable "public_subnet_ids" {
  description = "The public subnet IDs in different AZs where the ALB will live"
  type        = list(string)
}

# Security group ID(s) to attach to ALB
variable "alb_security_groups" {
  description = "List of Security Group IDs to associate with the ALB"
  type        = list(string)
}

# ALB name prefix
variable "alb_name" {
  description = "Name prefix for the ALB"
  type        = string
}

# Environment tag (e.g., irl-dev, sgp-dev)
variable "environment" {
  description = "Environment/region label"
  type        = string
}

# TODO: Keep it empty for initial setup, later we can request for ACM cert and make it https
variable "certificate_arn" {
  description = "ACM certificate ARN for enabling HTTPS listener"
  type        = string
  default     = ""
}
