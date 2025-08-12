output "lambda_function_arn" {
  description = "Qualified Lambda ARN with version for Lambda@Edge association"
  value       = aws_lambda_function.this.qualified_arn
}
