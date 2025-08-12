# ----------------------
# Network settings
# ----------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of Public Subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of Private Subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "List of Availability Zones for this environment"
  type        = list(string)
}

# ----------------------
# Environment Info
# ----------------------

variable "environment" {
  description = "Environment label (e.g., irl-dev, sgp-dev)"
  type        = string
}

# ----------------------
# ALB / SSL
# ----------------------

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS on ALB"
  type        = string
}

# ----------------------
# EC2 / ASG
# ----------------------

variable "ami_id" {
  description = "AMI ID for WordPress EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for WordPress"
  type        = string
}

# ----------------------
# Aurora / RDS
# ----------------------

variable "db_master_username" {
  description = "Master username for the Aurora cluster"
  type        = string
}

variable "db_name" {
  description = "Name of the database created in the Aurora cluster"
  type        = string

}
variable "instance_class" {
  description = "Instance class for the Aurora cluster"
  type        = string

}

# ----------------------
# S3 CRR
# ----------------------

variable "sgp_bucket_arn" {
  description = "Destination bucket ARN in Singapore for cross-region replication"
  type        = string
  default     = ""
}

variable "s3_replication_role_arn" {
  description = "IAM role ARN for S3 cross-region replication"
  type        = string
}

# ----------------------
# Secrets Manager
# ----------------------

variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for Aurora master password"
  type        = string
  default     = "" # default empty in case not deployed yet
}

# ----------------------
# Lambda@Edge
# ----------------------


variable "lambda_handler" {
  description = "Lambda function entry point handler"
  type        = string
  default     = "index.lambda_edge_routing"
}

variable "lambda_runtime" {
  description = "Runtime environment for Lambda@Edge"
  type        = string
  default     = "python3.9"
}


# ----------------------
# CloudFront and WAF
# ----------------------

variable "cloudfront_origins" {
  description = "List of CloudFront origins with domain_name, origin_id, origin_access_control_id, and optional custom_origin_config"
  type = list(object({
    domain_name              = string
    origin_id                = string
    origin_access_control_id = string
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
      origin_ssl_protocols   = list(string)
    }))
  }))
  default = []
}

variable "default_cache_behavior_origin_id" {
  description = "Origin ID for default cache behavior in CloudFront"
  type        = string
  default     = ""
}

variable "lambda_association_event_type" {
  description = "CloudFront event type to trigger Lambda@Edge function"
  type        = string
  default     = "origin-request"
}
