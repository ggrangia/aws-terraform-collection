/*
  Build the VPCs in account1 and make the Transit Gateway attachments
*/

module "vpc" {
  source = "../modules/vpc"

  for_each = var.vpcs

  tgw_asn = var.tgw_asn
  name    = each.key
  cidr    = each.value["cidr"]
  type    = each.value["type"]

  providers = {
    aws     = aws
    aws.tgw = aws.tgw
  }
}
