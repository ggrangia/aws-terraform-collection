data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_organizations_organization" "mine" {}
