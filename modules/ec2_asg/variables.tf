# AMI ID to use for WordPress EC2 instances
variable "ami_id" {
  description = "AMI ID for WordPress server"
  type        = string
}

# Instance type for WordPress EC2 instances
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# List of private subnet IDs for the ASG
variable "private_subnet_ids" {
  description = "Private subnet IDs where instances will be deployed"
  type        = list(string)
}

# Auto Scaling Group min/max/desired sizes
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}
variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}
variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

# Security group for EC2 instances
variable "ec2_security_group" {
  description = "Security Group ID for EC2 instances"
  type        = string
}

# Environment/region name
variable "environment" {
  description = "Environment label"
  type        = string
}

# ALB Target Group ARN to attach ASG
variable "target_group_arn" {
  description = "ARN of ALB target group"
  type        = string
}

variable "efs_id" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_host" { type = string }
variable "db_secret_arn" { type = string }
variable "instance_profile_name" {
  description = "Name of the IAM instance profile to associate with the EC2 instances"
  type        = string
}
