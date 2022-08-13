resource "aws_vpc" "this" {
  cidr_block           = var.main_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
  }
}


resource "aws_subnet" "pvt" {
  for_each = local.subnets_az

  availability_zone = each.key
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value

  tags = {
    Name = "sub-pvt-${each.key}"
  }
}

resource "aws_subnet" "tgw_eni" {
  for_each = local.tgw_subnets_az

  availability_zone = each.key
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value

  tags = {
    Name = "sub-pvt-tgw-${each.key}"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = (lookup(aws_subnet.pvt, each.value)).id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "tgw" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = (lookup(aws_subnet.tgw_eni, each.value)).id
  route_table_id = aws_route_table.private.id
}



resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_tgw" {
  subnet_ids                                      = [for s in aws_subnet.tgw_eni : s.id]
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.this.id
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "${var.name}-spoke"
  }
}

// Default routes go towards TGW attachment - This should be done AFTER the tgw attachment has been accepted
resource "aws_route" "default_route_pvt" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

