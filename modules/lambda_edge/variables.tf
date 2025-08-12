variable "function_name" {
  description = "The name of the Lambda@Edge function"
  type        = string
}

variable "handler" {
  description = "Function handler (entry point)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "role_arn" {
  description = "IAM Role ARN that Lambda will assume"
  type        = string
}

variable "lambda_zip_file_path" {
  description = "Path to the deployment package ZIP file for Lambda function"
  type        = string
}

variable "environment" {
  description = "Logical environment/region name (for tagging)"
  type        = string
}
