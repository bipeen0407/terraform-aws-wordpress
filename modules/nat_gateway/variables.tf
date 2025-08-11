# VPC ID where the NAT Gateway will be deployed
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# List of public subnet IDs where NAT Gateways will be created (one per AZ)
variable "public_subnet_ids" {
  description = "Public Subnet IDs for NAT Gateway placement"
  type        = list(string)
}

# List of private subnet IDs for routing
variable "private_subnet_ids" {
  description = "Private Subnet IDs to associate private route tables"
  type        = list(string)
}

# Environment or region label (e.g., irl-dev, sgp-dev)
variable "environment" {
  description = "Logical environment/region name"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the internet gateway attached to the VPC"
  type        = string
}

