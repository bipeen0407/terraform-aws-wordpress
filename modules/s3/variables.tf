# Name for this S3 bucket
variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

# Environment label (e.g., irl-dev, sgp-dev)
variable "environment" {
  description = "Environment identifier"
  type        = string
}

# Enable versioning on this bucket
variable "enable_versioning" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = true
}

# Destination bucket ARN for CRR (cross-region replication)
variable "replication_bucket_arn" {
  description = "Destination bucket ARN for Cross-Region Replication"
  type        = string
  default     = ""
}

# IAM role ARN for S3 replication (in destination region)
variable "replication_role_arn" {
  description = "IAM role ARN to be used for S3 replication"
  type        = string
  default     = ""
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that will access the bucket"
  type        = string
}
