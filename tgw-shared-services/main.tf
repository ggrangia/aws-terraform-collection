resource "aws_ec2_transit_gateway" "this" {
  provider    = aws.tgw
  description = "My ORG TGW"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  amazon_side_asn = 64512 # specify different asn in case you want to use multiple TGW

  tags = {
    "Name" = "MY TGW"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  provider = aws.tgw

  for_each           = toset(var.transit_gateway_rt_names)
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
    "Name" = each.key
  }
}

resource "aws_ram_resource_share" "tgw_org" {
  provider = aws.tgw
  name     = "tgw_org"

  tags = {
    Name = "tgw_org"
  }
}

resource "aws_ram_resource_association" "tgw_org" {
  provider = aws.tgw

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw_org.id
}

resource "aws_ram_principal_association" "tgw_org" {
  provider = aws.tgw

  principal          = data.aws_organizations_organization.mine.arn
  resource_share_arn = aws_ram_resource_share.tgw_org.arn
}

# Setup Global Network + register transit gateway
resource "aws_networkmanager_global_network" "this" {
  provider = aws.tgw

  description = "My network manager"
}

resource "aws_networkmanager_transit_gateway_registration" "tgwthis" {
  provider = aws.tgw

  global_network_id   = aws_networkmanager_global_network.this.id
  transit_gateway_arn = aws_ec2_transit_gateway.this.arn
}
