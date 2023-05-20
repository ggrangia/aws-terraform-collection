/*
  Build the VPCs in account1 and make the Transit Gateway attachments  
*/

module "acc1" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.acc1_vpc

  providers = {
    aws = aws.account1
  }

  name                  = each.key
  cidr                  = each.value["cidr"]
  secondary_cidr_blocks = ["100.64.0.0/26"]

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets = [cidrsubnet(each.value["cidr"], 2, 0), cidrsubnet(each.value["cidr"], 2, 1), cidrsubnet(each.value["cidr"], 2, 2)]
  # Use the "spare" /26 to make 2 subnets that will host the tgw attachment
  intra_subnets = [cidrsubnet(cidrsubnet(each.value["cidr"], 2, 3), 2, 0), cidrsubnet(cidrsubnet(each.value["cidr"], 2, 3), 2, 1)]
  # Public is non-routable in our network, it will be re-used for every vpc
  # 100.64.0.0/26, spare: 100.64.0.48/28
  public_subnets = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true

  depends_on = [
    aws_cloudwatch_event_target.vpc_attachment_created_sns,
  ]
}


resource "aws_ec2_transit_gateway_vpc_attachment" "acc1" {
  provider = aws.account1

  for_each = var.acc1_vpc

  depends_on = [
    aws_ram_principal_association.tgw_org,
    aws_ram_resource_association.tgw_org,
    aws_networkmanager_transit_gateway_registration.tgwthis,
    aws_cloudwatch_event_target.vpc_attachment_created_log_group
  ]

  subnet_ids         = module.acc1[each.key].intra_subnets
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.acc1[each.key].vpc_id

  tags = {
    Name = each.key
    Type = each.value["type"]
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "acc1" {
  provider = aws.tgw

  for_each = var.acc1_vpc

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.acc1[each.key].id

  # It is important to tag the attachment also on TGW side otherwise the lambda function will fail
  tags = {
    Name = each.key
    Type = each.value["type"]
  }
}
