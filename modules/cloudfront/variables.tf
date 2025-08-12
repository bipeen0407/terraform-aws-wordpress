variable "origin_domain_name" {
  description = "The domain name of the origin, e.g., your S3 bucket regional domain"
  type        = string
}

variable "lambda_version_arn" {
  description = "The ARN of the published Lambda@Edge function version to associate"
  type        = string
}

variable "lambda_association_event_type" {
  description = "CloudFront event type to trigger Lambda@Edge function (e.g., origin-request)"
  type        = string
  default     = "origin-request"
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the CloudFront distribution"
  type        = string
}

variable "environment" {
  description = "Environment tag for resource tagging"
  type        = string
}
