resource "aws_ec2_transit_gateway" "this" {
  description = "My ORG TGW"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  amazon_side_asn = var.private_asn # specify different asn in case you want to use multiple TGW

  tags = {
    "Name" = "MY TGW"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {

  for_each           = toset(var.transit_gateway_rt_names)
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
    "Name" = each.key
  }
}

resource "aws_ram_resource_share" "tgw_org" {
  name = "tgw_org"

  tags = {
    Name = "tgw_org"
  }
}

resource "aws_ram_resource_association" "tgw_org" {

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw_org.id
}

resource "aws_ram_principal_association" "tgw_org" {

  principal          = data.aws_organizations_organization.mine.arn
  resource_share_arn = aws_ram_resource_share.tgw_org.arn
}

# Setup Global Network + register transit gateway
resource "aws_networkmanager_global_network" "this" {

  description = "My network manager"
}

resource "aws_networkmanager_transit_gateway_registration" "tgwthis" {

  global_network_id   = aws_networkmanager_global_network.this.id
  transit_gateway_arn = aws_ec2_transit_gateway.this.arn
}
