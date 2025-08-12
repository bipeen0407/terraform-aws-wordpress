# Create EFS file system
resource "aws_efs_file_system" "this" {
  creation_token   = "${var.environment}-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name        = "${var.environment}-efs"
    Environment = var.environment
  }
}

# EFS mount targets, one per private subnet/AZ
resource "aws_efs_mount_target" "mt" {
  count          = length(var.private_subnet_ids)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = var.private_subnet_ids[count.index]
  security_groups = var.efs_security_groups

  # Each mount target is deployed in a separate AZ (via subnet)
}
