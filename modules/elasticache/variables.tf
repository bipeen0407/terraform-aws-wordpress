# VPC ID where ElastiCache will be deployed
variable "vpc_id" {
  description = "VPC ID for ElastiCache subnet group"
  type        = string
}

# List of subnet IDs (private subnets across AZs)
variable "private_subnet_ids" {
  description = "Private subnet IDs for ElastiCache subnet group"
  type        = list(string)
}

# Security group ID for ElastiCache
variable "elasticache_security_group" {
  description = "Security Group ID for ElastiCache cluster"
  type        = string
}

# Redis node types
variable "node_type" {
  description = "ElastiCache Redis node type (e.g., cache.t4g.small, cache.m6g.large)"
  type        = string
}

# Environment tag
variable "environment" {
  description = "Environment/region label"
  type        = string
}
