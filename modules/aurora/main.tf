# Aurora Subnet Group (spans private subnets in multiple AZs)
resource "aws_db_subnet_group" "aurora" {
  name        = "${var.environment}-aurora-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Aurora Subnet Group"
}

# Aurora Global Cluster (primary region only)
resource "aws_rds_global_cluster" "this" {
  count                     = var.enable_global_cluster && var.global_cluster_id == "" ? 1 : 0
  global_cluster_identifier = "${var.environment}-aurora-global"
  engine                    = var.db_engine
  engine_version            = var.engine_version
}

# Aurora Cluster
resource "aws_rds_cluster" "this" {
  cluster_identifier          = var.cluster_identifier
  engine                      = var.db_engine
  engine_version              = var.engine_version
  database_name               = var.db_name
  manage_master_user_password = true
  master_username             = var.db_master_username
  db_subnet_group_name        = aws_db_subnet_group.aurora.name
  vpc_security_group_ids      = [var.aurora_security_group]
  storage_encrypted           = true
  skip_final_snapshot         = true
  # If global cluster enabled in primary, attach it
  global_cluster_identifier = var.enable_global_cluster && var.global_cluster_id == "" ? aws_rds_global_cluster.this[0].id : var.global_cluster_id

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-aurora-cluster"
  }
}

# Aurora Cluster Instances (one writer, rest readers in other AZs)
resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${var.environment}-aurora-writer"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = var.db_engine
  publicly_accessible = false
  # Place writer in first subnet/AZ
  db_subnet_group_name = aws_db_subnet_group.aurora.name
}

resource "aws_rds_cluster_instance" "reader" {
  count                = length(var.private_subnet_ids) - 1
  identifier           = "${var.environment}-aurora-reader-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = var.instance_class
  engine               = var.db_engine
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aurora.name
}

data "aws_secretsmanager_secret" "db_master_password_secret" {
  name = "rds/${aws_rds_cluster.this.cluster_identifier}/${aws_rds_cluster.this.master_username}"
}
