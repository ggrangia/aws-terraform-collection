module "tgw" {
  source = "./tgw"

  providers = {
    aws = aws.tgw,
    aws.netmanagerevent = aws.netmanagerevent
   }
}

/*
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "egress" {
  provider = aws.tgw

  transit_gateway_attachment_id = module.egress.tgw_attachment.id

  tags = {
    Name = "terraform-egress"
    Side = "Accepter"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "spoke" {
  provider = aws.tgw

  transit_gateway_attachment_id = module.spoke.tgw_attachment.id

  tags = {
    Name = "terraform-spoke"
    Side = "Accepter"
  }
}

// FIXME: Implement a way to do the associatons via lambda or take out the route towards the tgw from vpc module

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  provider = aws.tgw

  transit_gateway_attachment_id  = module.egress.tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.egress_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  provider = aws.tgw
  
  transit_gateway_attachment_id  = module.spoke.tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.spoke_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_tgw_egress" {
  provider = aws.tgw
  
  transit_gateway_attachment_id  = module.spoke.tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.egress_route_table.id
}

resource "aws_ec2_transit_gateway_route" "spoke_default" {
  provider = aws.tgw
  
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.egress.tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.spoke_route_table.id
}
*/