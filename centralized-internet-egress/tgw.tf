module "tgw" {
  source = "./tgw"

  providers = {
    aws = aws.tgw
  }
}


resource "aws_ram_resource_share" "tgw_org" {
  provider = aws.tgw
  name = "tgw_org"

  tags = {
    Name = "tgw_org"
  }
}

resource "aws_ram_resource_association" "tgw_org" {
  provider = aws.tgw

  resource_arn       = module.tgw.transit_gateway_arn
  resource_share_arn = aws_ram_resource_share.tgw_org.id
}

resource "aws_ram_principal_association" "tgw_org" {
  provider = aws.tgw
  
  principal          = data.aws_organizations_organization.mine.arn
  resource_share_arn = aws_ram_resource_share.tgw_org.arn
}