# VPC and subnet group for Aurora cluster
variable "vpc_id" {
  description = "ID of the VPC where Aurora will be placed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Aurora subnet group (across multiple AZs)"
  type        = list(string)
}

# DB cluster and instance settings
variable "db_engine" {
  description = "Aurora DB engine (aurora-mysql or aurora-postgresql)"
  type        = string
}

variable "engine_version" {
  description = "Engine version for Aurora"
  type        = string
}

variable "instance_class" {
  description = "Instance class for Aurora nodes (e.g., db.r6g.large)"
  type        = string
}

variable "db_name" {
  description = "Database name for WordPress"
  type        = string
}

variable "db_master_username" {
  description = "Master username for Aurora DB"
  type        = string
}

variable "cluster_identifier" {
  description = "Name/identifier for this Aurora cluster"
  type        = string
}

variable "environment" {
  description = "Environment or region label"
  type        = string
}

# Enable global cluster for cross-region replication
variable "enable_global_cluster" {
  description = "Enable Aurora global cluster for cross-region replication"
  type        = bool
  default     = false
}

# ID of global cluster (used by secondary region)
variable "global_cluster_id" {
  description = "Global cluster ID, set in secondary region for replication"
  type        = string
  default     = ""
}

variable "aurora_security_group" {
  description = ""
  type        = string
}
