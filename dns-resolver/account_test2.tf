// Copy-paste from account_test1.tf

module "account2_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v5.21.0"

  providers = {
    aws = aws.account2
  }

  name                  = "main_vpc"
  cidr                  = "10.0.2.0/24"
  secondary_cidr_blocks = ["100.64.0.0/26"]

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  # 10.0.2.0/24, spare: 10.0.2.192/26
  private_subnets = ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]
  # Public is non-routable in our network
  # 100.64.0.0/26, spare: 100.64.0.48/28
  public_subnets = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
}
resource "aws_route53_resolver_rule_association" "main_account2" {
  provider = aws.account2


  resolver_rule_id = aws_route53_resolver_rule.mydomain.id
  vpc_id           = module.account2_vpc.vpc_id

  depends_on = [
    aws_ram_resource_association.main,
  ]

}

resource "aws_route53_resolver_rule_association" "extra_account2" {
  provider = aws.account2

  for_each = { for rule in var.extra_fwd_rules : rule.name => rule }

  resolver_rule_id = aws_route53_resolver_rule.extra[each.value.name].id
  vpc_id           = module.account2_vpc.vpc_id

  depends_on = [
    aws_ram_resource_association.extra,
  ]
}

resource "aws_route53_zone" "account2" {
  provider = aws.account2
  name     = "account2.${var.private_domain}"

  vpc {
    vpc_id = module.account2_vpc.vpc_id
  }

  // necessary when there are cross-account associations
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "test2" {
  provider = aws.account2

  zone_id = aws_route53_zone.account2.zone_id
  name    = "test"
  type    = "A"
  ttl     = 30
  records = ["2.2.2.2"] // Random value, just for test
}

resource "aws_route53_vpc_association_authorization" "account2_main" {
  provider = aws.account2

  vpc_id  = module.main_vpc.vpc_id
  zone_id = aws_route53_zone.account2.id
}

resource "aws_route53_zone_association" "account2_main" {
  vpc_id  = aws_route53_vpc_association_authorization.account2_main.vpc_id
  zone_id = aws_route53_vpc_association_authorization.account2_main.zone_id
}
