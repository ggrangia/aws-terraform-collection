module "acc1" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.acc1_vpc

  providers = {
    aws = aws.account1
  }

  name = each.key
  cidr = each.value["cidr"]

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets = [cidrsubnet(each.value["cidr"], 2, 0), cidrsubnet(each.value["cidr"], 2, 1), cidrsubnet(each.value["cidr"], 2, 2)]
  # Public is non-routable in our network, it will be re-used for every vpc
  # 100.64.0.0/26, spare: 100.64.0.48/28
  public_subnets = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

/*
resource "aws_ec2_transit_gateway_vpc_attachment" "acc1" {
  provider = aws.account1

  depends_on = [
    aws_ram_principal_association.tgw_org,
    aws_ram_resource_association.tgw_org,
  ]

  subnet_ids         = module.account1_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.account1_vpc.vpc_id

  tags = {
    Name = "account1"
    Type = "Standard_NonProd"
  }
}
*/
