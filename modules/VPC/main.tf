locals {
  tag_name = "${var.app_name}-${var.app_environment}"
}

#Create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support= true
  enable_dns_hostnames= true

  tags = {
    Name        = "${local.tag_name}-vpc"
    Environment = var.app_environment
  }
}

#Create private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets_cidr_blocks)
  cidr_block        = element(var.private_subnets_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${local.tag_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr_blocks)
  cidr_block              = element(var.public_subnets_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.tag_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

#Create IGW 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${local.tag_name}-igw"
    Environment = var.app_environment
  }
}

#Create two Elastic ips

resource "aws_eip" "eips" {
  count = length(var.availability_zones)
  domain   = "vpc"

  tags = {
  Name        = "${local.tag_name}-eip-${count.index + 1}"
  Environment = var.app_environment
  }
}

#Create two NAT gateways

resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.availability_zones)
  allocation_id = element(aws_eip.eips.*.id, count.index)
  subnet_id     =element(aws_subnet.public.*.id, count.index)
  connectivity_type = "public"

  tags = {
    Name        = "${local.tag_name}-nat-${count.index + 1}"
  Environment = var.app_environment
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


# Create public and private route table and associate them to related subnets
resource "aws_route_table" "public_route_table" {
   vpc_id = aws_vpc.vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

    tags = {
    Name        = "${local.tag_name}-public-route-table"
    Environment = var.app_environment
  }

}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr_blocks)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_tables" {
  count = length(var.private_subnets_cidr_blocks)
  vpc_id = aws_vpc.vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateways.*.id, count.index)
  }

    tags = {
    Name        = "${local.tag_name}-private-route-table-${count.index+1}"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr_blocks)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_tables.*.id, count.index)
}
