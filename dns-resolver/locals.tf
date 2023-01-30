locals {
  escaped_domain_name = replace(var.private_domain, ".", "_")
  extra_rules_arn     = [for r in aws_route53_resolver_rule.extra : r.arn]
  all_rules           = concat([aws_route53_resolver_rule.mydomain.arn], local.extra_rules_arn)
}