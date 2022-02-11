# Create a VPC
resource "aws_vpc" "admin_account_vpc" {
  cidr_block = var.admin_vpc_cidr
  tags = {
    "Name" = "${var.default_tags.project}-vpc"
  }
  assign_generated_ipv6_cidr_block = true
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
}

# Public subnet
resource "aws_subnet" "admin_subnet_public" {
  count  = var.vpc_public_subnet_count
  vpc_id = aws_vpc.admin_account_vpc.id
  # cidrsubnet builtin function used to carve smaller blocks(https://www.terraform.io/language/functions/cidrsubnet)
  # 10.255.0.0/20 -> 10.255.0.0/24
  cidr_block                      = cidrsubnet(aws_vpc.admin_account_vpc.cidr_block, 4, count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.admin_account_vpc.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
  tags = {
    "Name" = "${var.default_tags.project}-public-${data.aws_availability_zones.available.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "admin_rt_public" {
  vpc_id = aws_vpc.admin_account_vpc.id
  tags = {
    "Name" = "${var.default_tags.project}-public-rt"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.admin_account_vpc.id

  tags = {
    "Name" = "${var.default_tags.project}-gw"
  }
}

resource "aws_route" "admin_public_route_access" {
  route_table_id         = aws_route_table.admin_rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "admin_rt_associate_public" {
  count          = var.vpc_public_subnet_count
  subnet_id      = element(aws_subnet.admin_subnet_public.*.id, count.index)
  route_table_id = aws_route_table.admin_rt_public.id
}

# Private subnet
resource "aws_subnet" "admin_subnet_private" {
  count  = var.vpc_private_subnet_count
  vpc_id = aws_vpc.admin_account_vpc.id
  # cidrsubnet builtin function used to carve smaller blocks(https://www.terraform.io/language/functions/cidrsubnet)
  # 10.255.0.0/20 -> 10.255.0.0/24
  cidr_block = cidrsubnet(aws_vpc.admin_account_vpc.cidr_block, 4, count.index + var.vpc_public_subnet_count)
  tags = {
    "Name" = "${var.default_tags.project}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "admin_rt_private" {
  vpc_id = aws_vpc.admin_account_vpc.id
  tags = {
    "Name" = "${var.default_tags.project}-private-rt"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    "Name" = "${var.default_tags.project}-nat"
  }
}

resource "aws_nat_gateway" "nat_eip" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.admin_subnet_public.0.id
  tags = {
    "Name" = "${var.default_tags.project}-nat-gw"
  }
  depends_on = [
    aws_eip.nat_eip,
    aws_internet_gateway.gw
  ]
}

resource "aws_route" "admin_private_route_access" {
  route_table_id         = aws_route_table.admin_rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id      = aws_nat_gateway.nat_eip.id
}

resource "aws_route_table_association" "admin_rt_associate_private" {
  count          = var.vpc_private_subnet_count
  subnet_id      = element(aws_subnet.admin_subnet_private.*.id, count.index)
  route_table_id = aws_route_table.admin_rt_private.id
}

# Public route table and routes
# private route table and routes
# public and private subnets
# internet gateway
# NAT gateway

