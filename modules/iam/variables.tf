variable "environment" {
  description = "Deployment environment name (e.g., irl-dev, sgp-dev)"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for Aurora master password"
  type        = string
}
