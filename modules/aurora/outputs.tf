output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.this.id
}

output "aurora_writer_endpoint" {
  description = "Aurora cluster writer (endpoint for writes)"
  value       = aws_rds_cluster.this.endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint (for read-only workload)"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "global_cluster_id" {
  description = "Global cluster ID (used for cross-region Aurora global DB setup)"
  value       = var.enable_global_cluster && var.global_cluster_id == "" ? aws_rds_global_cluster.this[0].id : var.global_cluster_id
}

output "db_secret_arn" {
  value       = data.aws_secretsmanager_secret.db_master_password_secret.arn
  description = "The ARN of the Secrets Manager secret for the DB master user password."
}

output "db_name" {
  value       = var.db_name
  description = "The name of the database created in the Aurora cluster."
}

output "db_master_username" {
  value       = var.db_master_username
  description = "The master username for the Aurora cluster."
}

