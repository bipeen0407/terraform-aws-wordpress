##############################
# ALB Security Group
##############################
#TODO: Allow from internet for now, don't pass cloudfront_ipv4_cidrs
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Security Group for ALB allowing HTTP/HTTPS from allowed CIDRs"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP
  ingress {
    description = "Allow HTTP from allowed CIDRs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = length(var.cloudfront_ipv4_cidrs) > 0 ? var.cloudfront_ipv4_cidrs : ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS
  ingress {
    description = "Allow HTTPS from allowed CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = length(var.cloudfront_ipv4_cidrs) > 0 ? var.cloudfront_ipv4_cidrs : ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

##############################
# EC2 Security Group
##############################
resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Security Group for WordPress EC2 instances"
  vpc_id      = var.vpc_id

  # HTTP from ALB
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound to private subnets
  egress {
    description = "Allow outbound to private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ec2-sg"
    Environment = var.environment
  }
}

##############################
# Aurora SG
##############################
resource "aws_security_group" "aurora_sg" {
  name        = "${var.environment}-aurora-sg"
  description = "Security Group for Aurora allowing inbound from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL from EC2 SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-aurora-sg"
    Environment = var.environment
  }
}

##############################
# ElastiCache SG
##############################
resource "aws_security_group" "elasticache_sg" {
  name        = "${var.environment}-elasticache-sg"
  description = "Security Group for ElastiCache Redis from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Redis from EC2 SG"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-elasticache-sg"
    Environment = var.environment
  }
}

##############################
# EFS SG
##############################
resource "aws_security_group" "efs_sg" {
  name        = "${var.environment}-efs-sg"
  description = "Security Group for EFS from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow NFS from EC2 SG"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-efs-sg"
    Environment = var.environment
  }
}
