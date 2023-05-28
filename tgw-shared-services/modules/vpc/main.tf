/*
  Build the VPCs in account1 and make the Transit Gateway attachments  
*/

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = var.name
  cidr                  = var.cidr
  secondary_cidr_blocks = local.secondary_cidr_blocks

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets = [cidrsubnet(var.cidr, 2, 0), cidrsubnet(var.cidr, 2, 1), cidrsubnet(var.cidr, 2, 2)]
  # Use the "spare" /26 to make 2 subnets that will host the tgw attachment
  intra_subnets = [cidrsubnet(cidrsubnet(var.cidr, 2, 3), 2, 0), cidrsubnet(cidrsubnet(var.cidr, 2, 3), 2, 1)]
  # Public is non-routable in our network, it will be re-used for every vpc
  # 100.64.0.0/26, spare: 100.64.0.48/28
  public_subnets = local.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
}


resource "aws_ec2_transit_gateway_vpc_attachment" "this" {

  subnet_ids         = module.vpc.intra_subnets
  transit_gateway_id = local.tgw_id
  vpc_id             = module.vpc.vpc_id

  tags = {
    Name = var.name
    Type = var.type
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  provider = aws.tgw

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this.id

  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  # It is important to tag the attachment also on TGW side otherwise the lambda function will fail
  tags = {
    Name = var.name
    Type = var.type
  }
}

// Add TGW Routes to VPCs route tables
resource "aws_route" "tgw_rt_pvt" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  transit_gateway_id     = local.tgw_id
  destination_cidr_block = local.network_cidr

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]
}

resource "aws_route" "tgw_rt_intra" {
  route_table_id         = module.vpc.intra_route_table_ids[0]
  transit_gateway_id     = local.tgw_id
  destination_cidr_block = local.network_cidr

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.this]
}
