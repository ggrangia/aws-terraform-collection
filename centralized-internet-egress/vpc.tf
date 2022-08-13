module "spoke" {
  source = "./spoke_vpc"

  main_cidr = var.spoke_main_cidr
  name      = "spoke1"

  transit_gateway_id = module.tgw.transit_gateway.id
}

/*
module "egress" {
  source = "./egress_vpc"

  main_cidr   = var.egress_main_cidr
  public_cidr = var.egress_public_cidr

  vpc_backroute_cidr = [var.spoke_main_cidr]

  transit_gateway_id = module.tgw.transit_gateway.id
}
*/
// FIXME: VPC security groups
// FIXME: public in spoke??????
// Handle VPC names better2