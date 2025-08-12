provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "global"
  region = "us-east-1" # For global resources like Lambda@Edge, WAF
}

# -------------------------------------------------
# 1. VPC Setup
# -------------------------------------------------
module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
  environment     = var.environment

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 2. NAT Gateway & Route Tables
# -------------------------------------------------
module "nat_gateway" {
  source              = "../../modules/nat_gateway"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  internet_gateway_id = module.vpc.internet_gateway_id
  environment         = var.environment

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 3. Security Groups
# -------------------------------------------------
module "security_groups" {
  source               = "../../modules/security_groups"
  vpc_id               = module.vpc.vpc_id
  private_subnet_cidrs = var.private_subnets
  environment          = var.environment

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 4. Application Load Balancer (ALB)
# -------------------------------------------------
module "alb" {
  source              = "../../modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  alb_security_groups = [module.security_groups.alb_sg_id]
  alb_name            = "wordpress-alb"
  environment         = var.environment
  certificate_arn     = "" # TODO: Required for HTTPS

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 5. IAM Roles (including roles for EC2 and Lambda@Edge)
# -------------------------------------------------
module "iam" {
  source        = "../../modules/iam"
  environment   = var.environment
  db_secret_arn = module.aurora.db_secret_arn
  providers = {
    aws = aws.ireland
  }
  depends_on = [module.aurora]
}

# -------------------------------------------------
# 6. EC2 Auto Scaling Group (WordPress instances)
# -------------------------------------------------
module "ec2_asg" {
  source                = "../../modules/ec2_asg"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_profile_name = module.iam.wordpress_instance_profile_name
  db_secret_arn         = module.aurora.db_secret_arn
  efs_id                = module.efs.efs_id
  db_name               = module.aurora.db_name
  db_user               = module.aurora.db_master_username
  db_host               = module.aurora.aurora_writer_endpoint
  asg_min_size          = 2
  asg_max_size          = 5
  asg_desired_capacity  = 3
  ec2_security_group    = module.security_groups.ec2_sg_id
  environment           = var.environment
  target_group_arn      = module.alb.target_group_arn

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 7. EFS for persistent storage
# -------------------------------------------------
module "efs" {
  source              = "../../modules/efs"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  efs_security_groups = [module.security_groups.efs_sg_id]
  environment         = var.environment

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 8. ElastiCache Redis Cluster
# -------------------------------------------------
module "elasticache" {
  source                     = "../../modules/elasticache"
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  elasticache_security_group = module.security_groups.elasticache_sg_id
  node_type                  = "cache.m6g.large"
  environment                = var.environment

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 9. Aurora Database Cluster
# -------------------------------------------------
module "aurora" {
  source                = "../../modules/aurora"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  aurora_security_group = module.security_groups.aurora_sg_id
  db_engine             = "aurora-mysql"
  engine_version        = "8.0.mysql_aurora.3.04.0"
  instance_class        = var.instance_class #"db.r6g.large"
  db_name               = var.db_name
  db_master_username    = var.db_master_username
  cluster_identifier    = "${var.environment}-aurora"
  environment           = var.environment
  enable_global_cluster = true

  providers = {
    aws = aws.ireland
  }
}

# -------------------------------------------------
# 10. S3 Bucket for Static Content (with Cross-Region Replication to Singapore)
# -------------------------------------------------
module "s3" {
  source                      = "../../modules/s3"
  bucket_name                 = "${var.environment}-wordpress-static"
  environment                 = var.environment
  replication_bucket_arn      = var.sgp_bucket_arn
  replication_role_arn        = var.s3_replication_role_arn
  cloudfront_distribution_arn = "" # Update after CF deployed

  providers = {
    aws = aws.ireland
  }
}

module "waf" {
  source = "../../modules/waf"

  waf_name          = "wordpress-waf-${var.environment}"
  environment       = var.environment
  rate_limit        = 2000 #block or throttle requests from clients that exceed 2,000 requests within a predefined time window
  blocked_countries = []
  providers = {
    aws = aws.global
  }

}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.environment}-oac"
  description                       = "OAC for CloudFront to access S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}
module "cloudfront" {
  source = "../../modules/cloudfront"

  origins = [
    {
      domain_name              = module.s3.bucket_regional_domain_name
      origin_id                = "ireland-s3-origin"
      origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    },
    # Add ALB origins here as needed
  ]

  default_cache_behavior_origin_id = "ireland-s3-origin"

  web_acl_id  = module.waf.web_acl_id
  environment = var.environment
}

