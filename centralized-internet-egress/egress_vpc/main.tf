resource "aws_vpc" "this" {
  cidr_block           = var.main_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "egress"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "public_cidr" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_cidr
}

resource "aws_subnet" "tgw_eni" {
  for_each = local.subnets_az

  availability_zone = each.key
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value

  tags = {
    Name = "egress-sub-pvt-tgw-${each.key}"
  }
}

resource "aws_subnet" "pub" {
  for_each = toset(local.azs)

  availability_zone = each.value
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc_ipv4_cidr_block_association.public_cidr.cidr_block, 2, index(local.azs, each.value))

  map_public_ip_on_launch = true

  tags = {
    Name = "egress-sub-pub-${each.value}"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.public_cidr,
  ]
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

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
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "egress-pub-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "egress-pvt-rt"
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
  for_each       = toset(local.azs)
  subnet_id      = (lookup(aws_subnet.pub, each.value, "")).id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "tgw" {
  for_each       = toset(local.azs)
  subnet_id      = (lookup(aws_subnet.tgw_eni, each.value, "")).id
  route_table_id = aws_route_table.private.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress_tgw" {
  subnet_ids                                      = [for s in aws_subnet.tgw_eni : s.id]
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.this.id
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "Egress Attachment"
  }

  // Explicit dependency on RAM Resource association
  depends_on = [
    var.tgw_ram_id
  ]
}
