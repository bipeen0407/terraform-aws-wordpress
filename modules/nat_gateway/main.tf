# Allocate an Elastic IP for each NAT Gateway (one per public subnet)
resource "aws_eip" "nat" {
  count = length(var.public_subnet_ids)

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }
}

# Create NAT Gateway in each public subnet using allocated EIPs
resource "aws_nat_gateway" "nat" {
  count = length(var.public_subnet_ids)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
  }
}

# Create one Public Route Table for the VPC
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Create route from public RT to internet gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Associate public route table with all public subnets
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Create one private route table per NAT Gateway (per AZ)
resource "aws_route_table" "private" {
  count  = length(var.public_subnet_ids)
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

# Create route from each private RT to corresponding NAT Gateway
resource "aws_route" "private_nat" {
  count                  = length(var.public_subnet_ids)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

# Associate each private route table with the private subnet of the same AZ
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}
