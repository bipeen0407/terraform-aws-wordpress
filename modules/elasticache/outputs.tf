output "redis_primary_endpoint" {
  description = "Primary endpoint for connecting to Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_replication_group_id" {
  description = "Replication Group ID"
  value       = aws_elasticache_replication_group.redis.id
}
