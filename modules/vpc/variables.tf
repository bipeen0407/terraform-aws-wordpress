# CIDR block for the main VPC
variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

# List of CIDR blocks for public subnets
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
}

# List of CIDR blocks for private subnets
variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
}

# Availability Zones to deploy subnets into
variable "azs" {
  description = "List of AZs where subnets will be created"
  type        = list(string)
}

# Logical name for environment (e.g., IRL-dev, SGP-dev, prod)
variable "environment" {
  description = "Environment or region label"
  type        = string
}
