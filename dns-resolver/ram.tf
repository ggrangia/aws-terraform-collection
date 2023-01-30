// Create the share
resource "aws_ram_resource_share" "rules" {
  name                      = "R53_resolver_rules"
  allow_external_principals = false // share with your org only
}

// Add all the rules to the share
resource "aws_ram_resource_association" "rules" {
    for_each = toset(local.all_rules)
    resource_arn = each.value
    resource_share_arn = aws_ram_resource_share.rules.arn
}

resource "aws_ram_principal_association" "rules_org" {
  principal = data.aws_organizations_organization.myorg.id
  resource_share_arn = aws_ram_resource_share.rules.arn
}