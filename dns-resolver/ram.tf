// Create the share
resource "aws_ram_resource_share" "rules" {
  name                      = "R53_resolver_rules"
  allow_external_principals = false // share with your org only
}

// Add all the rules to the share
resource "aws_ram_resource_association" "main" {
  resource_arn       = aws_route53_resolver_rule.mydomain.arn
  resource_share_arn = aws_ram_resource_share.rules.arn
}

resource "aws_ram_resource_association" "extra" {
  for_each           = toset(local.extra_rules_name)
  resource_arn       = aws_route53_resolver_rule.extra[each.value].arn
  resource_share_arn = aws_ram_resource_share.rules.arn
}

resource "aws_ram_principal_association" "rules_org" {
  principal          = data.aws_organizations_organization.myorg.arn
  resource_share_arn = aws_ram_resource_share.rules.arn
}