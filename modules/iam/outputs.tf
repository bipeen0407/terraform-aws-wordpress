output "wordpress_instance_profile_name" {
  value = aws_iam_instance_profile.wordpress_instance_profile.name
}

output "lambda_edge_execution_role_arn" {
  value = aws_iam_role.lambda_edge_execution.arn
}

output "lambda_edge_execution_role_name" {
  value = aws_iam_role.lambda_edge_execution.name
}
