locals {
  create = var.create

  subnets = local.create ? merge([
    for group_name, group in var.subnet_groups : {
      for idx, cidr in group.cidrs :
      "${group_name}-${idx % length(var.azs)}" => {
        group       = group_name
        cidr        = cidr
        az          = var.azs[idx % length(var.azs)]
        public      = group.public
        nat_gateway = group.nat_gateway
        count       = idx
      }
    }
  ]...) : {}

  public_subnets = {
    for k, v in local.subnets : k => v if v.public
  }

  private_subnets = {
    for k, v in local.subnets : k => v if !v.public
  }

  nat_routed_private_subnets = {
    for k, v in local.private_subnets : k => v if v.nat_gateway
  }
}

resource "aws_vpc" "this" {
  count = local.create ? 1 : 0

  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = local.create ? toset(var.secondary_cidr_blocks) : toset([])

  vpc_id     = aws_vpc.this[0].id
  cidr_block = each.value
}

resource "aws_internet_gateway" "this" {
  count = local.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = var.tags
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az


  tags = merge(var.tags, {
    Name = "${var.name}-${each.value.group}-${each.value.az}"
  })

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.this
  ]
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name}-${each.value.group}-${each.value.az}"
  })

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.this
  ]
}

resource "aws_eip" "nat" {
  for_each = local.public_subnets

  domain = "vpc"

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = local.public_subnets

  allocation_id = aws_eip.nat[each.key].id

  subnet_id = aws_subnet.public[each.key].id

  tags = var.tags
}

resource "aws_route_table" "public" {
  count = local.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id
}

resource "aws_route" "public" {
  count = local.create ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

}

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this[0].id
}

resource "aws_route" "nat_gateway" {
  for_each = local.nat_routed_private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  # aws_nat_gateway.this["public-1"]
  nat_gateway_id = aws_nat_gateway.this["public-${each.value.count % length(var.azs)}"].id
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id = aws_subnet.private[each.key].id

  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id = aws_subnet.public[each.key].id

  route_table_id = aws_route_table.public[0].id
}
