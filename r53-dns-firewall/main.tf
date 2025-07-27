locals {
  # took from the managed list in the dns firewall domain lists section
  aws_managed_domain_list_ids = [
    "rslvr-fdl-15f4860b1ad54ead",
    "rslvr-fdl-984dae9d8bac4e2b",
    "rslvr-fdl-aa970e9eb1ca4777",
    "rslvr-fdl-2c46f2ecbfec4dcc"
  ]

  aws_managed_domain_list_ids_indexed = { for count, id in local.aws_managed_domain_list_ids : id => count }

}

data "aws_route53_resolver_firewall_domain_list" "aws_managed" {
  for_each = local.aws_managed_domain_list_ids_indexed

  firewall_domain_list_id = each.key
}

resource "aws_route53_resolver_firewall_rule_group" "aws_managed" {
  name = "AWSManaged"
}


resource "aws_route53_resolver_firewall_rule_group" "custom" {
  name = "Custom"
}

resource "aws_route53_resolver_firewall_domain_list" "custom" {
  name = "custom"
  domains = [
    "google.com.",
    "*.google.com.",
    "*.amazon.com.",
    "amazon.com."
  ]
}

resource "aws_route53_resolver_firewall_rule" "aws_managed" {
  for_each = local.aws_managed_domain_list_ids_indexed

  name                    = "${aws_route53_resolver_firewall_rule_group.aws_managed.name}-${data.aws_route53_resolver_firewall_domain_list.aws_managed[each.key].name}"
  action                  = "BLOCK"
  block_override_dns_type = "CNAME"
  block_override_domain   = "example.com."
  block_override_ttl      = 10
  block_response          = "OVERRIDE"
  firewall_domain_list_id = each.key
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.aws_managed.id
  priority                = 100 + each.value
}

resource "aws_route53_resolver_firewall_rule" "custom" {

  name                    = "Custom"
  action                  = "BLOCK"
  block_override_dns_type = "CNAME"
  block_override_domain   = "example.com."
  block_override_ttl      = 10
  block_response          = "OVERRIDE"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.custom.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.custom.id
  priority                = 100
}

resource "aws_route53_resolver_firewall_rule_group_association" "aws_managed" {
  name                   = "aws_managed"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.aws_managed.id
  priority               = 101
  vpc_id                 = module.vpc.vpc_id
}

resource "aws_route53_resolver_firewall_rule_group_association" "custom" {
  name                   = "custom"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.custom.id
  priority               = 110
  vpc_id                 = module.vpc.vpc_id
}
