data "aws_organizations_organization" "mine" {}

data "aws_caller_identity" "current" {}

data "aws_ec2_transit_gateway" "tgw" {
  filter {
    name   = "options.amazon-side-asn"
    values = [var.tgw_asn]
  }
}
