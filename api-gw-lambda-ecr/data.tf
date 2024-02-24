# get authorization credentials to push to ecr
data "aws_ecr_authorization_token" "token" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
