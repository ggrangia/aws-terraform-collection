module "spoke" {
  source = "./spoke_vpc"

  main_cidr = var.spoke_main_cidr
  name      = "spoke1"

  transit_gateway_id = module.tgw.transit_gateway_id
  tgw_ram_id = aws_ram_resource_association.tgw_org.id // Needed for depencies ordering
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "spoke" {
  provider = aws.tgw

  transit_gateway_attachment_id = module.spoke.tgw_vpc_attachment_id

  tags = {
    Name = "terraform-spoke"
    Side = "Accepter"
  }
}

resource "aws_route" "default_route_pvt" {
  route_table_id         = module.spoke.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.transit_gateway_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.spoke
  ]
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  provider = aws.tgw

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.spoke.id
  transit_gateway_route_table_id = module.tgw.spoke_route_table.id
}


resource "aws_ec2_transit_gateway_route" "spoke_default" {
  provider = aws.tgw

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.egress.id
  transit_gateway_route_table_id = module.tgw.spoke_route_table.id
}
