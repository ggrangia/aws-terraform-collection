module "egress" {
  source = "./egress_vpc"

  main_cidr   = var.egress_main_cidr
  public_cidr = var.egress_public_cidr

  transit_gateway_id = module.tgw.transit_gateway_id
  tgw_ram_id = aws_ram_principal_association.tgw_org.id
}

// FIXME: VPC security groups

resource "aws_ec2_transit_gateway_vpc_attachment" "egress_tgw" {
  subnet_ids                                      = module.egress.tgw_subnets
  transit_gateway_id                              = module.tgw.transit_gateway_id
  vpc_id                                          = module.egress.vpc.id
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "Egress Attachment"
  }

  depends_on = [
    aws_ram_resource_association.tgw_org
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "egress" {
  provider = aws.tgw

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress_tgw.id

  tags = {
    Name = "terraform-egress"
    Side = "Accepter"
  }
}

resource "aws_route" "egress_backroute_pub" {

  for_each = toset(local.egress_routeback_cidr)

  route_table_id         = module.egress.public_rt.id
  destination_cidr_block = each.value
  transit_gateway_id     = module.tgw.transit_gateway_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.egress
  ]
}

resource "aws_route" "egress_backroute_pvt" {

  for_each = toset(local.egress_routeback_cidr)

  route_table_id         = module.egress.private_rt.id
  destination_cidr_block = each.value
  transit_gateway_id     = module.tgw.transit_gateway_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.egress
  ]
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  provider = aws.tgw

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.egress.id
  transit_gateway_route_table_id = module.tgw.egress_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_tgw_egress" {
  provider = aws.tgw

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.spoke.id
  transit_gateway_route_table_id = module.tgw.egress_route_table.id
}

