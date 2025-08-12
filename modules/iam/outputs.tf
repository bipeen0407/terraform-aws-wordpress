output "role_arn" {
  description = "IAM Role ARN for Lambda@Edge execution"
  value       = aws_iam_role.lambda_edge_execution.arn
}

output "wordpress_instance_profile_name" {
  description = "Name of the IAM instance profile for WordPress EC2 instances"
  value       = aws_iam_instance_profile.wordpress_instance_profile.name

}
