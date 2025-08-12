output "role_arn" {
  description = "IAM Role ARN for Lambda@Edge execution"
  value       = aws_iam_role.lambda_edge_execution.arn
}
