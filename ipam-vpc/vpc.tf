resource "aws_vpc" "test" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.child_pvt.id
  ipv4_netmask_length = 26
  depends_on = [
    aws_vpc_ipam_pool_cidr.child_pvt
  ]
}


resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count = var.secondary_private_cidr

  vpc_id              = aws_vpc.test.id
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.child_pvt.id
  ipv4_netmask_length = 26

  depends_on = [
    aws_vpc_ipam_pool_cidr.child_pvt,
  ]
}

resource "aws_vpc_ipv4_cidr_block_association" "public_cidr" {
  vpc_id              = aws_vpc.test.id
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.child_pub.id
  ipv4_netmask_length = 26

  depends_on = [
    aws_vpc_ipam_pool_cidr.child_pub,
  ]
}

resource "aws_subnet" "pvt" {
  for_each = toset(data.aws_availability_zones.available.names)

  availability_zone = each.value
  vpc_id            = aws_vpc.test.id
  cidr_block        = lookup(local.subnets_az, each.value, "")

  tags = {
    Name = "sub-pvt-${each.value}"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr,
  ]
}

resource "aws_subnet" "pub" {
  for_each = toset(data.aws_availability_zones.available.names)

  availability_zone = each.value
  vpc_id            = aws_vpc.test.id
  cidr_block        = cidrsubnet(aws_vpc_ipv4_cidr_block_association.public_cidr.cidr_block, 2, index(data.aws_availability_zones.available.names, each.value))

  map_public_ip_on_launch = true

  tags = {
    Name = "sub-pub-${each.value}"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr,
  ]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub[keys(aws_subnet.pub)[0]].id # deployed in the "first" subnet

  tags = {
    Name = "NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}


resource "aws_route_table_association" "public" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = (lookup(aws_subnet.pub, each.value, "")).id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = (lookup(aws_subnet.pvt, each.value, "")).id
  route_table_id = aws_route_table.private.id
}
