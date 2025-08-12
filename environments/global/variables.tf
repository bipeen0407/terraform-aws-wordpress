
# Lambda@Edge IAM role & ZIP path
variable "lambda_edge_execution_arn" {
  description = "IAM Role ARN for Lambda@Edge function"
  type        = string
}

variable "lambda_zip_file_path" {
  description = "Path to Lambda@Edge deployment ZIP file"
  type        = string
}


variable "environment" {
  description = "Global environment label"
  type        = string
  default     = "global"
}

