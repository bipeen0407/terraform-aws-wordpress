# Subnet group for ElastiCache across your private subnets
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for ElastiCache Redis cluster"
}

# Create ElastiCache Redis cluster (Replication Group mode for HA and Multi-AZ)
resource "aws_elasticache_replication_group" "redis" {
  description = "Redis Replication Group for ${var.environment}"
  replication_group_id          = "${var.environment}-redis"
  node_type                     = var.node_type
  automatic_failover_enabled    = true
  security_group_ids            = [var.elasticache_security_group]
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  engine                        = "redis"
  engine_version                = "7.0"
  multi_az_enabled              = true

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-redis"
  }
}
