locals {
  network_cidr = "10.0.0.0/8"

  // "public" CIDR
  secondary_cidr_blocks = ["100.64.0.0/26"]
  public_subnets        = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]

  tgw_id = data.aws_ec2_transit_gateway.tgw.id
}
