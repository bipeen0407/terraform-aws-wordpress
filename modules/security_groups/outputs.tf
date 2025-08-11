output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  description = "Security Group ID for EC2 instances"
  value       = aws_security_group.ec2_sg.id
}

output "aurora_sg_id" {
  description = "Security Group ID for Aurora DB"
  value       = aws_security_group.aurora_sg.id
}

output "elasticache_sg_id" {
  description = "Security Group ID for ElastiCache"
  value       = aws_security_group.elasticache_sg.id
}

output "efs_sg_id" {
  description = "Security Group ID for EFS"
  value       = aws_security_group.efs_sg.id
}
