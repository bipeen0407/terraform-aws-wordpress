output "efs_id" {
  description = "The ID of the created EFS file system"
  value       = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  description = "DNS name for EFS mount (used on EC2 instances)"
  value       = aws_efs_file_system.this.dns_name
}

output "mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = aws_efs_mount_target.mt[*].id
}
